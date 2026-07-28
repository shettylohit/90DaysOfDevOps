# Task 1: Log Rotation Script

## Objective

Create a Bash script named `log_rotate.sh` that:

- Takes a log directory as an argument (e.g., `/var/log/myapp`)
- Compresses `.log` files older than **7 days** using `gzip`
- Deletes `.gz` files older than **30 days**
- Prints how many files were compressed and deleted
- Exits with an error if the directory doesn't exist

## Script

```bash
#!/usr/bin/env bash

# Check if directory argument is provided
# $# returns the number of command-line arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <log_directory>"
    exit 1
fi

# Assign the provided directory argument
LOG_DIR="$1"

# Check if directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory '$LOG_DIR' does not exist."
    exit 1
fi

# Count files before processing
compressed_count=$(find "$LOG_DIR" -type f -name "*.log" -mtime +7 | wc -l)
deleted_count=$(find "$LOG_DIR" -type f -name "*.gz" -mtime +30 | wc -l)

# Compress .log files older than 7 days
find "$LOG_DIR" -type f -name "*.log" -mtime +7 -exec gzip {} \;

# Delete .gz files older than 30 days
find "$LOG_DIR" -type f -name "*.gz" -mtime +30 -exec rm -f {} \;

# Print summary
echo "Compressed: $compressed_count file(s)"
echo "Deleted: $deleted_count file(s)"
```
