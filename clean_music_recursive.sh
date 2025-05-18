#!/bin/bash

# Function to clean and format names
clean_name() {
  # Remove text between brackets and the preceding space
  local name="$1"
  local arg="$2"
  name=$(echo "$name" | sed 's/ *\[[^]]*\]//g')
  name=$(echo "$name" | sed 's/^ *//')
  # Remove specific phrases
  name=$(echo "$name" | sed 's/ *(Explicit)//g' | sed 's/ *(Lyrics)//g')
  name=$(echo "$name" | sed 's/ *(Audio)//g')
  name=$(echo "$name" | sed 's/ *(Lyric Video)//g')
  name=$(echo "$name" | sed 's/ *(Official[^)]*)//g')
  name=$(echo "$name" | sed 's/ *(Visualizer)//g')
  name=$(echo "$name" | sed 's/[0-9]\{2\}\.//g')
  name=$(echo "$name" | sed 's/[0-9]\{2\}\ - //g')
  name=$(echo "$name" | sed 's/[0-9]\{2\}\ -//g')
  name=$(echo "$name" | sed 's/[0-9]\{1\}\.//g')

  # If the second argument is provided, apply it
  if [ -n "$arg" ]; then
    name=$(echo "$name" | sed "$arg" 2>/dev/null)
    if [ $? -ne 0 ]; then
      echo "Error: Invalid sed argument: $arg"
      return 1
    fi
  fi
  echo "$name"
}

# Function to process a file
process_file() {
  local file="$1"
  local dir="$2"
  local album="$3"

  track_num=$(basename "$file" | sed -n 's/^\([0-9]\+\) -.*/\1/p')

  # Extract base name and clean it
  base_name=$(basename "$file")
  clean_base_name=$(clean_name "${base_name%.*}" "s/ *$artist - //g")

  output_dir=$(dirname "$file")
  output_file="$output_dir/${clean_base_name}.m4a"

  # Temporary file for the input to avoid name conflict
  temp_file="${file}.temp"

  # Rename the original file to the temporary file
  mv "$file" "$temp_file"

  # Check the input file codec
  codec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$temp_file")

  track_args=""
  if [[ "$track_num" =~ ^[0-9]+$ ]]; then
    track_args=" -metadata track=$track_num"
  fi

  # Convert file to M4A with metadata, using copy if codec is AAC
  if [ "$codec" == "aac" ]; then
    ffmpeg -y -i "$temp_file" -metadata artist="$artist" -metadata title="$clean_base_name" -metadata album="$album" $track_args -c:v copy -c copy "$output_file" 2>> ffmpeg_errors.log
  else
    ffmpeg -y -i "$temp_file" -metadata artist="$artist" -metadata title="$clean_base_name" -metadata album="$album" $track_args -c:v copy -codec:a aac -b:a 192k "$output_file" 2>> ffmpeg_errors.log
  fi

  # Check if the conversion was successful
  if [ $? -eq 0 ]; then
    # Delete the original file after conversion
    rm "$temp_file"
  else
    # If conversion failed, restore the original file name
    mv "$temp_file" "$file"
  fi
}

# Function to traverse directories
traverse_directory() {
  local dir="$1"
  local album="$2"

  for file in "$dir"/*; do
    if [ -d "$file" ]; then
      # If it's a directory, recurse into it
      album_name=$(basename "$file")
      traverse_directory "$file" "$album_name"
    elif [[ "$file" == *.opus || "$file" == *.m4a || "$file" == *.mp3 || "$file" == *.weba ]]; then
      # If it's an audio file, process it
      process_file "$file" "$dir" "$album"
    fi
  done
}

main_directory="$1"
artist="$2"
album="$3"

if [ -z "$artist" ]; then
  artist=$(basename "$main_directory")
fi

if [ -z "$album" ]; then
  album=""
fi

echo "$artist"

# Main execution
if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-artist-directory>"
  exit 1
fi

log_file="processing.log"

traverse_directory "$main_directory" "$album"
