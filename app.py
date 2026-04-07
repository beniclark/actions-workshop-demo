"""
Sample Flask API for GitHub Actions Workshop Demos.
Provides a simple REST API with health check, items CRUD, and version info.
"""

import os
from flask import Flask, jsonify, request

app = Flask(__name__)

# In-memory store for demo purposes
items = [
    {"id": 1, "name": "Widget A", "status": "active"},
    {"id": 2, "name": "Widget B", "status": "active"},
    {"id": 3, "name": "Widget C", "status": "active"},
]


@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint for deployment verification."""
    return jsonify({
        "status": "healthy",
        "version": os.getenv("APP_VERSION", "0.0.0-local"),
    })


@app.route("/api/items", methods=["GET"])
def get_items():
    """List all items."""
    return jsonify({"items": items, "count": len(items)})


@app.route("/api/items/<int:item_id>", methods=["GET"])
def get_item(item_id):
    """Get a single item by ID."""
    item = next((i for i in items if i["id"] == item_id), None)
    if item is None:
        return jsonify({"error": "Item not found"}), 404
    return jsonify(item)


@app.route("/api/items", methods=["POST"])
def create_item():
    """Create a new item."""
    data = request.get_json()
    if not data or "name" not in data:
        return jsonify({"error": "name is required"}), 400
    new_item = {
        "id": max(i["id"] for i in items) + 1 if items else 1,
        "name": data["name"],
        "status": data.get("status", "active"),
    }
    items.append(new_item)
    return jsonify(new_item), 201


if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))
    app.run(host="0.0.0.0", port=port)
