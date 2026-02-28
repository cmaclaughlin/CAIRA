---
title: CAIRA Smoke Test Guidance
description: 'Step 6 smoke-test checks and model validation payload notes for CAIRA deployments'
applies_to_step: ["step-6"]
---

## Step 6 Smoke Test Guidance

Use this guidance after a successful `terraform apply`.

### 1) Core Post-Deploy Checks

- Verify `terraform output` returns expected critical values.
- Confirm resource group resources are present with Azure CLI.
- Validate endpoint reachability relevant to the selected architecture.

### 2) Model Validation Payload Notes

When running model endpoint smoke tests with `scripts/curl-dynamic-model-endpoint.sh`:

- Deployments named `gpt-5*` are invoked with `max_completion_tokens` and without `temperature`.
- Other chat-capable models continue using `max_tokens` and `temperature`.
- Embedding models should be validated with embeddings endpoints/payloads.
