#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Configuration
# ============================================================

SUBSCRIPTION_ID="f0763483-cdd5-41ff-a288-256f6bc9cc63"
LOCATION="southafricanorth"

BOOTSTRAP_RG="rg-tfstate-github"
STATE_STORAGE="stcicdstategit001"
STATE_CONTAINER="tfstate"

APP_NAME="app-cicd-github"

GITHUB_ORG="C00SEVEN"
GITHUB_REPO="cicd-pipeline-made-simple"
GITHUB_ENVIRONMENT="lab"

# ============================================================
# Azure
# ============================================================

az account set \
  --subscription "$SUBSCRIPTION_ID"

# ============================================================
# Resource Group
# ============================================================

az group create \
  --name "$BOOTSTRAP_RG" \
  --location "$LOCATION"

# ============================================================
# Terraform State Storage
# ============================================================

az storage account create \
  --name "$STATE_STORAGE" \
  --resource-group "$BOOTSTRAP_RG" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --https-only true

az storage container create \
  --name "$STATE_CONTAINER" \
  --account-name "$STATE_STORAGE" \
  --auth-mode login \
  --public-access off

# ============================================================
# Entra App Registration
# ============================================================

APP_ID=$(az ad app create \
  --display-name "$APP_NAME" \
  --sign-in-audience AzureADMyOrg \
  --query appId \
  --output tsv)

echo "GitHub Application ID: $APP_ID"

# ============================================================
# Service Principal
# ============================================================

SP_OBJECT_ID=$(az ad sp create \
  --id "$APP_ID" \
  --query id \
  --output tsv)

# ============================================================
# GitHub OIDC Federated Credential
# ============================================================

cat > github-federated-credential.json <<EOF
{
  "name": "github-lab",
  "issuer": "https://token.actions.githubusercontent.com/",
  "subject": "repo:${GITHUB_ORG}/${GITHUB_REPO}:environment:${GITHUB_ENVIRONMENT}",
  "description": "GitHub Actions lab environment",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}
EOF

az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters github-federated-credential.json

rm github-federated-credential.json

# ============================================================
# RBAC
# ============================================================

az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role Contributor \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

echo
echo "=========================================="
echo "GitHub Bootstrap Complete"
echo "=========================================="
echo "Application ID: $APP_ID"
echo "Service Principal: $SP_OBJECT_ID"
echo "State Storage: $STATE_STORAGE"
echo "State Container: $STATE_CONTAINER"