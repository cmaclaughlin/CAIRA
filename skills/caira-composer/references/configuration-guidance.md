---
title: CAIRA Configuration Guidance
description: 'Delivers authoritative configuration guidance for CAIRA reference architectures, ensuring alignment with Azure AI Foundry deployment best practices, validated parameters, and secure, compliant dependency management tailored to user requirements'
applies_to_step: ["step-3"]
---

# CAIRA Configuration Guidance

Configuration-only guidance for CAIRA (Composable AI Reference Architecture). This file focuses on parameter quality, dependency compatibility, and secure defaults for Azure AI Foundry workloads.

## Scope

Use this guidance after a reference architecture has already been selected.

Review architecture files before advising values:

- `variables.tf` for required inputs and validation constraints
- `outputs.tf` for exposed dependency outputs
- architecture `README.md` for supported scenarios and limits

## Key Configuration Areas

- **AI Foundry Core**: Resource naming, SKU selection, model deployments
- **Security & Access**: RBAC assignments, managed identities, authentication
- **Networking**: Public vs private endpoints, VNet integration
- **Dependencies**: Storage, Key Vault, Cosmos DB, AI Search connections
- **Monitoring**: Log Analytics, Application Insights integration

## Dependency Configuration & Validation

1. **Identify Resource Dependencies**
   - Map required Azure services and relationships
   - Confirm dependency ordering and data flow
   - Validate cross-module references

1. **Validate Dependency Compatibility**
   - Check SKU and tier compatibility between dependent resources
   - Verify network connectivity requirements (public/private endpoints)
   - Ensure authentication methods align across services

1. **Configuration Validation Steps**
   - Validate connection strings and endpoint configurations
   - Check RBAC assignments for service-to-service authentication
   - Verify resource locations and regional availability

**Common Dependency Patterns:**

- **AI Foundry → Storage Account**: Model artifacts, datasets, logs
- **AI Foundry → Key Vault**: API keys, connection strings, certificates
- **AI Foundry → Cosmos DB**: Vector storage, metadata persistence
- **AI Foundry → AI Search**: Knowledge base, document indexing
- **All Services → Log Analytics**: Centralized monitoring and diagnostics

**Dependency Validation Rules:**

- **Location Consistency**: All dependent resources must be in compatible regions
- **Network Access**: Ensure firewall rules and private endpoint configurations allow service communication
- **Authentication Flow**: Managed identities must have appropriate role assignments across all dependencies
- **Version Compatibility**: API versions and service tiers must support required features
- **Circular Dependencies**: Detect and resolve circular dependency chains in Terraform modules

## Inter-Module Dependency Management

1. **Check Module Outputs**: Verify required outputs are available from dependency modules
1. **Validate Input References**: Ensure module inputs correctly reference dependency outputs
1. **Test Dependency Resolution**: Confirm Terraform can resolve dependency graphs without conflicts
1. **Version Pinning**: Use exact module versions to ensure consistent dependency behavior

## Response Format

## [Configuration Topic]

### Required Parameters

[Core parameters with examples]

### Optional Parameters

[Additional configuration options]

### Configuration Examples

[Working code snippets]

### Key Considerations

[Important relationships and constraints]

## Auto-Validation Triggers

Automatically validate when users ask about:

- Parameter requirements or valid values
- Environment-specific configurations
- Model deployments or versions
- RBAC or security settings
- SKU recommendations or constraints
- Dependency relationships and compatibility
- Resource connectivity and network access
- Cross-module dependencies and outputs
- Service authentication and authorization flows

## Security & Compliance Defaults

- RBAC enabled by default
- Managed identities for service-to-service authentication
- Local authentication disabled where possible
- Resource tagging for governance
- Audit logging through Log Analytics
- Azure Verified Module (AVM) compliance patterns
