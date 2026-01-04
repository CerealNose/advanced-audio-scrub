# How to Fix: "No output device matching..."

The error you're seeing means the script is looking for a device named **"CABLE Output (VB-Audio Virtual Cable)"** but can't find it on your system. This usually happens if:
1. The Virtual Cable is not installed.
2. The device name on your system is slightly different.

## Step 1: Find your actual device names

Run the diagnostic script I've provided:
```cmd
python list_audio_devices.py
```

Look for your virtual cable in the output. It might look like this:
- `CABLE Input (VB-Audio Virtual Cable)`
- `CABLE Output (VB-Audio Virtual Cable)`
- OR simply `CABLE Input` / `CABLE Output`

## Step 2: Update the script

Open `adv_audio_scrub/scrub_audio.py` in a text editor (like Notepad) and find these lines (around line 30):

```python
# CHANGE THESE NAMES TO MATCH YOUR SYSTEM
VIRTUAL_OUTPUT_NAME = "CABLE Output (VB-Audio Virtual Cable)"
VIRTUAL_INPUT_NAME = "CABLE Input (VB-Audio Virtual Cable)"
```

**Replace the text inside the quotes** with the exact names you found in Step 1.

### Example for macOS (BlackHole):
```python
VIRTUAL_OUTPUT_NAME = "BlackHole 2ch"
VIRTUAL_INPUT_NAME = "BlackHole 2ch"
```

### Example for Linux (VirtualCable):
```python
VIRTUAL_OUTPUT_NAME = "VirtualCable"
VIRTUAL_INPUT_NAME = "VirtualCable.monitor"
```

## Step 3: Save and Run

1. Save the file.
2. Run the GUI again: `python gui.py`
3. Try processing your file again.

---

## Still having issues?

### 1. Is the Virtual Cable installed?
If you don't see any "CABLE" devices in the list, you need to install the driver:
- **Windows**: [VB-Audio Virtual Cable](https://vb-audio.com/Cable/)
- **macOS**: `brew install blackhole-2ch`

### 2. Check Channel Counts
The script requires at least **2 channels** (stereo). Ensure your virtual cable is configured for stereo in your system's sound settings.

### 3. Restart your computer
Sometimes audio drivers need a restart to be recognized by Python's `sounddevice` library.
