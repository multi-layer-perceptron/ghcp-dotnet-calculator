$ErrorActionPreference = 'Stop'

$repoRoot = git rev-parse --show-toplevel
$workspacePath = Join-Path $repoRoot 'src/workspace'
$solutionRoot = Join-Path $workspacePath 'calculator-xunit-testing'

if (Test-Path $solutionRoot) {
    Remove-Item -Path $solutionRoot -Recurse -Force
    Write-Host "Removed: $solutionRoot"
}
else {
    Write-Host "Nothing to remove at: $solutionRoot"
}
