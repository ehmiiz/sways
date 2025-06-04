#!/usr/bin/env python3
"""
Sway Screenshot & Tools Setup Script

Run this script on a new Arch Linux system to set up the complete workflow.
"""

import subprocess
import sys
from pathlib import Path


def run_command(command, check=True):
    """
    Execute a shell command and handle errors.
    
    Args:
        command (list): Command to execute as a list of strings
        check (bool): Whether to raise exception on non-zero exit code
        
    Returns:
        subprocess.CompletedProcess: Result of the command execution
    """
    try:
        result = subprocess.run(command, check=check, capture_output=True, text=True)
        return result
    except subprocess.CalledProcessError as e:
        print(f"❌ Error running command: {' '.join(command)}")
        print(f"Error: {e.stderr}")
        if check:
            sys.exit(1)
        return e


def install_packages():
    """Install all required packages using pacman."""
    print("📦 Installing dependencies...")
    
    packages = [
        'sway',
        'alacritty', 
        'rofi',
        'grim',
        'slurp',
        'wl-clipboard',
        'swappy',
        'otf-font-awesome',
        'imv',
        'brightnessctl',
        'libpulse'
    ]
    
    command = ['sudo', 'pacman', '-S', '--needed'] + packages
    run_command(command)


def create_directories():
    """Create necessary configuration directories."""
    print("📁 Creating config directories...")
    
    directories = [
        Path.home() / '.config' / 'sway',
        Path.home() / '.config' / 'swappy',
        Path.home() / 'Pictures'
    ]
    
    for directory in directories:
        directory.mkdir(parents=True, exist_ok=True)


def create_swappy_config():
    """Create swappy configuration file."""
    print("📁 Creating swappy configuration...")
    
    config_content = """[Default]
save_dir=$HOME/Pictures
save_filename_format=swappy-%Y%m%d-%H%M%S.png
show_panel=true
line_size=5
text_size=20
text_font=sans-serif
paint_mode=brush
early_exit=false
fill_shape=false
"""
    
    config_path = Path.home() / '.config' / 'swappy' / 'config'
    config_path.write_text(config_content)


def print_completion_info():
    """Print setup completion information and next steps."""
    print("✅ Setup complete!")
    print("")
    print("📋 Next steps:")
    print("1. Copy your sway config to ~/.config/sway/config")
    print("2. Run 'sway' to start")
    print("")
    print("Available commands:")
    print("  • Print Key: Full screenshot to ~/Pictures/")
    print("  • Super+Print: Area selection to ~/Pictures/")
    print("  • Ctrl+Shift+b: Area selection → edit in swappy")
    print("  • Ctrl+Print: Full screenshot to clipboard")
    print("  • imv ~/Pictures/*.png: View screenshots")
    print("")
    print("🎨 Your grey-themed Sway setup is ready!")


def main():
    """Main function to orchestrate the setup process."""
    print("Setting up Sway screenshot workflow and tools...")
    
    try:
        install_packages()
        create_directories()
        create_swappy_config()
        print_completion_info()
    except KeyboardInterrupt:
        print("\n❌ Setup interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected error during setup: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main() 