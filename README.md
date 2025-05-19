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
    * prettytable: For displaying tabular data in the console.
    * requests: For making HTTP requests to web services like MusicBrainz.
    * mutagen: For reading and writing audio metadata in various formats (MP3, FLAC, M4A, etc.).

**Arch Linux Download Command**: 
```bash
sudo pacman -S python yt-dlp ffmpeg ffprobe sed awk mp4ary atomicparsley
```

**Download Command Pip**: 
```bash
pip install prettytable requests mutagen 
```
## Before Using
These scripts have been primarily tested on Arch Linux. While they may work on other Linux distributions or macOS, compatibility is not guaranteed, and you might need to adjust installation commands or script behavior.

To use `get_album_info.py`, you'll need to set a custom User-Agent header. MusicBrainz requires this to identify your application (see their Rate Limiting documentation for details and examples). A suggested format is "YourAppName/Version ( YourContactInfo )".

## Script Summaries
*  `append_music_doc.sh`: Appends links to a markdown document. 
*  `batch_download_playlists.sh`: Downloads multiple youtube playlists in batch.
*  `clean_audio_files.sh`: Cleans and formats audio filenames and metadata.
*  `clean_music_recursive.sh`: Recursively cleans audio files within a directory.
*  `cmus-addqueue.sh`: Adds selected music files to the cmus queue.
*  `cmus-quickplay.sh`: Starts and plays an audio file through cmus.
*  `download_playlist.sh`: Downloads audio tracks from an online playlist using yt-dlp.
*  `fix_metadata.py`: Sets advanced metadata and album art in audio files based on album info.
*  `full_download_basic.py`: Runs `download_playlist.sh`, `clean_audio_files.sh` and `set_cover_images.sh` in sequence.
*  `full_download_advanced.py`: Runs `get_album_info.sh`, `download_playlist.sh` and `fix_metadata.sh` in sequence.
*  `get_album_info.py`: Gets advanced metadata and album art using the [Musicbrainz API](https://musicbrainz.org/doc/MusicBrainz_API).
*  `man_set_tracknum.sh`: Loops through all audio files and asks the user to manually provide the correct track number.
*  `set_cover_images.sh`: Uses mp4art to embed cover art in audio files. 
*  `set_tracknum.sh`: Attempts to automatically set tracknumber based on a tracklist.

## Usage Examples 

### Basic Download and Clean (`full_download_basic.py`) 
1. Use download_playlist.sh to download a youtube playlist using yt-dlp
2. Use clean_audio_files.sh to clean the audio file's data and set metadata
3. Download cover art and use set_cover_images.sh to embed it

### Advanced Download and Metadata (`full_download_advanced.py`)
1. Use get_album_info.py to get the tracklist, advanced metadata, and cover art using the musicbrainz
2. Use download_playlist.sh to download a youtube playlist using yt-dlp
3. Use fix_metadata.py to embed the advanced metdata and cover art

Note: The "advanced metadata" obtained from the MusicBrainz API includes a wide range of information about the release, artists, tracks, and relationships.
