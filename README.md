# Music Automation Scripts

## Overview

This repository contains a collection of Bash and Python scripts designed to automate the process of downloading and formatting music files. These scripts were created to streamline the creation and organization of my personal music library.

## Technologies Used
  * **Bash:** Script execution, argument parsing, file system operations, and calling external tools.
  * **Python:** For more complex logic and potentially interacting with specific libraries or APIs.
  * **yt-dlp:** Downloading audio from online playlist URLs.
  * **ffmpeg:** For audio format conversion and basic metadata embedding.
  * **ffprobe:** For inspecting audio file codecs.
  * **sed:** For basic text manipulation and filename cleaning.
  * **awk:** For more advanced text processing and data extraction.
  * **mp4art:** For embedding album art into MP4 audio files.
  * **atomicparsley:** For advanced manipulation of metadata in audio files.
  * **Python Libraries:** 
    * testing

## Dependencies 

## Usage Examples 

### basic easy thing 
[1] Use download_playlist.sh to download a youtube playlist using yt-dlp
[2] Use clean_audio_files.sh to clean the audio file's data and set metadata
[3] Download cover art and use set_cover_images.sh to embed it

### thing r 
[1] Use get_album_info.py to get the tracklist, advanced metadata, and cover art using the musicbrainz
[2] Use download_playlist.sh to download a youtube playlist using yt-dlp
[3] Use fix_metadata.py to set the info using


## Script Descriptions

### `clean_audio_files.sh`

This Bash script is designed to take existing audio files as input and perform several cleaning and formatting operations. Its primary functionalities include:

* **Filename Cleaning:**
    * Removes bracketed information (e.g., `[Official Video]`).
    * Removes leading and trailing spaces.
    * Removes specific common phrases like `(Explicit)`, `(Lyrics)`, `(Audio)`, `(Lyric Video)`, `(Official...)`, `(Visualizer)`.
    * Removes leading track numbers in various formats (e.g., `01.`, `02 -`, `03 -`).
    * Allows for custom `sed` commands to be applied for more specific cleaning.
* **Metadata Embedding:**
    * Attempts to extract track numbers from filenames and embed them as metadata.
    * Embeds artist and album metadata provided via command-line flags.
* **Error Handling:**
    * Includes basic error checking for `sed` commands and `ffmpeg` conversions.
    * Restores the original filename if conversion fails.

**Usage:**
```bash
./clean_audio_files.sh [--artist <artist name>] [--album <album name>] [--remove-phrase <phrase>] [--format <extension>] <audio-files...>```

