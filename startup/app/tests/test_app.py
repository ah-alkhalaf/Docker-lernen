import importlib

import pytest


@pytest.fixture()
def client(monkeypatch):
    monkeypatch.delenv("DATABASE_URL", raising=False)
    import app as app_module

    importlib.reload(app_module)
    return app_module.app.test_client()


def test_health_without_db(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.get_json() == {"status": "ok", "db": "memory"}


def test_visits_increase(client):
    assert client.get("/api/visits").get_json()["visits"] == 1
    assert client.get("/api/visits").get_json()["visits"] == 2


def test_index_renders(client):
    r = client.get("/")
    assert r.status_code == 200
    assert "الزيارات" in r.get_data(as_text=True)


def test_health_fails_when_db_unreachable(monkeypatch):
    # Port 1 refuses connections immediately -> health must report 503.
    monkeypatch.setenv("DATABASE_URL", "postgresql://u:p@127.0.0.1:1/x")
    import app as app_module

    importlib.reload(app_module)
    r = app_module.app.test_client().get("/health")
    assert r.status_code == 503
    assert r.get_json()["status"] == "error"
