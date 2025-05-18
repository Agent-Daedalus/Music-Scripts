#!/bin/bash

# Check if the user provided the output file and at least one music file
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <output_file> <path_to_music_file...>"
  exit 1
fi

output_file="$1"         # First argument is the output file
shift                    # Shift to get the remaining arguments as music files

# Ensure the output file exists or create it
touch "$output_file"

# Loop through all provided music files
for music_file in "$@"; do
  if [[ -f "$music_file" ]]; then
    # Extract the title by removing the file extension
    title=$(basename "$music_file" | sed 's/\.[^.]*$//')

    # Replace percent-encoded characters back to original characters
    link=$(echo "$music_file" | sed 's/~/%7E/g' | sed 's/ /%20/g' | sed 's/(/%28/g' | sed 's/)/%29/g' | sed 's/:/\\:/g' | sed 's/&/\\&/g' | sed 's#/home/daedalus#~#g' | sed 's/'"'"'/\\'\''/g')

    # Append the formatted line to the document
    echo "[$title]($link)" >> "$output_file"
    echo "Appended: [$title]($link) to $output_file"
  else
    echo "File $music_file does not exist."
  fi
done
