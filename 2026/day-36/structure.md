# 1\. Python Flask \+ SQLite

 This version is the easiest to understand if you're learning backend development.

 ### Project structure

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

 ## `requirements.txt`

```
Flask==3.1.2
```

 ## `app.py`

```
from flask import Flask, request, jsonify, render_template
import sqlite3

app = Flask(__name__)

DATABASE = "tasks.db"

def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()

    conn.execute("""
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            completed INTEGER DEFAULT 0
        )
    """)

    conn.commit()
    conn.close()

@app.route("/")
def home():
    return render_template("index.html")

# GET all tasks
@app.route("/api/tasks", methods=["GET"])
def get_tasks():
    conn = get_db()

    tasks = conn.execute(
        "SELECT * FROM tasks ORDER BY id DESC"
    ).fetchall()

    conn.close()

    return jsonify([dict(task) for task in tasks])

# GET one task
@app.route("/api/tasks/<int:task_id>", methods=["GET"])
def get_task(task_id):
    conn = get_db()

    task = conn.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    conn.close()

    if task is None:
        return jsonify({"error": "Task not found"}), 404

    return jsonify(dict(task))

# CREATE task
@app.route("/api/tasks", methods=["POST"])
def create_task():
    data = request.get_json()

    title = data.get("title")
    description = data.get("description", "")

    if not title:
        return jsonify({"error": "Title is required"}), 400

    conn = get_db()

    cursor = conn.execute(
        """
        INSERT INTO tasks (title, description)
        VALUES (?, ?)
        """,
        (title, description)
    )

    conn.commit()

    task_id = cursor.lastrowid

    task = conn.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    conn.close()

    return jsonify(dict(task)), 201

# UPDATE task
@app.route("/api/tasks/<int:task_id>", methods=["PUT"])
def update_task(task_id):
    data = request.get_json()

    title = data.get("title")
    description = data.get("description", "")
    completed = data.get("completed", 0)

    conn = get_db()

    existing = conn.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    if existing is None:
        conn.close()
        return jsonify({"error": "Task not found"}), 404

    conn.execute(
        """
        UPDATE tasks
        SET title = ?, description = ?, completed = ?
        WHERE id = ?
        """,
        (title, description, completed, task_id)
    )

    conn.commit()

    task = conn.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    conn.close()

    return jsonify(dict(task))

# DELETE task
@app.route("/api/tasks/<int:task_id>", methods=["DELETE"])
def delete_task(task_id):
    conn = get_db()

    existing = conn.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    if existing is None:
        conn.close()
        return jsonify({"error": "Task not found"}), 404

    conn.execute(
        "DELETE FROM tasks WHERE id = ?",
        (task_id,)
    )

    conn.commit()
    conn.close()

    return jsonify({
        "message": "Task deleted successfully"
    })

if __name__ == "__main__":
    init_db()

    app.run(
        debug=True,
        host="0.0.0.0",
        port=5000
    )
```

 ## `templates/index.html`

```
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Task Manager - Flask</title>

    <link rel="stylesheet" href="/static/style.css">
</head>

<body>

<div class="container">

    <h1>Task Manager</h1>

    <form id="taskForm">

        <input
            type="text"
            id="title"
            placeholder="Task title"
            required
        >

        <input
            type="text"
            id="description"
            placeholder="Description"
        >

        <button type="submit">
            Add Task
        </button>

    </form>

    <div id="tasks"></div>

</div>

<script>

async function loadTasks() {

    const response = await fetch("/api/tasks");

    const tasks = await response.json();

    const container = document.getElementById("tasks");

    container.innerHTML = "";

    tasks.forEach(task => {

        const div = document.createElement("div");

        div.className = "task";

        div.innerHTML = `
            <div>
                <h3 class="${task.completed ? "completed" : ""}">
                    ${task.title}
                </h3>

                <p>${task.description || ""}</p>
            </div>

            <div>
                <button onclick="completeTask(${task.id}, ${task.completed})">
                    ${task.completed ? "Undo" : "Complete"}
                </button>

                <button
                    class="delete"
                    onclick="deleteTask(${task.id})"
                >
                    Delete
                </button>
            </div>
        `;

        container.appendChild(div);
    });
}

document.getElementById("taskForm").addEventListener(
    "submit",
    async function(event) {

        event.preventDefault();

        const title = document.getElementById("title").value;
        const description =
            document.getElementById("description").value;

        await fetch("/api/tasks", {

            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                title,
                description
            })
        });

        document.getElementById("taskForm").reset();

        loadTasks();
    }
);

async function completeTask(id, completed) {

    const response = await fetch(`/api/tasks/${id}`);

    const task = await response.json();

    await fetch(`/api/tasks/${id}`, {

        method: "PUT",

        headers: {
            "Content-Type": "application/json"
        },

        body: JSON.stringify({
            title: task.title,
            description: task.description,
            completed: completed ? 0 : 1
        })
    });

    loadTasks();
}

async function deleteTask(id) {

    if (!confirm("Delete this task?")) {
        return;
    }

    await fetch(`/api/tasks/${id}`, {
        method: "DELETE"
    });

    loadTasks();
}

loadTasks();

</script>

</body>

</html>
```

 ## `static/style.css`

