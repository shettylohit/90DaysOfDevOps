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

The ss -tulpn command displays active network socket connections, showing exactly which programs are listening for incoming traffic.

Breakdown of the Options-t 
(TCP): Shows TCP sockets.-u 
(UDP): Shows UDP sockets.
-l (Listening): Shows only sockets actively waiting for connections.
-p (Processes): Shows the process name and PID using the socket (requires sudo).
-n (Numeric): Shows raw port numbers and IP addresses instead of names (e.g., 80 instead of http).
#########################################################################################

13. curl -IL google.com 
HTTP/1.1 301 Moved Permanently
Location: http://www.google.com/
Content-Type: text/html; charset=UTF-8
Content-Security-Policy-Report-Only: object-src 'none';base-uri 'self';script-src 'nonce-43fV4nW79-Nw3MUyljXd_Q' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
Date: Tue, 07 Jul 2026 08:13:10 GMT
Expires: Thu, 06 Aug 2026 08:13:10 GMT
Cache-Control: public, max-age=2592000
Server: gws
Content-Length: 219
X-XSS-Protection: 0
X-Frame-Options: SAMEORIGIN

HTTP/1.1 200 OK
Content-Type: text/html; charset=ISO-8859-1
Content-Security-Policy-Report-Only: object-src 'none';base-uri 'self';script-src 'nonce-UgeGcIu_-AA8krbkQE_dlg' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
Date: Tue, 07 Jul 2026 08:13:10 GMT
Server: gws
X-XSS-Protection: 0
X-Frame-Options: SAMEORIGIN
Expires: Tue, 07 Jul 2026 08:13:10 GMT
Cache-Control: private
Set-Cookie: AEC=AdJVEauBoixQkQSObMK7yoa4GnP8xygjhMDa7-vu9dUk4AqOHdSBjC2va_U; expires=Sun, 03-Jan-2027 08:13:10 GMT; path=/; domain=.google.com; Secure; HttpOnly; SameSite=lax
Transfer-Encoding: chunked

Curl command fetches the response for the given URL
-I (Fetch Headers Only)
-L (Follow Redirects)

#########################################################################################

14. ping -c 4 google.com 
PING google.com (64.233.162.102) 56(84) bytes of data.
64 bytes from li-in-f102.1e100.net (64.233.162.102): icmp_seq=1 ttl=102 time=5.42 ms
64 bytes from li-in-f102.1e100.net (64.233.162.102): icmp_seq=2 ttl=102 time=3.92 ms
64 bytes from li-in-f102.1e100.net (64.233.162.102): icmp_seq=3 ttl=102 time=3.96 ms
64 bytes from li-in-f102.1e100.net (64.233.162.102): icmp_seq=4 ttl=102 time=3.92 ms

ping command tests network connectivity
ping: Sends ICMP Echo Request packets to network hosts.
-c 4: (Count) Limits the total number of packets sent to 4. Without this flag on Linux, ping will run indefinitely until you stop it manually with Ctrl + C

#########################################################################################
15. journalctl -u ssh 
Jul 07 08:01:02 ubuntu-host sshd[2177]: error: kex_exchange_identification: Connection closed by remote host
Jul 07 08:01:02 ubuntu-host sshd[2177]: Connection closed by 10.244.54.188 port 60276
Jul 07 08:01:02 ubuntu-host sshd[2178]: Connection closed by authenticating user root 10.244.54.188 port 60292 [preauth]
Jul 07 08:01:02 ubuntu-host sshd[2181]: Accepted password for root from 10.244.54.188 port 60300 ssh2
Jul 07 08:01:02 ubuntu-host sshd[2181]: pam_unix(sshd:session): session opened for user root(uid=0) by (uid=0)
Jul 07 08:01:02 ubuntu-host sshd[2181]: Received disconnect from 10.244.54.188 port 60300:11: disconnected by user
Jul 07 08:01:02 ubuntu-host sshd[2181]: Disconnected from user root 10.244.54.188 port 60300
Jul 07 08:01:02 ubuntu-host sshd[2181]: pam_unix(sshd:session): session closed for user root
Jul 07 08:01:02 ubuntu-host sshd[2196]: Accepted publickey for root from 10.244.54.188 port 60306 ssh2: RSA SHA256:NKPOq9aSIaxLhIZyoGJmz+blYo0XmN/j1MVVyIIro5g

The journalctl -u ssh command views the system logs

journalctl -u ssh -f
-f See live updates (Real-time tracking)

journalctl -u ssh -p err
-p Show only errors or failures

journalctl -u ssh --since today
--since See logs from today only

journalctl -u ssh -e
-e Jump straight to the end of the log
#########################################################################################

tail -n 5 /etc/sudoers.d/README 
#
# Finally, please note that using the visudo command is the recommended way
# to update sudoers content, since it protects against many failure modes.
# See the man page for visudo and sudoers for more information.
#

tail command displays the last 5 lines of the documentation file 

 tail -n 5 /etc/sudoers.d/README -f
#
# Finally, please note that using the visudo command is the recommended way
# to update sudoers content, since it protects against many failure modes.
# See the man page for visudo and sudoers for more information.

-f See live updates (Real-time tracking)
