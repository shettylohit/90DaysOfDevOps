# Ansible Playbooks

## `install-nginx.yml`

```yaml
---
- name: Install and start Nginx on web servers
  hosts: web
  become: true

  tasks:
    - name: Install Nginx
      yum:
        name: nginx
        state: present

    - name: Start and enable Nginx
      service:
        name: nginx
        state: started
        enabled: true

    - name: Create a custom index page
      copy:
        content: "<h1>Deployed by Ansible - TerraWeek Server</h1>"
        dest: /usr/share/nginx/html/index.html
```

---

## Understand Playbook Structure

```yaml
---
- name: Install Nginx
  hosts: web
  become: true

  tasks:
    - name: Install package
      yum:
        name: nginx
        state: present
```

| Component | Meaning |
|-----------|---------|
| `---` | Indicates the beginning of a YAML document |
| `name` | Describes the play or task |
| `hosts` | Specifies which inventory group to target |
| `become` | Enables privilege escalation (sudo) |
| `tasks` | Contains the list of tasks |
| `yum` | Ansible module used to manage packages |
| `state` | Defines the desired state |

---

## `essential-modules.yml`

```yaml
---
- name: Practice Essential Ansible Modules
  hosts: all
  become: true

  tasks:
    - name: Install multiple packages
      yum:
        name:
          - git
          - curl
          - wget
          - tree
        state: present

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
        enabled: true

    - name: Copy application config
      copy:
        src: files/app.conf
        dest: /etc/app.conf
        owner: root
        group: root
        mode: '0644'

    - name: Create application directory
      file:
        path: /opt/myapp
        state: directory
        owner: ec2-user
        mode: '0755'

    - name: Check disk space
      command: df -h
      register: disk_output

    - name: Print disk space
      debug:
        var: disk_output.stdout_lines

    - name: Count running processes
      shell: ps aux | wc -l
      register: process_count

    - name: Show process count
      debug:
        msg: "Total processes: {{ process_count.stdout }}"

    - name: Set timezone in environment
      lineinfile:
        path: /etc/environment
        line: 'TZ=Asia/Kolkata'
        create: true
```

---

## `nginx-config.yml`

```yaml
---
- name: Configure Nginx with a custom config
  hosts: web
  become: true

  tasks:
    - name: Install Nginx
      yum:
        name: nginx
        state: present

    - name: Deploy Nginx config
      copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
        owner: root
        mode: '0644'
      notify: Restart Nginx

    - name: Deploy custom index page
      copy:
        content: "<h1>Managed by Ansible</h1><p>Server: {{ inventory_hostname }}</p>"
        dest: /usr/share/nginx/html/index.html

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
        enabled: true

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```
