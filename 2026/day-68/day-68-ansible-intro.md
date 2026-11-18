# Inventory File
```
root@ansible-controller ~/playbooks ➜  cat inventory 
[web]
web1 ansible_host=10.244.223.75 ansible_ssh_pass=Passw0rd ansible_user=root
web2 ansible_host=10.244.51.174 ansible_ssh_pass=Passw0rd ansible_user=root
```

# Verify Ansible can reach all hosts:

```
root@ansible-controller ~/playbooks ➜  ansible all -i inventory -m ping
web2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
web1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

# Check uptime on all servers:
```
root@ansible-controller ~/playbooks ➜  ansible all -i inventory -m command -a "uptime"
web2 | CHANGED | rc=0 >>
 02:39:11 up 12:15,  0 user,  load average: 1.19, 1.10, 1.14
web1 | CHANGED | rc=0 >>
 02:39:11 up 12:15,  0 user,  load average: 1.68, 1.18, 1.05
```
# Check free memory on web servers only
```
root@ansible-controller ~/playbooks ➜  ansible web -i inventory -m command -a "free -h"
web1 | CHANGED | rc=0 >>
               total        used        free      shared  buff/cache   available
Mem:            61Gi        15Gi       5.2Gi       304Mi        42Gi        46Gi
Swap:             0B          0B          0B
web2 | CHANGED | rc=0 >>
               total        used        free      shared  buff/cache   available
Mem:            61Gi        17Gi        14Gi       579Mi        31Gi        44Gi
Swap:             0B          0B          0B
```

# Check disk space on all servers:
```
root@ansible-controller ~/playbooks ➜  ansible all -i inventory -m command -a "df -h"
web2 | CHANGED | rc=0 >>
Filesystem      Size  Used Avail Use% Mounted on
overlay         437G  137G  278G  33% /
tmpfs            64M     0   64M   0% /dev
tmpfs            31G   44K   31G   1% /run
tmpfs            31G     0   31G   0% /run/lock
tmpfs            31G  8.0M   31G   1% /var/log/journal
shm              64M     0   64M   0% /dev/shm
/dev/md2        437G  137G  278G  33% /etc/hosts
tmpfs           6.2G   13M  6.2G   1% /etc/hostname
tmpfs           500M   12K  500M   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs            31G     0   31G   0% /proc/acpi
tmpfs            31G     0   31G   0% /proc/scsi
tmpfs            31G     0   31G   0% /sys/firmware
tmpfs            31G     0   31G   0% /sys/devices/virtual/powercap
web1 | CHANGED | rc=0 >>
Filesystem      Size  Used Avail Use% Mounted on
overlay         437G  235G  180G  57% /
tmpfs            64M     0   64M   0% /dev
tmpfs            31G   44K   31G   1% /run
tmpfs            31G     0   31G   0% /run/lock
tmpfs            31G  8.0M   31G   1% /var/log/journal
shm              64M     0   64M   0% /dev/shm
/dev/md2        437G  235G  180G  57% /etc/hosts
tmpfs           6.2G   11M  6.2G   1% /etc/hostname
tmpfs           500M   12K  500M   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs            31G     0   31G   0% /proc/acpi
tmpfs            31G     0   31G   0% /proc/scsi
tmpfs            31G     0   31G   0% /sys/firmware
tmpfs            31G     0   31G   0% /sys/devices/virtual/powercap
```

# Install a package on the web group
```
root@ansible-controller ~/playbooks ✖ ansible web -i inventory -m apt -a "name=git state=present" --become
web1 | SUCCESS => {
    "cache_update_time": 1794985803,
    "cache_updated": false,
    "changed": false
}
web2 | SUCCESS => {
    "cache_update_time": 1794985813,
    "cache_updated": false,
    "changed": false
}
```
# Copy a file to all servers
```
root@ansible-controller ~/playbooks ➜  echo "Hello from Ansible" > hello.txt
ansible all -i inventory -m copy -a "src=hello.txt dest=/tmp/hello.txt"
web2 | CHANGED => {
    "changed": true,
    "checksum": "9b02adc484350380842c4c735d57a1ad071ff0a1",
    "dest": "/tmp/hello.txt",
    "gid": 0,
    "group": "root",
    "md5sum": "914d64e550abfbc035d79d50e214e47d",
    "mode": "0644",
    "owner": "root",
    "size": 19,
    "src": "/root/.ansible/tmp/ansible-tmp-1794987660.2956398-3422-189961913910682/.source.txt",
    "state": "file",
    "uid": 0
}
web1 | CHANGED => {
    "changed": true,
    "checksum": "9b02adc484350380842c4c735d57a1ad071ff0a1",
    "dest": "/tmp/hello.txt",
    "gid": 0,
    "group": "root",
    "md5sum": "914d64e550abfbc035d79d50e214e47d",
    "mode": "0644",
    "owner": "root",
    "size": 19,
    "src": "/root/.ansible/tmp/ansible-tmp-1794987660.287556-3421-138454056389134/.source.txt",
    "state": "file",
    "uid": 0
}

```
# Verify the file was copied

```
root@ansible-controller ~/playbooks ➜  ansible all -i inventory -m command -a "cat /tmp/hello.txt"
web2 | CHANGED | rc=0 >>
Hello from Ansible
web1 | CHANGED | rc=0 >>
Hello from Ansible
```
# Create an ansible.cfg to avoid typing -i inventory.ini every time:
```
root@ansible-controller ~/playbooks ➜  cat ansible.cfg 
[defaults]

inventory         = $HOME/playbooks/inventory
host_key_checking = false
interpreter_python = /usr/bin/python3.12
```
# Use ping module with inventory file
```
root@ansible-controller ~/playbooks ➜  ansible all -m ping
web2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
web1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

root@ansible-controller ~/playbooks ➜
```
