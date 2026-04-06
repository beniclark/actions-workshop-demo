#!/usr/bin/env bash
# Mock deployment script for workshop demos.
# Simulates deploying an application to an environment.

set -euo pipefail

ENVIRONMENT="${1:?Usage: deploy.sh <environment> <image-tag>}"
IMAGE_TAG="${2:?Usage: deploy.sh <environment> <image-tag>}"

# Validate environment
case "$ENVIRONMENT" in
  dev|staging|production) ;;
  *)
    echo "Error: Invalid environment '$ENVIRONMENT'. Must be dev, staging, or production."
    exit 1
    ;;
esac

echo "============================================"
echo "  Deploying to ${ENVIRONMENT}"
echo "============================================"
echo "  Image:     ${IMAGE_TAG}"
echo "  Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  Actor:     ${GITHUB_ACTOR:-local}"
echo "============================================"
echo ""

echo "Step 1/4: Pulling image..."
sleep 1
echo "Step 2/4: Updating deployment..."
sleep 1
echo "Step 3/4: Waiting for rollout..."
sleep 1
echo "Step 4/4: Running health check..."
sleep 1

echo ""
echo "Deployment to ${ENVIRONMENT} complete."
