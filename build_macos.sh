#!/usr/bin/env bash
# macOS build script using PyInstaller
# Ensure ffmpeg is installed (brew install ffmpeg) and ffmpeg is on PATH.

pyinstaller --noconfirm --onefile --windowed \
  --add-data "adv_audio_scrub:adv_audio_scrub" \
  gui.py

echo "Build finished. See dist/gui"
