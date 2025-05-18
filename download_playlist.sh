#!/bin/bash

# Define defaults 
output_format="%(title)s.%(ext)s"
yt_dlp_options=""
extension="m4a"

# Parse flags
while [[ "$#" -gt 0 ]]; do
  case "$1" in --include-index)
      output_format="%(playlist_index)02d - %(title)s.%(ext)s"
      shift
      ;;
    --include-metadata)
      yt_dlp_options+=("--add-metadata" "--embed-metadata")
      shift
      ;;
    --include-thumbnail)
      yt_dlp_options+=("--embed-thumbnail")
      shift
      ;;
    --output-dir)
      download_dir="$2"
      shift
      shift
      ;;
    --format)
      extension="$2"
      shift
      shift
      ;;
    --help)
      echo "Usage: $0 [--include-index] [--include-metadata] [--include-thumbnail] [--output-dir <folder>] <artist> <album> <link>"
      echo "  --output-dir <folder>    : Set the base output folder for downloaded music (default: $HOME/Music/[artist]/[album])"
      echo "  --include-index          : Include track numbers in filenames"
      echo "  --include-metadata       : Embed metadata into audio files"
      echo "  --include-thumbnail      : Embed thumbnails into audio files"
      echo "  --format <extension>     : Specify the desired audio format for download (default: m4a)"
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

# check if required arguments are set
if [ -z "$artist" ] || [ -z "$album" ] || [ -z "$link" ]; then
  echo "error: artist, album, and playlist link are required."
  exit 1
fi

if [ -z "$download_dir" ]; then
  download_dir="$HOME/Music/$artist/$album"
fi

# create the directory if it doesn't exist
mkdir -p "$download_dir"

# run yt-dlp for the playlist with the chosen output format and options
echo "downloading playlist: $link to directory: $download_dir"
yt-dlp -x --audio-format "$extension" "$yt_dlp_options" -o "$download_dir/$output_format" "$link"

echo "finished downloading: $link"

