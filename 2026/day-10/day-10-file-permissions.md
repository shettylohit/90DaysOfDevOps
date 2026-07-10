Task 1: Create Files (10 minutes)

Create empty file devops.txt using touch

Create notes.txt with some content using cat or echo

Create script.sh using vim with content: echo "Hello DevOps"


root@ubuntu-host ~ ➜  touch devops.txt


root@ubuntu-host ~ ➜  echo "This is notes for day 10" > notes.txt

root@ubuntu-host ~ ➜  vim scripts.sh

root@ubuntu-host ~ ➜  ls -l 
total 8
-rw-r--r-- 1 root root  0 Jul 10 13:50 devops.txt
-rw-r--r-- 1 root root 25 Jul 10 13:51 notes.txt
-rw-r--r-- 1 root root 33 Jul 10 13:51 scripts.sh


#########################################################################################

Task 2: Read Files (10 minutes)

Read notes.txt using cat

View script.sh in vim read-only mode

Display first 5 lines of /etc/passwd using head

Display last 5 lines of /etc/passwd using tail


root@ubuntu-host ~ ➜  cat notes.txt 

This is notes for day 10


root@ubuntu-host ~ ➜  vim scripts.sh 


root@ubuntu-host ~ ➜  head -5 /etc/passwd

root:x:0:0:root:/root:/bin/bash

daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin

bin:x:2:2:bin:/bin:/usr/sbin/nologin

sys:x:3:3:sys:/dev:/usr/sbin/nologin

sync:x:4:65534:sync:/bin:/bin/sync


root@ubuntu-host ~ ➜  tail -5 /etc/passwd

_apt:x:100:65534::/nonexistent:/usr/sbin/nologin

messagebus:x:101:101::/nonexistent:/usr/sbin/nologin

sshd:x:102:65534::/run/sshd:/usr/sbin/nologin

systemd-network:x:103:104:systemd Network Management,,,:/run/systemd:/usr/sbin/nologin

systemd-resolve:x:104:105:systemd Resolver,,,:/run/systemd:/usr/sbin/nologin


#################################################################################################

Task 3: Understand Permissions (10 minutes)

Format: rwxrwxrwx (owner-group-others)


r = read (4), w = write (2), x = execute (1)

Check your files: ls -l devops.txt notes.txt script.sh



root@ubuntu-host ~ ➜  ls -l scripts.sh 

-rw-r--r-- 1 root root 33 Jul 10 13:51 scripts.sh



Current permission User: Read/Write, Group: Read, Others: Read


#####################################################################################

Task 4: Modify Permissions (20 minutes)

Make script.sh executable → run it with ./script.sh

Set devops.txt to read-only (remove write for all)

Set notes.txt to 640 (owner: rw, group: r, others: none)

Create directory project/ with permissions 755




root@ubuntu-host ~ ➜  chmod 764 scripts.sh 


root@ubuntu-host ~ ➜  ./scripts.sh 

Hello DevOps



root@ubuntu-host ~ ➜  ls -l 

total 8

-rw-r--r-- 1 root root  0 Jul 10 13:50 devops.txt

-rw-r--r-- 1 root root 25 Jul 10 13:51 notes.txt

-rwxrw-r-- 1 root root 33 Jul 10 13:51 scripts.sh


root@ubuntu-host ~ ➜  chmod 444 devops.txt 



root@ubuntu-host ~ ➜  ls -l 

total 8

-r--r--r-- 1 root root  0 Jul 10 13:50 devops.txt

-rw-r--r-- 1 root root 25 Jul 10 13:51 notes.txt

-rwxrw-r-- 1 root root 33 Jul 10 13:51 scripts.sh



root@ubuntu-host ~ ✖ chmod 640 notes.txt 


root@ubuntu-host ~ ➜  ls -l 

total 8

-r--r--r-- 1 root root  0 Jul 10 13:50 devops.txt

-rw-r----- 1 root root 25 Jul 10 13:51 notes.txt

-rwxrw-r-- 1 root root 33 Jul 10 13:51 scripts.sh



root@ubuntu-host ~ ➜  mkdir project 



root@ubuntu-host ~ ➜  chmod 755 project/



root@ubuntu-host ~ ➜  ls -l 

total 12

-r--r--r-- 1 root root    0 Jul 10 13:50 devops.txt

-rw-r----- 1 root root   25 Jul 10 13:51 notes.txt

drwxr-xr-x 2 root root 4096 Jul 10 13:58 project

-rwxrw-r-- 1 root root   33 Jul 10 13:51 scripts.sh


####################################################################################

Task 5: Test Permissions (10 minutes)

Try writing to a read-only file - what happens?

Try executing a file without execute permission

Document the error messages



When you try to write into a file which has only read permission with root user, root user will be able to rite into a file as the root user has the capability CAP_DAC_OVERRIDE, which allows it to bypass normal file permission checks.


root@ubuntu-host ~ ➜  ls -l 

total 12

-r--r--r-- 1 root root    0 Jul 10 13:50 devops.txt

-rw-r----- 1 root root   25 Jul 10 13:51 notes.txt

drwxr-xr-x 2 root root 4096 Jul 10 13:58 project

-rwxrw-r-- 1 root root   33 Jul 10 13:51 scripts.sh

root@ubuntu-host ~ ➜  echo "Trying to write into file named devops.txt that has only read only permission" >> devops.txt 


root@ubuntu-host ~ ➜  cat devops.txt 

Trying to write into file named devops.txt that has only read only permission


root@ubuntu-host ~ ➜  su - john

$ echo "Hello" >> /root/devops.txt

-sh: 3: cannot create /root/devops.txt: Permission denied



When you try to run a script with the execute permission it will noy run and will give Permission denied error but you can use bash and run the same script with out execute permission 

root@ubuntu-host ~ ➜  vim script_without_ececute_permission.sh 



root@ubuntu-host ~ ➜  ls -l 

total 20

-r--r--r-- 1 root root   87 Jul 10 14:02 devops.txt

-rw-r----- 1 root root   25 Jul 10 13:51 notes.txt

drwxr-xr-x 2 root root 4096 Jul 10 13:58 project

-rwxrw-r-- 1 root root   33 Jul 10 13:51 scripts.sh

-rw-r--r-- 1 root root   39 Jul 10 14:12 script_without_ececute_permission.sh


root@ubuntu-host ~ ➜  bash script_without_ececute_permission.sh 

Hello Good Morning


root@ubuntu-host ~ ➜  ./script_without_ececute_permission.sh 

-bash: ./script_without_ececute_permission.sh: Permission denied



