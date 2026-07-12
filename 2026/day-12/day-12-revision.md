```markdown
# Linux Troubleshooting Notes

## Mindset & Plan

I now have the confidence to troubleshoot Linux issues by identifying running processes, checking open ports, managing files, and handling users, groups, and permissions.

---

# Processes & Services

## 1. Check Listening Ports

### Command

ss -tunlp

### Output

root@ubuntu-host ~ ➜ ss -tunlp

Netid         State          Recv-Q         Send-Q                 Local Address:Port                   Peer Address:Port         Process
udp           UNCONN         0              0                      127.0.0.53%lo:53                          0.0.0.0:*             users:(("systemd-resolve",pid=458,fd=13))
tcp           LISTEN         0              4096                   127.0.0.53%lo:53                          0.0.0.0:*             users:(("systemd-resolve",pid=458,fd=14))
tcp           LISTEN         0              128                          0.0.0.0:22                          0.0.0.0:*             users:(("sshd",pid=968,fd=3))
tcp           LISTEN         0              128                          0.0.0.0:8080                        0.0.0.0:*             users:(("ttyd",pid=967,fd=11))
tcp           LISTEN         0              128                             [::]:22                             [::]:*             users:(("sshd",pid=968,fd=4))

### Observation

- Port **22** is listening for SSH connections.
- Port **8080** is used by the **ttyd** web terminal.
- Port **53** is being used by **systemd-resolved** for DNS resolution.

---

## 2. View Running Processes

### Command

ps aux

### Output

root@ubuntu-host ~ ➜ ps aux

USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0 165280 10728 ?        Ss   14:09   0:00 /sbin/init --log-level=err
root         188  0.0  0.0  31748 11420 ?        Ss   14:09   0:00 /lib/systemd/systemd-journald
systemd+     458  0.0  0.0  25256 13416 ?        Ss   14:09   0:00 /lib/systemd/systemd-resolved
message+     886  0.0  0.0   8120  4476 ?        Ss   14:09   0:00 @dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
root         929  0.0  0.0  14900  7020 ?        Ss   14:09   0:00 /lib/systemd/systemd-logind
root         967  0.0  0.0   1420   872 ?        Rs   14:09   0:00 /usr/bin/ttyd -p 8080 --ping-interval 30
root         968  0.0  0.0  15420  9272 ?        Ss   14:09   0:00 sshd: /usr/sbin/sshd -D [listener]
root        2082  0.0  0.0  10948  4812 pts/0    Ss+  14:14   0:00 sudo su -
root        2083  0.0  0.0  10948  2248 pts/1    Ss   14:14   0:00 sudo su -
root        2084  0.0  0.0  10064  3952 pts/1    S    14:14   0:00 su -
root        2085  0.0  0.0   9472  5788 pts/1    S    14:14   0:00 -bash
root        2696  0.0  0.0  10388  3544 pts/1    R+   14:19   0:00 ps aux

### Observation

- Process ID (PID) uniquely identifies each running process.
- `systemd` is the init process.
- `sshd` handles SSH connections.
- `ttyd` provides browser-based terminal access.
- `ps aux` is useful for troubleshooting running services and identifying resource usage.

---

# File Management Commands

## 1. List Files Including Hidden Files

### Command

ls -la

### Output

root@ubuntu-host ~ ➜ ls -la

total 32
drwx------ 1 root root 4096 Jul 12 14:14 .
dr-xr-xr-x 1 root root 4096 Jul 12 14:19 ..
-rw-r--r-- 1 root root 561 Jul 12 14:09 .bash_profile
-rw-r--r-- 1 root root 3135 Mar 1 2023 .bashrc
drwx------ 3 root root 4096 Jul 12 14:14 .cache
drwxr-xr-x 2 root root 4096 Mar 1 2023 .config
-rw-r--r-- 1 root root 161 Jul 9 2019 .profile
drwx------ 2 root root 4096 Jul 12 14:14 .ssh

### Observation

- Displays both visible and hidden files.
- Hidden files begin with a (`.`).

---

## 2. Create a File

### Command

touch hello.txt

### Verify

root@ubuntu-host ~ ➜ ls

hello.txt

---

## 3. Create a Directory

### Command

mkdir day12

### Verify

root@ubuntu-host ~ ➜ ls -l

total 4
drwxr-xr-x 2 root root 4096 Jul 12 14:22 day12
-rw-r--r-- 1 root root 0 Jul 12 14:21 hello.txt

---

# Linux Cheat Sheet

## 1. grep — Search Text Inside Files

Finds specific words, patterns, or strings inside files or command output.

Example

grep "error" /var/log/syslog

---

## 2. find — Search for Files and Directories

Searches for files based on name, type, size, or modification time.

Example

find /home -name "*.log"

---

## 3. df — Check Disk Space

Displays available and used disk space on mounted file systems.

Example

df -h

---

## 4. chmod — Change File Permissions

Changes read, write, and execute permissions of files and directories.

Example

chmod +x script.sh

---

## 5. systemctl — Manage System Services

Starts, stops, restarts, or checks the status of system services.

Example

sudo systemctl status ssh

---

# User & Group Management Commands

## 1. useradd — Create a New User

Creates a new user account.

Example

sudo useradd -m -s /bin/bash newuser

---

## 2. passwd — Set or Change Password

Assigns or updates the password of a user.

Example

sudo passwd newuser

---

## 3. groupadd — Create a New Group

Creates a new user group for permission management.

Example

sudo groupadd developers

---

## 4. usermod — Modify User Account

Adds an existing user to a group.

Example

sudo usermod -aG developers newuser

---

## 5. chown — Change File Owner and Group

Changes ownership of files or directories.

Example

sudo chown -R newuser:developers /var/www/html

---

# Key Takeaways

- Use **ss -tunlp** to identify open ports and listening services.
- Use **ps aux** to inspect running processes.
- Use **ls -la** to view all files, including hidden files.
- Use **touch** to create files.
- Use **mkdir** to create directories.
- Use **grep** and **find** to search efficiently.
- Use **df -h** to monitor disk usage.
- Use **chmod** to modify permissions.
- Use **systemctl** to manage Linux services.
- Use **useradd**, **groupadd**, **usermod**, **passwd**, and **chown** for user and permission management.
```
