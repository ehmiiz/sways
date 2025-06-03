# Sway Setup - Complete Screenshot & Workflow Configuration

## 🚀 Quick Setup for New PC

### 1. Run the setup script:
```bash
./sway-setup.sh
```

### 2. Copy your sway config:
```bash
cp /path/to/backup/sway/config ~/.config/sway/config
```

### 3. Start Sway:
```bash
sway
```

## 📸 Screenshot Workflow

| Keybinding | Action |
|------------|--------|
| `Print` | Full screenshot → saved to ~/Pictures/ |
| `Super+Print` | Area selection → saved to ~/Pictures/ |
| `Ctrl+Shift+b` | Area selection → edit in swappy |
| `Ctrl+Print` | Full screenshot → clipboard |

## 🖼️ Image Viewing

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

## 🎨 Features

- **Grey-themed borders** for clean appearance
- **Swedish keyboard layout** configured
- **Touchpad optimized** for Framework laptop
- **Wayland-native tools** for best performance
- **Auto-timestamped files** for easy organization

## 📁 Files Included

- `sway-setup.sh` - Installation script
- `~/.config/sway/config` - Main Sway configuration
- `~/.config/swappy/config` - Screenshot editor settings

## 🔧 Dependencies Installed

- sway, alacritty, rofi
- grim, slurp, wl-clipboard, swappy
- imv, otf-font-awesome
- brightnessctl, pactl 