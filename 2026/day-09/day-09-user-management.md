Task 1: Create Users 

Create three users with home directories and passwords:

tokyo

berlin

professor

Verify: Check /etc/passwd and /home/ directory
 
      sudo adduser tokyo
      sudo useradd berlin
      sudo useradd professor
      
      sudo passwd tokyo
      sudo passwd berlin
      sudo passwd professor
      
    cd /home
    [root@ip-172-31-24-184 home]# ls
    berlin  ec2-user  professor  tokyo

    cat /etc/passwd
    tokyo:x:1001:1001::/home/tokyo:/bin/bash
    berlin:x:1002:1002::/home/berlin:/bin/bash
    professor:x:1003:1003::/home/professor:/bin/bash

  
    [root@ip-172-31-24-184 home]# cat /etc/shadow
    
    tokyo:$6$ZjzDp9k1hDGjWnqF$JfALaRIHOrG4P7UNAlmUZ5WDZWxOKjmPjWS9PPsjXTcNLM6tRr62usN.2kAaFuH/oDjqEHnRZrPV96LkIhiFg/:20643:0:99999:7:::
    berlin:$6$H/daP2ezhfDa4dwe$QFC3QIGtYJ04lPRcT5JuDf7Z/6b2DzV0/SmaFj12ML5vBB6bQGfZlntIy/ivLjwNtuPsDQ.M0zdCjqaONEJlt1:20643:0:99999:7:::
    professor:$6$GmfTc6fC/tcySivN$KoYOZLHc81/WxaSXBEAB1gwbym/tdsfwLXQTB0J3DmZSdXM3TmqRCZXjLuqYzGTlcs52MwnsGrc/Hayn6rl1e.:20643:0:99999:7:::

Task 2: Create Groups

Create two groups:


developers

admins

Verify: Check /etc/group

    [ec2-user@ip-172-31-24-184 ~]$ sudo groupadd admins
    [ec2-user@ip-172-31-24-184 ~]$ sudo groupadd developers 
    
    
    [ec2-user@ip-172-31-24-184 ~]$ cat /etc/group
    admins:x:1004:
    developers:x:1005:

Task 3: Assign to Groups

Assign users:


tokyo → developers

berlin → developers + admins (both groups)

professor → admins

    [ec2-user@ip-172-31-24-184 ~]$ sudo usermod -aG developers tokyo 
    [ec2-user@ip-172-31-24-184 ~]$ sudo usermod -aG developers berlin 
    [ec2-user@ip-172-31-24-184 ~]$ sudo usermod -aG admins berlin 
    [ec2-user@ip-172-31-24-184 ~]$ sudo usermod -aG admins professor 

    [ec2-user@ip-172-31-24-184 ~]$ cat /etc/group
    admins:x:1004:berlin,professor
    developers:x:1005:tokyo,berlin

Task 4: Shared Directory

Create directory: /opt/dev-project

Set group owner to developers

Set permissions to 775 (rwxrwxr-x)

Test by creating files as tokyo and berlin


    [ec2-user@ip-172-31-24-184 opt]$ mkdir dev-project
    [ec2-user@ip-172-31-24-184 opt]$ ls -l  
    total 0
    drwxr-xr-x. 4 root root 33 Jul  2 20:05 aws
    drwx--x--x. 4 root root 28 Jul  9 14:02 containerd
    drwxr-xr-x. 2 root root  6 Jul  9 15:20 dev-project
    
    
    [ec2-user@ip-172-31-24-184 opt]$ sudo chgrp developers dev-project/
    [ec2-user@ip-172-31-24-184 opt]$ ls -l 
    total 0
    drwxr-xr-x. 4 root root       33 Jul  2 20:05 aws
    drwx--x--x. 4 root root       28 Jul  9 14:02 containerd
    drwxr-xr-x. 2 root developers  6 Jul  9 15:20 dev-project

    [ec2-user@ip-172-31-24-184 opt]$ sudo chmod 775 dev-project/
    [ec2-user@ip-172-31-24-184 opt]$ ls -l 
    total 0
    drwxr-xr-x. 4 root root       33 Jul  2 20:05 aws
    drwx--x--x. 4 root root       28 Jul  9 14:02 containerd
    drwxrwxr-x. 2 root developers  6 Jul  9 15:20 dev-project

    [ec2-user@ip-172-31-24-184 opt]$ su tokyo
    Password: 
    [tokyo@ip-172-31-24-184 opt]$ pwd
    /opt
    [tokyo@ip-172-31-24-184 opt]$ touch tokyo_hello.tkt 
    touch: cannot touch 'tokyo_hello.tkt': Permission denied
    
    
    [tokyo@ip-172-31-24-184 opt]$ su berlin
    Password: 
    [berlin@ip-172-31-24-184 opt]$ touch berlin_hello.tkt
    touch: cannot touch 'berlin_hello.tkt': Permission denied

