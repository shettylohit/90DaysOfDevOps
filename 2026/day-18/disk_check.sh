# Task 2: Functions with Return Values

Create a Bash script named `disk_check.sh` that:

- Defines a function `check_disk` to display the disk usage of the root filesystem using `df -h`
- Defines a function `check_memory` to display free memory using `free -h`
- Calls both functions from the main section of the script

## Solution

#!/usr/bin/env bash

disk_usage() {
    echo "--------------- Disk Usage ---------------"
    df -h
}

memory() {
    echo "------------------ Memory --------------"
    free -h
}

disk_usage
memory

## Output

root@ubuntu-host ~/scripts ➜ ./disk_check.sh

--------------- Disk Usage ---------------
Filesystem      Size  Used Avail Use% Mounted on
overlay         437G   96G  319G  24% /
tmpfs            64M     0   64M   0% /dev
tmpfs            31G   48K   31G   1% /run
tmpfs            31G     0   31G   0% /run/lock
tmpfs            31G   16M   31G   1% /var/log/journal
shm              64M     0   64M   0% /dev/shm
/dev/md2        437G   96G  319G  24% /etc/hosts
tmpfs           6.2G   12M  6.2G   1% /etc/hostname
tmpfs           3.8G   12K  3.8G   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs            31G     0   31G   0% /proc/acpi
tmpfs            31G     0   31G   0% /proc/scsi
tmpfs            31G     0   31G   0% /sys/firmware
tmpfs            31G     0   31G   0% /sys/devices/virtual/powercap

------------------ Memory --------------
               total        used        free      shared  buff/cache   available
Mem:            61Gi       9.7Gi        11Gi       593Mi        41Gi        50Gi
Swap:             0B          0B          0B


