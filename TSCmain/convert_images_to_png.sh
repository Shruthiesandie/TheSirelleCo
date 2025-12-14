#!/bin/bash

BASE_DIR="assets/images"

find "$BASE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.png" \) | while read -r file; do
  dir=$(dirname "$file")
  name=$(basename "$file")
  base="${name%.*}"

  # lowercase filename
  lower_base=$(echo "$base" | tr 'A-Z' 'a-z')
  output="$dir/$lower_base.png"

  # convert only if needed
  if [ "$file" != "$output" ]; then
    echo "Converting: $file → $output"
    magick "$file" "$output"
    rm "$file"
  fi
done