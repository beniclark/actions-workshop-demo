#!/usr/bin/env bash
# Mock AI code review service for workshop demos.
# Simulates calling an internal AI-powered code analysis API.
# In a real scenario, this would be an HTTP call to an internal service.

set -euo pipefail

REVIEW_SCOPE="${1:-full}"
FILES_CHANGED="${2:-5}"

echo "============================================"
echo "  Internal AI Code Review Service"
echo "============================================"
echo "  Scope:         ${REVIEW_SCOPE}"
echo "  Files changed: ${FILES_CHANGED}"
echo "  Model:         internal-codereview-v3"
echo "  Timestamp:     $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "============================================"
echo ""

echo "Connecting to internal AI service..."
sleep 1

echo "Sending code for analysis..."
sleep 2

echo ""
echo "--- AI Review Findings ---"
echo ""
echo "  [INFO]     app.py:12 — Consider adding input validation for item names"
echo "  [INFO]     app.py:34 — Unused import detected: 'os' module"
echo "  [WARNING]  tests/unit/test_app.py:8 — Test coverage gap: no test for POST with empty body"
echo "  [INFO]     Dockerfile:15 — Pin base image digest for reproducible builds"
echo ""
echo "Summary: 4 findings (0 critical, 1 warning, 3 info)"
echo ""

# Output structured results for workflow consumption
cat <<EOF
---STRUCTURED_OUTPUT---
{
  "findings_count": 4,
  "critical": 0,
  "warnings": 1,
  "info": 3,
  "model_version": "internal-codereview-v3",
  "review_scope": "${REVIEW_SCOPE}",
  "pass": true
}
EOF
