
#!/bin/bash

# Function to set cover image for audio files
set_cover_images() {
  local cover_image="$1"  # First argument is the cover image
  shift
  local audio_files=("$@")  # Remaining arguments are the audio files

  # Iterate over all files
  for file in "${audio_files[@]}"; do
    if [[ -f "$file" ]]; then
      mp4art --remove --quiet "$file"
      mp4art --add "$cover_image" "$file"
    else
      echo "File $file does not exist."
    fi
  done
}

# Check for correct number of arguments
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <cover-image> <audio-files...>"
  exit 1
fi

# Call the function with all arguments
set_cover_images "$@"

