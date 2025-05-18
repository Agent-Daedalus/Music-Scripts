#!/bin/bash

# Define default values
include_metadata=false
include_thumbnail=false
include_index=false

# Define the music directory
music_dir="$HOME/Music/$artist/$album"

# Parse flags
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --include-index)
      include_index=true
      shift # Move to the next argument
      ;;
    --include-metadata)
      include_metadata=true
      shift
      ;;
    --include-thumbnail)
      include_thumbnail=true
      shift
      ;;
    --help)
      echo "Usage: $0 [--include-index] [--include-metadata] [--include-thumbnail] <artist> <album> <link>"
      exit 0
      ;;
    *)
      # Handle positional arguments
      if [ -z "$artist" ]; then
        artist="$1"
      elif [ -z "$album" ]; then
        album="$1"
      elif [ -z "$link" ]; then
        link="$1"
      else
        echo "Unexpected argument: $1"
        exit 1
      fi
      shift
      ;;
  esac
done

# Check if required arguments are set
if [ -z "$artist" ] || [ -z "$album" ] || [ -z "$link" ]; then
  echo "Error: Artist, album, and playlist link are required."
  exit 1
fi

# Set the yt-dlp output format based on the flag
if [ "$include_index" = true ]; then
  output_format="%(playlist_index)02d - %(title)s.%(ext)s"
else
  output_format="%(title)s.%(ext)s"
fi

if [ "$include_metadata" = true ]; then
  yt_dlp_options+=("--add-metadata" "--embed-metadata")
fi

if [ "$include_thumbnail" = true ]; then
  yt_dlp_options+=("--embed-thumbnail")
fi

# Create the directory if it doesn't exist
mkdir -p "$music_dir/$artist/$album"

# Run yt-dlp for the playlist with the chosen output format and options
echo "Downloading playlist: $link to directory: $music_dir"
yt-dlp -x --audio-format "m4a" -o "$music_dir/$artist/$album/$output_format" "$link"

echo "Finished downloading: $link"

