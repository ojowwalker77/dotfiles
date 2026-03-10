#!/bin/bash

# Check if Music is running (without launching it)
if ! pgrep -x "Music" > /dev/null; then
    echo ""
    exit 0
fi

# Single AppleScript call for everything (much faster than 3 separate calls)
info=$(osascript -e '
tell application "Music"
    if player state is playing then
        set trackName to name of current track
        set artistName to artist of current track
        return trackName & " - " & artistName
    end if
end tell
' 2>/dev/null)

# Exit if nothing playing or empty result
if [ -z "$info" ]; then
    echo ""
    exit 0
fi

# Truncate if too long (max 35 chars)
if [ ${#info} -gt 35 ]; then
    info="${info:0:32}..."
fi

echo "♫ $info"
