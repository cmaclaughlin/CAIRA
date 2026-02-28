---
title: CAIRA Composer Reference Index
description: 'Quick index for CAIRA composer guidance files and when to use each during the workflow'
applies_to_step: ["step-1", "step-3", "step-4", "step-5", "step-6"]
---

# CAIRA Composer References

Use this index to quickly choose the right guidance file during the `caira-composer` workflow.

## Machine-readable index

```yaml
reference_index:
  schema_version: "1.0"
  files:
    - file: references/architecture-guidance.md
      applies_to_step: ["step-1", "post-step-1-optional"]
      purpose: architecture_recommendations_and_well_architected_considerations
      used_when:
        - architecture selection is complete and additional design guidance is requested
      not_for:
        - deployment command execution
        - parameter value walkthroughs
    - file: references/configuration-guidance.md
      applies_to_step: ["step-3"]
      purpose: parameter_dependency_and_secure_configuration_validation
      used_when:
        - validating variables.tf inputs and dependency compatibility
      not_for:
        - architecture selection flow
        - deployment authentication runbooks
    - file: references/deployment-guidance.md
      applies_to_step: ["step-4", "step-5"]
      purpose: pre_plan_apply_prerequisites_and_authentication_setup
      used_when:
        - preparing terraform init/validate/plan/apply execution
      not_for:
        - deep architecture trade-off analysis
    - file: references/smoke-test-guidance.md
      applies_to_step: ["step-6"]
      purpose: post_deploy_smoke_test_checks_and_model_validation_payload_guidance
      used_when:
        - running post-deployment checks and model endpoint validation
      not_for:
        - terraform plan/apply prerequisites
        - architecture trade-off analysis
```

## JSON output contract

For script automation, treat these keys as stable when `--json` is used:

- `scripts/assign-openai-contributor-role.sh`: `status`, `action`, `role`, `scope`, `assignee_object_id`, `assignee_upn`, `message`, `exit_code`
- `scripts/curl-dynamic-model-endpoint.sh`: `status`, `action`, `endpoint`, `deployment`, `api_style`, `http_status`, `message`, `response_raw`, `exit_code`

Notes:

- `status` is `success` or `error`
- `exit_code` mirrors process exit code (`0`, `2`, `3`, `4`)

## Quick Mapping to Skill Workflow

- **Step 1 (discover/select RA)**: primarily `SKILL.md`
- **Step 3 (customize config)**: `configuration-guidance.md`
- **Step 4 (plan readiness)**: `deployment-guidance.md`
- **Step 5 (apply readiness)**: `deployment-guidance.md`
- **Step 6 (smoke testing)**: `smoke-test-guidance.md`
- **Optional architecture review after selection**: `architecture-guidance.md`

Use the machine-readable index above as the canonical source for file purpose, `used_when`, and `not_for` definitions.
