---
title: CAIRA Deployment Prerequisites Guidance
description: 'Step 4 prerequisites for CAIRA plan/apply, including Azure CLI authentication and Terraform AzureRM environment variables'
applies_to_step: ["step-4"]
---

## Step 4 Prerequisites (Plan and Apply)

Complete these checks before running `terraform init/validate/plan/apply`.

### 1) Review Architecture Documentation

- **MANDATORY**: Read the selected architecture `README.md` completely
- Confirm resources to be deployed and expected dependencies
- Review networking and RBAC/security assumptions

### 2) Required Tooling

- `terraform` installed and available on `PATH`
- `az` (Azure CLI) installed and available on `PATH`

### 3) Azure Authentication and Subscription Context

```bash
# Login to Azure (use --tenant if required)
az login

# Set active subscription for this deployment
az account set --subscription "<subscription_id>"

# Verify current context
az account show --output table
```

### 4) Terraform Environment Variables for AzureRM

Use Azure CLI authentication and export the Azure context Terraform should target:

```bash
# Required for consistent Terraform targeting
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export ARM_TENANT_ID=$(az account show --query tenantId -o tsv)

# Optional: set when your workflow requires explicit Azure CLI auth mode
export ARM_USE_CLI=true

# Verify variables
echo "$ARM_SUBSCRIPTION_ID"
echo "$ARM_TENANT_ID"
echo "$ARM_USE_CLI"
```

### 5) Access Validation Before Plan

```bash
# Confirm you can query resources in target subscription
az group list --query "[].name" -o tsv | head

# Confirm Terraform can initialize from the selected architecture directory
terraform init -backend=false
```
