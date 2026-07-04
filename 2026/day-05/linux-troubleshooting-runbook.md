1. uname -a >> Linux ubuntu-host 6.8.0-124-generic #124~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Tue May 26 21:05:19 UTC  x86_64 x86_64 x86_64 GNU/Linux
The uname command displays information about your operating system and kernel.
#########################################################################################

2. cat /etc/os-release  >>
NAME="Ubuntu"
VERSION="20.04.6 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.6 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal

os-release displays information about your Linux distribution (OS), such as its name, version, and ID.

#########################################################################################

3. mkdir /tmp/runbook-demo, cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp/runbook-demo  >>> hosts-copy

mkdir will create a new directory called runbook-demo and cp command will copy all the content of directory /etc/hosts to /tmp/runbook-demo/hosts-copy and the ls -l will list all the contnet in directory runbook-demo


#########################################################################################
4. top >>>
top - 10:36:38 up 0 min,  0 users,  load average: 0.76, 0.94, 1.02
Tasks:  11 total,   1 running,  10 sleeping,   0 stopped,   0 zombie
%Cpu(s):  5.3 us,  3.2 sy,  0.0 ni, 90.9 id,  0.3 wa,  0.0 hi,  0.3 si,  0.0 st
MiB Mem :  63339.0 total,   9384.2 free,  10018.5 used,  43936.3 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.  52092.2 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                     
      1 root      20   0  171036  12024   8408 S   0.0   0.0   0:03.45 systemd                                                     
    698 message+  20   0    7224   4480   3748 S   0.0   0.0   0:00.35 dbus-daemon                                                 
    727 root      20   0   17272   7268   6404 S   0.0   0.0   0:00.18 systemd-logind                                              
    761 root      20   0    1356    864    764 S   0.0   0.0   0:00.35 ttyd                                                        

The top command is a real-time system monitoring tool that displays running processes and overall system resource usage, including CPU, memory, and load average.


#########################################################################################

5. htop  is an interactive, improved version of top. It provides a more user-friendly interface with color, mouse support, scrolling, searching, and easier process management.


#########################################################################################

6. ps >>

    ps -o pid,pcpu,pmem,comm 
    PID %CPU %MEM COMMAND
   1394  0.0  0.0 bash
  46545  0.0  0.0 ps

    ps -o pid,pcpu,pmem,comm -p 1394
    PID %CPU %MEM COMMAND
   1394  0.0  0.0 bash

The ps command displays information about running processes.
-o flag will let specify which columns to display
-p  flag will let you specify the process id 


#########################################################################################

7. free -h >>>
              total        used        free      shared  buff/cache   available
Mem:           61Gi        10Gi       7.3Gi       238Mi        44Gi        50Gi
Swap:            0B          0B          0B

The free command displays memory (RAM) and swap usage on a Linux system.
-h option means human-readable

#########################################################################################

8. df -h
Filesystem      Size  Used Avail Use% Mounted on
overlay         437G  173G  242G  42% /
tmpfs            64M     0   64M   0% /dev
tmpfs            31G   52K   31G   1% /run
tmpfs            31G     0   31G   0% /run/lock
tmpfs            31G  8.0M   31G   1% /var/log/journal
udev             31G     0   31G   0% /dev/tty
shm              64M     0   64M   0% /dev/shm
/dev/md2        437G  173G  242G  42% /etc/hosts
tmpfs           6.2G   12M  6.2G   1% /etc/hostname
tmpfs           3.8G   12K  3.8G   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs            31G     0   31G   0% /proc/acpi
tmpfs            31G     0   31G   0% /proc/scsi
tmpfs            31G     0   31G   0% /sys/firmware
tmpfs            31G     0   31G   0% /sys/devices/virtual/powercap


The df (disk free) command displays disk space usage for mounted filesystems.

#########################################################################################

9. du -sh /var/log
8.4M    /var/log

du -h /var/log
164K    /var/log/apt
8.0M    /var/log/journal/1ae5e998fe3eec4292d72c0a63ff0eae
8.0M    /var/log/journal
4.0K    /var/log/sysstat
4.0K    /var/log/private
8.4M    /var/log

du = total disk space used by the /var/log directory.
-s = shows the whole summery without s we will get disk usage of individual folder 

#########################################################################################

10. iostat 
Linux 6.8.0-124-generic (ubuntu-host)   07/04/2026      _x86_64_        (16 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           6.41    0.00    2.15    0.15    0.00   91.29

Device             tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd
nvme0n1       12347.11     56437.01    568542.01     60716.14 1003794387 10112145112 1079903396
nvme1n1       13646.17     93614.23    568542.01     60657.32 1665032065 10112145112 1078857188

iostat is a Linux command used to monitor CPU usage and disk I/O (input/output) performance
#########################################################################################

11. vmstat 
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 3  0      0 12566460 4874672 37836940    0    0    38   233    0    1  6  2 91  0  0

vmstat (Virtual Memory Statistics) is a Linux command used to monitor system performance — including CPU, memory, processes, paging, and I/O activity in real time.
#########################################################################################

12. ss -tulpn
Netid       State         Recv-Q        Send-Q               Local Address:Port               Peer Address:Port       Process       
udp         UNCONN        0             0                    127.0.0.53%lo:53                      0.0.0.0:*                        
tcp         LISTEN        0             4096                 127.0.0.53%lo:53                      0.0.0.0:*                        
tcp         LISTEN        0             128                        0.0.0.0:22                      0.0.0.0:*                        
tcp         LISTEN        0             128                        0.0.0.0:8080                    0.0.0.0:*                        
tcp         LISTEN        0             128                           [::]:22                         [::]:*                        

