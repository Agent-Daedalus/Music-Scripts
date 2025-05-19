from prettytable import PrettyTable
import requests
import os
import json
import sys

BASE_URL = "https://musicbrainz.org/ws/2/release-group/"
RELEASE_URL = "https://musicbrainz.org/ws/2/release/"
MEDIA_URL = "https://musicbrainz.org/ws/2/media/"

# Set your own header here:
headers = { "User-Agent": "TestAlbumMetadata/1.0 (agentdumbledore@gmail.com)" }
# headers = { "User-Agent": "MyAwesomeTagger/1.2.0 ( me@example.com )" }

MUSIC_DIRECTORY = "/home/daedalus/Music"
choose_release_group = True

def search_album(artist, album):
    query = f"release:{album} AND artist:{artist}"
    params = {"query": query, "fmt": "json"}
    response = requests.get(BASE_URL, params=params, headers=headers)

    if response.status_code != 200:
        print("Error fetching data from MusicBrainz:", response.status_code, response.text)
        return None

    data = response.json()
    release_groups = data.get("release-groups", [])

    if not release_groups:
        print("No albums found.")
        return None

    # Automatically select the highest-score release group
    best_match = max(release_groups, key=lambda r: r.get("score", 0))

    chosen_group = best_match
    if (choose_release_group):
        table = PrettyTable()
        table.field_names = ["#", "Title", "Date", "Country"]

        for i, release_group in enumerate(release_groups):
            title = release_group.get("title", "Unknown")
            date = release_group.get("date", "Unknown")
            disambiguation = release_group.get("disambiguation", "")
            country = release_group.get("country", "Unknown")
            
            # Combine title and disambiguation info
            full_title = f"{title} ({disambiguation})" if disambiguation else title

            # Add data to the table
            table.add_row([i + 1, full_title, date, country])

        print(table)

        selected_release_group = release_groups[0]
        # Select a release version
        try:
            choice = int(input("\nEnter number: ")) - 1
            if 0 <= choice < len(release_groups):
                selected_release_group = release_groups[choice]

                title = selected_release_group.get("title", "Unknown")
                disambiguation = selected_release_group.get("disambiguation", "")

                full_title = f"{title} ({disambiguation})" if disambiguation else title

                date = selected_release_group.get("date", "Unknown")

                print(f"\nSelected Release: {full_title} [{date}]")
                # print(f"MBID: {selected_release['id']}")
            else:
                print("Invalid selection.")
        except ValueError:
            print("Invalid input.")

        chosen_group = selected_release_group

    return chosen_group

def get_releases(release_group_id):
    params = {"fmt": "json", "inc": "releases"}
    response = requests.get(f"{BASE_URL}{release_group_id}", params=params, headers=headers)

    if response.status_code != 200:
        print("Error fetching releases.")
        return []

    data = response.json()
    return data.get("releases", [])

def get_release_details(release_id):
    params = {"fmt": "json", "inc": "media+labels"}
    response = requests.get(f"{RELEASE_URL}{release_id}", params=params, headers=headers)

    if response.status_code != 200:
        print(f"Error fetching release details for ID {release_id}.")
        return None

    data = response.json()
    return data

def get_advanced_release_info(release_id):
    params = {"fmt": "json", "inc": "artist-credits+labels+recordings+recording-level-rels+work-rels+work-level-rels+artist-rels"}
    response = requests.get(f"{RELEASE_URL}{release_id}", params=params, headers=headers)

    if response.status_code != 200:
        print(f"Error fetching release details for ID {release_id}.")
        return None

    data = response.json()
    return data

