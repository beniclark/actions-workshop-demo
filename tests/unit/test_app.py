"""Unit tests for the sample Flask API."""

import pytest
from app import app


@pytest.fixture
def client():
    """Create a test client."""
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_health_check(client):
    """Health endpoint should return 200 with status healthy."""
    resp = client.get("/health")
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["status"] == "healthy"
    assert "version" in data


def test_get_items(client):
    """Items endpoint should return a list."""
    resp = client.get("/api/items")
    assert resp.status_code == 200
    data = resp.get_json()
    assert "items" in data
    assert "count" in data
    assert data["count"] >= 0


def test_get_item_found(client):
    """Getting an existing item should return 200."""
    resp = client.get("/api/items/1")
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["id"] == 1


def test_get_item_not_found(client):
    """Getting a non-existent item should return 404."""
    resp = client.get("/api/items/9999")
    assert resp.status_code == 404


def test_create_item(client):
    """Creating an item should return 201."""
    resp = client.post("/api/items", json={"name": "Widget C"})
    assert resp.status_code == 201
    data = resp.get_json()
    assert data["name"] == "Widget C"
    assert data["status"] == "active"


def test_create_item_missing_name(client):
    """Creating an item without name should return 400."""
    resp = client.post("/api/items", json={"status": "active"})
    assert resp.status_code == 400
