#!/usr/bin/env python3

import sys
import subprocess
from pathlib import Path
import os

def main():
    if len(sys.argv) > 3:
        artist, album, link = sys.argv[1:4]
    else:
        artist = input("Enter artist name: ").strip()
        album = input("Enter album name: ").strip()
        link = input("Enter playlist link: ").strip()

    music_dir = Path.home() / "Music"
    album_path = music_dir / artist / album

    # Define script paths (relative to the current script's directory)
    script_dir = os.path.dirname(os.path.realpath(__file__))
    download_playlist_script = os.path.join(script_dir, "download_playlist.sh")
    clean_music_script = os.path.join(script_dir, "clean_music_recursive.py")

    # Run download_playlist.sh
    subprocess.run(["bash", download_playlist_script, artist, album, link], check=True)

    # Run clean_music.sh
    subprocess.run(["bash", clean_music_script, str(album_path), artist, album], check=True)

    print("All tasks completed successfully!")

if __name__ == "__main__":
    main()

