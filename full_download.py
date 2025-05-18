
import sys
import subprocess
from pathlib import Path

def main():
    if len(sys.argv) > 3:
        artist, album, link = sys.argv[1:4]
    else:
        artist = input("Enter artist name: ").strip()
        album = input("Enter album name: ").strip()
        link = input("Enter playlist link: ").strip()

    music_dir = Path.home() / "Music"
    album_path = music_dir / artist / album

    # Define script paths
    download_playlist_script = "/home/daedalus/Music/download_playlist.sh"
    clean_music_script = "/home/daedalus/Music/clean_music.sh"
    get_album_info_script = "/home/daedalus/Music/get_album_info.py"
    fix_metadata_script = "/home/daedalus/Music/fix_metadata.py"

    # Run get_album_info.py synchronously
    subprocess.run(["python3", get_album_info_script, artist, album], check=True)

    # Run download_playlist.sh
    subprocess.run(["bash", download_playlist_script, "--include-metadata", "--include-index", artist, album, link], check=True)

    # Run clean_music.sh
    subprocess.run(["bash", clean_music_script, str(album_path), artist, album], check=True)

    # Now run fix_metadata.py
    subprocess.run(["python3", fix_metadata_script, str(album_path)], check=True)

    print("All tasks completed successfully!")

if __name__ == "__main__":
    main()

