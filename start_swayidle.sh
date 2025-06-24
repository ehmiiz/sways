#!/bin/bash

# swayidle management script
# This script ensures only one instance of swayidle is running

SWAYIDLE_PID_FILE="/tmp/swayidle.pid"

# Function to kill existing swayidle
kill_swayidle() {
    if [ -f "$SWAYIDLE_PID_FILE" ]; then
        local pid=$(cat "$SWAYIDLE_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo "Killed existing swayidle (PID: $pid)"
        fi
        rm -f "$SWAYIDLE_PID_FILE"
    fi
}

# Kill any existing swayidle instance
kill_swayidle

# Start new swayidle instance
swayidle -w \
    timeout 300 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock -f -c 000000' &

# Save PID for future management
echo $! > "$SWAYIDLE_PID_FILE"
echo "Started swayidle (PID: $!)" 