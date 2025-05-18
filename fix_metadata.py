import os
import re
import sys
import json
import glob
import difflib
from mutagen.easyid3 import EasyID3
from mutagen.mp3 import MP3
from mutagen.flac import FLAC
from mutagen.mp4 import MP4
from mutagen.id3._frames import APIC
import shutil

def load_metadata(album_path):
    """Load advanced metadata JSON file from the album directory."""
    metadata_file = os.path.join(album_path, "advanced_release_info.json")

    if not os.path.exists(metadata_file):
        print(f"Metadata file not found: {metadata_file}")
        sys.exit(1)

    with open(metadata_file, "r", encoding="utf-8") as f:
        metadata = json.load(f)

    return metadata

def load_tracklist(album_path):
    """Load advanced metadata JSON file from the album directory."""
    tracklist_file = os.path.join(album_path, "tracklist.txt")

    if not os.path.exists(tracklist_file):
        print(f"Metadata file not found: {tracklist_file}")
        sys.exit(1)

    with open(tracklist_file, "r", encoding="utf-8") as f:
        tracklist = [line.strip() for line in f.readlines()]

    return tracklist

def find_audio_files(album_path, extensions=("*.mp3", "*.flac", "*.wav", "*.m4a")):
    """Find all audio files in the given directory."""
    audio_files = []
    escaped_path = glob.escape(album_path)
    for ext in extensions:
        audio_files.extend(glob.glob(os.path.join(escaped_path, ext)))
    return sorted(audio_files)  # Ensure correct order

def set_cover_image_mp3_flac(audio, img_data):
    # For MP3 and FLAC, we use APIC to set the cover image in ID3 tags
    audio.tags.add(APIC(
        encoding=3,  # 3 means UTF-8 encoding
        mime='image/png',
        type=3,  # Type 3 means "Front Cover"
        desc="Cover",
        data=img_data
    ))

def sanitize_filename(filename):
    return filename.replace("/", "⧸")

def clean_title(title):
    # Remove anything at the start followed by " - "
    title = re.sub(r"^.*?\s* - \s*", "", title)
    title = re.sub(r"^.*?\s* - \s*", "", title)

    # Remove (feat. ...) completely
    title = re.sub(r"\s*\(feat\..*?\)", "", title, flags=re.IGNORECASE)
    # Remove 'ft. ...' up to the next '(' if present, otherwise remove everything after 'ft.'
    title = re.sub(r"\s*ft\..*?(?=\s*\(|$)", "", title, flags=re.IGNORECASE)

    # Remove leading track numbers (e.g., "01. ")
    title = re.sub(r"^\d{2}\.\s*", "", title)

    # Remove "(Audio)"
    title = re.sub(r"\s*\(Audio\)", "", title, flags=re.IGNORECASE)
    
    # Remove "(Lyric Video)"
    title = re.sub(r"\s*\(Lyric Video\)", "", title, flags=re.IGNORECASE)
    
    # Remove "(Official ...)" variations
    title = re.sub(r"\s*\(Official[^)]*\)", "", title, flags=re.IGNORECASE)

    return title.strip()