def main():
    if len(sys.argv) > 2:
        artist = sys.argv[1]
        album = sys.argv[2]
    else:
        artist = input("Enter artist name: ").strip()
        album = input("Enter album name: ").strip()

    selected_group = search_album(artist, album)

    if not selected_group:
        return

    print(f"\nSelected Release Group: {selected_group['title']} ({selected_group.get('first-release-date', 'Unknown Date')})")
    print(f"MBID: {selected_group['id']}")

    releases = get_releases(selected_group["id"])

    if not releases:
        print("No specific releases found.")
        return

    # Define the table columns
    table = PrettyTable()
    table.field_names = ["#", "Title", "Date", "Country", "Tracks", "Format", "Label"]

    for i, release in enumerate(releases):
        title = release.get("title", "Unknown")
        date = release.get("date", "Unknown")
        disambiguation = release.get("disambiguation", "")
        country = release.get("country", "Unknown")
        
        # Combine title and disambiguation info
        full_title = f"{title} ({disambiguation})" if disambiguation else title

        # Get detailed release info
        release_id = release['id']
        release_details = get_release_details(release_id)

        if not release_details:
            print(f"Could not fetch details for release ID {release_id}.")
            continue


        # Extract media (which contains track-count and format)
        media = release_details.get("media", [])
        labels_info = release_details.get("label-info", [])

        labels = ', '.join(sorted(set(label['label']['name'] for label in labels_info if label.get('label') and label['label'].get('name'))))

        # Sum tracks and collect formats
        tracks_count = sum(medium.get("track-count", 0) for medium in media)

        formats_text = ""
        formats = set(medium.get("format", "Unknown Format") for medium in media)
        if formats:
            formats_text = ', '.join(formats)

        

        # Add data to the table
        table.add_row([i + 1, full_title, date, country, tracks_count, formats_text, labels])

    print(table)

    selected_release = releases[0]
    # Select a release version
    try:
        choice = int(input("\nEnter number: ")) - 1
        if 0 <= choice < len(releases):
            selected_release = releases[choice]

            title = selected_release.get("title", "Unknown")
            disambiguation = selected_release.get("disambiguation", "")

            full_title = f"{title} ({disambiguation})" if disambiguation else title

            date = selected_release.get("date", "Unknown")

            print(f"\nSelected Release: {full_title} [{date}]")
            # print(f"MBID: {selected_release['id']}")
        else:
            print("Invalid selection.")
    except ValueError:
        print("Invalid input.")

    advanced_release_info = get_advanced_release_info(selected_release['id'])

    if not advanced_release_info:
        print(f"Could not fetch details for release ID {advanced_release_info}.")
        return

    media = advanced_release_info.get("media", [])

    if not media:
        print("No media found for this release.")
        return

    artist_title = advanced_release_info.get("artist-credit", [{}])[0].get("artist", {}).get("name", "Unknown Artist")
    album_title = advanced_release_info.get("title", "Unknown Album")

    all_tracks = []
    for medium in media:
        tracks = medium.get("tracks", [])
        all_tracks.extend(tracks)

    os.makedirs(f"{MUSIC_DIRECTORY}/{artist_title}/{album_title}", exist_ok=True)

    with open(f"{MUSIC_DIRECTORY}/{artist_title}/{album_title}/tracklist.txt", "w", encoding="utf-8") as f:
        for track in all_tracks:
            artist_credit = track.get("artist-credit", [])
            featured_artists = [artist["name"] for artist in artist_credit[1:]]

            feat_text = f" (feat. {', '.join(featured_artists)})" if featured_artists else ""

            f.write(f"{track.get('title', 'Unknown title')}{feat_text}\n")

    with open(f"{MUSIC_DIRECTORY}/{artist_title}/{album_title}/advanced_release_info.json", "w", encoding="utf-8") as f:
        json.dump(advanced_release_info, f, indent=4, ensure_ascii=False)

    # Fetch all album covers
    cover_art_url = f"https://coverartarchive.org/release/{selected_release['id']}"
    response = requests.get(cover_art_url)

    if response.status_code == 200:
        cover_data = response.json()  # Get the JSON data that contains the image URLs
        cover_images = cover_data.get("images", [])
        
        if cover_images:
            print(f"Downloading {len(cover_images)} album covers...")

            for idx, cover in enumerate(cover_images):
                cover_url = cover['image']
                cover_response = requests.get(cover_url)

                if cover_response.status_code == 200:
                    cover_image_path = f"{MUSIC_DIRECTORY}/{artist_title}/{album_title}/cover_{idx + 1}.jpg"
                    with open(cover_image_path, "wb") as img_file:
                        img_file.write(cover_response.content)
                    print(f"Saved cover: {cover_image_path}")
                else:
                    print(f"Failed to download cover {idx + 1}")
        else:
            print("No cover images available.")
    else:
        print("No album cover found.")

if __name__ == "__main__":
    main()

