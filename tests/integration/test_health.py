"""Integration tests — start the app and test over HTTP."""

import subprocess
import time
import urllib.request
import json
import signal
import os
import pytest


@pytest.fixture(scope="module")
def running_app():
    """Start the Flask app as a subprocess and yield, then clean up."""
    env = os.environ.copy()
    env["PORT"] = "5099"
    env["APP_VERSION"] = "integration-test"
    proc = subprocess.Popen(
        ["python", "app.py"],
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    # Wait for startup
    for _ in range(10):
        try:
            urllib.request.urlopen("http://localhost:5099/health")
            break
        except Exception:
            time.sleep(0.5)
    yield "http://localhost:5099"
    proc.terminate()
    proc.wait(timeout=5)


def test_health_over_http(running_app):
    """Health endpoint should respond over HTTP."""
    resp = urllib.request.urlopen(f"{running_app}/health")
    assert resp.status == 200
    data = json.loads(resp.read())
    assert data["status"] == "healthy"
    assert data["version"] == "integration-test"


def test_items_over_http(running_app):
    """Items endpoint should respond over HTTP."""
    resp = urllib.request.urlopen(f"{running_app}/api/items")
    assert resp.status == 200
    data = json.loads(resp.read())
    assert "items" in data
