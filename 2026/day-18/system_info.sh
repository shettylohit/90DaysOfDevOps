Task 5: Build a Script — System Info Reporter
Create system_info.sh that uses functions for everything:

A function to print hostname and OS info
A function to print uptime
A function to print disk usage (top 5 by size)
A function to print memory usage
A function to print top 5 CPU-consuming processes
A main function that calls all of the above with section headers
Use set -euo pipefail at the top
Output should look clean and readable.



#!/usr/bin/env bash 

set -euo pipefail

# 1. Function to print hostname and OS info
host_name() {
    echo "--- System & OS Information ---"
    echo "Hostname: $(hostname)"
    echo ""
    echo "OS -Info "
    cat /etc/os-release

    echo ""
}

# 2. Function to print uptime
up_time() {
    echo "--- System Uptime ---"
    uptime -p
    echo ""
}

# 3. Function to print disk usage (top 5 by size)
disk_usage() {
    echo "--- Top 5 Disk Consumers (Current Directory) ---"
    # Added 2>/dev/null to keep the output clean of permission errors
    du -ah . 2>/dev/null | sort -rh | head -n 5
    echo ""
}

# 4. Function to print memory usage
memory_usage() {
    echo "--- Memory Usage ---"
    free -h
    echo ""
}

# 5. Function to print top 5 CPU-consuming processes
cpu_usage(){
    echo "--- Top 5 CPU Consuming Processes ---"
    ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6
    echo ""
}

# 6. Main function that acts as the entry point and orchestrates execution
main() {
    echo "============================================="
    echo "          SYSTEM INFO REPORT                 "
    echo "============================================="
    echo ""

    host_name
    up_time
    disk_usage
    memory_usage
    cpu_usage

    echo "============================================="
}

# Trigger the main function to start the script
main




output>>>

# 6. Main function that acts as the entry point and orchestrates execution
main() {
    echo "============================================="
    echo "          SYSTEM INFO REPORT                 "
    echo "============================================="
    echo ""

    host_name
    up_time
    disk_usage
    memory_usage
    cpu_usage

    echo "============================================="
}

# Trigger the main function to start the script
main
