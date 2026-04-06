#!/usr/bin/env bash
# =============================================================================
# Install and configure the GitHub Actions self-hosted runner agent
# =============================================================================
# Usage (run this ON the VM after SSH-ing in):
#   ./setup-runner.sh <GITHUB_REPO_URL> <REGISTRATION_TOKEN>
#
# Example:
#   ./setup-runner.sh https://github.com/myorg/github-actions-demos AABCDE12345...
#
# To get a registration token:
#   1. Go to your repo on GitHub
#   2. Settings > Actions > Runners > New self-hosted runner
#   3. Copy the token from the configure step
#
# Or via CLI (requires admin access):
#   gh api -X POST repos/OWNER/REPO/actions/runners/registration-token --jq .token
# =============================================================================

set -euo pipefail

RUNNER_VERSION="${RUNNER_VERSION:-2.321.0}"
RUNNER_DIR="${HOME}/actions-runner"
RUNNER_LABELS="self-hosted,linux"

# --- Validate arguments -------------------------------------------------------
if [ $# -lt 2 ]; then
    echo "Usage: $0 <GITHUB_REPO_URL> <REGISTRATION_TOKEN>"
    echo ""
    echo "Example:"
    echo "  $0 https://github.com/myorg/github-actions-demos AABCDE12345..."
    exit 1
fi

REPO_URL="$1"
REG_TOKEN="$2"

echo "=== GitHub Actions Runner Setup ==="
echo ""
echo "  Runner version: ${RUNNER_VERSION}"
echo "  Repo URL:       ${REPO_URL}"
echo "  Labels:         ${RUNNER_LABELS}"
echo "  Install dir:    ${RUNNER_DIR}"
echo ""

# --- Verify prerequisites -----------------------------------------------------
echo "--- Checking prerequisites ---"

if ! docker --version &>/dev/null; then
    echo "WARNING: Docker not found. Cloud-init may still be running."
    echo "Wait a few minutes and try again, or install Docker manually."
fi

if ! python3 --version &>/dev/null; then
    echo "WARNING: Python3 not found. Cloud-init may still be running."
fi

echo "  Docker: $(docker --version 2>/dev/null || echo 'not ready')"
echo "  Python: $(python3 --version 2>/dev/null || echo 'not ready')"
echo ""

# --- Download and extract runner -----------------------------------------------
echo "--- Installing runner agent ---"
mkdir -p "${RUNNER_DIR}"
cd "${RUNNER_DIR}"

RUNNER_ARCHIVE="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
if [ ! -f "${RUNNER_ARCHIVE}" ]; then
    curl -sL -o "${RUNNER_ARCHIVE}" \
        "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_ARCHIVE}"
fi

tar xzf "${RUNNER_ARCHIVE}"

# --- Configure the runner ------------------------------------------------------
echo ""
echo "--- Configuring runner ---"
./config.sh \
    --url "${REPO_URL}" \
    --token "${REG_TOKEN}" \
    --labels "${RUNNER_LABELS}" \
    --name "$(hostname)" \
    --work "_work" \
    --unattended \
    --replace

# --- Install and start as a systemd service ------------------------------------
echo ""
echo "--- Installing as system service ---"
sudo ./svc.sh install
sudo ./svc.sh start

echo ""
echo "=== Runner Setup Complete ==="
echo ""
echo "  The runner is now online and listening for jobs."
echo "  Verify in your repo: Settings > Actions > Runners"
echo ""
echo "  Runner name:   $(hostname)"
echo "  Labels:        ${RUNNER_LABELS}"
echo "  Work directory: ${RUNNER_DIR}/_work"
echo ""
