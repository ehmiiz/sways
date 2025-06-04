# Sway Setup - Complete Screenshot & Workflow Configuration

## Quick Setup for New PC

### 1. Run the setup script:
```bash
./sway-setup.sh
```

### 2. Install Cursor IDE (optional):
```bash
./cursor-linux-installer-sway.sh
```

### 3. Apply high-DPI scaling fixes:
```bash
./scaling-fix.sh
```

### 4. Copy your sway config:
```bash
cp config ~/.config/sway/config
```

### 5. Reload Sway:
```bash
swaymsg reload
```

### 6. Log out and back in:
Log out and back in (or reboot) to apply all environment variables and scaling fixes.

### 7. Start Sway (if not already running):
```bash
sway
```

## Scripts Included

### sway-setup.sh
Main installation script that installs all required packages for the Sway environment.

### cursor-linux-installer-sway.sh
Installs Cursor IDE with proper Sway/Wayland integration:
- Installs Cursor with Wayland optimizations
- Sets up proper desktop file for dmenu/rofi
- Creates icon integration
- Adds 'cursor' command wrapper

### scaling-fix.sh
Applies system-wide high-DPI scaling fixes:
- Sets environment variables for proper scaling
- Configures Flatpaks to use Wayland
- Fixes rofi DPI settings
- Ensures all applications scale properly on high-DPI displays

## Screenshot Workflow

| Keybinding | Action |
|------------|--------|
| `Print` | Full screenshot → saved to ~/Pictures/ |
| `Super+Print` | Area selection → saved to ~/Pictures/ |
| `Ctrl+Shift+b` | Area selection → edit in swappy |
| `Ctrl+Print` | Full screenshot → clipboard |

## Image Viewing

| Keybinding | Action |
|------------|--------|
| `Super+i` | Open image viewer (imv) in ~/Pictures/ |
| `Super+Shift+i` | List screenshots in terminal |

### Terminal commands:
```bash
# View all screenshots
imv ~/Pictures/

# View specific screenshot
imv ~/Pictures/screenshot-2024-01-01-123456.png

# List screenshots
ls ~/Pictures/*.png
```

## Features

- **Grey-themed borders** for clean appearance
- **Swedish keyboard layout** configured
- **Touchpad optimized** for Framework laptop
- **Wayland-native tools** for best performance
- **Auto-timestamped files** for easy organization
- **High-DPI scaling** for crisp display on Framework 13
- **System-wide environment variables** for consistent scaling
- **Flatpak Wayland integration** for all applications

## Files Included

- `sway-setup.sh` - Main installation script
- `cursor-linux-installer-sway.sh` - Cursor IDE installer with Sway integration
- `scaling-fix.sh` - High-DPI scaling configuration script
- `config` - Main Sway configuration file
- `README.md` - This documentation

## Dependencies Installed

- sway, alacritty, rofi
- grim, slurp, wl-clipboard, swappy
- imv, otf-font-awesome
- brightnessctl, pactl