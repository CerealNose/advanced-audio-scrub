# Quick Start Guide

Get up and running with Advanced Audio Scrub in 5 minutes!

## Step 1: Install

### Windows
```cmd
install.bat
```

### Linux / macOS
```bash
bash install.sh
```

**That's it!** The installer handles everything automatically.

## Step 2: Set Up Virtual Audio Cable

### Windows
1. Download [VB-Audio Virtual Cable](https://vb-audio.com/Cable/)
2. Run the installer
3. Restart if prompted

### macOS
```bash
brew install blackhole-2ch
```

### Linux
```bash
pactl load-module module-null-sink sink_name=virtual_cable
```

## Step 3: Run the Application

### GUI Mode (Recommended)
```bash
python gui.py
```

1. Click "Add Files" to select audio files
2. Click "Start Processing"
3. Wait for completion
4. Find cleaned files in the same directory with `_clean.wav` suffix

### Command Line Mode
```bash
python -m adv_audio_scrub.scrub_audio your_audio.mp3
```

## Common Issues

### "Virtual device not found"
- Make sure you installed the virtual audio cable (Step 2)
- Check device names:
  ```python
  import sounddevice as sd
  print(sd.query_devices())
  ```

### "ffmpeg not found"
- The installer should have installed it
- Verify: `ffmpeg -version`
- If missing, reinstall or add to PATH

### "PortAudio error"
- The installer should have fixed this
- Try reinstalling: `pip install --force-reinstall sounddevice`

## Next Steps

- Read [README_ENHANCED.md](README_ENHANCED.md) for detailed documentation
- Customize settings in `adv_audio_scrub/scrub_audio.py`
- Build a standalone executable with `build_windows.bat` or `build_linux.sh`

## Need Help?

1. Check the troubleshooting section in README_ENHANCED.md
2. Verify all dependencies are installed
3. Test with a small audio file first

Enjoy scrubbing your audio! 🎵
