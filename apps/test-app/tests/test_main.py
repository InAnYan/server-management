"""Unit tests for the template FastAPI service."""

from fastapi.testclient import TestClient

from src.main import app

client = TestClient(app)


def test_read_main():
    """Verify root endpoint responds with Hello World."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Hello World!"
    assert data["status"] == "healthy"


def test_healthz():
    """Verify healthcheck endpoint returns status ok."""
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_read_info():
    """Verify info HTML page responds with 200 and expected markup."""
    response = client.get("/info")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]
    assert "Service Overview" in response.text


def test_read_version():
    """Verify version endpoint returns version and name."""
    response = client.get("/version")
    assert response.status_code == 200
    data = response.json()
    assert data["version"] == "0.3.0"
    assert data["name"] == "Test App"


def test_read_features():
    """Verify features endpoint returns capability list."""
    response = client.get("/features")
    assert response.status_code == 200
    data = response.json()
    assert data["version"] == "0.3.0"
    assert "gitops" in data["features"]
    assert "metrics" in data["features"]
    assert data["status"] == "operational"


def test_read_metrics():
    """Verify metrics endpoint returns runtime telemetry."""
    response = client.get("/metrics")
    assert response.status_code == 200
    data = response.json()
    assert data["version"] == "0.3.0"
    assert data["status"] == "healthy"
    assert "uptime_seconds" in data
    assert "database_connected" in data
    assert "runtime" in data
    assert "python_version" in data["runtime"]


def test_db_status_mocked(monkeypatch):
    """Verify database status endpoint when connected."""
    mock_data = {
        "database": "test_app",
        "user": "test_app_user",
        "version": "PostgreSQL 16.11",
    }
    monkeypatch.setattr("src.main.check_db_connection", lambda: mock_data)
    response = client.get("/db/status")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "connected"
    assert data["database"] == "test_app"
    assert data["user"] == "test_app_user"
