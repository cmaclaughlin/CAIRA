#!/usr/bin/env bash
# Idempotently assigns the signed-in user the Cognitive Services OpenAI Contributor role.
# Intended to prepare RBAC for Entra ID-authenticated model invocation tests.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  assign-openai-contributor-role.sh \
    [--scope <azure_resource_scope>] \
    [--from-terraform <path>] \
    [--json] \
    [--role "Cognitive Services OpenAI Contributor"]

Description:
  Idempotently assigns the signed-in Entra user the "Cognitive Services OpenAI Contributor"
  role at the given scope.

Scope source (pick one):
  1) --scope <scope>
     Example: /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/<account>
  2) --from-terraform <ra_dir>
     Reads scope from: terraform output -raw ai_foundry_id
  3) If omitted, defaults to subscription scope: /subscriptions/<current-subscription-id>

Examples:
  scripts/assign-openai-contributor-role.sh \
    --from-terraform reference_architectures/foundry_basic

  scripts/assign-openai-contributor-role.sh \
    --scope /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/<account>

Exit codes:
  0 = success (created) or no-op (already exists)
  2 = invalid input / argument parsing error
  3 = authentication / prerequisite resolution error
  4 = role-assignment operation failed
EOF
}

json_mode=false

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  printf '%s' "$value"
}

emit_json_result() {
  local status="$1"
  local action="$2"
  local message="$3"
  local code="$4"
  printf '{"status":"%s","action":"%s","role":"%s","scope":"%s","assignee_object_id":"%s","assignee_upn":"%s","message":"%s","exit_code":%s}\n' \
    "$(json_escape "$status")" \
    "$(json_escape "$action")" \
    "$(json_escape "$role_name")" \
    "$(json_escape "${scope:-}")" \
    "$(json_escape "${assignee_object_id:-}")" \
    "$(json_escape "${assignee_upn:-}")" \
    "$(json_escape "$message")" \
    "$code"
}

fail() {
  local code="$1"
  local message="$2"
  local action="${3:-failed}"

  if [[ "$json_mode" == true ]]; then
    emit_json_result "error" "$action" "$message" "$code"
  else
    echo "Error: $message" >&2
  fi
  exit "$code"
}

log_info() {
  if [[ "$json_mode" != true ]]; then
    echo "$1" >&2
  fi
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail 3 "required command not found: $1" "missing_command"
  fi
}

role_name="Cognitive Services OpenAI Contributor"
scope=""
from_terraform=""
assignee_object_id=""
assignee_upn=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)
      scope="$2"
      shift 2
      ;;
    --from-terraform)
      from_terraform="$2"
      shift 2
      ;;
    --role)
      role_name="$2"
      shift 2
      ;;
    --json)
      json_mode=true
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail 2 "unknown argument: $1" "invalid_argument"
      ;;
  esac
done

require_cmd az

if [[ -n "$scope" && -n "$from_terraform" ]]; then
  fail 2 "use only one scope source: --scope or --from-terraform" "invalid_scope_source"
fi

# Ensure user is signed in.
subscription_id="$(az account show --query id -o tsv 2>/dev/null || true)"
if [[ -z "$subscription_id" ]]; then
  fail 3 "no active Azure login context found. Run 'az login' first." "auth_context_missing"
fi

# Resolve signed-in user object id.
assignee_object_id="$(az ad signed-in-user show --query id -o tsv 2>/dev/null || true)"
assignee_upn="$(az ad signed-in-user show --query userPrincipalName -o tsv 2>/dev/null || true)"

if [[ -z "$assignee_object_id" ]]; then
  fail 3 "unable to resolve signed-in user via 'az ad signed-in-user show'. Ensure user-principal login and Graph read permission." "assignee_resolution_failed"
fi

if [[ -n "$from_terraform" ]]; then
  require_cmd terraform
  if [[ ! -d "$from_terraform" ]]; then
    fail 2 "terraform path not found: $from_terraform" "invalid_terraform_path"
  fi

  scope="$(terraform -chdir="$from_terraform" output -raw ai_foundry_id 2>/dev/null || true)"
  if [[ -z "$scope" ]]; then
    fail 3 "failed to read terraform output 'ai_foundry_id' from: $from_terraform" "terraform_output_missing"
  fi
fi

if [[ -z "$scope" ]]; then
  scope="/subscriptions/$subscription_id"
fi

log_info "Assignee: ${assignee_upn:-$assignee_object_id}"
log_info "Role: $role_name"
log_info "Scope: $scope"

existing_count="$(az role assignment list \
  --assignee-object-id "$assignee_object_id" \
  --scope "$scope" \
  --query "[?roleDefinitionName=='$role_name'] | length(@)" \
  -o tsv 2>/dev/null || echo 0)"

if [[ "$existing_count" -ge 1 ]]; then
  if [[ "$json_mode" == true ]]; then
    emit_json_result "success" "noop" "role assignment already exists; no changes made" 0
  else
    echo "Role assignment already exists. No changes made." >&2
  fi
  exit 0
fi

if ! az role assignment create \
  --assignee-object-id "$assignee_object_id" \
  --assignee-principal-type User \
  --role "$role_name" \
  --scope "$scope" \
  -o none; then
  fail 4 "failed to create role assignment" "create_failed"
fi

if [[ "$json_mode" == true ]]; then
  emit_json_result "success" "created" "role assignment created; RBAC propagation may take a few minutes" 0
else
  echo "Role assignment created successfully." >&2
  echo "Note: RBAC propagation can take a few minutes before access is effective." >&2
fi
