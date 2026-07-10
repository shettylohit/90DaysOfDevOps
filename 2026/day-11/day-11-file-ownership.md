
Task 1: Understanding Ownership (10 minutes)

Run ls -l in your home directory

Identify the owner and group columns

Check who owns your files




root@ubuntu-host ~ ➜  ls -l 

total 4

-rw-r--r-- 1 root root    0 Jul 10 15:35 hello.txt

drwxr-xr-x 2 root root 4096 Jul 10 15:35 test1



File and directory both are owned by root 


Difference between owner and group 

Owner (User) – the user who owns the file.

Group – a group of users who share certain permissions.

##################################################################################


Task 2: Basic chown Operations (20 minutes)

Create file devops-file.txt

Check current owner: ls -l devops-file.txt

Change owner to tokyo (create user if needed)

Change owner to berlin

Verify the changes



root@ubuntu-host ~ ➜  touch devops-file.txt



root@ubuntu-host ~ ➜  ls -l

total 4

-rw-r--r-- 1 root root    0 Jul 10 15:39 devops-file.txt

-rw-r--r-- 1 root root    0 Jul 10 15:35 hello.txt

drwxr-xr-x 2 root root 4096 Jul 10 15:35 test1



root@ubuntu-host ~ ➜  chown tokyo devops-file.txt 



root@ubuntu-host ~ ➜  ls -l 

total 4

-rw-r--r-- 1 tokyo root    0 Jul 10 15:39 devops-file.txt

-rw-r--r-- 1 root  root    0 Jul 10 15:35 hello.txt

drwxr-xr-x 2 root  root 4096 Jul 10 15:35 test1



root@ubuntu-host ~ ➜  chown berlin  devops-file.txt



root@ubuntu-host ~ ➜  ls -l 

total 4

-rw-r--r-- 1 berlin root    0 Jul 10 15:39 devops-file.txt

-rw-r--r-- 1 root   root    0 Jul 10 15:35 hello.txt

drwxr-xr-x 2 root   root 4096 Jul 10 15:35 test1

######################################################################################



Task 3: Basic chgrp Operations (15 minutes)

Create file team-notes.txt

Check current group: ls -l team-notes.txt

Create group: sudo groupadd heist-team

Change file group to heist-team

Verify the change



root@ubuntu-host ~ ➜  touch team-notes.txt



root@ubuntu-host ~ ➜  ls -l 

total 4

-rw-r--r-- 1 berlin root    0 Jul 10 15:39 devops-file.txt

-rw-r--r-- 1 root   root    0 Jul 10 15:35 hello.txt


-rw-r--r-- 1 root   root    0 Jul 10 15:40 team-notes.txt

drwxr-xr-x 2 root   root 4096 Jul 10 15:35 test1



root@ubuntu-host ~ ➜  sudo groupadd heist-team



root@ubuntu-host ~ ➜  chgrp heist-team team-notes.txt 



root@ubuntu-host ~ ➜  ls -l 

total 4

-rw-r--r-- 1 berlin root          0 Jul 10 15:39 devops-file.txt

-rw-r--r-- 1 root   root          0 Jul 10 15:35 hello.txt

-rw-r--r-- 1 root   heist-team    0 Jul 10 15:40 team-notes.txt

drwxr-xr-x 2 root   root       4096 Jul 10 15:35 test1

#########################################################################################


Task 4: Combined Owner & Group Change (15 minutes)

Using chown you can change both owner and group together:



Create file project-config.yaml

Change owner to professor AND group to heist-team (one command)

Create directory app-logs/

Change its owner to berlin and group to heist-team



root@ubuntu-host ~ ➜  touch project-config.yaml



root@ubuntu-host ~ ls -l 

total 4

-rw-r--r-- 1 berlin root          0 Jul 10 15:39 devops-file.txt

-rw-r--r-- 1 root   root          0 Jul 10 15:35 hello.txt

-rw-r--r-- 1 root   root          0 Jul 10 15:42 project-config.yaml

-rw-r--r-- 1 root   heist-team    0 Jul 10 15:40 team-notes.txt

drwxr-xr-x 2 root   root       4096 Jul 10 15:35 test1



root@ubuntu-host ~ ➜  chown professor:heist-team project-config.yaml



root@ubuntu-host ~ ➜  ls -l 

total 4

-rw-r--r-- 1 berlin    root          0 Jul 10 15:39 devops-file.txt

-rw-r--r-- 1 root      root          0 Jul 10 15:35 hello.txt

-rw-r--r-- 1 professor heist-team    0 Jul 10 15:42 project-config.yaml

