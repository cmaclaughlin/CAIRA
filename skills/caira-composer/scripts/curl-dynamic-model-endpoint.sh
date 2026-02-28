#!/usr/bin/env bash
# Invokes a selected AI Foundry model deployment endpoint using curl.
# Uses Entra ID bearer tokens and supports endpoint discovery from Terraform outputs.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  curl-dynamic-model-endpoint.sh \
    --deployment <deployment_name> \
    [--endpoint <https://...>] \
    [--from-terraform <path>] \
    [--access-token <token>] \
    [--json] \
    [--api-style deployments|v1] \
    [--api-version <version>] \
    [--prompt <text>] \
    [--payload-file <file.json>] \
    [--max-tokens <n>] \
    [--temperature <n>]

Description:
  Sends a curl request to a CAIRA AI Foundry reference endpoint for a dynamic model deployment.

Endpoint source (pick one):
  1) --endpoint <url>
  2) --from-terraform <ra_dir>  (reads: terraform output -raw ai_foundry_endpoint)

Auth:
  Entra ID authentication is enforced.
  - Use --access-token <token>, OR
  - Omit --access-token and the script will run:
      az account get-access-token --resource https://cognitiveservices.azure.com/

API style:
  deployments (default):
    POST {endpoint}/openai/deployments/{deployment}/chat/completions?api-version={api-version}

  v1:
    POST {endpoint}/openai/v1/chat/completions
    (payload includes: "model": "{deployment}")

Model-specific behavior:
  - For deployments whose name starts with "gpt-5", the script automatically:
    - uses "max_completion_tokens" instead of "max_tokens"
    - omits the "temperature" field
  - For other models, the script keeps the existing payload fields.

Examples:
  scripts/curl-dynamic-model-endpoint.sh \
    --from-terraform reference_architectures/foundry_basic \
    --deployment gpt-4o-mini

  scripts/curl-dynamic-model-endpoint.sh \
    --endpoint "https://my-foundry.openai.azure.com" \
    --deployment gpt-4o-mini \
    --access-token "$AZURE_OPENAI_ACCESS_TOKEN" \
    --api-style v1 \
    --prompt "Summarize this deployment result"

Exit codes:
  0 = request succeeded (HTTP < 400)
  2 = invalid input / argument parsing error
  3 = authentication / prerequisite resolution error
  4 = invocation failed (curl failure or HTTP >= 400)
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
  local message="$2"
  local code="$3"
  local http_status="${4:-}"
  local response_raw="${5:-}"

  printf '{"status":"%s","action":"invoke","endpoint":"%s","deployment":"%s","api_style":"%s","http_status":"%s","message":"%s","response_raw":"%s","exit_code":%s}\n' \
    "$(json_escape "$status")" \
    "$(json_escape "${endpoint:-}")" \
    "$(json_escape "${deployment:-}")" \
    "$(json_escape "${api_style:-}")" \
    "$(json_escape "$http_status")" \
    "$(json_escape "$message")" \
    "$(json_escape "$response_raw")" \
    "$code"
}

fail() {
  local code="$1"
  local message="$2"
  local http_status="${3:-}"
  local response_raw="${4:-}"

  if [[ "$json_mode" == true ]]; then
    emit_json_result "error" "$message" "$code" "$http_status" "$response_raw"
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
    fail 3 "required command not found: $1"
  fi
}

endpoint=""
from_terraform=""
deployment=""
access_token="${AZURE_OPENAI_ACCESS_TOKEN:-}"
api_style="deployments"
api_version="2024-10-21"
prompt="Hello from CAIRA dynamic model deployment test."
payload_file=""
max_tokens="300"
temperature="0.2"
token_parameter_name="max_tokens"
temperature_fragment=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --endpoint)
      endpoint="$2"
      shift 2
      ;;
    --from-terraform)
      from_terraform="$2"
      shift 2
      ;;
    --deployment)
      deployment="$2"
      shift 2
      ;;
    --access-token)
      access_token="$2"
      shift 2
      ;;
    --json)
      json_mode=true
      shift
      ;;
    --api-key)
      fail 2 "API key auth is disabled for model deployments. Use Entra ID access tokens instead."
      ;;
    --api-style)
      api_style="$2"
      shift 2
      ;;
    --api-version)
      api_version="$2"
      shift 2
      ;;
    --prompt)
      prompt="$2"
      shift 2
      ;;
    --payload-file)
      payload_file="$2"
      shift 2
      ;;
    --max-tokens)
      max_tokens="$2"
      shift 2
      ;;
    --temperature)
      temperature="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail 2 "unknown argument: $1"
      ;;
  esac