```
* {
    box-sizing: border-box;
}

body {
    font-family: Arial, sans-serif;
    background: #f4f6f8;
    margin: 0;
    padding: 40px;
}

.container {
    max-width: 800px;
    margin: auto;
}

h1 {
    text-align: center;
    color: #222;
}

form {
    display: flex;
    gap: 10px;
    margin-bottom: 30px;
}

input {
    flex: 1;
    padding: 12px;
    border: 1px solid #ccc;
    border-radius: 6px;
}

button {
    padding: 10px 16px;
    border: none;
    border-radius: 6px;
    background: #2563eb;
    color: white;
    cursor: pointer;
}

button:hover {
    background: #1d4ed8;
}

.task {
    background: white;
    padding: 20px;
    margin-bottom: 15px;
    border-radius: 8px;

    display: flex;
    justify-content: space-between;
    align-items: center;

    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.08);
}

.completed {
    text-decoration: line-through;
    color: #777;
}

.delete {
    background: #dc2626;
}

.delete:hover {
    background: #b91c1c;
}
```

 ### Run it

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

---

 # 2\. Node.js Express + MongoDB

 This version is good if you want a JavaScript-based full-stack project.

 ### Project structure

```
express-task-manager/
│
├── server.js
├── package.json
├── .env
│
├── models/
│   └── Task.js
│
└── public/
    ├── index.html
    └── style.css
```

 ## `package.json`

```
{
  "name": "express-task-manager",
  "version": "1.0.0",
  "description": "Task manager using Express and MongoDB",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "node --watch server.js"
  },
  "dependencies": {
    "dotenv": "^16.4.7",
    "express": "^5.1.0",
    "mongoose": "^8.19.0"
  }
}
```

 ## `.env`

 For local MongoDB:

```
PORT=3000
MONGO_URI=mongodb://127.0.0.1:27017/taskmanager
```

 If you're using MongoDB Atlas, replace `MONGO_URI` with your Atlas connection string.

 ## `models/Task.js`

```
const mongoose = require("mongoose");

const taskSchema = new mongoose.Schema(
    {
        title: {
            type: String,
            required: true,
            trim: true
        },

        description: {
            type: String,
            default: ""
        },

        completed: {
            type: Boolean,
            default: false
        }
    },

    {
        timestamps: true
    }
);

module.exports = mongoose.model("Task", taskSchema);
```

 ## `server.js`

