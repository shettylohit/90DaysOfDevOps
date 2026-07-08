File system in Linux 

/

root folder starting of everything 
This is the top-level directory of the Linux filesystem.
Everything on the system starts from /.
All other directories are inside it.

/root  

root user's home directory 
This is the home directory of the root (administrator) user.
Only the root user normally has access to it.

/home

user's home directory 
Stores the personal files of normal users.
Each user gets their own folder.

/etc

configuration file 
Contains system-wide configuration files.
Most software stores its configuration here.

/var/log: 

log files
Stores system and application logs.
Logs help troubleshoot problems and monitor system activity.

/tmp

temporary files
Used for temporary files created by applications or the operating system.
Files may be deleted automatically after a reboot or periodically.

/bin

Essential  binary files of commands 
Contains essential command-line programs needed for the system to boot and operat
/bin/ls
/bin/cp
/bin/mv
/bin/cat
/bin/bash


/usr/bin : 

user binary file of commands 
Contains most user applications and commands.
This directory has many more programs than /bin
/usr/bin/python3
/usr/bin/git
/usr/bin/gcc
/usr/bin/vim



/opt: optional/third part application 

Used to install optional or third-party applications that are not part of the core operating system.


Find the largest log file in /var/log


du -sh /var/log/* 2>/dev/null | sort -h | tail -n 5
1.4M	/var/log/sysstat
1.8M	/var/log/installer
1.9M	/var/log/kern.log
8.2M	/var/log/syslog
49M	/var/log/journal


Look at a config file in /etc

cat /etc/hostname 
ubuntu-host


Check your home directory

ls -larta ~
total 36
-rw-r--r-- 1 root root  161 Jul  9  2019 .profile
drwxr-xr-x 2 root root 4096 Mar  1  2023 .config
-rw-r--r-- 1 root root 3135 Mar  1  2023 .bashrc
-rw-r--r-- 1 root root  561 Jul  7 08:55 .bash_profile
dr-xr-xr-x 1 root root 4096 Jul  7 10:43 ..
drwx------ 2 root root 4096 Jul  7 14:33 .ssh
drwx------ 3 root root 4096 Jul  7 14:33 .cache
drwx------ 1 root root 4096 Jul  7 14:34 .
-rw-r--r-- 1 root root  681 Jul  7 14:35 notes.txt





Scenario 1: Service Not Starting

A web application service called 'myapp' failed to start after a server reboot.
What commands would you run to diagnose the issue?

systemctl status myapp       : get the current status 

systemctl restart myapp      : restart the myapp 

systemctl is-enabled myapp   : check if myapp is configured to start automatically after a reboot.

journalctl -u myapp -f       : get realtime log of myapp using journalctl 

journalctl -b                : Shows all logs from the current boot.

ss -tulnp                    : Check whether the service is listening on the expected port




Scenario 2: High CPU Usage

Your manager reports that the application server is slow.
You SSH into the server. What commands would you run to identify
which process is using high CPU?


top /htop: to check all process in real time 

ps -eo pid,user,%cpu,%mem,cmd --sort=-%cpu | head : List the top CPU-consuming processes

ps -fp <PID> : Get detailed information about a specific process


Scenario 3: Finding Service Logs
A developer asks: "Where are the logs for the 'docker' service?"
The service is managed by systemd.
What commands would you use?

journalctl -u docker -f  : to get live logs of docker service
journalctl -u docker -b  : to get docker logs since the last boot
systemctl status docker  : status of docker service 



Scenario 4: File Permissions Issue
A script at /home/user/backup.sh is not executing.
When you run it: ./backup.sh
You get: "Permission denied"

What commands would you use to fix this?

chmod 764 backup.sh 
this command will give Read/Write/Execute permissing for user, Read/Write to group and Read permission to others
