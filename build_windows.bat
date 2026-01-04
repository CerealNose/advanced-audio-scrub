@echo off
REM Windows build script using PyInstaller
REM Place ffmpeg.exe in the repo root or ensure ffmpeg is on PATH.

pyinstaller --noconfirm --onefile --windowed ^
  --add-data "ffmpeg.exe;." ^
  --add-data "adv_audio_scrub;adv_audio_scrub" ^
  gui.py

echo Build finished. Dist folder contains the exe.
pause
