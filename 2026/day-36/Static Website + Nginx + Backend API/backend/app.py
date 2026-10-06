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
