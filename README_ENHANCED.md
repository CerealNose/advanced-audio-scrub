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