done

if [[ -z "$deployment" ]]; then
  usage >&2
  fail 2 "--deployment is required"
fi

if [[ -n "$endpoint" && -n "$from_terraform" ]]; then
  fail 2 "use only one endpoint source: --endpoint or --from-terraform"
fi

if [[ -n "$from_terraform" ]]; then
  require_cmd terraform
  if [[ ! -d "$from_terraform" ]]; then
    fail 2 "terraform path not found: $from_terraform"
  fi

  endpoint="$(terraform -chdir="$from_terraform" output -raw ai_foundry_endpoint 2>/dev/null || true)"
fi

if [[ -z "$endpoint" ]]; then
  fail 2 "endpoint is required. Provide --endpoint or --from-terraform"
fi

if [[ -z "$access_token" ]]; then
  require_cmd az
  access_token="$(az account get-access-token --resource https://cognitiveservices.azure.com/ --query accessToken -o tsv 2>/dev/null || true)"
fi

if [[ -z "$access_token" ]]; then
  fail 3 "failed to acquire Entra ID access token. Run 'az login' and retry, or pass --access-token"
fi

endpoint="${endpoint%/}"

if [[ "$api_style" != "deployments" && "$api_style" != "v1" ]]; then
  fail 2 "--api-style must be 'deployments' or 'v1'"
fi

deployment_lc="$(printf '%s' "$deployment" | tr '[:upper:]' '[:lower:]')"
if [[ "$deployment_lc" == gpt-5* ]]; then
  token_parameter_name="max_completion_tokens"
else
  temperature_fragment="$(printf ',\n  "temperature": %s' "$temperature")"
fi

if [[ -n "$payload_file" ]]; then
  if [[ ! -f "$payload_file" ]]; then
    fail 2 "payload file not found: $payload_file"
  fi
  payload="$(cat "$payload_file")"
else
  escaped_prompt="${prompt//\\/\\\\}"
  escaped_prompt="${escaped_prompt//\"/\\\"}"

  if [[ "$api_style" == "deployments" ]]; then
    payload=$(
      cat <<EOF
{
  "messages": [
    {"role": "system", "content": "You are a concise assistant."},
    {"role": "user", "content": "$escaped_prompt"}
  ],
  "$token_parameter_name": $max_tokens$temperature_fragment
}
EOF
    )
  else
    payload=$(
      cat <<EOF
{
  "model": "$deployment",
  "messages": [
    {"role": "system", "content": "You are a concise assistant."},
    {"role": "user", "content": "$escaped_prompt"}
  ],
  "$token_parameter_name": $max_tokens$temperature_fragment
}
EOF
    )
  fi
fi

if [[ "$api_style" == "deployments" ]]; then
  url="$endpoint/openai/deployments/$deployment/chat/completions?api-version=$api_version"
else
  url="$endpoint/openai/v1/chat/completions"
fi

log_info "Calling endpoint: $url"

curl_result="$(curl -sS -X POST "$url" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $access_token" \
  --data "$payload" \
  -w $'\n%{http_code}' 2>&1 || true)"

http_status="$(printf '%s\n' "$curl_result" | tail -n 1)"
response_body="$(printf '%s\n' "$curl_result" | sed '$d')"

if ! [[ "$http_status" =~ ^[0-9]{3}$ ]]; then
  fail 4 "curl invocation failed" "" "$curl_result"
fi

if ((http_status >= 400)); then
  fail 4 "endpoint invocation returned HTTP $http_status" "$http_status" "$response_body"
fi

if [[ "$json_mode" == true ]]; then
  emit_json_result "success" "endpoint invocation succeeded" 0 "$http_status" "$response_body"
else
  printf '%s\n' "$response_body"
  echo >&2
fi
