#!/usr/bin/env python3
"""
adv_audio_scrub.scrub_audio

Importable core functions for the re-record (loopback) + neural-codec scrub workflow.

Public functions:
 - rerecord(input_file, output_wav, **kwargs)
 - neural_scrub(input_wav, output_wav, bitrate=..., cmd_template=...)
 - detect_devices(output_name_substr, input_name_substr)
 - available_devices() -> list of devices (helper)
"""
from __future__ import annotations
import subprocess
import queue
import threading
import time
import os
import sys
import numpy as np
import soundfile as sf
import sounddevice as sd
from typing import Optional, Tuple, Callable, Iterable

# Default configuration (can be overridden by callers)
TARGET_SR = 44100
TARGET_BITS = 24
CHANNELS = 2
BLOCKSIZE = 1024
VIRTUAL_OUTPUT_NAME = "CABLE Output (VB-Audio Virtual Cable)"
VIRTUAL_INPUT_NAME = "CABLE Input (VB-Audio Virtual Cable)"
CODEC_BITRATE = "12k"  # set None to skip neural scrub

# Template for neural scrub command. Formatting placeholders: {bitrate}, {input}, {output}
NEURAL_SCRUB_CMD_TEMPLATE = [
    sys.executable, "-m", "demucs.encodec", "--bitrate", "{bitrate}", "{input}", "-o", "{output}"
]

# Type for simple log callback
LogCallback = Optional[Callable[[str], None]]

def available_devices() -> list:
    """Return sounddevice.query_devices() list for inspection."""
    return sd.query_devices()

def find_device_index(name_substring: str, kind: str, channels: int = CHANNELS) -> int:
    """Find first device index whose name contains name_substring and supports required channels."""
    name_substring = (name_substring or "").lower()
    devices = sd.query_devices()
    candidates = []
    for i, dev in enumerate(devices):
        dev_name = dev.get("name", "").lower()
        if name_substring in dev_name:
            if kind == "output" and dev.get("max_output_channels", 0) >= channels:
                candidates.append(i)
            if kind == "input" and dev.get("max_input_channels", 0) >= channels:
                candidates.append(i)
    if not candidates:
        raise RuntimeError(f"No {kind} device matching '{name_substring}' with >= {channels} channels found.")
    return candidates[0]

