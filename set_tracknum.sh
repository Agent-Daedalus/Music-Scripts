#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <tracklist> <audio-files...>"
  exit 1
fi

# Levenshtein distance function using awk
levenshtein() {
  local s1="$1"
  local s2="$2"
  
  awk -v s1="$s1" -v s2="$s2" '
    BEGIN {
      n = length(s1)
      m = length(s2)
      for (i = 0; i <= n; i++) d[i, 0] = i
      for (j = 0; j <= m; j++) d[0, j] = j
      for (i = 1; i <= n; i++) {
        for (j = 1; j <= m; j++) {
          cost = (substr(s1, i, 1) == substr(s2, j, 1)) ? 0 : 1
          d[i, j] = min(d[i-1, j] + 1, d[i, j-1] + 1, d[i-1, j-1] + cost)
        }
      }
      print d[n, m]
    }
    function min(x, y, z) {
      if (x <= y && x <= z) return x
      if (y <= x && y <= z) return y
      return z
    }'
}

tracklist_file="$1"
mapfile -t tracklist < "$tracklist_file"
shift
audio_files=("$@")

threshold=0

for file in "${audio_files[@]}"; do
  base_name=$(basename "$file" .m4a)

  found=false

  tracknum=1
  for track in "${tracklist[@]}"; do
    track_title="$track"

    if [[ "$base_name" == "$track_title" ]]; then
      atomicparsley "$file" --tracknum "$tracknum" --overWrite
      found=true
      break
    fi
    tracknum=$((tracknum + 1))
  done

  tracknum=1
  for track in "${tracklist[@]}"; do
    track_title="$track"
    score=$(levenshtein "$track_title" "$base_name")
    if [[ "$score" -lt "$threshold" ]]; then
      atomicparsley "$file" --tracknum "$tracknum" --overWrite
      found=true
      break
    fi
    tracknum=$((tracknum + 1))
  done

  if [ "$found" = false ]; then
    echo "Could not determine track number for '$file'."
    echo "Tracklist:"
    tracknum=1
    for track in "${tracklist[@]}"; do
      echo "$tracknum. $track"
      tracknum=$((tracknum + 1))
    done
    read -p "Please enter the track number for '$file': " tracknum
    atomicparsley "$file" --tracknum "$tracknum" --overWrite
  fi
done
