#!/usr/bin/env bash

weather=$(curl -s wttr.in/Torre_da_Marinha?format=3)

if [ $(echo "$weather" | grep -E "(Unknown|curl|HTML)" | wc -l) -gt 0 ]; then
    echo "WEATHER UNAVAILABLE"
else
    echo "$weather" | awk '{print $3" "$2}'
fi