-rw-r--r-- 1 root      heist-team    0 Jul 10 15:40 team-notes.txt
drwxr-xr-x 2 root      root       4096 Jul 10 15:35 test1



root@ubuntu-host ~ ➜  mkdir app-logs



root@ubuntu-host ~ ➜  ls -l 

total 8

drwxr-xr-x 2 root      root       4096 Jul 10 15:44 app-logs

-rw-r--r-- 1 berlin    root          0 Jul 10 15:39 devops-file.txt

-rw-r--r-- 1 root      root          0 Jul 10 15:35 hello.txt

-rw-r--r-- 1 professor heist-team    0 Jul 10 15:42 project-config.yaml


-rw-r--r-- 1 root      heist-team    0 Jul 10 15:40 team-notes.txt

drwxr-xr-x 2 root      root       4096 Jul 10 15:35 test1



root@ubuntu-host ~ ➜  chown berlin:heist-team app-logs/



root@ubuntu-host ~ ➜  ls -l 

total 8

drwxr-xr-x 2 berlin    heist-team 4096 Jul 10 15:44 app-logs

-rw-r--r-- 1 berlin    root          0 Jul 10 15:39 devops-file.txt

-rw-r--r-- 1 root      root          0 Jul 10 15:35 hello.txt

-rw-r--r-- 1 professor heist-team    0 Jul 10 15:42 project-config.yaml

-rw-r--r-- 1 root      heist-team    0 Jul 10 15:40 team-notes.txt

drwxr-xr-x 2 root      root       4096 Jul 10 15:35 test1


######################################################################################



Task 5: Recursive Ownership (20 minutes)

Create directory structure:



mkdir -p heist-project/vault

mkdir -p heist-project/plans

touch heist-project/vault/gold.txt

touch heist-project/plans/strategy.conf

Create group planners: sudo groupadd planners


Change ownership of entire heist-project/ directory:


Owner: professor

Group: planners

Use recursive flag (-R)

Verify all files and subdirectories changed: ls -lR heist-project/



root@ubuntu-host ~ ➜  ls -l heist-project/

total 8

drwxr-xr-x 2 root root 4096 Jul 10 15:49 plans

drwxr-xr-x 2 root root 4096 Jul 10 15:49 vault

root@ubuntu-host ~ ➜  chown -R professor:planners heist-project/


root@ubuntu-host ~ ➜  ls -lR heist-project/

heist-project/:

total 8

drwxr-xr-x 2 professor planners 4096 Jul 10 15:49 plans

drwxr-xr-x 2 professor planners 4096 Jul 10 15:49 vault



heist-project/plans:

total 0

-rw-r--r-- 1 professor planners 0 Jul 10 15:49 strategy.conf



heist-project/vault:
total 0

-rw-r--r-- 1 professor planners 0 Jul 10 15:49 gold.txt

##########################################################################################


Task 6: Practice Challenge (20 minutes)

Create users: tokyo, berlin, nairobi (if not already created)



Create groups: vault-team, tech-team



Create directory: bank-heist/

Create 3 files inside:


touch bank-heist/access-codes.txt

touch bank-heist/blueprints.pdf

touch bank-heist/escape-plan.txt

Set different ownership:



access-codes.txt → owner: tokyo, group: vault-team

blueprints.pdf → owner: berlin, group: tech-team

escape-plan.txt → owner: nairobi, group: vault-team

Verify: ls -l bank-heist/




root@ubuntu-host ~ ➜  ls -lR bank-heist/

bank-heist/:

total 0

-rw-r--r-- 1 root root 0 Jul 10 15:54 access-codes.txt

-rw-r--r-- 1 root root 0 Jul 10 15:54 blueprints.pdf

-rw-r--r-- 1 root root 0 Jul 10 15:54 escape-plan.txt


root@ubuntu-host ~ ➜  chown tokyo:vault-team bank-heist/access-codes.txt 



root@ubuntu-host ~ ➜  chown berlin:tech-team bank-heist/blueprints.pdf 


root@ubuntu-host ~ ➜  chown nairobi:vault-team bank-heist/escape-plan.txt 


root@ubuntu-host ~ ➜  ls -lR bank-heist/

bank-heist/:

total 0

-rw-r--r-- 1 tokyo   vault-team 0 Jul 10 15:54 access-codes.txt

-rw-r--r-- 1 berlin  tech-team  0 Jul 10 15:54 blueprints.pdf

-rw-r--r-- 1 nairobi vault-team 0 Jul 10 15:54 escape-plan.txt


root@ubuntu-host ~ ➜  
