#!/usr/bin/env bash
# =============================================================================
# Tear down the workshop Azure resources
# =============================================================================
# Usage:
#   ./teardown.sh
#
# Deletes the entire resource group and all resources within it.
# =============================================================================

set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-actions-workshop}"

echo "=== Workshop Teardown ==="
echo ""
echo "  This will DELETE resource group: ${RESOURCE_GROUP}"
echo "  All resources inside it will be permanently destroyed."
echo ""

read -rp "Are you sure? Type the resource group name to confirm: " confirm
if [ "${confirm}" != "${RESOURCE_GROUP}" ]; then
    echo "Cancelled — input did not match '${RESOURCE_GROUP}'."
    exit 0
fi

echo ""
echo "Deleting resource group (running in background)..."
az group delete \
    --name "${RESOURCE_GROUP}" \
    --yes \
    --no-wait

echo ""
echo "Deletion initiated. It may take a few minutes to complete."
echo "Check status: az group show --name ${RESOURCE_GROUP} --query properties.provisioningState -o tsv"
echo ""