```
const express = require("express");
const mongoose = require("mongoose");
const path = require("path");
require("dotenv").config();

const Task = require("./models/Task");

const app = express();

const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

app.use(express.static(
    path.join(__dirname, "public")
));

// Connect MongoDB
mongoose
    .connect(process.env.MONGO_URI)
    .then(() => {
        console.log("MongoDB connected");
    })
    .catch(error => {
        console.error("MongoDB connection error:", error);
    });

// GET all tasks
app.get("/api/tasks", async (req, res) => {

    try {

        const tasks = await Task.find()
            .sort({ createdAt: -1 });

        res.json(tasks);

    } catch (error) {

        res.status(500).json({
            error: "Failed to fetch tasks"
        });
    }
});

// GET one task
app.get("/api/tasks/:id", async (req, res) => {

    try {

        const task = await Task.findById(req.params.id);

        if (!task) {
            return res.status(404).json({
                error: "Task not found"
            });
        }

        res.json(task);

    } catch (error) {

        res.status(500).json({
            error: "Failed to fetch task"
        });
    }
});

// CREATE task
app.post("/api/tasks", async (req, res) => {

    try {

        const {
            title,
            description
        } = req.body;

        if (!title) {
            return res.status(400).json({
                error: "Title is required"
            });
        }

        const task = await Task.create({
            title,
            description
        });

        res.status(201).json(task);

    } catch (error) {

        res.status(500).json({
            error: "Failed to create task"
        });
    }
});

// UPDATE task
app.put("/api/tasks/:id", async (req, res) => {

    try {

        const task = await Task.findByIdAndUpdate(
            req.params.id,
            req.body,
            {
                new: true,
                runValidators: true
            }
        );

        if (!task) {
            return res.status(404).json({
                error: "Task not found"
            });
        }

        res.json(task);

    } catch (error) {

        res.status(500).json({
            error: "Failed to update task"
        });
    }
});

// DELETE task
app.delete("/api/tasks/:id", async (req, res) => {

    try {

        const task = await Task.findByIdAndDelete(
            req.params.id
        );

        if (!task) {
            return res.status(404).json({
                error: "Task not found"
            });
        }

        res.json({
            message: "Task deleted successfully"
        });

    } catch (error) {

        res.status(500).json({
            error: "Failed to delete task"
        });
    }
});

// Start server
app.listen(PORT, () => {

    console.log(
        `Server running at http://localhost:${PORT}`
    );

});
```

 ## `public/index.html`

```
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Task Manager - Express</title>

    <link rel="stylesheet" href="style.css">

</head>

<body>

<div class="container">

    <h1>Task Manager</h1>

    <form id="taskForm">

        <input
            id="title"
            type="text"
            placeholder="Task title"
            required
        >

        <input
            id="description"
            type="text"
            placeholder="Description"
        >

        <button type="submit">
            Add Task
        </button>

    </form>

    <div id="tasks"></div>

</div>

<script>

async function loadTasks() {

    const response = await fetch("/api/tasks");

    const tasks = await response.json();

    const container = document.getElementById("tasks");

    container.innerHTML = "";

    tasks.forEach(task => {

        const element = document.createElement("div");

        element.className = "task";

        element.innerHTML = `

            <div>

                <h3 class="${task.completed ? "completed" : ""}">
                    ${task.title}
                </h3>

                <p>
                    ${task.description || ""}
                </p>

            </div>

            <div>

                <button
                    onclick="toggleTask('${task._id}', ${task.completed})"
                >
                    ${task.completed ? "Undo" : "Complete"}
                </button>

                <button
                    class="delete"
                    onclick="deleteTask('${task._id}')"
                >
                    Delete
                </button>

            </div>

        `;

        container.appendChild(element);
    });
}

document
    .getElementById("taskForm")
    .addEventListener("submit", async event => {

        event.preventDefault();

        const title =
            document.getElementById("title").value;

        const description =
            document.getElementById("description").value;

        await fetch("/api/tasks", {

            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                title,
                description
            })

        });

        event.target.reset();

        loadTasks();
    });

async function toggleTask(id, completed) {

    await fetch(`/api/tasks/${id}`, {

        method: "PUT",

        headers: {
            "Content-Type": "application/json"
        },

        body: JSON.stringify({
            completed: !completed
        })

    });

    loadTasks();
}

async function deleteTask(id) {

    if (!confirm("Delete this task?")) {
        return;
    }

    await fetch(`/api/tasks/${id}`, {
        method: "DELETE"
    });

    loadTasks();
}

loadTasks();

</script>

</body>

</html>
```

 ## `public/style.css`

```
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    padding: 40px;

    font-family: Arial, sans-serif;

    background: #f4f6f8;
}

.container {
    max-width: 800px;
    margin: auto;
}

h1 {
    text-align: center;
}

form {
    display: flex;
    gap: 10px;
    margin-bottom: 30px;
}

input {
    flex: 1;

    padding: 12px;

    border: 1px solid #ccc;
    border-radius: 6px;
}

button {
    border: none;
    border-radius: 6px;

    padding: 10px 16px;

    color: white;
    background: #2563eb;

    cursor: pointer;
}

.task {
    display: flex;

    justify-content: space-between;
    align-items: center;

    padding: 20px;

    margin-bottom: 15px;

    background: white;

    border-radius: 8px;

    box-shadow: 0 2px 5px rgba(0, 0, 0, .08);
}

.completed {
    text-decoration: line-through;
    color: #777;
}

