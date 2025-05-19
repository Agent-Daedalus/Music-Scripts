#!/bin/bash

# Function to clean and format names
clean_name() {
  # Remove text between brackets and the preceding space
  local name="$1"
  local sed_commands="$2"

  if [ -n "$sed_commands" ]; then
    name=$(echo "$name" | sed "$sed_commands" 2>/dev/null)
    if [ $? -ne 0 ]; then
      echo "Error: Invalid sed argument(s): $sed_commands"
      return 1
    fi
  fi

  # Remove specific phrases
  name=$(echo "$name" | sed 's/ *(Explicit)//g')
  name=$(echo "$name" | sed 's/ *(Lyrics)//g')
  name=$(echo "$name" | sed 's/ *(Audio)//g')
  name=$(echo "$name" | sed 's/ *(Lyric Video)//g')
  name=$(echo "$name" | sed 's/ *(Official[^)]*)//g')
  name=$(echo "$name" | sed 's/ *(Visualizer)//g')
  name=$(echo "$name" | sed 's/[0-9]\{2\}\.//g')
  name=$(echo "$name" | sed 's/[0-9]\{2\}\ - //g')
  name=$(echo "$name" | sed 's/[0-9]\{2\}\ -//g')
  name=$(echo "$name" | sed 's/[0-9]\{1\}\.//g')

  name=$(echo "$name" | sed 's/ *\[[^]]*\]//g')
  name=$(echo "$name" | sed 's/^ *//')

  
  echo "$name"
}

# Function to process a file
process_file() {
  local file="$1"
  local artist="$2"
  local album="$3"
  local removed_phrase_list="$4"

  track_num=$(basename "$file" | sed -n 's/^\([0-9]\+\) -.*/\1/p')

  # Build sed command for removing phrases
  local remove_sed_command=""
  if [ -n "$removed_phrase_list" ]; then
    IFS=';' read -ra phrases <<< "$removed_phrase_list"
    for phrase in "${phrases[@]}"; do
      if [ -n "$phrase" ]; then
        remove_sed_command+=";s/ *$phrase *//g"
      fi
    done
  fi

  # Extract base name and clean it
  base_name=$(basename "$file")
  clean_base_name=$(clean_name "${base_name%.*}" "s/ *$artist - //g;s/ *$album - //g$remove_sed_command")

  output_dir=$(dirname "$file")
  output_file="$output_dir/${clean_base_name}.m4a"

  # Temporary file for the input to avoid name conflict
  temp_file="${file}.temp"
  mv "$file" "$temp_file"

  # Check the input file codec
  codec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$temp_file")

  # Prevent overwriting track num when blank
  track_args=""
  if [[ "$track_num" =~ ^[0-9]+$ ]]; then
    track_args=" -metadata track=$track_num"
  fi

  # Keep the original format (or copy if AAC to m4a)
  if [ "$codec" == "aac" ]; then
    ffmpeg -y -i "$temp_file" -metadata artist="$artist" -metadata title="$clean_base_name" -metadata album="$album" $track_args -c:v copy -c copy "$output_file" 2>> ffmpeg_logs.log
  else
    ffmpeg -y -i "$temp_file" -metadata artist="$artist" -metadata title="$clean_base_name" -metadata album="$album" $track_args -c:v copy -acodec copy "$output_file" 2>> ffmpeg_logs.log
  fi

  if [ $? -eq 0 ]; then
    # Delete the original file if successful
    rm "$temp_file"
  else
    # If failed, restore the original file name
    mv "$temp_file" "$file"
    echo "Conversion failed: $file"
  fi
}

parsed_artist=""
parsed_album=""
removed_phrases=""

# Parse flags
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --artist)
      parsed_artist="$2"
      removed_phrases+=";$2 - "
      shift
      shift
      ;;
    --album)
      parsed_album="$2"
      removed_phrases+=";$2 - "
      shift
      shift
      ;;
    --remove-phrase)
      removed_phrases+=";$2"
      shift
      shift
      ;;
    --help)
      echo "Usage: $0 [--artist <artist name>] [--album <album name>] [--remove-phrase <phrase>] <audio-files...>"
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

for file in "$@"; do
  process_file "$file" "$parsed_artist" "$parsed_album" "$removed_phrases"
done
