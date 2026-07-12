# pre-tool-use-secret-scan.ps1 - Block file writes containing hardcoded secrets
# Input: JSON via stdin with { timestamp, cwd, toolName, toolArgs }
# Output: JSON with permissionDecision to deny when a secret is detected

$ErrorActionPreference = 'Stop'
$HookInput = $input | Out-String | ConvertFrom-Json

$ToolName = if ($HookInput.toolName) { $HookInput.toolName } else { '' }
$ToolArgs = if ($HookInput.toolArgs) { $HookInput.toolArgs } else { '' }

# Only check file write/create operations
if ($ToolName -ne "create" -and $ToolName -ne "edit" -and $ToolName -ne "write") {
    exit 0
}

try {
    $ArgsObject = if ($ToolArgs -is [string]) {
        $ToolArgs | ConvertFrom-Json
    }
    else {
        $ToolArgs
    }

    $Content = if ($ArgsObject.content) { $ArgsObject.content } elseif ($ArgsObject.new_string) { $ArgsObject.new_string } else { '' }
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
        Write-Output '{"permissionDecision":"deny","permissionDecisionReason":"Potential secret or credential detected in file content. Use environment variables instead of hardcoded secrets."}'
        exit 0
    }
}

exit 0
