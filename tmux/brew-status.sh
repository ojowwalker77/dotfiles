#!/bin/bash

# Cache file - brew outdated is slow, cache for 30 min
CACHE_FILE="/tmp/tmux-brew-status"
CACHE_MAX_AGE=1800

# Check if cache exists and is fresh
if [ -f "$CACHE_FILE" ]; then
    cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE")))
    if [ "$cache_age" -lt "$CACHE_MAX_AGE" ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Run brew outdated
outdated=$(brew outdated --quiet 2>/dev/null)
count=$(echo "$outdated" | grep -c . 2>/dev/null || echo "0")

if [ "$count" -eq 0 ] || [ -z "$outdated" ]; then
    result="#[fg=#666666]brew: all up-to-date"
else
    result="#[fg=#666666]brew: $count updates available"
fi

echo "$result" > "$CACHE_FILE"
echo "$result"
