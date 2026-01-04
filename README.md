# adv_audio_scrub

Small app that wraps a re-record (virtual loopback) + optional neural-codec scrub pipeline.
Includes a simple Tkinter GUI (gui.py) and an importable core (adv_audio_scrub/scrub_audio.py).

Quick start (development):
1. Create and activate a Python venv:
   python -m venv .venv
   source .venv/bin/activate   # macOS/Linux
   .venv\Scripts\activate      # Windows

2. Install deps:
   pip install -r requirements.txt
   # If you plan to use neural scrub (demucs/encodec), install the appropriate package separately.
   # Ensure ffmpeg is installed and available on PATH.

3. Run GUI:
   python gui.py

Notes:
- Configure your OS to route playback to a virtual cable (VB-Audio, BlackHole, etc.) and set the corresponding input to the virtual cable's input.
- Use the Virtual Output / Virtual Input text boxes to match your device names (substring match).
- If neural scrub is used, make sure the CLI/module name in adv_audio_scrub/scrub_audio.NEURAL_SCRUB_CMD_TEMPLATE matches your installation.

Packaging (one-file executables)
- Windows (example):
  1. Put ffmpeg.exe in the repo root or ensure ffmpeg is on PATH.
  2. Run: build_windows.bat
  This uses PyInstaller to create a one-file windowed executable for gui.py.

- macOS (example):
  1. Ensure ffmpeg and BlackHole or other virtual driver installed.
  2. Run: sh build_macos.sh
  This uses PyInstaller to produce a single-file app (may require additional macOS-specific adjustments).

Troubleshooting:
- Device listing: run `python -c "import sounddevice as sd; print(sd.query_devices())"`
- If you get buffer underruns, try increasing BLOCKSIZE in adv_audio_scrub/scrub_audio.py or reduce system load.
- Ensure ffmpeg is on PATH.

License: MIT (see LICENSE file)
