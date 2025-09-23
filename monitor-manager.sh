#!/bin/bash

# Monitor manager for Framework 13 AMD with HDMI TV
# When external monitor connected via HDMI/USB-C - disable laptop screen and use TV only
# When disconnected - enable laptop screen

echo "=== Framework 13 AMD Monitor Manager ==="
echo "Checking for external monitors..."

# Debug: Show all outputs
echo "All outputs:"
swaymsg -t get_outputs | jq -r '.[] | "\(.name): active=\(.active)"'

# Get list of all connected and active external outputs (Framework 13 AMD uses DP-X outputs for HDMI via USB-C)
EXTERNAL_OUTPUTS=$(swaymsg -t get_outputs | jq -r '.[] | select(.name != "eDP-1" and .active == true) | .name')

if [ -n "$EXTERNAL_OUTPUTS" ]; then
    echo "External monitor detected: $EXTERNAL_OUTPUTS"
    echo "Disabling laptop screen and configuring TV as only display"
    
    # Disable laptop screen
    swaymsg output eDP-1 disable
    
    # Configure each external output (TV)
    for output in $EXTERNAL_OUTPUTS; do
        echo "Configuring $output for TV display"
        
        # Check if this is the specific MF27165QHD monitor for 120Hz
        MONITOR_MODEL=$(swaymsg -t get_outputs | jq -r ".[] | select(.name == \"$output\") | .model")
        if [ "$MONITOR_MODEL" = "MF27165QHD" ]; then
            echo "Detected MF27165QHD monitor - configuring for 120Hz"
            swaymsg output "$output" mode 2560x1440@120Hz scale 1 position 0 0
        else
            # Try common TV resolutions - prioritize 4K, then 1080p
            swaymsg output "$output" mode 3840x2160@60Hz scale 1 position 0 0 || \
            swaymsg output "$output" mode 1920x1080@60Hz scale 1 position 0 0 || \
            swaymsg output "$output" mode 1920x1080@30Hz scale 1 position 0 0
        fi
        
        # Set TV as primary workspace target
        swaymsg workspace 1
        swaymsg focus output "$output"
    done
    
    echo "TV is now the only active display"
else
    echo "No external monitor detected - enabling laptop screen"  
    swaymsg output eDP-1 enable
    swaymsg output eDP-1 mode 2880x1920@120Hz scale 2 position 0 0
fi

echo "Monitor configuration complete"
