#!/bin/bash

if [[ "$#" -lt 2 ]]; then
    printf "Usage: render-svg <file> <width> [height]\n"
    exit 1
fi

file_in="$1"
file_out="$(basename "$file_in" .svg).png"

width="$2"

if [[ "$#" -ge 3 ]]; then
    height="$3"
    rsvg-convert -w "$width" -h "$height" "$file_in" > "$file_out"
else
    rsvg-convert -w "$width" "$file_in" > "$file_out"
fi

