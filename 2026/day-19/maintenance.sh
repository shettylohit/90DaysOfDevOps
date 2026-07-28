Task 4: Combine — Scheduled Maintenance Script
Create maintenance.sh that:

Calls your log rotation function
Calls your backup function
Logs all output to /var/log/maintenance.log with timestamps
Write the cron entry to run it daily at 1 AM
#!/usr/bin/env bash

set -euo pipefail

LOG_FILE="/var/log/maintenance.log"

# Function to write timestamped logs
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Log rotation function
log_rotate() {
    local LOG_DIR="$1"

    if [ ! -d "$LOG_DIR" ]; then
        log "ERROR: Log directory '$LOG_DIR' does not exist."
        return 1
    fi

    compressed=$(find "$LOG_DIR" -type f -name "*.log" -mtime +7 | wc -l)
    deleted=$(find "$LOG_DIR" -type f -name "*.gz" -mtime +30 | wc -l)

    find "$LOG_DIR" -type f -name "*.log" -mtime +7 -exec gzip {} \;
    find "$LOG_DIR" -type f -name "*.gz" -mtime +30 -delete

    log "Compressed $compressed log file(s)"
    log "Deleted $deleted compressed log(s)"
}

# Backup function
backup() {
    local SOURCE_DIR="$1"
    local BACKUP_DIR="$2"

    if [ ! -d "$SOURCE_DIR" ]; then
        log "ERROR: Source directory '$SOURCE_DIR' does not exist."
        return 1
    fi

    mkdir -p "$BACKUP_DIR"

    ARCHIVE="$BACKUP_DIR/backup-$(date +%F).tar.gz"

    tar -czf "$ARCHIVE" -C "$SOURCE_DIR" .

    if [ -f "$ARCHIVE" ]; then
        SIZE=$(du -h "$ARCHIVE" | cut -f1)
        log "Backup created: $ARCHIVE ($SIZE)"
    else
        log "ERROR: Backup failed."
        return 1
    fi

    find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +14 -delete
    log "Old backups (>14 days) removed."
}

# Main execution
log "===== Maintenance Started ====="

log_rotate "/var/log/myapp"
backup "/home/user/project" "/home/user/backups"

log "===== Maintenance Completed ====="
