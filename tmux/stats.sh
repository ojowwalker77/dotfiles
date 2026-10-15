#!/bin/bash

ssd=$(df -H /System/Volumes/Data | awk 'NR==2 {gsub(/%/,"",$5); printf "%02d", $5}')

if [ "${ssd#0}" -ge 90 ]; then
    echo "#[fg=colour1]ssd: ${ssd}%"
else
    echo "#[fg=colour8]ssd: ${ssd}%"
fi
