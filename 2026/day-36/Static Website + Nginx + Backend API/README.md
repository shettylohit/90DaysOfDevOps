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
