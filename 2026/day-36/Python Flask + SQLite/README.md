## Python Flask + SQLite

This version is the easiest to understand if you're learning backend development.
```
flask-task-manager/
│
├── app.py
├── requirements.txt
├── tasks.db
│
├── templates/
│   └── index.html
│
└── static/
    └── style.css
```

Run it
```
cd flask-task-manager

python -m venv venv
```
Windows:
```
venv\Scripts\activate
```
Linux/macOS:
```
source venv/bin/activate
```
Then:
```
pip install -r requirements.txt
python app.py
```
Open:
```
http://localhost:5000
```


```
┌──────────────────────────────────────────────┐
│                  Docker Host                 │
│                                              │
│   ┌──────────────────────────────────────┐   │
│   │          Flask Container             │   │
│   │                                      │   │
│   │   Flask App                          │   │
│   │   ├── Routes / API                   │   │
│   │   ├── HTML Templates                 │   │
│   │   └── Static Files                   │   │
│   │                                      │   │
│   │        Port 5000                     │   │
│   └──────────────────┬───────────────────┘   │
│                      │                       │
│                      ▼                       │
│              ┌───────────────┐               │
│              │ SQLite DB     │               │
│              │ tasks.db      │               │
│              └───────────────┘               │
│                      ▲                       │
│                      │                       │
│                Docker Volume                 │
│              (persist database)              │
│                                              │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
                    Browser
                 localhost:5000
```

What you need to do
```
Python application
       │
       ▼
Create Flask Docker image
       │
       ▼
Run Flask container
       │
       ├── Port 5000 → Host
       │
       └── SQLite file → Docker Volume
```
Important: SQLite doesn't need its own container. The database is simply a file used by the Flask container, and the volume makes sure the file survives container recreation.
