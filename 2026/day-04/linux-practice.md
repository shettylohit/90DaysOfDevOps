Process Commands 

ps >>> 
PID TTY          TIME CMD
   2103 pts/1    00:00:00 sudo
   2104 pts/1    00:00:00 su
   2105 pts/1    00:00:00 bash
   2143 pts/1    00:00:00 ps

   top >>>

   top - 06:34:25 up 0 min,  1 user,  load average: 0.79, 0.99, 1.02
Tasks:  12 total,   1 running,  11 sleeping,   0 stopped,   0 zombie
%Cpu(s):  1.8 us,  1.5 sy,  0.0 ni, 96.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :  63339.0 total,  21315.9 free,   9035.9 used,  32987.2 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.  53030.8 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND              
      1 root      20   0  165280  10808   8376 S   0.0   0.0   0:00.14 systemd              
    190 root      20   0   31748  11196  10144 S   0.0   0.0   0:00.04 systemd-journal      
    478 systemd+  20   0   25256  13268   9272 S   0.0   0.0   0:00.09 systemd-resolve      
    871 message+  20   0    8120   4404   3892 S   0.0   0.0   0:00.00 dbus-daemon          
    925 root      20   0   14900   7144   6252 S   0.0   0.0   0:00.07 systemd-logind       
    968 root      20   0    1352    844    740 S   0.0   0.0   0:00.01 ttyd                 
    982 root      20   0   15420   9140   7512 S   0.0   0.0   0:00.00 sshd                 
   2102 root      20   0   10948   5040   4452 S   0.0   0.0   0:00.00 sudo                 
   2103 root      20   0   10948   2196   1612 S   0.0   0.0   0:00.00 sudo                 
   2104 root      20   0   10064   4124   3612 S   0.0   0.0   0:00.00 su                   
   2105 root      20   0    9472   5844   3712 S   0.0   0.0   0:00.01 bash                 
   2329 root      20   0   10612   3824   3244 R   0.0   0.0   0:00.00 top     


pgrep >>>

pgrep -a nginx
3603 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
3604 nginx: worker process                           
3605 nginx: worker process                           



Service commands

systemctl list-units lists the systemd units that are currently loaded. By default, it shows only active units.

systemctl list-units
  UNIT                                                            LOAD   ACTIVE     SUB       DESCRIPTION                                               
  dev-md2.device                                                  loaded activating tentative /dev/md2                                                  
  -.mount                                                         loaded active     mounted   Root Mount
  dev-full.mount                                                  loaded active     mounted   /dev/full
  dev-kmsg.mount                                                  loaded active     mounted   /dev/kmsg
  dev-mqueue.mount                                                loaded active     mounted   POSIX Message Queue File System
  dev-null.mount                                                  loaded active     mounted   /dev/null
  dev-random.mount                                                loaded active     mounted   /dev/random


 systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2026-07-06 06:37:38 UTC; 3min 10s ago
       Docs: man:nginx(8)
    Process: 3601 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 3602 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 3603 (nginx)
      Tasks: 17 (limit: 75795)
     Memory: 14.5M
        CPU: 29ms
     CGroup: /system.slice/nginx.service
             ├─3603 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─3604 "nginx: worker process" "" "




log commands

journalctl -u ssh
Jul 06 04:04:29 ubuntu-host sshd[2023]: error: kex_exchange_identification: Connection closed by remote host
Jul 06 04:04:29 ubuntu-host sshd[2023]: Connection closed by 10.244.150.42 port 45155
Jul 06 06:33:00 ubuntu-host sshd[2046]: error: kex_exchange_identification: Connection closed by remote host
Jul 06 06:33:00 ubuntu-host sshd[2046]: Connection closed by 10.244.28.239 port 55488
Jul 06 06:33:00 ubuntu-host sshd[2047]: Connection closed by authenticating user root 10.244.28.239 port 55494 [preauth]
Jul 06 06:33:00 ubuntu-host sshd[2049]: Accepted password for root from 10.244.28.239 port 55502 ssh2
Jul 06 06:33:00 ubuntu-host sshd[2049]: pam_unix(sshd:session): session opened for user root(uid=0) by (uid=0)
Jul 06 06:33:00 ubuntu-host sshd[2049]: Received disconnect from 10.244.28.239 port 55502:11: disconnected by user
Jul 06 06:33:00 ubuntu-host sshd[2049]: Disconnected from user root 10.244.28.239 port 55502
Jul 06 06:33:00 ubuntu-host sshd[2049]: pam_unix(sshd:session): session closed for user root
Jul 06 06:33:00 ubuntu-host sshd[2064]: Accepted publickey for root from 10.244.28.239 port 55504 ssh2: RSA SHA256:0rJztyoguXsvDYsKjE6FSXO0zfconyfwutZUGGQVAkw
Jul 06 06:33:00 ubuntu-host sshd[2064]: pam_unix(sshd:session): session opened for user root(uid=0) by (uid=0)


tail -n 3 passwd
sshd:x:102:65534::/run/sshd:/usr/sbin/nologin
systemd-network:x:103:104:systemd Network Management,,,:/run/systemd:/usr/sbin/nologin
systemd-resolve:x:104:105:systemd Resolver,,,:/run/systemd:/usr/sbin/nologin


systemctl show ssh
Type=notify
Restart=on-failure
NotifyAccess=main
RestartUSec=100ms
TimeoutStartUSec=1min 30s
TimeoutStopUSec=1min 30s
TimeoutAbortUSec=1min 30s
TimeoutStartFailureMode=terminate
TimeoutStopFailureMode=terminate
RuntimeMaxUSec=infinity
WatchdogUSec=0




Pick one service on your system and inspect it

systemctl status ssh
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2026-07-06 04:04:12 UTC; 2h 43min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 982 (sshd)
      Tasks: 1 (limit: 75795)
     Memory: 1.8M
        CPU: 193ms
     CGroup: /system.slice/ssh.service
             └─982 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
