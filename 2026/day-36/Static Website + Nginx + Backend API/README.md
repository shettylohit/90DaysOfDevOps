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
