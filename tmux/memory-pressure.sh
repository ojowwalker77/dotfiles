#!/bin/bash

free=$(memory_pressure 2>/dev/null | grep "System-wide memory free percentage" | awk '{print $5}' | tr -d '%')

if [ -z "$free" ]; then
    echo ""
    exit 0
fi

used=$((100 - free))
used_fmt=$(printf "%02d" $used)

if [ "$used" -ge 80 ]; then
    echo "#[fg=#ff5555]mem: ${used_fmt}%"
else
    echo "#[fg=#666666]mem: ${used_fmt}%"
fi
