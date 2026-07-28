Task 2: Server Backup Script
Create backup.sh that:

Takes a source directory and backup destination as arguments
Creates a timestamped .tar.gz archive (e.g., backup-2026-02-08.tar.gz)
Verifies the archive was created successfully
Prints archive name and size
Deletes backups older than 14 days from the destination
Handles errors — exit if source doesn't exist


#!/usr/bin/env bash

set -euo pipefail

# Check arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <source_directory> <backup_directory>"
    exit 1
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"

# Check source exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

ARCHIVE="$BACKUP_DIR/backup-$(date +%F).tar.gz"

# Create archive
tar -czf "$ARCHIVE" -C "$SOURCE_DIR" .

# Verify archive
if [ ! -f "$ARCHIVE" ]; then
    echo "Backup creation failed."
    exit 1
fi

# Print archive information
SIZE=$(du -h "$ARCHIVE" | cut -f1)

echo "Backup created successfully."
echo "Archive: $ARCHIVE"
echo "Size: $SIZE"

# Delete backups older than 14 days
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +14 -delete
