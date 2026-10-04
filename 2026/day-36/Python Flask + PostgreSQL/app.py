from flask import Flask, jsonify, request
import os
import psycopg2

app = Flask(__name__)

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:postgres@localhost:5432/day36"
)


def get_db_connection():
    return psycopg2.connect(DATABASE_URL)


@app.route("/")
def home():
    return jsonify({
        "message": "Day 36 Flask Docker Project",
        "status": "running"
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    })


@app.route("/users", methods=["GET"])
def get_users():
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT id, name, email FROM users ORDER BY id")
    users = cursor.fetchall()

    cursor.close()
    connection.close()

    return jsonify([
        {
            "id": user[0],
            "name": user[1],
            "email": user[2]
        }
        for user in users
    ])


@app.route("/users", methods=["POST"])
def create_user():
    data = request.get_json()

    name = data.get("name")
    email = data.get("email")

    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute(
        "INSERT INTO users (name, email) VALUES (%s, %s) RETURNING id",
        (name, email)
    )

    user_id = cursor.fetchone()[0]

    connection.commit()

    cursor.close()
    connection.close()

    return jsonify({
        "id": user_id,
        "name": name,
        "email": email
    }), 201


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
