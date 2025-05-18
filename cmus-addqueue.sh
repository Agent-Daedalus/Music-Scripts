#!/bin/bash

# A script to add audio files to cmus queue with error handling

# Get the file passed as an argument
file="$1"

# Check if the file was provided
if [ -z "$file" ]; then
    echo "Error: No file provided."
    exit 1
fi

# Check if the file exists
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    exit 1
fi

# Check if cmus is running; if not, start it
if ! pgrep -x "cmus" > /dev/null; then
    echo "cmus is not running. Starting cmus..."
    cmus &  # Start cmus in the background
    sleep 1  # Give cmus a moment to start
fi

# Add the file to cmus playlist without clearing or starting playback
cmus-remote -q "$file"

# Check if the file was successfully added
if [ $? -ne 0 ]; then
    echo "Error: Failed to add '$file' to cmus."
    exit 1
fi

echo "File '$file' added to cmus queue successfully."
