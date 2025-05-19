#!/bin/bash

# Define an array of directory and playlist pairs
# Format: "directory|playlist_url"
playlists=(
  "/home/daedalus/Podcasts/Lemonade Stand/|https://podcasts.apple.com/us/podcast/are-we-getting-dumber-ep-003-lemonade-stand/id1799868725?i=1000700170581"
  "/home/daedalus/Podcasts/Lemonade Stand/|https://podcasts.apple.com/us/podcast/we-are-moving-to-japan-ep-004-lemonade-stand/id1799868725?i=1000701159102"
  "/home/daedalus/Podcasts/Lemonade Stand/|https://podcasts.apple.com/us/podcast/liberation-day-changes-everything-ep-005-lemonade-stand/id1799868725?i=1000702109279"
  "/home/daedalus/Podcasts/Lemonade Stand/|https://podcasts.apple.com/us/podcast/the-trade-wars-have-begun-ep-006-lemonade-stand/id1799868725?i=1000703078551"
  "/home/daedalus/Podcasts/Lemonade Stand/|https://podcasts.apple.com/us/podcast/the-war-on-chatgpt-ep-007-lemonade-stand/id1799868725?i=1000703925386"
  "/home/daedalus/Podcasts/Lemonade Stand/|https://podcasts.apple.com/us/podcast/were-not-paying-ep-008-lemonade-stand/id1799868725?i=1000704807477"
  "/home/daedalus/Podcasts/Lemonade Stand/|https://podcasts.apple.com/us/podcast/its-been-100-days-ep-009-lemonade-stand/id1799868725?i=1000705765294"
  "/home/daedalus/Podcasts/Lemonade Stand/|https://podcasts.apple.com/us/podcast/this-will-change-medicine-forever-ep-010-lemonade-stand/id1799868725?i=1000706889043"
  "/home/daedalus/Podcasts/Lemonade Stand/|https://podcasts.apple.com/us/podcast/gen-z-cant-get-laid-ep-011-lemonade-stand/id1799868725?i=1000708653040"
)

# Define defaults 
output_format="%(title)s.%(ext)s"
yt_dlp_options=""
extension="m4a"

echo "testing"

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
    --format)
      extension="$2"
      shift
      shift
      ;;
    --help)
      echo "Usage: $0 [--include-index] [--include-metadata] [--include-thumbnail]"
      echo "  --include-index          : Include track numbers in filenames"
      echo "  --include-metadata       : Embed metadata into audio files"
      echo "  --include-thumbnail      : Embed thumbnails into audio files"
      exit 0
      ;;
    *)
      echo "Unexpected argument: $1"
      exit 1
  esac
done

echo "testing"

# Iterate over the playlist pairs
for entry in "${playlists[@]}"; do
  # Split the entry into directory and playlist link
  IFS='|' read -r dir link <<< "$entry"
  
  # Create the directory if it doesn't exist
  mkdir -p "$dir"

  # Run yt-dlp for the current playlist
  echo "Downloading playlist: $link to directory: $dir"
  yt-dlp -x --audio-format "$extension" "$yt_dlp_options" -o "$output_format" --paths "$dir" "$link"


  echo "Finished downloading: $link"
done

echo "All playlists downloaded!"
