#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root
[[ $EUID -eq 0 ]] && { error "Don't run this as root!"; exit 1; }

# Install dependencies
install_deps() {
    local missing_deps=()
    command -v curl >/dev/null || missing_deps+=(curl)
    command -v jq >/dev/null || missing_deps+=(jq)
    
    [[ ${#missing_deps[@]} -eq 0 ]] && return
    
    log "Installing missing dependencies: ${missing_deps[*]}"
    
    if command -v pacman >/dev/null; then
        sudo pacman -S --needed --noconfirm "${missing_deps[@]}"
    elif command -v apt >/dev/null; then
        sudo apt update && sudo apt install -y "${missing_deps[@]}"
    elif command -v dnf >/dev/null; then
        sudo dnf install -y "${missing_deps[@]}"
    else
        error "Unsupported package manager. Install curl and jq manually."
        exit 1
    fi
}

# Determine if Cursor is installed
is_cursor_installed() {
    if command -v cursor >/dev/null 2>&1; then
        return 0
    fi

    # Fall back to checking common install locations created by installers
    [[ -x "$HOME/.local/bin/cursor" ]] && return 0
    [[ -f "$HOME/.local/share/applications/cursor.desktop" ]] && return 0
    return 1
}

# Install Cursor (fresh install)
install_cursor() {
    log "Installing Cursor (fresh install)..."
    curl -fsSL https://raw.githubusercontent.com/watzon/cursor-linux-installer/main/install.sh | bash
}

# Update Cursor to the latest AppImage
update_cursor() {
    # Re-running the upstream installer is idempotent and fetches the latest release
    log "Updating Cursor to the latest AppImage..."
    curl -fsSL https://raw.githubusercontent.com/watzon/cursor-linux-installer/main/install.sh | bash
}

# Fix icon and desktop integration for Sway
fix_sway_integration() {
    local icon_dir="$HOME/.local/share/icons/hicolor"
    local cursor_icon="$icon_dir/48x48/apps/cursor.png"
    local desktop_file="$HOME/.local/share/applications/cursor.desktop"
    
    log "Setting up Sway integration..."
    
    # Create icon directories
    mkdir -p "$icon_dir/48x48/apps" "$HOME/.local/share/pixmaps" "$HOME/.icons"
    
    # Ensure desktop file exists and is properly configured
    if [[ -f "$desktop_file" ]]; then
        log "Updating desktop file for better Sway integration..."
        # Fix desktop file for Wayland/Sway
        sed -i 's/Exec=cursor/Exec=cursor --enable-features=UseOzonePlatform --ozone-platform=wayland/' "$desktop_file" 2>/dev/null || true
        
        # Ensure proper categories for dmenu/rofi
        if ! grep -q "Categories=" "$desktop_file"; then
            echo "Categories=Development;TextEditor;IDE;" >> "$desktop_file"
        fi
        
        # Ensure StartupWMClass for proper window handling
        if ! grep -q "StartupWMClass=" "$desktop_file"; then
            echo "StartupWMClass=cursor" >> "$desktop_file"
        fi
    else
        warn "Desktop file not found, creating one..."
        cat > "$desktop_file" << 'EOF'
[Desktop Entry]
Name=Cursor
Comment=The AI-first code editor
GenericName=Text Editor
Exec=cursor --enable-features=UseOzonePlatform --ozone-platform=wayland %F
Icon=cursor
Type=Application
StartupNotify=true
StartupWMClass=cursor
Categories=Development;TextEditor;IDE;
MimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/x-ruby;text/x-tcl;text/x-tex;application/x-sh;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/x-ruby;text/x-tcl;text/x-tex;application/x-sh;
EOF
    fi
    
    # Copy icon to multiple locations for better compatibility
    if [[ -f "$cursor_icon" ]]; then
        cp "$cursor_icon" "$HOME/.local/share/pixmaps/cursor.png" 2>/dev/null || true
        cp "$cursor_icon" "$HOME/.icons/cursor.png" 2>/dev/null || true
        log "Icon copied to multiple locations"
    else
        warn "Cursor icon not found, skipping icon copy"
    fi
    
    # Create hicolor theme index if missing
    [[ ! -f "$icon_dir/index.theme" ]] && {
        cat > "$icon_dir/index.theme" << 'EOF'
[Icon Theme]
Name=Hicolor
Comment=Fallback icon theme
Hidden=true
Directories=16x16/apps,22x22/apps,24x24/apps,32x32/apps,48x48/apps,64x64/apps,128x128/apps,256x256/apps,512x512/apps

[16x16/apps]
Size=16
Context=Applications
Type=Fixed

[22x22/apps]
Size=22
Context=Applications
Type=Fixed

[24x24/apps]
Size=24
Context=Applications
Type=Fixed

[32x32/apps]
Size=32
Context=Applications
Type=Fixed

[48x48/apps]
Size=48
Context=Applications
Type=Fixed

[64x64/apps]
Size=64
Context=Applications
Type=Fixed

[128x128/apps]
Size=128
Context=Applications
Type=Fixed

[256x256/apps]
Size=256
Context=Applications
Type=Fixed

[512x512/apps]
Size=512
Context=Applications
Type=Fixed
EOF
    }
    
    # Update desktop database and icon cache
    command -v update-desktop-database >/dev/null && {
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
        log "Desktop database updated"
    }
    
    command -v gtk-update-icon-cache >/dev/null && {
        gtk-update-icon-cache -f -t "$icon_dir" 2>/dev/null || true
        log "Icon cache updated"
    }
    
    # Create 'code' wrapper if it doesn't exist
    if command -v cursor >/dev/null && [[ ! -f "$HOME/.local/bin/code" ]]; then
        log "Creating 'code' wrapper for Cursor..."
        mkdir -p "$HOME/.local/bin"
        cat > "$HOME/.local/bin/code" << 'EOF'
#!/bin/bash
cursor "$@"
EOF
        chmod +x "$HOME/.local/bin/code"
        
        # Add to PATH in bash config if needed
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            local bash_config=""
            
            # Determine which bash config file to use
            if [[ -f "$HOME/.bashrc" ]]; then
                bash_config="$HOME/.bashrc"
            elif [[ -f "$HOME/.bash_profile" ]]; then
                bash_config="$HOME/.bash_profile"
            else
                bash_config="$HOME/.bashrc"
                touch "$bash_config"
            fi
            
            # Add PATH export if not already present
            if ! grep -q "export PATH=.*\.local/bin" "$bash_config"; then
                echo "" >> "$bash_config"
                echo "# Add ~/.local/bin to PATH for local binaries" >> "$bash_config"
                echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$bash_config"
                log "Added ~/.local/bin to bash PATH in $bash_config"
                warn "Please run 'source $bash_config' or restart your terminal"
            fi
        fi
    fi
}

main() {
    log "Cursor installer/updater for Sway WM with wmenu integration"

    install_deps

    if is_cursor_installed; then
        update_cursor
    else
        install_cursor
    fi

    fix_sway_integration

    log "All done! Cursor should now:"
    log "  - Appear in wmenu/wofi/bemenu and other launchers"
    log "  - Display proper icon in launchers"
    log "  - Run with Wayland optimizations"
    log "  - Be available as 'code' command"
    log ""
    log "You may need to reload Sway or restart applications for changes to take effect."
}

main "$@"
