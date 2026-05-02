#!/bin/bash
# Build script for Citadel Clash
# Usage: ./build.sh [linux|windows|web|all]

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODOT_DIR="$PROJECT_DIR/godot"
BUILD_DIR="$PROJECT_DIR/builds"
VERSION="0.2.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if godot4 is available
check_godot() {
    if command -v godot4 &> /dev/null; then
        GODOT_CMD="godot4"
    elif command -v godot &> /dev/null; then
        GODOT_CMD="godot"
    else
        log_error "Godot not found! Please install Godot 4.4 or later."
        log_info "Download from: https://godotengine.org/download"
        exit 1
    fi
    log_info "Using Godot command: $GODOT_CMD"
}

# Build for Linux
build_linux() {
    log_info "Building for Linux..."
    mkdir -p "$BUILD_DIR/citadel-clash-v${VERSION}-linux"
    
    "$GODOT_CMD" --headless --path "$GODOT_DIR" --export-release "Linux/X11" \
        "$BUILD_DIR/citadel-clash-v${VERSION}-linux/citadel-clash.x86_64" || {
        log_error "Linux build failed!"
        return 1
    }
    
    log_info "Linux build complete!"
}

# Build for Windows
build_windows() {
    log_info "Building for Windows..."
    mkdir -p "$BUILD_DIR/citadel-clash-v${VERSION}-windows"
    
    "$GODOT_CMD" --headless --path "$GODOT_DIR" --export-release "Windows Desktop" \
        "$BUILD_DIR/citadel-clash-v${VERSION}-windows/citadel-clash.exe" || {
        log_error "Windows build failed!"
        return 1
    }
    
    log_info "Windows build complete!"
}

# Build for Web
build_web() {
    log_info "Building for Web..."
    mkdir -p "$BUILD_DIR/citadel-clash-v${VERSION}-web"
    
    "$GODOT_CMD" --headless --path "$GODOT_DIR" --export-release "Web" \
        "$BUILD_DIR/citadel-clash-v${VERSION}-web/index.html" || {
        log_error "Web build failed!"
        return 1
    }
    
    log_info "Web build complete!"
}

# Create distribution packages
package_builds() {
    log_info "Creating distribution packages..."
    cd "$BUILD_DIR"
    
    # Create ZIP files
    for dir in citadel-clash-v${VERSION}-*/; do
        if [ -d "$dir" ]; then
            zip -r "${dir%/}.zip" "$dir"
            log_info "Created ${dir%/}.zip"
        fi
    done
    
    cd - > /dev/null
}

# Main build process
main() {
    log_info "Citadel Clash Build Script v${VERSION}"
    log_info "Project directory: $PROJECT_DIR"
    
    check_godot
    
    TARGET="${1:-all}"
    
    case "$TARGET" in
        linux)
            build_linux
            ;;
        windows)
            build_windows
            ;;
        web)
            build_web
            ;;
        all)
            build_linux
            build_windows
            build_web
            package_builds
            ;;
        *)
            log_error "Unknown target: $TARGET"
            log_info "Usage: $0 [linux|windows|web|all]"
            exit 1
            ;;
    esac
    
    log_info "Build process complete!"
    log_info "Output directory: $BUILD_DIR"
}

main "$@"