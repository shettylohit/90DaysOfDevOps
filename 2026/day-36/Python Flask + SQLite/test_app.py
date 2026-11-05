
import pytest
import os
from app import app, get_db

@pytest.fixture
def client():
    app.config["TESTING"] = True

    # Use a separate database for testing
    import app as app_module
    app_module.DATABASE = "test_tasks.db"

    conn = get_db()
    conn.execute("""
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            completed INTEGER DEFAULT 0
        )
    """)
    conn.execute("DELETE FROM tasks")
    conn.commit()
    conn.close()

    with app.test_client() as client:
        yield client

    if os.path.exists("test_tasks.db"):
        os.remove("test_tasks.db")


# Test 1: GET all tasks
def test_get_tasks(client):
    response = client.get("/api/tasks")

    assert response.status_code == 200
    assert response.json == []


# Test 2: CREATE a task
def test_create_task(client):
    response = client.post(
        "/api/tasks",
        json={
            "title": "Learn Flask",
            "description": "Practice Flask testing"
        }
    )

    assert response.status_code == 201
    assert response.json["title"] == "Learn Flask"


# Test 3: GET one task
def test_get_single_task(client):
    create_response = client.post(
        "/api/tasks",
        json={"title": "Test Task"}
    )

    task_id = create_response.json["id"]

    response = client.get(f"/api/tasks/{task_id}")

    assert response.status_code == 200
    assert response.json["title"] == "Test Task"


# Test 4: UPDATE a task
def test_update_task(client):
    create_response = client.post(
        "/api/tasks",
        json={"title": "Old Task"}
    )

    task_id = create_response.json["id"]

    response = client.put(
        f"/api/tasks/{task_id}",
        json={
            "title": "Updated Task",
            "description": "Updated description",
            "completed": 1
        }
    )

    assert response.status_code == 200
    assert response.json["title"] == "Updated Task"
    assert response.json["completed"] == 1


# Test 5: DELETE a task
def test_delete_task(client):
    create_response = client.post(
        "/api/tasks",
        json={"title": "Task to Delete"}
    )

    task_id = create_response.json["id"]

    response = client.delete(f"/api/tasks/{task_id}")

    assert response.status_code == 200
    assert response.json["message"] == "Task deleted successfully"


# Test 6: GET a task that does not exist
def test_task_not_found(client):
    response = client.get("/api/tasks/999")

    assert response.status_code == 404
    assert response.json["error"] == "Task not found"
