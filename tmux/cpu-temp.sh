#!/bin/bash

temp=$(osx-cpu-temp 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)

if [ -n "$temp" ] && [ "$temp" != "0.0" ]; then
    temp_int=${temp%.*}
    if [ "$temp_int" -ge 80 ]; then
        echo "#[fg=#D08472]cpu: ${temp}°"
    else
        echo "#[fg=#66666C]cpu: ${temp}°"
    fi
else
    cores=$(sysctl -n hw.ncpu)
    cpu_raw=$(ps -A -o %cpu | tail -n +2 | awk '{s+=$1} END {print s}')
    cpu=$(echo "$cpu_raw $cores" | awk '{printf "%02.0f", $1/$2}')
    
    if [ "${cpu#0}" -ge 80 ]; then
        echo "#[fg=#D08472]cpu: ${cpu}%"
    else
        echo "#[fg=#66666C]cpu: ${cpu}%"
    fi
fi
