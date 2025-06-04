#!/bin/bash

# Sway High-DPI Scaling Fix Script - Clean System-wide approach
echo "Applying clean system-wide high-DPI scaling fixes for Sway..."

# 1. Backup current config (if not already done)
if [ ! -f config.backup ]; then
    cp config config.backup
    echo "Config backed up to config.backup"
else
    echo "Backup already exists, skipping..."
fi

# 2. Update Sway config with proper rofi DPI
echo "Updating Sway config with proper scaling..."
sed -i 's/set $menu "rofi -show drun -show-icons -modi drun,run,window"/set $menu "rofi -show drun -show-icons -modi drun,run,window -dpi 192"/' config

# 3. Check if scaling config is already present
if ! grep -q "High-DPI Scaling Configuration" config; then
    echo "Adding scaling configuration to Sway config..."
    cat >> config << 'EOF'

### High-DPI Scaling Configuration
# Display scaling
output eDP-1 scale 2
output * scale 2
EOF
else
    echo "Scaling configuration already present in config"
fi

# 4. Create system-wide environment file for session
echo "Creating system-wide scaling environment..."
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/scaling.conf << 'EOF'
# High-DPI scaling environment variables
GDK_SCALE=2
GDK_DPI_SCALE=0.5
QT_AUTO_SCREEN_SCALE_FACTOR=1
QT_SCALE_FACTOR=2
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
XCURSOR_SIZE=32

# Force Wayland for supported applications
MOZ_ENABLE_WAYLAND=1
ELECTRON_OZONE_PLATFORM_HINT=wayland

# Backend preferences
GDK_BACKEND=wayland,x11
QT_QPA_PLATFORM=wayland;xcb
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland
EOF

# 5. Create fish shell environment (if fish is being used)
if command -v fish &> /dev/null; then
    echo "Setting up fish shell environment..."
    mkdir -p ~/.config/fish/conf.d
    cat > ~/.config/fish/conf.d/scaling.fish << 'EOF'
# High-DPI scaling environment variables
set -gx GDK_SCALE 2
set -gx GDK_DPI_SCALE 0.5
set -gx QT_AUTO_SCREEN_SCALE_FACTOR 1
set -gx QT_SCALE_FACTOR 2
set -gx QT_WAYLAND_DISABLE_WINDOWDECORATION 1
set -gx XCURSOR_SIZE 32

# Force Wayland for supported applications
set -gx MOZ_ENABLE_WAYLAND 1
set -gx ELECTRON_OZONE_PLATFORM_HINT wayland

# Backend preferences
set -gx GDK_BACKEND "wayland,x11"
set -gx QT_QPA_PLATFORM "wayland;xcb"
set -gx SDL_VIDEODRIVER wayland
set -gx CLUTTER_BACKEND wayland
EOF
fi

# 6. Configure ALL Flatpaks to always use Wayland
echo "Configuring ALL Flatpak applications to use Wayland..."
flatpak override --user --socket=wayland --env=GDK_BACKEND=wayland --env=QT_QPA_PLATFORM=wayland --env=SDL_VIDEODRIVER=wayland --env=GDK_SCALE=2 --env=ELECTRON_OZONE_PLATFORM_HINT=wayland 2>/dev/null || echo "Note: Flatpak overrides require flatpak to be running"

# 7. Create simple 'cursor' wrapper for Cursor AppImage only
if command -v cursor &> /dev/null; then
    echo "Creating 'cursor' wrapper for Cursor..."
    mkdir -p ~/.local/bin
    cat > ~/.local/bin/cursor << 'EOF'
#!/bin/bash
cursor "$@"
EOF
    chmod +x ~/.local/bin/cursor
    
    # Add to PATH if needed
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo "Adding ~/.local/bin to PATH..."
        if [ -f ~/.config/fish/config.fish ]; then
            echo "set -gx PATH ~/.local/bin \$PATH" >> ~/.config/fish/config.fish
        else
            mkdir -p ~/.config/fish
            echo "set -gx PATH ~/.local/bin \$PATH" > ~/.config/fish/config.fish
        fi
    fi
else
    echo "Cursor not found, skipping 'cursor' wrapper creation"
fi

# 8. Clean up any unnecessary files we might have created
echo "Cleaning up unnecessary files..."
[ -f ~/.local/bin/cursor-wayland ] && rm ~/.local/bin/cursor-wayland && echo "Removed cursor-wayland wrapper"
[ -f ~/.local/bin/signal-wayland ] && rm ~/.local/bin/signal-wayland && echo "Removed signal-wayland wrapper"
[ -f ~/.local/bin/code ] && rm ~/.local/bin/code && echo "Removed code wrapper"

# 9. Instructions
echo ""
echo "Clean system-wide scaling fixes applied successfully!"
echo ""
echo "What was configured:"
echo "- System-wide environment variables for all applications"
echo "- Fish shell environment variables"
echo "- Rofi DPI setting in Sway config"
echo "- ALL Flatpaks configured to use Wayland"
echo "- Simple 'cursor' command for Cursor AppImage"
echo ""
echo "Next steps:"
echo "1. Copy config to Sway: cp config ~/.config/sway/config"
echo "2. Reload Sway: swaymsg reload"
echo "3. Log out and log back in for environment variables to take effect"
echo "4. All apps should scale properly without individual wrappers"
echo "5. Use 'cursor' to launch Cursor"
echo ""
echo "Troubleshooting:"
echo "- Check display: swaymsg -t get_outputs"
echo "- Test environment: echo \$GDK_SCALE (should show 2)"
echo "- All Flatpaks now use Wayland by default"