.delete {
    background: #dc2626;
}
```

 ### Run it

 First make sure MongoDB is running.

 Then:

```
cd express-task-manager
npm install
npm run dev
```

 Open:

```
http://localhost:3000
```

---

 # 3\. Static Website + Nginx + Backend API

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

 For the backend, we'll use **Python Flask** and SQLite. The important difference is that Nginx serves the frontend and reverse-proxies `/api` requests to Flask.

 ### Project structure

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

---

 ## Backend

 ### `backend/app.py`

```
from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)

DATABASE = "tasks.db"

def get_db():

    conn = sqlite3.connect(DATABASE)

    conn.row_factory = sqlite3.Row

    return conn

def init_db():

    conn = get_db()

    conn.execute("""
        CREATE TABLE IF NOT EXISTS tasks (

            id INTEGER PRIMARY KEY AUTOINCREMENT,

            title TEXT NOT NULL,

            description TEXT,

            completed INTEGER DEFAULT 0

        )
    """)

    conn.commit()

    conn.close()

@app.get("/api/tasks")
def get_tasks():

    conn = get_db()

    tasks = conn.execute(
        "SELECT * FROM tasks ORDER BY id DESC"
    ).fetchall()

    conn.close()

    return jsonify([
        dict(task)
        for task in tasks
    ])

@app.post("/api/tasks")
def create_task():

    data = request.get_json()

    title = data.get("title")

    description = data.get(
        "description",
        ""
    )

    if not title:

        return jsonify({
            "error": "Title is required"
        }), 400

    conn = get_db()

    cursor = conn.execute(
        """
        INSERT INTO tasks
        (title, description)
        VALUES (?, ?)
        """,
        (
            title,
            description
        )
    )

    conn.commit()

    task_id = cursor.lastrowid

    task = conn.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    conn.close()

    return jsonify(
        dict(task)
    ), 201

@app.put("/api/tasks/<int:task_id>")
def update_task(task_id):

    data = request.get_json()

    conn = get_db()

    existing = conn.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    if not existing:

        conn.close()

        return jsonify({
            "error": "Task not found"
        }), 404

    title = data.get(
        "title",
        existing["title"]
    )

    description = data.get(
        "description",
        existing["description"]
    )

    completed = data.get(
        "completed",
        existing["completed"]
    )

    conn.execute(
        """
        UPDATE tasks

        SET
            title = ?,
            description = ?,
            completed = ?

        WHERE id = ?
        """,
        (
            title,
            description,
            completed,
            task_id
        )
    )

    conn.commit()

    task = conn.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    conn.close()

    return jsonify(
        dict(task)
    )

@app.delete("/api/tasks/<int:task_id>")
def delete_task(task_id):

    conn = get_db()

    cursor = conn.execute(
        "DELETE FROM tasks WHERE id = ?",
        (task_id,)
    )

    conn.commit()

    deleted = cursor.rowcount

    conn.close()

    if deleted == 0:

        return jsonify({
            "error": "Task not found"
        }), 404

    return jsonify({
        "message": "Task deleted successfully"
    })

if __name__ == "__main__":

    init_db()

    app.run(
        host="127.0.0.1",
        port=5000
    )
```

---

 # Frontend

 ## `frontend/index.html`

```
<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Task Manager</title>

    <link rel="stylesheet" href="style.css">

</head>

<body>

    <main class="container">

        <h1>Task Manager</h1>

        <form id="taskForm">

            <input
                id="title"
                placeholder="Task title"
                required
            >

            <input
                id="description"
                placeholder="Description"
            >

            <button>
                Add Task
            </button>

        </form>

        <section id="tasks"></section>

    </main>

    <script src="app.js"></script>

</body>

</html>
```

 ## `frontend/app.js`

```
const API = "/api/tasks";

async function loadTasks() {

    const response = await fetch(API);

    const tasks = await response.json();

    const container =
        document.getElementById("tasks");

    container.innerHTML = "";

    tasks.forEach(task => {

        const element =
            document.createElement("div");

        element.className = "task";

        element.innerHTML = `

            <div>

                <h3 class="${task.completed ? "completed" : ""}">
                    ${task.title}
                </h3>

                <p>
                    ${task.description || ""}
                </p>

            </div>

            <div>

                <button
                    onclick="
                        toggleTask(
                            ${task.id},
                            ${task.completed}
                        )
                    "
                >
                    ${task.completed
                        ? "Undo"
                        : "Complete"}
                </button>

                <button
                    class="delete"
                    onclick="
                        deleteTask(${task.id})
                    "
                >
                    Delete
                </button>

            </div>
        `;

        container.appendChild(element);
    });
}

