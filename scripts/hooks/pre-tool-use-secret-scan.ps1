# pre-tool-use-secret-scan.ps1 - Block file writes containing hardcoded secrets
# Input: JSON via stdin with { tool_name, tool_input }
# Output: JSON with a PreToolUse permission decision when a secret is detected

$ErrorActionPreference = 'Stop'
$HookInput = $input | Out-String | ConvertFrom-Json

$ToolName = if ($HookInput.tool_name) { $HookInput.tool_name } elseif ($HookInput.toolName) { $HookInput.toolName } else { '' }
$ToolInput = if ($HookInput.tool_input) { $HookInput.tool_input } elseif ($HookInput.toolArgs) { $HookInput.toolArgs } else { '' }

# Only check file write/create operations
if ($ToolName -notmatch '(?i)(create|edit|write|apply_patch|replace_string_in_file)') {
    exit 0
}

try {
    $Content = if ($ToolInput -is [string]) {
        $ToolInput
    }
    else {
        $TextFields = @('content', 'new_string', 'newString', 'replacement', 'text', 'input')
        $ExtractedContent = foreach ($TextField in $TextFields) {
            $Value = $ToolInput.$TextField
            if ($Value -is [string]) {
                $Value
            }
        }

        if ($ExtractedContent) {
            $ExtractedContent -join "`n"
        }
        else {
            $ToolInput | ConvertTo-Json -Depth 100 -Compress
        }
    }
} catch {
    exit 0
}

if (-not $Content) { exit 0 }

# Scan for common secret patterns
$SecretPatterns = @(
    'sk-[a-zA-Z0-9]{20,}',
    'AKIA[0-9A-Z]{16}',
    'ghp_[a-zA-Z0-9]{36}',
    '-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----',
    'password\s*=\s*["\x27][^"\x27]{8,}',
    'api[_-]?key\s*=\s*["\x27][^"\x27]{8,}'
)

foreach ($SecretPattern in $SecretPatterns) {
    if ($Content -match $SecretPattern) {
        @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = 'Potential secret or credential detected in file content. Use environment variables instead of hardcoded secrets.' } } | ConvertTo-Json -Compress
        exit 0
    }
}

exit 0
