#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

logfile="$1"

if [ ! -f "$logfile" ]; then
    echo "Error: File does not exist."
    exit 1
fi

total_lines=$(wc -l < "$logfile")

error_count=$(grep -Ei "ERROR|Failed" "$logfile" | wc -l)

echo "Total Error Count: $error_count"

echo "---- Critical Events ----"
grep -n "CRITICAL" "$logfile"

echo
echo "---- Top 5 Error Messages ----"
grep "ERROR" "$logfile" \
    | sed 's/.*ERROR //' \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -5
