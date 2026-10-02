"""Tiny web app for the Docker-lernen course.

- Counts page visits (PostgreSQL if DATABASE_URL is set, otherwise in memory).
- /health is what Docker Compose healthchecks and monitoring call.
"""
import os

from flask import Flask, jsonify

app = Flask(__name__)

APP_NAME = os.getenv("APP_NAME", "Docker-lernen Startup")
DATABASE_URL = os.getenv("DATABASE_URL")

_memory = {"visits": 0}
_db_ready = False


def _connect():
    import psycopg2  # imported lazily so tests run without a database

    return psycopg2.connect(DATABASE_URL, connect_timeout=3)


def _init_db():
    global _db_ready
    if _db_ready:
        return
    with _connect() as conn, conn.cursor() as cur:
        cur.execute(
            "CREATE TABLE IF NOT EXISTS visits ("
            "id SERIAL PRIMARY KEY, ts TIMESTAMPTZ DEFAULT now())"
        )
    _db_ready = True


def count_visit():
    """Record one visit and return the total."""
    if not DATABASE_URL:
        _memory["visits"] += 1
        return _memory["visits"]
    _init_db()
    with _connect() as conn, conn.cursor() as cur:
        cur.execute("INSERT INTO visits DEFAULT VALUES")
        cur.execute("SELECT count(*) FROM visits")
        return cur.fetchone()[0]


@app.get("/")
def index():
    try:
        total = count_visit()
    except Exception as exc:  # show the problem instead of a blank 500
        app.logger.error("index: database error: %s", exc)
        return f"<h1>{APP_NAME}</h1><p>Database error: {exc}</p>", 503
    return (
        f"<!doctype html><html lang='ar' dir='rtl'><meta charset='utf-8'>"
        f"<title>{APP_NAME}</title>"
        f"<body style='font-family:sans-serif;max-width:40em;margin:3em auto'>"
        f"<h1>{APP_NAME}</h1>"
        f"<p>عدد الزيارات: <b>{total}</b></p>"
        f"<p><a href='/health'>/health</a> · <a href='/api/visits'>/api/visits</a></p>"
        f"</body></html>"
    )


@app.get("/api/visits")
def visits():
    try:
        return jsonify(visits=count_visit())
    except Exception as exc:
        app.logger.error("visits: database error: %s", exc)
        return jsonify(error=str(exc)), 503


@app.get("/health")
def health():
    if not DATABASE_URL:
        return jsonify(status="ok", db="memory")
    try:
        _init_db()
        return jsonify(status="ok", db="up")
    except Exception as exc:
        app.logger.error("health check failed: %s", exc)
        return jsonify(status="error", db="down", detail=str(exc)), 503
