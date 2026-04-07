#!/usr/bin/env bash
# Demonstrates sending a repository_dispatch event to trigger cross-team workflows.
# This script shows how Team A can trigger automation in Team B's repository.
#
# Usage:
#   ./send-dispatch.sh <owner/repo> <event-type> [payload-json]
#
# Examples:
#   ./send-dispatch.sh myorg/downstream-repo tool-completed '{"tool":"security-scanner","version":"2.1"}'
#   ./send-dispatch.sh myorg/ml-pipeline model-updated '{"model":"fraud-detect-v3","accuracy":"0.97"}'
#
# Prerequisites:
#   - GitHub CLI (gh) authenticated with repo scope
#   - Or a PAT with repo scope for curl-based approach

set -euo pipefail

REPO="${1:?Usage: send-dispatch.sh <owner/repo> <event-type> [payload-json]}"
EVENT_TYPE="${2:?Usage: send-dispatch.sh <owner/repo> <event-type> [payload-json]}"
PAYLOAD="${3:-{\}}"

echo "============================================"
echo "  Sending repository_dispatch Event"
echo "============================================"
echo "  Target repo:  ${REPO}"
echo "  Event type:   ${EVENT_TYPE}"
echo "  Payload:      ${PAYLOAD}"
echo "  Timestamp:    $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "============================================"
echo ""

# Method 1: Using GitHub CLI (recommended)
echo "--- Method 1: GitHub CLI ---"
echo "gh api repos/${REPO}/dispatches \\"
echo "  -f event_type='${EVENT_TYPE}' \\"
echo "  -f client_payload='${PAYLOAD}'"
echo ""

# Actually send it if gh is available
if command -v gh &>/dev/null; then
  echo "Sending event via gh CLI..."
  gh api "repos/${REPO}/dispatches" \
    --method POST \
    -f "event_type=${EVENT_TYPE}" \
    --raw-field "client_payload=${PAYLOAD}" && echo "Event sent successfully!" || echo "Failed to send (check permissions)"
else
  echo "gh CLI not found — showing curl equivalent:"
  echo ""
  echo "--- Method 2: curl with PAT ---"
  echo 'curl -X POST \\'
  echo "  -H \"Accept: application/vnd.github+json\" \\"
  echo "  -H \"Authorization: Bearer \$GITHUB_TOKEN\" \\"
  echo "  https://api.github.com/repos/${REPO}/dispatches \\"
  echo "  -d '{\"event_type\":\"${EVENT_TYPE}\",\"client_payload\":${PAYLOAD}}'"
fi
