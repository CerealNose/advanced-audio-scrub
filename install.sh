#!/usr/bin/env bash
# Auto-installer for Advanced Audio Scrub
# Supports Linux (Ubuntu/Debian) and macOS
# Usage: bash install.sh

set -e  # Exit on error

echo "=========================================="
echo "Advanced Audio Scrub - Auto Installer"
echo "=========================================="
echo ""

# Detect OS
OS_TYPE=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="linux"
    echo "Detected OS: Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
    echo "Detected OS: macOS"
else
    echo "Unsupported OS: $OSTYPE"
    echo "This installer supports Linux and macOS only."
    exit 1
fi
echo ""

# Check Python version
echo "Checking Python installation..."
PYTHON_CMD=""
for cmd in python3.11 python3.10 python3.9 python3.8 python3; do
    if command -v $cmd &> /dev/null; then
        VERSION=$($cmd --version 2>&1 | awk '{print $2}')
        MAJOR=$(echo $VERSION | cut -d. -f1)
        MINOR=$(echo $VERSION | cut -d. -f2)
        if [ "$MAJOR" -eq 3 ] && [ "$MINOR" -ge 8 ]; then
            PYTHON_CMD=$cmd
            echo "✓ Found Python $VERSION at $(which $cmd)"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "✗ Python 3.8 or higher is required but not found."
    echo "Please install Python 3.8+ and try again."
    exit 1
fi
echo ""

# Install system dependencies
echo "Installing system dependencies..."
if [ "$OS_TYPE" == "linux" ]; then
    echo "Checking for sudo privileges..."
    if ! sudo -n true 2>/dev/null; then
        echo "This script requires sudo privileges to install system packages."
        echo "You may be prompted for your password."
    fi
    
    echo "Updating package lists..."
    sudo apt-get update -qq
    
    echo "Installing required packages:"
    echo "  - ffmpeg (audio processing)"
    echo "  - portaudio19-dev (audio device access)"
    echo "  - libsndfile1 (audio file I/O)"
    echo "  - python3-tk (GUI support)"
    
    sudo apt-get install -y -qq \
        ffmpeg \
        portaudio19-dev \
        libportaudio2 \
        libsndfile1 \
        python3-tk \
        python3-dev \
        build-essential
    
    echo "✓ System dependencies installed"
    
elif [ "$OS_TYPE" == "macos" ]; then
    echo "Checking for Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "✗ Homebrew is not installed."
        echo "Please install Homebrew from https://brew.sh/ and try again."
        exit 1
    fi
    echo "✓ Homebrew found"
    
    echo "Installing required packages:"
    echo "  - ffmpeg (audio processing)"
    echo "  - portaudio (audio device access)"
    echo "  - libsndfile (audio file I/O)"
    
    brew install ffmpeg portaudio libsndfile
    
    echo "✓ System dependencies installed"
fi
echo ""

# Check ffmpeg installation
echo "Verifying ffmpeg installation..."
if command -v ffmpeg &> /dev/null; then
    FFMPEG_VERSION=$(ffmpeg -version 2>&1 | head -n1)
    echo "✓ $FFMPEG_VERSION"
else
    echo "✗ ffmpeg not found in PATH"
    exit 1
fi
echo ""

# Create virtual environment (optional but recommended)
echo "Setting up Python environment..."
read -p "Create a virtual environment? (recommended) [Y/n]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    VENV_DIR="venv"
    if [ -d "$VENV_DIR" ]; then
        echo "Virtual environment already exists at ./$VENV_DIR"
        read -p "Remove and recreate? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$VENV_DIR"
            $PYTHON_CMD -m venv "$VENV_DIR"
            echo "✓ Virtual environment recreated"
        fi
    else
        $PYTHON_CMD -m venv "$VENV_DIR"
        echo "✓ Virtual environment created at ./$VENV_DIR"
    fi
    
    # Activate virtual environment
    source "$VENV_DIR/bin/activate"
    PYTHON_CMD="python"
    echo "✓ Virtual environment activated"
else
    echo "Skipping virtual environment creation"
fi
echo ""

# Upgrade pip
echo "Upgrading pip..."
$PYTHON_CMD -m pip install --upgrade pip setuptools wheel --quiet
echo "✓ pip upgraded"
echo ""

# Install Python dependencies
echo "Installing Python dependencies..."
echo "This may take a few minutes..."
echo ""

echo "Installing core dependencies:"
echo "  - numpy (numerical computing)"
echo "  - sounddevice (audio I/O)"
echo "  - soundfile (audio file handling)"
$PYTHON_CMD -m pip install numpy sounddevice soundfile --quiet
echo "✓ Core dependencies installed"
echo ""

echo "Installing demucs (neural audio codec)..."
echo "This is a large package and may take several minutes..."
$PYTHON_CMD -m pip install demucs --quiet
if [ $? -eq 0 ]; then
    echo "✓ demucs installed successfully"
else
    echo "⚠ demucs installation failed or was interrupted"
    echo "  You can install it later with: $PYTHON_CMD -m pip install demucs"
    echo "  The tool will work without it, but neural scrubbing will be unavailable"
fi
echo ""

echo "Installing development tools:"
echo "  - pyinstaller (for building executables)"
$PYTHON_CMD -m pip install pyinstaller --quiet
echo "✓ Development tools installed"
echo ""

# Verify installation
echo "Verifying installation..."
$PYTHON_CMD -c "import numpy; import sounddevice; import soundfile; print('✓ Core modules imported successfully')"

if $PYTHON_CMD -c "import demucs" 2>/dev/null; then
    DEMUCS_VERSION=$($PYTHON_CMD -c "import demucs; print(demucs.__version__)" 2>/dev/null || echo "unknown")
    echo "✓ demucs version $DEMUCS_VERSION"
else
    echo "⚠ demucs not available (optional)"
fi
echo ""

# Display audio devices
echo "Available audio devices:"
$PYTHON_CMD -c "import sounddevice as sd; devices = sd.query_devices(); print(f'Found {len(devices)} audio device(s)'); [print(f'  [{i}] {d[\"name\"]}') for i, d in enumerate(devices)]" 2>/dev/null || echo "  (No audio devices detected - this is normal in headless environments)"
echo ""

# Installation complete
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
if [ -d "venv" ]; then
    echo "1. Activate the virtual environment:"
    echo "   source venv/bin/activate"
    echo ""
fi
echo "2. Run the GUI application:"
echo "   $PYTHON_CMD gui.py"
echo ""
echo "3. Or use the command-line interface:"
echo "   $PYTHON_CMD -m adv_audio_scrub.scrub_audio your_audio_file.mp3"
echo ""
echo "4. To build a standalone executable:"
if [ "$OS_TYPE" == "linux" ]; then
    echo "   bash build_linux.sh"
elif [ "$OS_TYPE" == "macos" ]; then
    echo "   bash build_macos.sh"
fi
echo ""
echo "For more information, see README.md"
echo ""

# Create activation helper script
if [ -d "venv" ]; then
    cat > activate_env.sh << 'EOF'
#!/usr/bin/env bash
# Helper script to activate the virtual environment
source venv/bin/activate
echo "Virtual environment activated!"
echo "Run 'python gui.py' to start the application"
EOF
    chmod +x activate_env.sh
    echo "Tip: Run './activate_env.sh' to quickly activate the environment"
    echo ""
fi
