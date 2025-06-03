#!/bin/bash

# Sway Screenshot & Tools Setup Script
# Run this script on a new Arch Linux system to set up the complete workflow

echo "🚀 Setting up Sway screenshot workflow and tools..."

# Install all required packages
echo "📦 Installing dependencies..."
sudo pacman -S --needed \
    sway \
    alacritty \
    rofi \
    grim \
    slurp \
    wl-clipboard \
    swappy \
    otf-font-awesome \
    imv \
    brightnessctl \
    pactl

echo "📁 Creating config directories..."
mkdir -p ~/.config/sway
mkdir -p ~/.config/swappy
mkdir -p ~/Pictures

echo "⚙️  Creating swappy configuration..."
cat > ~/.config/swappy/config << 'EOF'
[Default]
save_dir=$HOME/Pictures
save_filename_format=swappy-%Y%m%d-%H%M%S.png
show_panel=true
line_size=5
text_size=20
text_font=sans-serif
paint_mode=brush
early_exit=false
fill_shape=false
EOF

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Copy your sway config to ~/.config/sway/config"
echo "2. Run 'sway' to start"
echo ""
echo "🎯 Available commands:"
echo "  • Print Key: Full screenshot to ~/Pictures/"
echo "  • Super+Print: Area selection to ~/Pictures/"
echo "  • Ctrl+Shift+b: Area selection → edit in swappy"
echo "  • Ctrl+Print: Full screenshot to clipboard"
echo "  • imv ~/Pictures/*.png: View screenshots"
echo ""
echo "🎨 Your grey-themed Sway setup is ready!" 