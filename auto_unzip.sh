#!/bin/bash
# Watches the Uploads folder and automatically extracts encrypted zip files
# using the password "sandbox", then opens any .eml file found in Thunderbird.

UPLOAD_DIR="/home/kasm-user/Desktop/Uploads"
ZIP_PASSWORD="$(hostname)"
mkdir -p "$UPLOAD_DIR"

inotifywait -m -e close_write,moved_to --format "%f" "$UPLOAD_DIR" | while read -r FILENAME; do
    [[ "${FILENAME,,}" == *.zip ]] || continue

    ZIPFILE="$UPLOAD_DIR/$FILENAME"
    DESTDIR="$UPLOAD_DIR/${FILENAME%.zip}"
    mkdir -p "$DESTDIR"

    if unzip -o -P "$ZIP_PASSWORD" "$ZIPFILE" -d "$DESTDIR"; then
        rm -f "$ZIPFILE"

        # Find and open any .eml file in the extracted folder
        while IFS= read -r -d '' EMLFILE; do
            thunderbird "$EMLFILE" &
        done < <(find "$DESTDIR" -maxdepth 2 -name "*.eml" -print0)
    fi
done
