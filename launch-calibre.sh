#!/bin/bash
# Launch Calibre with proper Wayland scaling
export QT_QPA_PLATFORM=wayland
export QT_SCALE_FACTOR=1
export QT_AUTO_SCREEN_SCALE_FACTOR=0
exec calibre "$@"
