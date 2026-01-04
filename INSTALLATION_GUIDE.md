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
