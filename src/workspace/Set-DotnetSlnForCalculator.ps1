$ErrorActionPreference = 'Stop'

$repoRoot = git rev-parse --show-toplevel
$workspacePath = Join-Path $repoRoot 'src/workspace'
$solutionRoot = Join-Path $workspacePath 'calculator-xunit-testing'

if (-not (Test-Path $workspacePath)) {
    New-Item -ItemType Directory -Path $workspacePath | Out-Null
}

if (-not (Test-Path $solutionRoot)) {
    New-Item -ItemType Directory -Path $solutionRoot | Out-Null
}

Set-Location $solutionRoot

# Create solution file
if (-not (Test-Path './calculator.slnx')) {
    dotnet new sln --name calculator
    Write-Host "Created solution: ./calculator.slnx"
}

# Create console app project
if (-not (Test-Path './calculator/calculator.csproj')) {
    dotnet new console --name calculator --framework net8.0
    Write-Host "Created project: ./calculator/calculator.csproj"
}

# Create xUnit test project
if (-not (Test-Path './calculator.tests/calculator.tests.csproj')) {
    dotnet new xunit --name calculator.tests --framework net8.0
    Write-Host "Created project: ./calculator.tests/calculator.tests.csproj"
}

# Add projects to solution
dotnet sln ./calculator.slnx add ./calculator/calculator.csproj
dotnet sln ./calculator.slnx add ./calculator.tests/calculator.tests.csproj
Write-Host "Added projects to solution"

# Add project reference from tests to console app
dotnet add ./calculator.tests/calculator.tests.csproj reference ./calculator/calculator.csproj
Write-Host "Added reference: calculator.tests -> calculator"

# Rename generated files to match our naming convention
if (Test-Path './calculator/Program.cs') {
    Rename-Item -Path './calculator/Program.cs' -NewName 'Calculator.cs' -Force
    Write-Host "Renamed: Program.cs -> Calculator.cs"
}

if (Test-Path './calculator.tests/UnitTest1.cs') {
    Rename-Item -Path './calculator.tests/UnitTest1.cs' -NewName 'CalculatorTest.cs' -Force
    Write-Host "Renamed: UnitTest1.cs -> CalculatorTest.cs"
}

# Build solution to verify setup
dotnet build ./calculator.slnx
Write-Host "Build succeeded. Solution setup complete."
