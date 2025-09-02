#!/usr/bin/env python3
"""
Installs and configures applications.
"""

import subprocess

dict = {
    "cursor": {
        "command": "cursor",
        "description": "Cursor IDE",
        "source": "AppImage",
        "desktop_file": "cursor.desktop",
        "mime_types": []
    },
    "firefox": {
        "command": "firefox",
        "description": "Default: web browser",
        "source": "pacman",
        "desktop_file": "firefox.desktop",
        "mime_types": ["text/html", "text/xml", "application/xhtml+xml", "x-scheme-handler/http", "x-scheme-handler/https"]
    },
    "obsidian": {
        "command": "flatpak run md.obsidian.Obsidian",
        "description": "Obsidian note-taking app",
        "source": "flatpak",
        "desktop_file": "md.obsidian.Obsidian.desktop",
        "mime_types": []
    },
    "imv": {
        "command": "imv",
        "description": "Default: image viewer",
        "source": "pacman",
        "desktop_file": "imv.desktop",
        "mime_types": ["image/jpeg", "image/png", "image/gif", "image/bmp", "image/webp", "image/tiff"]
    },
    "alacritty": {
        "command": "alacritty",
        "description": "Terminal",
        "source": "pacman",
        "desktop_file": "Alacritty.desktop",
        "mime_types": []
    },
    "mpv": {
        "command": "mpv",
        "description": "Default: Video player",
        "source": "pacman",
        "desktop_file": "mpv.desktop",
        "mime_types": ["video/mp4", "video/x-msvideo", "video/quicktime", "video/webm", "video/x-matroska", "audio/mpeg", "audio/x-wav"]
    },
    "nvim": {
        "command": "nvim",
        "description": "Default: text editor",
        "source": "pacman",
        "desktop_file": "nvim.desktop",
        "mime_types": ["text/plain", "text/x-c", "text/x-python", "text/x-shellscript", "application/json"]
    }
}

def is_pacman_package_installed(package_name):
    """Check if a pacman package is already installed."""
    try:
        result = subprocess.run(["pacman", "-Q", package_name], 
                              capture_output=True, text=True)
        return result.returncode == 0
    except Exception:
        return False

def install_pacman_package(package_name):
    """Install a pacman package if not already installed."""
    if is_pacman_package_installed(package_name):
        print(f"✓ {package_name} is already installed")
        return True
    
    print(f"Installing {package_name} via pacman...")
    try:
        result = subprocess.run(["sudo", "pacman", "-S", "--needed", package_name], 
                              check=True)
        print(f"✓ Successfully installed {package_name}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ Failed to install {package_name}: {e}")
        return False

def set_default_mime_types(app_name, app_data):
    """Set default MIME types for an application."""
    if not app_data['mime_types']:
        print(f"No MIME types configured for {app_name}")
        return
    
    desktop_file = app_data['desktop_file']
    print(f"Setting {app_name} as default for {len(app_data['mime_types'])} MIME types...")
    
    for mime_type in app_data['mime_types']:
        try:
            result = subprocess.run(["xdg-mime", "default", desktop_file, mime_type], 
                                  check=True, capture_output=True, text=True)
            print(f"  ✓ Set {mime_type} -> {desktop_file}")
        except subprocess.CalledProcessError as e:
            print(f"  ✗ Failed to set {mime_type}: {e}")

for app in dict:
    #print(f"{app}: {dict[app]['description']} ({dict[app]['source']})")
    if dict[app]['description'].startswith("Default:"):
        print(f"{app}: {dict[app]['description']} ({dict[app]['source']})")
        # ensure that the app is installed
        if dict[app]['source'] == "pacman":
            if install_pacman_package(app):
                set_default_mime_types(app, dict[app])
        elif dict[app]['source'] == "flatpak":
            result = subprocess.run(["flatpak", "install", "-y", app])
            if result.returncode == 0:
                set_default_mime_types(app, dict[app])
        elif dict[app]['source'] == "AppImage":
            subprocess.run(["chmod", "+x", app])
            subprocess.run(["./" + app])
            set_default_mime_types(app, dict[app])