document
    .getElementById("taskForm")
    .addEventListener(
        "submit",
        async event => {

            event.preventDefault();

            const title =
                document.getElementById(
                    "title"
                ).value;

            const description =
                document.getElementById(
                    "description"
                ).value;

            await fetch(API, {

                method: "POST",

                headers: {
                    "Content-Type":
                        "application/json"
                },

                body: JSON.stringify({
                    title,
                    description
                })
            });

            event.target.reset();

            loadTasks();
        }
    );

async function toggleTask(
    id,
    completed
) {

    await fetch(`${API}/${id}`, {

        method: "PUT",

        headers: {
            "Content-Type":
                "application/json"
        },

        body: JSON.stringify({
            completed: completed ? 0 : 1
        })
    });

    loadTasks();
}

async function deleteTask(id) {

    if (!confirm(
        "Delete this task?"
    )) {
        return;
    }

    await fetch(`${API}/${id}`, {
        method: "DELETE"
    });

    loadTasks();
}

loadTasks();
```

 ## `frontend/style.css`

```
* {
    box-sizing: border-box;
}

body {
    margin: 0;

    padding: 40px;

    font-family: Arial, sans-serif;

    background: #f4f6f8;
}

.container {
    max-width: 800px;

    margin: auto;
}

h1 {
    text-align: center;
}

form {
    display: flex;

    gap: 10px;

    margin-bottom: 30px;
}

input {
    flex: 1;

    padding: 12px;

    border: 1px solid #ccc;

    border-radius: 6px;
}

button {
    padding: 10px 16px;

    border: none;

    border-radius: 6px;

    background: #2563eb;

    color: white;

    cursor: pointer;
}

.task {
    display: flex;

    justify-content: space-between;

    align-items: center;

    padding: 20px;

    margin-bottom: 15px;

    background: white;

    border-radius: 8px;

    box-shadow:
        0 2px 5px
        rgba(0, 0, 0, 0.08);
}

.completed {
    text-decoration: line-through;

    color: #777;
}

