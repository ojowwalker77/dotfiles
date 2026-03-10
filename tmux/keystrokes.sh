#!/bin/bash

FILE="$HOME/.keystroke_count"

if [ ! -f "$FILE" ]; then
    echo "#[fg=#666666]⌨ --"
    exit 0
fi

# Read date and count
read -r date count < "$FILE"

# Check if today
today=$(date +%Y-%m-%d)
if [ "$date" != "$today" ]; then
    echo "#[fg=#666666]⌨ 0"
    exit 0
fi

# Format count with K for thousands
if [ "$count" -ge 1000 ]; then
    formatted=$(echo "$count" | awk '{printf "%.1fk", $1/1000}')
else
    formatted=$count
fi

# Color based on activity
if [ "$count" -lt 1000 ]; then
    echo "#[fg=#666666]⌨ $formatted"
elif [ "$count" -lt 5000 ]; then
    echo "#[fg=#f1fa8c]⌨ $formatted"
else
    echo "#[fg=#50fa7b]⌨ $formatted"
fi
