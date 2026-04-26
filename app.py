# ============================================================
# DevSecOps Demo App — Simple Task Manager API
# Built with Python Flask
#
# WARNING: This app contains INTENTIONAL security vulnerabilities
# for DevSecOps pipeline demonstration purposes.
# Do NOT deploy this to production.
# ============================================================

import sqlite3
import os
from flask import Flask, request, jsonify

app = Flask(__name__)

# ----------------------------------------------------------
# VULNERABILITY 1: Hardcoded secrets
# Secrets should never be hardcoded in source code.
# Use environment variables or a secrets manager instead.
# ----------------------------------------------------------
app.secret_key = "supersecretkey123"
API_TOKEN = "hardcoded-api-token-abc123xyz"
AWS_ACCESS_KEY_ID = "AKIAQRNHZR2SXHZQWERT"
AWS_SECRET_ACCESS_KEY = "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"
SECRET_KEY = "AKIAI44QH8DHBEXAMPLE"

# ----------------------------------------------------------
# VULNERABILITY 2: Debug mode hardcoded to True
# Exposes stack traces and the Werkzeug debugger in production.
# ----------------------------------------------------------
app.config["DEBUG"] = True

DB_PATH = "tasks.db"


def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS tasks (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            title       TEXT NOT NULL,
            description TEXT,
            status      TEXT DEFAULT 'pending'
        )
        """
    )
    conn.commit()
    conn.close()


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200


@app.route("/tasks", methods=["GET"])
def get_tasks():
    search = request.args.get("search", "")
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # ----------------------------------------------------------
    # VULNERABILITY 3: SQL Injection
    # User input is directly embedded into the SQL query.
    # The fix is to use parameterised queries with ? placeholders.
    # ----------------------------------------------------------
    query = f"SELECT * FROM tasks WHERE title LIKE '%{search}%'"
    cursor.execute(query)

    tasks = cursor.fetchall()
    conn.close()

    return jsonify(
        [
            {
                "id": t[0],
                "title": t[1],
                "description": t[2],
                "status": t[3],
            }
            for t in tasks
        ]
    ), 200


@app.route("/tasks", methods=["POST"])
def create_task():
    data = request.get_json()

    if not data or "title" not in data:
        return jsonify({"error": "Title is required"}), 400

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO tasks (title, description, status) VALUES (?, ?, ?)",
        (data["title"], data.get("description", ""), data.get("status", "pending")),
    )
    conn.commit()
    task_id = cursor.lastrowid
    conn.close()

    return jsonify({"id": task_id, "message": "Task created"}), 201


@app.route("/tasks/<int:task_id>", methods=["DELETE"])
def delete_task(task_id):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM tasks WHERE id = ?", (task_id,))
    conn.commit()
    conn.close()
    return jsonify({"message": "Task deleted"}), 200


# ----------------------------------------------------------
# VULNERABILITY 4: eval() on user-supplied input
# Allows an attacker to execute arbitrary Python code.
# Example payload: {"expression": "__import__('os').system('rm -rf /')"}
# ----------------------------------------------------------
@app.route("/calculate", methods=["POST"])
def calculate():
    data = request.get_json()
    expression = data.get("expression", "")
    result = eval(expression)
    return jsonify({"result": result}), 200


if __name__ == "__main__":
    init_db()
    # ----------------------------------------------------------
    # VULNERABILITY 5: Listening on all interfaces with debug on
    # 0.0.0.0 exposes the app on every network interface.
    # ----------------------------------------------------------
    app.run(host="0.0.0.0", port=5000, debug=True)