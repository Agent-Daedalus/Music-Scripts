#!/bin/bash

# Define an array of directory and playlist pairs
# Format: "directory|playlist_url"
playlists=(
  "/home/daedalus/Music/|"
)

# yt-dlp command options
yt_dlp_options=(
  "-x"
  "--audio-format m4a"               # Change to "m4a" for M4A
  "--add-metadata"
  "--embed-thumbnail"
  "--embed-metadata"
  "--output" "%(playlist_index)02d - %(title)s.%(ext)s"
)

# Iterate over the playlist pairs
for entry in "${playlists[@]}"; do
  # Split the entry into directory and playlist link
  IFS='|' read -r dir link <<< "$entry"
  
  # Create the directory if it doesn't exist
  mkdir -p "$dir"

  # Run yt-dlp for the current playlist
  echo "Downloading playlist: $link to directory: $dir"
  yt-dlp -x --audio-format "m4a" --add-metadata --embed-metadata --embed-thumbnail -o "%(playlist_index)02d - %(title)s.%(ext)s" --paths "$dir" "$link"

  echo "Finished downloading: $link"
done

echo "All playlists downloaded!"
