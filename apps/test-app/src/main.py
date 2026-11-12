"""FastAPI template application for automated Proxmox GitOps deployment."""

# [impl->req~app-template-python-uv~1]
import os
import platform
import time

import psycopg
from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse

START_TIME = time.time()

app = FastAPI(title="Test App", version="0.3.0")


def get_db_password() -> str:
    """Retrieve PostgreSQL password from in-memory Docker secret."""
    secret_path = os.getenv("POSTGRES_PASSWORD_FILE", "/run/secrets/postgres_password")
    if os.path.exists(secret_path):
        with open(secret_path, "r", encoding="utf-8") as f:
            return f.read().strip()
    return os.getenv("POSTGRES_PASSWORD", "").strip()


def check_db_connection() -> dict:
    """Check connectivity to PostgreSQL database."""
    host = os.getenv("DB_HOST", "10.20.2.10")
    port = int(os.getenv("DB_PORT", "5432"))
    dbname = os.getenv("DB_NAME", "test_app")
    user = os.getenv("DB_USER", "test_app_user")
    password = get_db_password()

    if not password:
        raise ValueError(
            "Database password not provided via Docker secret or environment."
        )

    conninfo = (
        f"host={host} port={port} dbname={dbname} "
        f"user={user} password={password} connect_timeout=3"
    )
    with psycopg.connect(conninfo) as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT current_database(), current_user, version();")
            row = cur.fetchone()
            return {
                "database": row[0],
                "user": row[1],
                "version": row[2].split(" ")[0] + " " + row[2].split(" ")[1],
            }


@app.get("/")
def read_root():
    """Root endpoint returning Hello World, environment, and database status."""
    app_env = os.getenv("APP_ENV", "development")
    db_status = "unknown"
    try:
        check_db_connection()
        db_status = "connected"
    except Exception as e:
        db_status = f"disconnected: {e}"

    return {
        "message": "Hello World!",
        "status": "healthy",
        "environment": app_env,
        "database": db_status,
    }


@app.get("/healthz")
def healthz():
    """Healthcheck endpoint for orchestrators and load balancers."""
    return {"status": "ok"}


@app.get("/version")
def read_version():
    """Version metadata endpoint."""
    return {
        "version": app.version,
        "name": app.title,
    }


@app.get("/features")
def read_features():
    """List active platform capabilities."""
    return {
        "version": app.version,
        "features": [
            "gitops",
            "infisical",
            "fastapi-uv",
            "atlantis",
            "caddy-ingress",
            "metrics",
        ],
        "status": "operational",
    }


@app.get("/metrics")
def read_metrics():
    """Application operational metrics and runtime telemetry."""
    db_connected = False
    try:
        check_db_connection()
        db_connected = True
    except Exception:
        db_connected = False

    uptime_seconds = round(time.time() - START_TIME, 2)
    return {
        "status": "healthy",
        "version": app.version,
        "environment": os.getenv("APP_ENV", "development"),
        "uptime_seconds": uptime_seconds,
        "database_connected": db_connected,
        "runtime": {
            "python_version": platform.python_version(),
            "platform": platform.platform(),
        },
    }


@app.get("/db/status")
def db_status():
    """Database connectivity status endpoint."""
    try:
        info = check_db_connection()
        return {
            "status": "connected",
            "database": info["database"],
            "user": info["user"],
            "version": info["version"],
        }
    except Exception as e:
        raise HTTPException(
            status_code=503,
            detail=f"Database connection error: {str(e)}",
        )


@app.get("/info", response_class=HTMLResponse)
def read_info():
    """Information HTML page displaying service overview and status."""
    app_env = os.getenv("APP_ENV", "development")
    db_status = "unknown"
    try:
        check_db_connection()
        db_status = "connected"
    except Exception as e:
        db_status = f"disconnected ({e})"

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test App — Service Overview</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background-color: #f4f6f8;
            color: #1f2937;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
        }}
        .card {{
            background: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            padding: 2rem;
            max-width: 480px;
            width: 100%;
        }}
        h1 {{
            font-size: 1.5rem;
            margin-top: 0;
            color: #111827;
        }}
        .badge {{
            display: inline-block;
            background-color: #10b981;
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 600;
        }}
        p {{
            line-height: 1.5;
            color: #4b5563;
        }}
    </style>
</head>
<body>
    <div class="card">
        <h1>Service Overview</h1>
        <p>Custom HTML view deployed via automated GitOps.</p>
        <p>Environment: <span class="badge">{app_env}</span></p>
        <p>Database: <strong>{db_status}</strong></p>
    </div>
</body>
</html>"""