Task 5: Team Workspace

Create user nairobi with home directory

Create group project-team

Add nairobi and tokyo to project-team

Create /opt/team-workspace directory

Set group to project-team, permissions to 775

Test by creating file as nairobi

    [ec2-user@ip-172-31-24-184 opt]$ sudo useradd nairobi 
    

    [ec2-user@ip-172-31-24-184 opt]$ sudo groupadd project-team
    
    [ec2-user@ip-172-31-24-184 opt]$ sudo usermod -aG project-team nairobi 
    [ec2-user@ip-172-31-24-184 opt]$ sudo usermod -aG project-team tokyo 

    
    [ec2-user@ip-172-31-24-184 opt]$ sudo mkdir /opt/team-workspace
    [ec2-user@ip-172-31-24-184 opt]$ cd /opt/
    [ec2-user@ip-172-31-24-184 opt]$ ls -l 
    total 0
    drwxr-xr-x. 4 root root       33 Jul  2 20:05 aws
    drwx--x--x. 4 root root       28 Jul  9 14:02 containerd
    drwxrwxr-x. 2 root developers  6 Jul  9 15:20 dev-project
    drwxr-xr-x. 2 root root        6 Jul  9 15:35 team-workspace
    
    

    [ec2-user@ip-172-31-24-184 opt]$ sudo chmod 775 team-workspace/
    [ec2-user@ip-172-31-24-184 opt]$ ls -l 
    total 0
    drwxr-xr-x. 4 root root       33 Jul  2 20:05 aws
    drwx--x--x. 4 root root       28 Jul  9 14:02 containerd
    drwxrwxr-x. 2 root developers  6 Jul  9 15:20 dev-project
    drwxrwxr-x. 2 root root        6 Jul  9 15:35 team-workspace
    
    [ec2-user@ip-172-31-24-184 opt]$ sudo chgrp project-team team-workspace/
    [ec2-user@ip-172-31-24-184 opt]$ ls -l 
    total 0
    drwxr-xr-x. 4 root root         33 Jul  2 20:05 aws
    drwx--x--x. 4 root root         28 Jul  9 14:02 containerd
    drwxrwxr-x. 2 root developers    6 Jul  9 15:20 dev-project
    drwxrwxr-x. 2 root project-team  6 Jul  9 15:35 team-workspace
    
    
    [ec2-user@ip-172-31-24-184 opt]$ su nairobi 
    Password: 
    [nairobi@ip-172-31-24-184 opt]$ ls -l 
    total 0
    drwxr-xr-x. 4 root root         33 Jul  2 20:05 aws
    drwx--x--x. 4 root root         28 Jul  9 14:02 containerd
    drwxrwxr-x. 2 root developers    6 Jul  9 15:20 dev-project
    drwxrwxr-x. 2 root project-team  6 Jul  9 15:35 team-workspace
    
    [nairobi@ip-172-31-24-184 opt]$ touch nairobi_hello.txt 
    touch: cannot touch 'nairobi_hello.txt': Permission denied



