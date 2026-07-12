# Post-tool-use hook: verify the calculator solution after C# edits.

$ErrorActionPreference = 'Stop'

$toolName = $env:TOOL_NAME
$filePath = $env:FILE_PATH

if ($toolName -ne 'edit' -and $toolName -ne 'create') {
    exit 0
}

if ([string]::IsNullOrWhiteSpace($filePath) -or $filePath -notlike '*.cs') {
    exit 0
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$solutionPath = Join-Path $repoRoot 'src\workspace\calculator-xunit-testing\calculator.slnx'

if (-not (Test-Path $solutionPath)) {
    Write-Host "Calculator solution not found: $solutionPath"
    exit 1
}

$buildOutput = & dotnet build $solutionPath --nologo --verbosity quiet 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED after editing $filePath"
    Write-Host ''
    $buildOutput | Select-Object -Last 20 | ForEach-Object { Write-Host $_ }
    Write-Host ''
    Write-Host 'Fix the build errors before continuing.'
    exit 1
}

Write-Host "Build succeeded after editing $filePath"
