
#!/bin/bash

# Function to set cover image for audio files
set_cover_image() {
  local cover_image="$1"  # First argument is the cover image
  shift
  local audio_files=("$@")  # Remaining arguments are the audio files

  # Iterate over all files
  for file in "${audio_files[@]}"; do
    if [[ -f "$file" ]]; then
      # temp_file="${file}.temp"
      
      # Add cover image to audio file
      # ffmpeg -y -i "$file" -i "$cover_image" -map 0 -map 1 -c copy -disposition:v:1 attached_pic "$temp_file"
      mp4art --remove "$file"
      mp4art --add "$cover_image" "$file"
      
      # if [[ $? -eq 0 ]]; then
      #   mv "$temp_file" "$file"
      # else
      #   echo "Failed to process $file"
      #   rm -f "$temp_file"
      # fi
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
set_cover_image "$@"

