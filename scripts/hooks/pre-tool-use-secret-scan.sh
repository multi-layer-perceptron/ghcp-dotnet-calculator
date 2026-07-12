#!/usr/bin/env bash
# pre-tool-use-secret-scan.sh — Block commits containing hardcoded secrets
# Input: JSON via stdin with { timestamp, cwd, toolName, toolArgs }
# Output: JSON with permissionDecision to deny if secrets found

set -euo pipefail

# Check for jq dependency
if ! command -v jq &> /dev/null; then
  echo "ERROR: jq is required for hooks. Run: scripts/setup.sh" >&2
  exit 1
fi

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // .toolName // ""')
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // .toolArgs // {}')

# Only check file write/create operations
if ! [[ "$TOOL_NAME" =~ (create|edit|write|apply_patch|replace_string_in_file) ]]; then
  exit 0
fi

# Prefer unescaped text fields, then scan the complete structured input as a fallback.
CONTENT=$(echo "$TOOL_INPUT" | jq -r '[.content, .new_string, .newString, .replacement, .text, .input] | map(select(type == "string")) | join("\n")' 2>/dev/null)
if [ -z "$CONTENT" ]; then
  CONTENT="$TOOL_INPUT"
fi

if [ -z "$CONTENT" ]; then
  exit 0
fi

# Scan for common secret patterns
SECRET_PATTERNS='(sk-[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----|password\s*=\s*["\x27][^"\x27]{8,}|api[_-]?key\s*=\s*["\x27][^"\x27]{8,})'

if echo "$CONTENT" | grep -qiE "$SECRET_PATTERNS"; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Potential secret or credential detected in file content. Use environment variables instead of hardcoded secrets."}}'
  exit 0
fi

exit 0
