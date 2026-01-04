# Advanced Audio Scrub

A professional audio processing tool that uses loopback recording and neural codec compression to "scrub" audio files, removing artifacts and improving quality.

## Features

- **Loopback Recording**: Re-records audio through virtual audio cables to remove digital artifacts
- **Neural Codec Processing**: Uses Meta's Demucs neural codec for advanced audio compression/decompression
- **Batch Processing**: Process multiple files at once
- **GUI Interface**: Easy-to-use Tkinter-based graphical interface
- **Cross-Platform**: Supports Windows, macOS, and Linux

## Quick Start

### Automatic Installation (Recommended)

#### Windows
1. Double-click `install.bat` or run in Command Prompt:
   ```cmd
   install.bat
   ```

#### Linux / macOS
1. Open terminal in the project directory
2. Run the installer:
   ```bash
   bash install.sh
   ```

The installer will:
- Check for Python 3.8+
- Install system dependencies (ffmpeg, portaudio, etc.)
- Create a virtual environment (optional)
- Install all Python packages including demucs
- Verify the installation

### Manual Installation

If you prefer to install manually:

#### 1. System Dependencies

**Windows:**
- Install Python 3.8+ from [python.org](https://www.python.org/downloads/)
- Download ffmpeg from [gyan.dev/ffmpeg](https://www.gyan.dev/ffmpeg/builds/)
- Extract ffmpeg and add to PATH, or place `ffmpeg.exe` in the project directory

**macOS:**
```bash
brew install python3 ffmpeg portaudio libsndfile
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install python3 python3-pip python3-venv ffmpeg \
    portaudio19-dev libportaudio2 libsndfile1 python3-tk
```

#### 2. Python Dependencies

```bash
# Create virtual environment (optional but recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate.bat

# Install dependencies
pip install numpy sounddevice soundfile demucs pyinstaller
```

## Usage

### GUI Application

```bash
python gui.py
```

Features:
- Add files via file picker
- Remove selected files
- Start batch processing
- Real-time progress bar
- Log window for detailed output

### Command Line

Process a single file:
```bash
python -m adv_audio_scrub.scrub_audio your_audio.mp3
```

Process multiple files:
```bash
python -m adv_audio_scrub.scrub_audio file1.mp3 file2.mp3 file3.mp3
```

Process all MP3 files in current directory:
```bash
python -m adv_audio_scrub.scrub_audio *.mp3
```

Skip neural scrubbing (faster, but less effective):
```bash
python -m adv_audio_scrub.scrub_audio --no-neural your_audio.mp3
```

### Python API

```python
from adv_audio_scrub import rerecord, neural_scrub, process_files

# Process a single file
rerecord("input.mp3", "output_rerecord.wav")
neural_scrub("output_rerecord.wav", "output_clean.wav", bitrate="12k")

# Batch process with custom settings
files = ["song1.mp3", "song2.mp3", "song3.mp3"]
process_files(
    files,
    output_suffix="_clean.wav",
    bitrate="12k",
    log=print
)
```

## Virtual Audio Cable Setup

This tool requires a virtual audio cable to perform loopback recording:

### Windows
1. Download and install [VB-Audio Virtual Cable](https://vb-audio.com/Cable/)
2. The installer will automatically detect "CABLE Output" and "CABLE Input"

### macOS
1. Install BlackHole:
   ```bash
   brew install blackhole-2ch
   ```
2. Create an aggregate device in Audio MIDI Setup
3. Update device names in `adv_audio_scrub/scrub_audio.py` if needed

### Linux
1. Install PulseAudio module:
   ```bash
   pactl load-module module-null-sink sink_name=virtual_cable
   ```
2. Update device names in `adv_audio_scrub/scrub_audio.py` if needed

## Building Standalone Executables

### Windows
```cmd
build_windows.bat
```

### macOS
```bash
bash build_macos.sh
```

### Linux
```bash
bash build_linux.sh
```

The executable will be created in the `dist/` directory.

## Configuration

Edit `adv_audio_scrub/scrub_audio.py` to customize:

```python
# Audio settings
TARGET_SR = 44100          # Sample rate (Hz)
TARGET_BITS = 24           # Bit depth
CHANNELS = 2               # Stereo

# Virtual device names (adjust for your system)
VIRTUAL_OUTPUT_NAME = "CABLE Output (VB-Audio Virtual Cable)"
VIRTUAL_INPUT_NAME = "CABLE Input (VB-Audio Virtual Cable)"

# Neural codec settings
CODEC_BITRATE = "12k"      # Lower = more compression (6k, 12k, 24k)
```

## Troubleshooting

### "PortAudio library not found"
- **Linux**: Install `portaudio19-dev` and `libportaudio2`
- **macOS**: Install portaudio via Homebrew
- **Windows**: Usually works out of the box, try reinstalling sounddevice

### "No device matching..." error
- Check available devices:
  ```python
  import sounddevice as sd
  print(sd.query_devices())
  ```
- Update device names in `scrub_audio.py` to match your system

### "ffmpeg not found"
- Ensure ffmpeg is installed and in your PATH
- Test with: `ffmpeg -version`

### Buffer underruns
- Increase `BLOCKSIZE` in `scrub_audio.py`
- Close other audio applications
- Reduce system load

### Demucs installation fails
- This is optional; the tool works without it (loopback only)
- Try installing with: `pip install demucs --no-cache-dir`
- Or skip neural scrubbing with `--no-neural` flag

## Dependencies

### System
- Python 3.8+
- ffmpeg
- portaudio (Linux/macOS)
- Virtual audio cable driver

### Python Packages
- numpy - Numerical computing
- sounddevice - Audio I/O
- soundfile - Audio file handling
- demucs - Neural codec (optional)
- pyinstaller - Building executables (dev only)

## How It Works

1. **Loopback Recording**: The input audio is decoded by ffmpeg and played through a virtual output device, while simultaneously recording from the virtual input device. This process removes certain digital artifacts.

2. **Neural Codec Scrubbing**: The recorded audio is compressed using Meta's Demucs neural codec at a low bitrate (12kbps by default), then decompressed. This aggressive compression/decompression cycle removes additional artifacts and noise.

3. **Output**: The final "scrubbed" audio is saved as a high-quality WAV file (24-bit, 44.1kHz stereo by default).

## Performance

- Processing time is approximately 1.5-2x the audio duration
- GPU acceleration available for demucs (requires CUDA)
- Memory usage: ~500MB base + ~2GB per concurrent file

## License

MIT License - See LICENSE file for details

## Credits

- Demucs neural codec by Meta AI Research (facebookresearch/demucs)
- VB-Audio Virtual Cable by VB-Audio Software
- Project structure and implementation by CerealNose

## Support

For issues, questions, or contributions:
- Check existing issues in the repository
- Review the troubleshooting section above
- Ensure all dependencies are correctly installed

## Version History

- **v1.0.0** (2026-01-04)
  - Initial release
  - Loopback recording support
  - Neural codec integration
  - Cross-platform GUI
  - Batch processing
  - Auto-installer scripts
\n\n---\n\n
# Installation Guide - Advanced Audio Scrub

Complete installation instructions for all platforms.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Automatic Installation](#automatic-installation)
3. [Manual Installation](#manual-installation)
4. [Verification](#verification)
5. [Virtual Audio Cable Setup](#virtual-audio-cable-setup)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### All Platforms
- **Python 3.8 or higher** (3.9+ recommended)
- **Internet connection** (for downloading packages)
- **~2GB free disk space** (for demucs and dependencies)

### Platform-Specific

#### Windows
- Windows 10 or later (64-bit)
- Administrator privileges (for installing system components)

#### macOS
- macOS 10.15 (Catalina) or later
- Homebrew package manager
- Xcode Command Line Tools

#### Linux
- Ubuntu 20.04+ / Debian 11+ (or equivalent)
- sudo privileges

---

## Automatic Installation

**This is the recommended method for most users.**

### Windows

1. **Extract the project** to a folder (e.g., `C:\AdvancedAudioScrub`)

2. **Run the installer**:
   - Double-click `install.bat`
   - OR open Command Prompt in the project folder and run:
     ```cmd
     install.bat
     ```

3. **Follow the prompts**:
   - The installer will check for Python
   - Install ffmpeg if needed (follow instructions if prompted)
   - Create a virtual environment (recommended)
   - Install all Python dependencies

4. **Wait for completion** (5-15 minutes depending on internet speed)

### Linux / macOS

1. **Extract the project** to a folder

2. **Open terminal** in the project directory

3. **Run the installer**:
   ```bash
   bash install.sh
   ```

4. **Enter your password** when prompted (for installing system packages)

5. **Follow the prompts**:
   - Choose whether to create a virtual environment (recommended: Yes)
   - Wait for all packages to install

6. **Installation complete!**

---

## Manual Installation

If the automatic installer doesn't work or you prefer manual control:

### Step 1: Install System Dependencies

#### Windows

1. **Install Python**:
   - Download from [python.org](https://www.python.org/downloads/)
   - During installation, **check "Add Python to PATH"**
   - Verify: `python --version`

2. **Install ffmpeg**:
   - Download from [gyan.dev/ffmpeg/builds](https://www.gyan.dev/ffmpeg/builds/)
   - Get "ffmpeg-release-essentials.zip"
   - Extract to a folder (e.g., `C:\ffmpeg`)
   - Add `C:\ffmpeg\bin` to your PATH environment variable
   - OR place `ffmpeg.exe` directly in the project folder
   - Verify: `ffmpeg -version`

#### macOS

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install python@3.11 ffmpeg portaudio libsndfile

# Verify
python3 --version
ffmpeg -version
```

#### Linux (Ubuntu/Debian)

```bash
# Update package list
sudo apt-get update

# Install dependencies
sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-tk \
    python3-dev \
    ffmpeg \
    portaudio19-dev \
    libportaudio2 \
    libsndfile1 \
    build-essential

# Verify
python3 --version
ffmpeg -version
```

### Step 2: Set Up Python Environment

```bash
# Navigate to project directory
cd /path/to/adv_audio_scrub

# Create virtual environment (recommended)
python3 -m venv venv

# Activate virtual environment
# Linux/macOS:
source venv/bin/activate
# Windows:
venv\Scripts\activate.bat

# Upgrade pip
pip install --upgrade pip setuptools wheel
```

### Step 3: Install Python Packages

```bash
# Install core dependencies
pip install numpy sounddevice soundfile

# Install demucs (optional but recommended, ~500MB, takes 5-10 minutes)
pip install demucs

# Install development tools (optional, for building executables)
pip install pyinstaller
```

### Step 4: Verify Installation

```bash
python verify_installation.py
```

---

## Verification

After installation, run the verification script:

```bash
python verify_installation.py
```

This will check:
- ✓ Python version (3.8+)
- ✓ ffmpeg availability
- ✓ Core Python packages (numpy, sounddevice, soundfile)
- ✓ Optional packages (demucs, pyinstaller)
- ✓ Project files
- ✓ Audio devices

Expected output:
```
============================================================
Advanced Audio Scrub - Installation Verification
============================================================

Checking Python version...
  ✓ Python 3.11.0

Checking ffmpeg...
  ✓ ffmpeg version 4.4.2

Checking Python dependencies...
  ✓ numpy (version 1.24.0)
  ✓ sounddevice (version 0.4.6)
  ✓ soundfile (version 0.12.1)

...

✓ All critical checks passed!
```

---

## Virtual Audio Cable Setup

**Required for the loopback recording feature to work.**

### Windows - VB-Audio Virtual Cable

1. **Download**:
   - Visit [vb-audio.com/Cable](https://vb-audio.com/Cable/)
   - Download "VBCABLE_Driver_Pack43.zip"

2. **Install**:
   - Extract the ZIP file
   - Right-click `VBCABLE_Setup_x64.exe` (or x86)
   - Select "Run as administrator"
   - Click "Install Driver"

3. **Restart** if prompted

4. **Verify**:
   - Open Sound settings
   - You should see "CABLE Input" and "CABLE Output" devices

### macOS - BlackHole

```bash
# Install via Homebrew
brew install blackhole-2ch

# Or download from:
# https://github.com/ExistentialAudio/BlackHole

# After installation, create an aggregate device:
# 1. Open "Audio MIDI Setup" (in Applications/Utilities)
# 2. Click "+" and select "Create Aggregate Device"
# 3. Check both "BlackHole 2ch" and your output device
# 4. Name it "Loopback"
```

**Note**: You may need to update device names in `adv_audio_scrub/scrub_audio.py`:
```python
VIRTUAL_OUTPUT_NAME = "BlackHole 2ch"
VIRTUAL_INPUT_NAME = "BlackHole 2ch"
```

### Linux - PulseAudio Virtual Sink

```bash
# Create virtual sink
pactl load-module module-null-sink sink_name=virtual_cable sink_properties=device.description=VirtualCable

# Make it persistent (add to PulseAudio config)
echo "load-module module-null-sink sink_name=virtual_cable" | sudo tee -a /etc/pulse/default.pa

# Restart PulseAudio
pulseaudio -k
pulseaudio --start
```

**Note**: Update device names in `adv_audio_scrub/scrub_audio.py`:
```python
VIRTUAL_OUTPUT_NAME = "VirtualCable"
VIRTUAL_INPUT_NAME = "VirtualCable.monitor"
```

---

## Troubleshooting

### Python not found

**Windows**:
- Reinstall Python and check "Add Python to PATH"
- Or use full path: `C:\Python311\python.exe`

**Linux/macOS**:
- Install Python 3.8+: `sudo apt-get install python3` or `brew install python3`

### ffmpeg not found

**Windows**:
- Add ffmpeg to PATH or place `ffmpeg.exe` in project folder
- Verify: `ffmpeg -version`

**Linux**:
- `sudo apt-get install ffmpeg`

**macOS**:
- `brew install ffmpeg`

### PortAudio library not found

**Linux**:
```bash
sudo apt-get install portaudio19-dev libportaudio2
pip install --force-reinstall sounddevice
```

**macOS**:
```bash
brew install portaudio
pip install --force-reinstall sounddevice
```

### demucs installation fails or times out

This is a large package (~500MB) with many dependencies:

1. **Increase timeout**:
   ```bash
   pip install --timeout=300 demucs
   ```

2. **Install without cache**:
   ```bash
   pip install --no-cache-dir demucs
   ```

3. **Skip demucs** (tool still works without it):
   - Just skip this package
   - Use `--no-neural` flag when processing audio

### Virtual device not found

1. **Check device names**:
   ```python
   import sounddevice as sd
   print(sd.query_devices())
   ```

2. **Update configuration**:
   - Edit `adv_audio_scrub/scrub_audio.py`
   - Update `VIRTUAL_OUTPUT_NAME` and `VIRTUAL_INPUT_NAME`
   - Match the names from step 1

### Permission denied (Linux/macOS)

```bash
# Don't use sudo with pip in virtual environment
# Instead, ensure you're in the venv:
source venv/bin/activate
pip install ...
```

### Import errors after installation

```bash
# Verify you're in the correct directory
pwd  # Should show project directory

# Verify virtual environment is activated
which python  # Should show venv/bin/python

# Reinstall if needed
pip install --force-reinstall sounddevice soundfile numpy
```

---

## Next Steps

After successful installation:

1. **Read the Quick Start**: See [QUICKSTART.md](QUICKSTART.md)
2. **Run the GUI**: `python gui.py`
3. **Test with a file**: Process a short audio file first
4. **Customize settings**: Edit `adv_audio_scrub/scrub_audio.py`
5. **Build executable**: Run `build_windows.bat` or `build_linux.sh`

---

## Getting Help

If you encounter issues:

1. Run `python verify_installation.py` to diagnose problems
2. Check the [Troubleshooting](#troubleshooting) section above
3. Review [README_ENHANCED.md](README_ENHANCED.md) for detailed documentation
4. Ensure all prerequisites are met
5. Try manual installation if automatic installer fails

---

## Uninstallation

### If using virtual environment:
```bash
# Just delete the venv folder
rm -rf venv  # Linux/macOS
rmdir /s venv  # Windows
```

### If installed globally:
```bash
pip uninstall numpy sounddevice soundfile demucs pyinstaller
```

### System packages:
- Windows: Uninstall VB-Audio Virtual Cable from Control Panel
- macOS: `brew uninstall blackhole-2ch`
- Linux: `pactl unload-module module-null-sink`

---

**Happy audio scrubbing!** 🎵
\n\n---\n\n
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
