This architecture separates the frontend and backend.

```
Browser
   |
   v
Nginx
   |
   ├── /          → Static HTML/CSS/JS
   |
   └── /api/      → Backend API
```
For the backend, we'll use Python Flask and SQLite. The important difference is that Nginx serves the frontend and reverse-proxies /api requests to Flask.

Project structure
```
nginx-task-manager/
│
├── backend/
│   ├── app.py
│   └── tasks.db
│
├── frontend/
│   ├── index.html
│   ├── app.js
│   └── style.css
│
└── nginx/
    └── task-manager.conf
```

With this configuration:
```
http://localhost/
```
returns:
```
frontend/index.html
```
while:
```
http://localhost/api/tasks
```
gets forwarded to:
```
http://127.0.0.1:5000/api/tasks
```
This is the most realistic architecture of the three.

You should think of it as two containers:
```
                         Docker Host
┌───────────────────────────────────────────────────────────┐
│                                                           │
│                    ┌───────────────┐                      │
│                    │    Nginx      │                      │
│                    │   Container   │                      │
│                    │               │                      │
│                    │ Static HTML   │                      │
│                    │ CSS           │                      │
│                    │ JavaScript    │                      │
│                    │               │                      │
│                    │ Port 80       │                      │
│                    └───────┬───────┘                      │
│                            │                              │
│                            │ /api/                        │
│                            ▼                              │
│                    ┌───────────────┐                      │
│                    │ Flask API     │                      │
│                    │  Container    │                      │
│                    │               │                      │
│                    │ Python        │                      │
│                    │ Flask         │                      │
│                    │               │                      │
│                    │ Port 5000     │                      │
│                    └───────┬───────┘                      │
│                            │                              │
│                            ▼                              │
│                    ┌───────────────┐                      │
│                    │   SQLite DB   │                      │
│                    │    tasks.db   │                      │
│                    └───────┬───────┘                      │
│                            │                              │
│                            ▼                              │
│                     Docker Volume                         │
│                                                           │
└───────────────────────────┬───────────────────────────────┘
                            │
                            ▼
                         Browser
                       localhost:80
```
Request flow
When the user opens:
```
http://localhost
```
the request goes:
```
Browser
   │
   ▼
Nginx Container
   │
   ├──────────────► HTML/CSS/JS
   │
   │
   └── /api/tasks ─────► Flask Container
                              │
                              ▼
                           SQLite
```
For example:

Loading the website
```
Browser
   │
   │ GET /
   ▼
Nginx
   │
   ▼
index.html
```
Loading tasks
```
Browser
   │
   │ GET /api/tasks
   ▼
Nginx
   │
   │ reverse proxy
   ▼
Flask
   │
   ▼
SQLite
   │
   ▼
Flask
   │
   ▼
Nginx
   │
   ▼
Browser
```


How to run the application 
```
cd ~/nginx/backend
source venv/bin/activate
gunicorn -w 2 -b 127.0.0.1:5000 app:app
```

In a second terminal:

```
curl http://127.0.0.1:5000/api/tasks     # should return []
```

Run the backend permanently with systemd

```
sudo nano /etc/systemd/system/task-manager.service
ini
[Unit]
Description=Task Manager Flask API
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/nginx/backend
ExecStart=/home/ubuntu/nginx/backend/venv/bin/gunicorn -w 2 -b 127.0.0.1:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl enable --now task-manager
sudo systemctl status task-manager
```

Install Nginx and deploy the frontend

```
sudo apt update && sudo apt install -y nginx
sudo mkdir -p /var/www/task-manager
sudo cp -r ~/nginx/frontend /var/www/task-manager/
```

Enable the Nginx config

```
sudo cp ~/nginx/nginx/task-manager.conf /etc/nginx/sites-available/task-manager
sudo ln -s /etc/nginx/sites-available/task-manager /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default      # avoid conflict on port 80
sudo nginx -t
sudo systemctl reload nginx
```

Open port 80 on AWS

In the EC2 console, go to your instance’s Security Group → Inbound rules and add HTTP, TCP 80, source 0.0.0.0/0.

Open the app

Visit http://<your-ec2-public-ip>/ in your browser. You can also test from the server with curl http://localhost/api/tasks.

Docker compose file

Project layout
```
nginx/                        (your project root)
├── backend/
│   ├── app.py
│   ├── requirements.txt      <- new
│   ├── Dockerfile            <- new
│   └── .dockerignore         <- new
├── frontend/
├── nginx/
│   ├── Dockerfile            <- new
│   └── default.conf          <- new (Docker version of your config)
└── docker-compose.yml        <- new
```

Install Docker on the instance
```
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker ubuntu
newgrp docker        # or log out and back in
```

Stop the old setup (it’s using port 80)
```
sudo systemctl disable --now task-manager
sudo systemctl disable --now nginx
```
Build and run
```
cd ~/nginx
docker compose up -d --build
docker compose ps
```
