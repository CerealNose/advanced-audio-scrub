@echo off
REM Auto-installer for Advanced Audio Scrub (Windows)
REM Usage: Double-click this file or run: install.bat

setlocal enabledelayedexpansion

echo ==========================================
echo Advanced Audio Scrub - Auto Installer
echo ==========================================
echo.

REM Check for Python
echo Checking Python installation...
set PYTHON_CMD=
for %%P in (python python3 py) do (
    where %%P >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=2" %%V in ('%%P --version 2^>^&1') do (
            set VERSION=%%V
            for /f "tokens=1,2 delims=." %%A in ("!VERSION!") do (
                set MAJOR=%%A
                set MINOR=%%B
                if !MAJOR! geq 3 if !MINOR! geq 8 (
                    set PYTHON_CMD=%%P
                    echo [OK] Found Python !VERSION! at %%P
                    goto :python_found
                )
            )
        )
    )
)

:python_found
if "%PYTHON_CMD%"=="" (
    echo [ERROR] Python 3.8 or higher is required but not found.
    echo.
    echo Please install Python from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation.
    echo.
    pause
    exit /b 1
)
echo.

REM Check for ffmpeg
echo Checking ffmpeg installation...
where ffmpeg >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] ffmpeg found in PATH
) else (
    echo [WARNING] ffmpeg not found in PATH
    echo.
    echo ffmpeg is required for audio processing.
    echo.
    echo Download options:
    echo 1. Download from: https://www.gyan.dev/ffmpeg/builds/
    echo    - Download "ffmpeg-release-essentials.zip"
    echo    - Extract and add the 'bin' folder to your PATH
    echo.
    echo 2. Or place ffmpeg.exe in this directory
    echo.
    echo After installing ffmpeg, run this installer again.
    echo.
    set /p CONTINUE="Continue without ffmpeg? (not recommended) [y/N]: "
    if /i not "!CONTINUE!"=="y" (
        pause
        exit /b 1
    )
)
echo.

REM Create virtual environment
echo Setting up Python environment...
set /p CREATE_VENV="Create a virtual environment? (recommended) [Y/n]: "
if /i "!CREATE_VENV!"=="n" goto :skip_venv

set VENV_DIR=venv
if exist "%VENV_DIR%" (
    echo Virtual environment already exists at .\%VENV_DIR%
    set /p RECREATE="Remove and recreate? [y/N]: "
    if /i "!RECREATE!"=="y" (
        rmdir /s /q "%VENV_DIR%"
        %PYTHON_CMD% -m venv "%VENV_DIR%"
        echo [OK] Virtual environment recreated
    )
) else (
    %PYTHON_CMD% -m venv "%VENV_DIR%"
    echo [OK] Virtual environment created at .\%VENV_DIR%
)

REM Activate virtual environment
call "%VENV_DIR%\Scripts\activate.bat"
set PYTHON_CMD=python
echo [OK] Virtual environment activated
goto :after_venv

:skip_venv
echo Skipping virtual environment creation

:after_venv
echo.

REM Upgrade pip
echo Upgrading pip...
%PYTHON_CMD% -m pip install --upgrade pip setuptools wheel --quiet
echo [OK] pip upgraded
echo.

REM Install Python dependencies
echo Installing Python dependencies...
echo This may take a few minutes...
echo.

echo Installing core dependencies:
echo   - numpy (numerical computing)
echo   - sounddevice (audio I/O)
echo   - soundfile (audio file handling)
%PYTHON_CMD% -m pip install numpy sounddevice soundfile --quiet
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install core dependencies
    pause
    exit /b 1
)
echo [OK] Core dependencies installed
echo.

echo Installing demucs (neural audio codec)...
echo This is a large package and may take several minutes...
echo Please be patient...
%PYTHON_CMD% -m pip install demucs --quiet
if %errorlevel% equ 0 (
    echo [OK] demucs installed successfully
) else (
    echo [WARNING] demucs installation failed or was interrupted
    echo   You can install it later with: %PYTHON_CMD% -m pip install demucs
    echo   The tool will work without it, but neural scrubbing will be unavailable
)
echo.

echo Installing development tools:
echo   - pyinstaller (for building executables)
%PYTHON_CMD% -m pip install pyinstaller --quiet
echo [OK] Development tools installed
echo.

REM Verify installation
echo Verifying installation...
%PYTHON_CMD% -c "import numpy; import sounddevice; import soundfile; print('[OK] Core modules imported successfully')"
if %errorlevel% neq 0 (
    echo [ERROR] Installation verification failed
    pause
    exit /b 1
)

%PYTHON_CMD% -c "import demucs; print('[OK] demucs version', demucs.__version__)" 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] demucs not available (optional)
)
echo.

REM Display audio devices
echo Available audio devices:
%PYTHON_CMD% -c "import sounddevice as sd; devices = sd.query_devices(); print(f'Found {len(devices)} audio device(s)'); [print(f'  [{i}] {d[\"name\"]}') for i, d in enumerate(devices)]" 2>nul
echo.

REM Installation complete
echo ==========================================
echo Installation Complete!
echo ==========================================
echo.
echo Next steps:
echo.
if exist "venv" (
    echo 1. Activate the virtual environment:
    echo    venv\Scripts\activate.bat
    echo.
)
echo 2. Run the GUI application:
echo    %PYTHON_CMD% gui.py
echo.
echo 3. Or use the command-line interface:
echo    %PYTHON_CMD% -m adv_audio_scrub.scrub_audio your_audio_file.mp3
echo.
echo 4. To build a standalone executable:
echo    build_windows.bat
echo.
echo For more information, see README.md
echo.

REM Create activation helper script
if exist "venv" (
    echo @echo off > activate_env.bat
    echo call venv\Scripts\activate.bat >> activate_env.bat
    echo echo Virtual environment activated! >> activate_env.bat
    echo echo Run 'python gui.py' to start the application >> activate_env.bat
    
    echo Tip: Run 'activate_env.bat' to quickly activate the environment
    echo.
)

pause
