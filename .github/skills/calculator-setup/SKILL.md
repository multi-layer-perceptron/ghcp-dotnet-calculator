---
name: calculator-setup
description: "Set up .NET 8 calculator solution structure with console app and xUnit test project. Use when: create calculator solution, setup calculator, initialize calculator projects, prepare calculator workspace."
---

# Calculator Setup Skill

Establishes the complete .NET 8 calculator solution structure including console application and xUnit test projects with proper project references and file naming conventions.

## Purpose

* Create `calculator-xunit-testing` directory structure under `src/workspace/`
* Scaffold .NET 8 console app (`calculator`) and xUnit test project (`calculator.tests`)
* Configure solution file and project references
* Apply repository naming conventions
* Verify build succeeds

## Prerequisites

* Git repository initialized (to detect repo root via `git rev-parse --show-toplevel`)
* .NET 8 SDK installed and accessible via `dotnet` command
* PowerShell 7+ with execution policy allowing script execution
* Current working directory: repository root or `src/workspace`

## Quick Start

### Option 1: Use the Provided Setup Script

Run the setup script from `src/workspace/`:

```powershell
cd src/workspace
.\Set-DotnetSlnForCalculator.ps1
```

### Option 2: Manual Setup Commands

Execute these commands sequentially from `src/workspace/calculator-xunit-testing/`:

```powershell
# Create solution and projects
dotnet new sln --name calculator
dotnet new console --name calculator --framework net8.0
dotnet new xunit --name calculator.tests --framework net8.0

# Add to solution
dotnet sln ./calculator.slnx add ./calculator/calculator.csproj
dotnet sln ./calculator.slnx add ./calculator.tests/calculator.tests.csproj

# Configure reference
dotnet add ./calculator.tests/calculator.tests.csproj reference ./calculator/calculator.csproj

# Rename files
Rename-Item -Path './calculator/Program.cs' -NewName 'Calculator.cs' -Force
Rename-Item -Path './calculator.tests/UnitTest1.cs' -NewName 'CalculatorTest.cs' -Force

# Verify
dotnet build ./calculator.slnx
```

## Setup Script Reference

The `src/workspace/Set-DotnetSlnForCalculator.ps1` script handles all setup tasks idempotently:

```powershell
$ErrorActionPreference = 'Stop'
$repoRoot = git rev-parse --show-toplevel
$workspacePath = Join-Path $repoRoot 'src/workspace'
$solutionRoot = Join-Path $workspacePath 'calculator-xunit-testing'

if (-not (Test-Path $solutionRoot)) {
    New-Item -ItemType Directory -Path $solutionRoot | Out-Null
}

Set-Location $solutionRoot

# Create solution and projects
if (-not (Test-Path './calculator.slnx')) {
    dotnet new sln --name calculator
    Write-Host "Created solution: ./calculator.slnx"
}

if (-not (Test-Path './calculator/calculator.csproj')) {
    dotnet new console --name calculator --framework net8.0
    Write-Host "Created project: ./calculator/calculator.csproj"
}

if (-not (Test-Path './calculator.tests/calculator.tests.csproj')) {
    dotnet new xunit --name calculator.tests --framework net8.0
    Write-Host "Created project: ./calculator.tests/calculator.tests.csproj"
}

# Add projects to solution
dotnet sln ./calculator.slnx add ./calculator/calculator.csproj
dotnet sln ./calculator.slnx add ./calculator.tests/calculator.tests.csproj
Write-Host "Added projects to solution"

# Add project reference
dotnet add ./calculator.tests/calculator.tests.csproj reference ./calculator/calculator.csproj
Write-Host "Added reference: calculator.tests -> calculator"

# Rename files
if (Test-Path './calculator/Program.cs') {
    Rename-Item -Path './calculator/Program.cs' -NewName 'Calculator.cs' -Force
    Write-Host "Renamed: Program.cs -> Calculator.cs"
}

if (Test-Path './calculator.tests/UnitTest1.cs') {
    Rename-Item -Path './calculator.tests/UnitTest1.cs' -NewName 'CalculatorTest.cs' -Force
    Write-Host "Renamed: UnitTest1.cs -> CalculatorTest.cs"
}

# Build solution to verify
dotnet build ./calculator.slnx
Write-Host "Build succeeded. Solution setup complete."
```

## Verification Checklist

After running setup, verify:

| Check | Command | Expected Result |
|-------|---------|-----------------|
| Solution exists | `Test-Path 'src/workspace/calculator-xunit-testing/calculator.slnx'` | `$true` |
| Console app project | `Test-Path 'src/workspace/calculator-xunit-testing/calculator/calculator.csproj'` | `$true` |
| Test project | `Test-Path 'src/workspace/calculator-xunit-testing/calculator.tests/calculator.tests.csproj'` | `$true` |
| Calculator.cs exists | `Test-Path 'src/workspace/calculator-xunit-testing/calculator/Calculator.cs'` | `$true` |
| CalculatorTest.cs exists | `Test-Path 'src/workspace/calculator-xunit-testing/calculator.tests/CalculatorTest.cs'` | `$true` |
| Build succeeds | `dotnet build .\calculator.slnx` (from solution directory) | `Build succeeded` |

## Troubleshooting

### Problem: Script file not found

**Error:** `Cannot find a script or executable file named 'Set-DotnetSlnForCalculator.ps1'`

**Solution:** 
1. Verify script exists: `Test-Path "src/workspace/Set-DotnetSlnForCalculator.ps1"`
2. If missing, create it using the script content above
3. Ensure you're running from the correct directory (`src/workspace` or repo root)

### Problem: Execution policy blocks script

**Error:** `cannot be loaded because running scripts is disabled on this system`

**Solution:** Override execution policy for the current process:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\Set-DotnetSlnForCalculator.ps1
```

### Problem: git command not found

**Error:** `'git' is not recognized as an internal or external command`

**Solution:**
1. Install Git for Windows or ensure Git is in PATH
2. Or manually specify the repo root instead of using `git rev-parse --show-toplevel`

### Problem: dotnet command not found

**Error:** `'dotnet' is not recognized as an internal or external command`

**Solution:**
1. Install .NET 8 SDK from https://dotnet.microsoft.com/download
2. Verify installation: `dotnet --version` should show version 8.x.x or higher
3. Restart terminal after installation

### Problem: Build fails with project reference errors

**Error:** `Project reference '../calculator/calculator.csproj' was not found`

**Solution:**
1. Ensure you ran all `dotnet sln add` commands
2. Verify project structure matches: `calculator/calculator.csproj` and `calculator.tests/calculator.tests.csproj`
3. Run `dotnet add ./calculator.tests/calculator.tests.csproj reference ./calculator/calculator.csproj` again

### Problem: Stale artifacts after setup changes

**Error:** Build succeeds but old files remain or tests don't run

**Solution:** Clean all artifacts and rebuild:

```powershell
dotnet clean
dotnet restore
dotnet build ./calculator.slnx
```

## Next Steps

After setup completes successfully:

1. **Implement Calculator.cs** — Add top-level statements and console interaction logic
2. **Implement CalculatorOperations.cs** — Add public static arithmetic methods
3. **Implement CalculatorTest.cs** — Add xUnit test cases
4. **Run Tests** — Execute `dotnet test ./calculator.slnx` to validate implementation

See the implementation prompt `1.12-implement-full-calculator-solution.prompt.md` for detailed guidance on calculator code.

---