def process_audio_file(audio_file, tracklist, metadata, cover_art_data = None, similarity_threshold = 0.90):
    ext = os.path.splitext(audio_file)[1].lower()
    
    if ext == ".mp3":
        audio = MP3(audio_file, ID3=EasyID3)
        title = audio.get("title", [None])[0]
        track_number = audio.get("tracknumber", [None])[0]
    elif ext == ".flac":
        audio = FLAC(audio_file)
        title = audio.get("title", [None])[0]
        track_number = audio.get("tracknumber", [None])[0]
    elif ext == ".m4a":
        audio = MP4(audio_file)
        title = audio.tags.get("\xa9nam", [None])[0]  # MP4 stores title under '\xa9nam'
        track_number = audio.tags.get("trkn", [(None,)])[0][0]  # 'trkn' stores (track_no, total_tracks)
    else:
        print(f"Unsupported format: {audio_file}")
        return None

    if title == None:
        title = os.path.basename(os.path.splitext(audio_file)[0])

    # Ensure track_number is valid
    try:
        track_number = int(track_number) if track_number else None
    except ValueError:
        track_number = None

    if track_number == None:
        similarity_list = []
        for idx, recording in enumerate(tracklist, 1):
            track_similarity = difflib.SequenceMatcher(None, clean_title(title.lower()), clean_title(recording.lower())).ratio()
            similarity_list.append([track_similarity, idx])

        similarity_list.sort(reverse=True, key=lambda x: x[0])

        track_number = similarity_list[0][1]

    # Get expected title from tracklist
    expected_title = tracklist[track_number - 1] if track_number and 1 <= track_number <= len(tracklist) else ""

    # Compare extracted title with expected title
    similarity = difflib.SequenceMatcher(None, clean_title(title.lower()), clean_title(expected_title.lower())).ratio()

    if similarity < similarity_threshold:
        for idx, recording in enumerate(tracklist, 1):
            if clean_title(title) == clean_title(recording): 
                print(f"Perfect title match ({idx}) for '{title}'")
                track_number = idx
                similarity = 1.0
                break

    if similarity < similarity_threshold:
        print(f"Warning: Low title match ({similarity:.2f}) for '{title}' (Expected: '{expected_title}')")

        correct_title = input(f"Is this the correct title for track {track_number}? (y/n): ").strip().lower()
        if correct_title != 'y':
            print("Tracklist:")
            for idx, recording in enumerate(tracklist, 1):
                print(f"{idx}. {recording}")
            
            # Ask user to select the correct track number or skip
            while True:
                try:
                    new_track_num = input("Enter the correct track number (or 'skip' to skip): ").strip()
                    if new_track_num.lower() == 'skip':
                        print("Skipping track.")
                        return
                    new_track_num = int(new_track_num)
                    if 1 <= new_track_num <= len(tracklist):
                        track_number = new_track_num
                        break
                    else:
                        print("Invalid track number. Please try again.")
                except ValueError:
                    print("Invalid input. Please enter a valid number or 'skip'.")

    true_title = tracklist[track_number - 1] if track_number and 1 <= track_number <= len(tracklist) else None

    # Now set the artist and album metadata
    album = metadata.get("title", "") 
    
    artist_credit = metadata.get("artist-credit", [])
    album_artist = artist_credit[0].get("artist", {}).get("name", "") if artist_credit else ""

    media = metadata.get("media", [])

    all_tracks = []
    for medium in media:
        tracks = medium.get("tracks", [])
        all_tracks.extend(tracks)

    status = metadata.get("status", "Unknown");
    
    if (track_number == None): return
    if (track_number - 1) >= len(all_tracks): 
        print('\033[93m' + f"Warning: Track {title} out of size" + '\033[0m')
        return

    recording = all_tracks[track_number - 1].get("recording", [{}]) if track_number else [{}]

    date = recording.get("first-release-date", "Unknown")
    relations = recording.get("relations", [{}])

    full_description = ""
    for relation in relations:
        relation_type = relation.get("type", "unknown").capitalize()
        artist = relation.get("artist", {})  # Default should be {}
        artist_name = artist.get("name", "unknown")

        attributes = relation.get("attributes", [])
        attributes_text = f" ({', '.join(attr.capitalize() for attr in attributes)})" if attributes else ""

        full_description += f"{artist_name}: {relation_type}{attributes_text}\n"

    labels_info = metadata.get("label-info", [])
    labels = ', '.join(sorted(set(label['label']['name'] for label in labels_info if label.get('label') and label['label'].get('name'))))
    full_description += "\n" + labels

    track_artist_credit = recording.get("artist-credit", [])
    track_artist = track_artist_credit[0].get("artist", {}).get("name", "") if artist_credit else ""  

    if ext == ".mp3" or ext == ".flac":
        for tag in audio.keys():
            audio.delete(tag)

        audio["title"] = true_title
        audio["album"] = album
        audio["artist"] = track_artist
        audio["tracknumber"] = track_number
        audio["organization"] = labels
        audio["comment"] = status
        audio["description"] = full_description
        audio["date"] = date
        if ext == ".mp3":
            audio["TPE2"] = album_artist
        elif ext == ".flac":
            audio["albumartist"] = album_artist

        if cover_art_data:
            set_cover_image_mp3_flac(audio, cover_art_data)

    elif ext == ".m4a":
        audio.tags.clear()

        audio.tags["\xa9nam"] = true_title
        audio.tags["\xa9alb"] = album  # '\xa9alb' is the tag for album in M4A files
        audio.tags["\xa9ART"] = track_artist  # '\xa9ART' is the tag for artist in M4A files
        audio.tags["aART"] = album_artist
        audio.tags["trkn"] = [(track_number, len(tracklist))]
        audio.tags["\xa9pub"] = labels
        audio.tags["\xa9cmt"] = status
        audio.tags["\xa9day"] = date
        audio.tags["desc"] = full_description
        if (cover_art_data):
            audio.tags["covr"] = [cover_art_data]
    else:
        print("Unsupported format, artist and album not updated.")

    if title != true_title:
        print(f"Title updated to: {true_title}")

    audio.save()

    if title != true_title:
        print(f"Fixing file name and title: From '{title}' to '{true_title}'")

        safe_title = sanitize_filename(true_title)

        # Rename the file
        new_filename = f"{os.path.dirname(audio_file)}/{safe_title}{os.path.splitext(audio_file)[1]}"
        shutil.move(audio_file, new_filename)
        print(f"File renamed to: {new_filename}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 fix_metadata.py <album_directory>")
        sys.exit(1)

    album_path = sys.argv[1]

    cover_art = None
    cover_art_data = None
    if len(sys.argv) > 2:
        cover_art = sys.argv[2]

    if not os.path.isdir(album_path):
        print(f"Invalid directory: {album_path}")
        sys.exit(1)

    if not cover_art:
        potential_cover = os.path.join(album_path, "cover_1.jpg")
        if os.path.isfile(potential_cover):
            cover_art = potential_cover
        
    if cover_art:
        try:
            with open(cover_art, "rb") as img_file:
                cover_art_data = img_file.read()
            print(f"Cover art loaded from {cover_art}")
        except Exception as e:
            print(f"Failed to read cover art: {e}")

    metadata = load_metadata(album_path)
    audio_files = find_audio_files(album_path)
    tracklist = load_tracklist(album_path)

    print(f"Loaded metadata for album: {metadata.get('title', 'Unknown Album')}")
    print(f"Found {len(audio_files)} audio files.")

    for audio_file in audio_files:
        process_audio_file(audio_file,tracklist,metadata,cover_art_data)

if __name__ == "__main__":
    main()