.delete {
    background: #dc2626;
}
```

---

 # Nginx configuration

 The important part of this version is Nginx.

 ## `nginx/task-manager.conf`

```
server {

    listen 80;

    server_name localhost;

    # Frontend

    root /var/www/task-manager/frontend;

    index index.html;

    location / {

        try_files $uri $uri/ /index.html;

    }

    # Backend API

    location /api/ {

        proxy_pass http://127.0.0.1:5000;

        proxy_http_version 1.1;

        proxy_set_header Host $host;

        proxy_set_header X-Real-IP $remote_addr;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
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

---




Absolutely. Think of Dockerizing each project as **putting each major component into its own container**. You don't need to write the Docker files yet—the diagrams below show what you need to build.

 ## 1\. Flask + SQLite — Dockerized

 Your original project:

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
│                      │                        │
│                      ▼                        │
│              ┌───────────────┐               │
│              │ SQLite DB     │               │
│              │ tasks.db      │               │
│              └───────────────┘               │
│                      ▲                        │
│                      │                        │
│                Docker Volume                 │
│              (persist database)              │
│                                              │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
                    Browser
                 localhost:5000
```

 ### What you need to do

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

 **Important:** SQLite doesn't need its own container. The database is simply a file used by the Flask container, and the volume makes sure the file survives container recreation.

---

 # 2\. Express + MongoDB — Dockerized

 This one is more interesting because MongoDB should be a **separate container**.

```
                         Docker Host
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   ┌──────────────────────┐                              │
│   │   Express Container  │                              │
│   │                      │                              │
│   │   Node.js            │                              │
│   │   Express API        │                              │
│   │   Frontend           │                              │
│   │                      │                              │
│   │       Port 3000      │                              │
│   └──────────┬───────────┘                              │
│              │                                          │
│              │ MongoDB connection                       │
│              │ mongodb://mongodb:27017/taskmanager     │
│              ▼                                          │
│   ┌──────────────────────┐                              │
│   │   MongoDB Container  │                              │
│   │                      │                              │
│   │      MongoDB         │                              │
│   │                      │                              │
│   │       Port 27017     │                              │
│   └──────────┬───────────┘                              │
│              │                                          │
│              ▼                                          │
│       ┌───────────────┐                                 │
│       │ Docker Volume │                                 │
│       │ MongoDB Data  │                                 │
│       └───────────────┘                                 │
│                                                         │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
                        Browser
                     localhost:3000
```

 ### The important concept

 You now have **two containers**:

```
┌─────────────────┐
│ Express         │
│ Container       │
│                 │
│ Node.js         │
│ Express         │
└────────┬────────┘
         │
         │ Docker Network
         │
         ▼
┌─────────────────┐
│ MongoDB         │
│ Container       │
│                 │
│ MongoDB         │
└────────┬────────┘
         │
         ▼
    Docker Volume
```

 The Express container **doesn't connect to `localhost` for MongoDB**.

 Instead, Docker provides a network between the containers.

 Conceptually:

```
Express
   │
   │
   └──────► mongodb:27017
                  │
                  ▼
              MongoDB
```

 So your application configuration changes from something like:

```
localhost:27017
```

 to:

```
mongodb:27017
```

 where `mongodb` is the MongoDB container/service name.

---

 # 3\. Nginx + Flask API + SQLite — Dockerized

 This is the most realistic architecture of the three.

 You should think of it as **two containers**:

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
│                     Docker Volume                        │
│                                                           │
└───────────────────────────┬───────────────────────────────┘
                            │
                            ▼
                         Browser
                       localhost:80
```

 ## Request flow

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

 ### Loading the website

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

 ### Loading tasks

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

---

 # All Three Side-by-Side

 This is probably the easiest way to remember the differences.

```
┌──────────────────────────────────────────────────────────┐
│                 PROJECT 1                                │
│              Flask + SQLite                             │
│                                                          │
│   Browser                                                │
│      │                                                   │
│      ▼                                                   │
│ ┌──────────────┐                                         │
│ │ Flask        │                                         │
│ │ Container    │                                         │
│ └──────┬───────┘                                         │
│        ▼                                                 │
│    SQLite + Volume                                       │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                 PROJECT 2                                │
│             Express + MongoDB                            │
│                                                          │
│   Browser                                                │
│      │                                                   │
│      ▼                                                   │
│ ┌──────────────┐                                         │
│ │ Express      │                                         │
│ │ Container    │                                         │
│ └──────┬───────┘                                         │
│        │ Docker Network                                  │
│        ▼                                                 │
│ ┌──────────────┐                                         │
│ │ MongoDB      │                                         │
│ │ Container    │                                         │
│ └──────┬───────┘                                         │
│        ▼                                                 │
│    MongoDB Volume                                        │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                 PROJECT 3                                │
│           Nginx + Flask + SQLite                         │
│                                                          │
│   Browser                                                │
│      │                                                   │
│      ▼                                                   │
│ ┌──────────────┐                                         │
│ │ Nginx        │                                         │
│ │ Container    │                                         │
│ └──────┬───────┘                                         │
│        │                                                 │
│        │ /api                                            │
│        ▼                                                 │
│ ┌──────────────┐                                         │
│ │ Flask API    │                                         │
│ │ Container    │                                         │
│ └──────┬───────┘                                         │
│        ▼                                                 │
│    SQLite + Volume                                       │
└──────────────────────────────────────────────────────────┘
```

 # What Docker concepts you are learning

 The three projects together give you a very good introduction to Docker:

```
                    DOCKER
                       │
       ┌───────────────┼────────────────┐
       ▼               ▼                ▼
    Images         Containers        Volumes
       │               │                │
       │               │                │
       ▼               ▼                ▼
   Package app     Run app         Persist data
       │               │                │
       └───────────────┼────────────────┘
                       │
                       ▼
                   Networks
                       │
                       ▼
              Container ↔ Container
```

 Specifically:

 | Project | Containers | Volume | Network |
| --- | --- | --- | --- |
| Flask + SQLite | 1 | SQLite volume | Not necessary |
| Express + MongoDB | 2 | MongoDB volume | **Required** |
| Nginx + Flask + SQLite | 2 | SQLite volume | **Required** |

## The final mental model

 Don't think:

 > "I need to Dockerize my entire project."

 Think:

 > **"What processes do I have, and which process should run in which container?"**

 For your three projects:

```
Flask project
    ↓
1 application process
    ↓
1 container

Express + MongoDB
    ↓
2 processes
    ↓
2 containers

Nginx + Flask
    ↓
2 processes
    ↓
2 containers
```

 And **databases get volumes** because containers themselves are disposable.

 That's the core Docker architecture you need to understand before writing the Dockerfiles.
