$ErrorActionPreference = 'Stop'

$repoRoot = git rev-parse --show-toplevel
$workspacePath = Join-Path $repoRoot 'programming/dotnet/csharp/workspace'
$solutionRoot = Join-Path $workspacePath 'calculator-xunit-testing'

if (-not (Test-Path $workspacePath)) {
    New-Item -ItemType Directory -Path $workspacePath | Out-Null
}

if (-not (Test-Path $solutionRoot)) {
    New-Item -ItemType Directory -Path $solutionRoot | Out-Null
}

Set-Location $solutionRoot

if (-not (Test-Path './calculator.sln')) {
    dotnet new sln --name calculator --format sln
}

if (-not (Test-Path './calculator/calculator.csproj')) {
    dotnet new console --name calculator --framework net8.0
}

if (-not (Test-Path './calculator.tests/calculator.tests.csproj')) {
    dotnet new xunit --name calculator.tests --framework net8.0
}

$solutionProjects = dotnet sln ./calculator.sln list
$solutionProjectsText = $solutionProjects -join "`n"

if ($solutionProjectsText -notmatch [regex]::Escape('calculator/calculator.csproj')) {
    dotnet sln ./calculator.sln add ./calculator/calculator.csproj
}

if ($solutionProjectsText -notmatch [regex]::Escape('calculator.tests/calculator.tests.csproj')) {
    dotnet sln ./calculator.sln add ./calculator.tests/calculator.tests.csproj
}

$projectReferences = dotnet list ./calculator.tests/calculator.tests.csproj reference
$projectReferencesText = $projectReferences -join "`n"
if ($projectReferencesText -notmatch [regex]::Escape('../calculator/calculator.csproj')) {
    dotnet add ./calculator.tests/calculator.tests.csproj reference ./calculator/calculator.csproj
}

if (Test-Path './calculator/Program.cs') {
    Rename-Item -Path './calculator/Program.cs' -NewName 'Calculator.cs' -Force
}

if (Test-Path './calculator.tests/UnitTest1.cs') {
    Rename-Item -Path './calculator.tests/UnitTest1.cs' -NewName 'CalculatorTest.cs' -Force
}
