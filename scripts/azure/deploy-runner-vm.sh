#!/usr/bin/env bash
# =============================================================================
# Deploy an Azure VM for GitHub Actions self-hosted runner
# =============================================================================
# Usage:
#   ./deploy-runner-vm.sh
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Sufficient permissions to create resources
#
# The script creates:
#   - A resource group
#   - An Ubuntu 22.04 VM with Docker and Python 3.12 (via cloud-init)
#   - An NSG allowing SSH (port 22) from your current IP only
# =============================================================================

set -euo pipefail

# --- Configuration (edit these) -----------------------------------------------
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-actions-workshop}"
LOCATION="${LOCATION:-eastus}"
VM_NAME="${VM_NAME:-runner-vm}"
VM_SIZE="${VM_SIZE:-Standard_B2ms}"
ADMIN_USER="${ADMIN_USER:-azureuser}"
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLOUD_INIT_FILE="${SCRIPT_DIR}/cloud-init.yml"

echo "=== GitHub Actions Runner VM Deployment ==="
echo ""
echo "  Resource Group: ${RESOURCE_GROUP}"
echo "  Location:       ${LOCATION}"
echo "  VM Name:        ${VM_NAME}"
echo "  VM Size:        ${VM_SIZE}"
echo "  Admin User:     ${ADMIN_USER}"
echo ""

# Check Azure CLI is available and logged in
if ! az account show &>/dev/null; then
    echo "ERROR: Not logged in to Azure CLI. Run 'az login' first."
    exit 1
fi

SUBSCRIPTION=$(az account show --query name -o tsv)
echo "  Subscription:   ${SUBSCRIPTION}"
echo ""

# Confirm before proceeding
read -rp "Proceed with deployment? (y/N) " confirm
if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "--- Creating resource group ---"
az group create \
    --name "${RESOURCE_GROUP}" \
    --location "${LOCATION}" \
    --output table

echo ""
echo "--- Creating VM (this takes 2-3 minutes) ---"
az vm create \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${VM_NAME}" \
    --image Ubuntu2204 \
    --size "${VM_SIZE}" \
    --admin-username "${ADMIN_USER}" \
    --generate-ssh-keys \
    --custom-data "${CLOUD_INIT_FILE}" \
    --public-ip-sku Standard \
    --output table

echo ""
echo "--- Restricting SSH access to your current IP ---"
MY_IP=$(curl -s https://api.ipify.org)
az network nsg rule update \
    --resource-group "${RESOURCE_GROUP}" \
    --nsg-name "${VM_NAME}NSG" \
    --name default-allow-ssh \
    --source-address-prefixes "${MY_IP}/32" \
    --output table 2>/dev/null || echo "NSG rule update skipped (may need manual config)"

echo ""
echo "--- Getting VM public IP ---"
PUBLIC_IP=$(az vm show \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${VM_NAME}" \
    --show-details \
    --query publicIps -o tsv)

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "  VM Public IP: ${PUBLIC_IP}"
echo ""
echo "  SSH into the VM:"
echo "    ssh ${ADMIN_USER}@${PUBLIC_IP}"
echo ""
echo "  Cloud-init is still running. Wait 3-5 minutes, then verify:"
echo "    ssh ${ADMIN_USER}@${PUBLIC_IP} 'docker --version && python3 --version'"
echo ""
echo "  Next step: SSH in and run setup-runner.sh to install the GitHub Actions runner agent."
echo ""
