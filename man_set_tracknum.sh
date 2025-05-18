#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <audio-files...>"
  exit 1
fi

audio_files=("$@")

for file in "${audio_files[@]}"; do
  base_name=$(basename "$file" .m4a)

  echo "Could not determine track number for '$file'."
  tracknum=1
  read -p "Please enter the track number for '$file': " tracknum
  atomicparsley "$file" --tracknum "$tracknum" --overWrite
done