def ffmpeg_decode_generator(infile: str, samplerate: int, channels: int, block_frames: int) -> Iterable[np.ndarray]:
    """
    Run ffmpeg to decode infile to f32le PCM on stdout and yield (n_frames, channels) numpy float32 arrays.
    """
    cmd = [
        "ffmpeg", "-v", "error", "-i", infile,
        "-f", "f32le", "-acodec", "pcm_f32le",
        "-ac", str(channels), "-ar", str(samplerate), "-"
    ]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    bytes_per_frame = 4 * channels  # float32 = 4 bytes
    try:
        while True:
            raw = proc.stdout.read(block_frames * bytes_per_frame)
            if not raw:
                break
            arr = np.frombuffer(raw, dtype=np.float32)
            if arr.size == 0:
                break
            if arr.size % channels != 0:
                # drop incomplete frame at end if any
                arr = arr[:(arr.size // channels) * channels]
            arr = arr.reshape(-1, channels)
            yield arr
    finally:
        try:
            proc.stdout.close()
        except Exception:
            pass
        proc.wait()

def rerecord(
    input_file: str,
    output_wav: str,
    vout_name: str = VIRTUAL_OUTPUT_NAME,
    vin_name: str = VIRTUAL_INPUT_NAME,
    samplerate: int = TARGET_SR,
    channels: int = CHANNELS,
    blocksize: int = BLOCKSIZE,
    log: LogCallback = None
) -> None:
    """
    Re-record input_file by playing decoded audio to the virtual output device and recording from virtual input device.
    Writes the result to output_wav (WAV PCM_{TARGET_BITS}).
    Raises on error.
    """
    if log:
        log(f"[rerecord] {input_file} -> {output_wav}")
    out_dev = find_device_index(vout_name, "output", channels)
    in_dev = find_device_index(vin_name, "input", channels)
    if log:
        log(f"  using output device index {out_dev}, input device index {in_dev}")

    decode_gen = ffmpeg_decode_generator(input_file, samplerate, channels, blocksize)
    q: queue.Queue = queue.Queue(maxsize=64)

    def callback(indata, outdata, frames, time_info, status):
        if status and log:
            log(f"[stream status] {status}")
        # get next decoded chunk
        try:
            chunk = next(callback._gen)
        except StopIteration:
            # no more data
            outdata.fill(0)
            # still put any input (may be silence) to queue
            try:
                q.put_nowait(indata.copy())
            except queue.Full:
                pass
            callback._done = True
            return
        # chunk may be shorter or longer than frames
        if chunk.shape[0] < frames:
            out = np.zeros((frames, channels), dtype=np.float32)
            out[:chunk.shape[0], :] = chunk
            outdata[:] = out
            callback._done = True  # signal we'll stop after writing remaining recorded frames
        else:
            outdata[:] = chunk[:frames, :]
        # push the recorded input into queue for writer
        try:
            q.put_nowait(indata.copy())
        except queue.Full:
            # drop if writer is too slow
            pass

    # attach attributes
    callback._gen = decode_gen
    callback._done = False

    # Open soundfile for writing
    subtype = f"PCM_{TARGET_BITS}"
    with sf.SoundFile(output_wav, mode="w", samplerate=samplerate, channels=channels, subtype=subtype) as f:
        # open stream
        with sd.Stream(samplerate=samplerate, blocksize=blocksize, dtype='float32',
                       channels=channels, callback=callback, device=(out_dev, in_dev)):
            if log:
                log("  stream started...")
            # Continue until callback._done is set and queue is drained
            while True:
                try:
                    frames = q.get(timeout=0.5)
                except queue.Empty:
                    if callback._done:
                        break
                    continue
                f.write(frames)
            # drain any remaining inputs for a short time
            drain_deadline = time.time() + 0.5
            while time.time() < drain_deadline:
                try:
                    frames = q.get_nowait()
                    f.write(frames)
                except queue.Empty:
                    break
    if log:
        log("  recording finished")

def neural_scrub(in_wav, out_wav, bitrate=CODEC_BITRATE, cmd_template=None, log: LogCallback = None):
    """
    Run the configured neural-codec scrub command. Raises on non-zero exit.
    """
    if bitrate is None:
        raise ValueError("bitrate is None; neural scrub is disabled")
    if cmd_template is None:
        cmd_template = NEURAL_SCRUB_CMD_TEMPLATE
    cmd = [part.format(bitrate=bitrate, input=in_wav, output=out_wav) for part in cmd_template]
    if log:
        log("  running neural scrub: " + " ".join(cmd))
    subprocess.run(cmd, check=True)
    if log:
        log("  neural scrub finished")

def process_files(
    inputs: Iterable[str],
    output_suffix: str = "_clean.wav",
    rerecord_suffix: str = "_rerecord.wav",
    bitrate: Optional[str] = CODEC_BITRATE,
    vout_name: str = VIRTUAL_OUTPUT_NAME,
    vin_name: str = VIRTUAL_INPUT_NAME,
    log: LogCallback = None,
    progress_callback: Optional[Callable[[int, int], None]] = None
) -> None:
    """
    Process a list of input files sequentially. Reports progress via progress_callback(current_index, total)
    and logs via log(str).
    """
    files = list(inputs)
    total = len(files)
    for idx, mp3 in enumerate(files, start=1):
        base, _ = os.path.splitext(mp3)
        temp = f"{base}{rerecord_suffix}"
        final = f"{base}{output_suffix}"
        if log:
            log(f"Processing {mp3} ({idx}/{total})")
        rerecord(mp3, temp, vout_name=vout_name, vin_name=vin_name, log=log)
        if bitrate:
            neural_scrub(temp, final, bitrate=bitrate, log=log)
            try:
                os.remove(temp)
            except Exception:
                pass
        else:
            os.replace(temp, final)
        if progress_callback:
            progress_callback(idx, total)
        if log:
            log(f"  → {final}")

if __name__ == "__main__":
    import glob
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="*", help="MP3 or audio files; if empty use *.mp3")
    ap.add_argument("--no-neural", dest="bitrate", action="store_const", const=None, default=CODEC_BITRATE)
    args = ap.parse_args()
    files = args.files or glob.glob("*.mp3")
    def _log(s): print(s)
    process_files(files, bitrate=args.bitrate, log=_log)
