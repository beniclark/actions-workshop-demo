#!/usr/bin/env bash
# Mock smoke test script for workshop demos.
# Simulates running health checks against a deployed application.

set -euo pipefail

TARGET_URL="${1:?Usage: smoke-test.sh <target-url>}"

echo "============================================"
echo "  Smoke Testing: ${TARGET_URL}"
echo "============================================"

echo "Check 1/3: Health endpoint..."
sleep 1
echo "  /health -> 200 OK"

echo "Check 2/3: API endpoint..."
sleep 1
echo "  /api/items -> 200 OK"

echo "Check 3/3: Response time..."
sleep 1
echo "  Average: 45ms (threshold: 500ms)"

echo ""
echo "All smoke tests passed."
