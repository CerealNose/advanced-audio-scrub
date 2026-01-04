#!/usr/bin/env bash
# Linux build script using PyInstaller
# Ensure ffmpeg is installed and on PATH

set -e

echo "Building Advanced Audio Scrub for Linux..."
echo ""

# Detect Python command
PYTHON_CMD=""
for cmd in python3.11 python3.10 python3.9 python3.8 python3; do
    if command -v $cmd &> /dev/null; then
        PYTHON_CMD=$cmd
        break
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "Error: Python 3.8+ not found"
    exit 1
fi

# Check if in virtual environment
if [ -d "venv" ] && [ -z "$VIRTUAL_ENV" ]; then
    echo "Activating virtual environment..."
    source venv/bin/activate
    PYTHON_CMD="python"
fi

# Check PyInstaller
if ! $PYTHON_CMD -c "import PyInstaller" 2>/dev/null; then
    echo "Installing PyInstaller..."
    $PYTHON_CMD -m pip install pyinstaller
fi

# Build
echo "Running PyInstaller..."
$PYTHON_CMD -m PyInstaller --noconfirm --onefile --windowed \
  --add-data "adv_audio_scrub:adv_audio_scrub" \
  --hidden-import="numpy" \
  --hidden-import="sounddevice" \
  --hidden-import="soundfile" \
  --name="AdvancedAudioScrub" \
  gui.py

echo ""
echo "Build finished!"
echo "Executable: ./dist/AdvancedAudioScrub"
echo ""
echo "Note: ffmpeg must be installed on the target system"
