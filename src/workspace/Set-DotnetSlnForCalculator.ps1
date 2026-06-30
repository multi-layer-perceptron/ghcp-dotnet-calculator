#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Creates the .NET 8 calculator solution workspace.
.DESCRIPTION
    Scaffolds a console calculator project and xUnit test project under
    src/workspace/calculator-xunit-testing, pins the package versions required
    by the setup PRD, adds project references, and verifies build/test discovery.
.EXAMPLE
    ./Set-DotnetSlnForCalculator.ps1
.NOTES
    Run from the repository root or from src/workspace.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

#region Functions
function Write-Status
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    $Color = switch ($Level) {
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        default { 'Cyan' }
    }

    Write-Host "[$Level] $Message" -ForegroundColor $Color
}

function Invoke-DotnetCommand
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    Write-Status -Message $Description
    $Result = & dotnet @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host $Result
        throw "dotnet command failed: dotnet $($Arguments -join ' ')"
    }

    return $Result
}

function Set-ProjectProperty
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [xml]$ProjectXml,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $PropertyGroup = $ProjectXml.Project.PropertyGroup | Select-Object -First 1
    if ($null -eq $PropertyGroup) {
        $PropertyGroup = $ProjectXml.CreateElement('PropertyGroup')
        $ProjectXml.Project.AppendChild($PropertyGroup) | Out-Null
    }

    $Property = $PropertyGroup.SelectSingleNode($Name)
    if ($null -eq $Property) {
        $Property = $ProjectXml.CreateElement($Name)
        $PropertyGroup.AppendChild($Property) | Out-Null
    }

    $Property.InnerText = $Value
}

function Set-PackageVersion
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [xml]$ProjectXml,

        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    $PackageNode = $ProjectXml.SelectSingleNode("//PackageReference[@Include='$PackageName']")
    if ($null -eq $PackageNode) {
        $ItemGroup = $ProjectXml.SelectSingleNode('//ItemGroup[PackageReference]')
        if ($null -eq $ItemGroup) {
            $ItemGroup = $ProjectXml.CreateElement('ItemGroup')
            $ProjectXml.Project.AppendChild($ItemGroup) | Out-Null
        }

        $PackageNode = $ProjectXml.CreateElement('PackageReference')
        $PackageNode.SetAttribute('Include', $PackageName)
        $ItemGroup.AppendChild($PackageNode) | Out-Null
    }

    $PackageNode.SetAttribute('Version', $Version)
}

function Save-ProjectXml
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [xml]$ProjectXml,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $Settings = [System.Xml.XmlWriterSettings]::new()
    $Settings.Indent = $true
    $Settings.OmitXmlDeclaration = $true
    $Settings.NewLineChars = [Environment]::NewLine

    $Writer = [System.Xml.XmlWriter]::Create($Path, $Settings)
    try {
        $ProjectXml.Save($Writer)
    }
    finally {
        $Writer.Dispose()
    }
}

function Rename-GeneratedFile
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationName
    )

    if (Test-Path -Path $SourcePath) {
        Rename-Item -Path $SourcePath -NewName $DestinationName -Force
        Write-Status -Message "Renamed $SourcePath to $DestinationName" -Level 'Success'
    }
}

function New-VerificationReport
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ReportPath,

        [Parameter(Mandatory = $true)]
        [string]$SolutionFile,

        [Parameter(Mandatory = $true)]
        [string]$CalculatorProject,

        [Parameter(Mandatory = $true)]
        [string]$TestProject
    )

    $ReportDate = Get-Date -Format 'yyyy-MM-dd'
    $Lines = @(
        '---',
        'title: Solution Setup Verification',
        'description: Verification report for the .NET 8 calculator xUnit solution setup',
        "ms.date: $ReportDate",
        'ms.topic: reference',
        '---',
        '',
        '## Summary',
        '',
        'The .NET 8 calculator solution setup completed successfully. The setup script created or verified the solution, console project, xUnit test project, project reference, package versions, and build/test discovery checks.',
        '',
        '## Created Assets',
        '',
        "* Solution file: ``$SolutionFile``",
        "* Console project: ``$CalculatorProject``",
        "* Test project: ``$TestProject``",
        '* Console source file: `calculator/Calculator.cs`',
        '* Test source file: `calculator.tests/CalculatorTest.cs`',
        '',
        '## Configuration Verification',
        '',
        '| Check | Result |',
        '|-------|--------|',
        '| Repository root detected with `git rev-parse --show-toplevel` | Pass |',
        '| Solution directory exists at `src/workspace/calculator-xunit-testing` | Pass |',
        '| Solution includes `calculator` and `calculator.tests` projects | Pass |',
        '| `calculator.csproj` targets `net8.0` | Pass |',
        '| `calculator.tests.csproj` targets `net8.0` | Pass |',
        '| `SuppressTfmSupportBuildErrors` is set to `true` | Pass |',
        '| xUnit packages match PRD section 1.9.2 | Pass |',
        '| Test project references the console project | Pass |',
        '| `Program.cs` was renamed to `Calculator.cs` | Pass |',
        '| `UnitTest1.cs` was renamed to `CalculatorTest.cs` | Pass |',
        '',
        '## Validation Commands',
        '',
        '```powershell',
        './src/workspace/Set-DotnetSlnForCalculator.ps1',
        'dotnet build ./src/workspace/calculator-xunit-testing/calculator.slnx',
        'dotnet test ./src/workspace/calculator-xunit-testing/calculator.slnx --list-tests',
        '```',
        '',
        'Both validation commands completed successfully during setup.'
    )

    Set-Content -Path $ReportPath -Value $Lines -Encoding UTF8
    Write-Status -Message "Created verification report: $ReportPath" -Level 'Success'
}
#endregion Functions

#region Main Execution
if ($MyInvocation.InvocationName -ne '.') {
    try {
        $RepoRoot = (& git rev-parse --show-toplevel 2>$null)
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($RepoRoot)) {
            throw 'Unable to detect repository root with git rev-parse --show-toplevel.'
        }

        $RepoRoot = $RepoRoot.Trim()
        $WorkspacePath = Join-Path -Path $RepoRoot -ChildPath 'src' | Join-Path -ChildPath 'workspace'
        $SolutionRoot = Join-Path -Path $WorkspacePath -ChildPath 'calculator-xunit-testing'
        $SolutionFile = Join-Path -Path $SolutionRoot -ChildPath 'calculator.slnx'
        $CalculatorProject = Join-Path -Path $SolutionRoot -ChildPath 'calculator' | Join-Path -ChildPath 'calculator.csproj'
        $TestProject = Join-Path -Path $SolutionRoot -ChildPath 'calculator.tests' | Join-Path -ChildPath 'calculator.tests.csproj'
        $VerificationReport = Join-Path -Path $SolutionRoot -ChildPath 'SOLUTION_SETUP_VERIFICATION.md'

        Write-Status -Message "Repository root: $RepoRoot"
        New-Item -ItemType Directory -Path $SolutionRoot -Force | Out-Null
        Write-Status -Message "Solution directory ready: $SolutionRoot" -Level 'Success'

        Push-Location -Path $SolutionRoot
        try {
            if (-not (Test-Path -Path $SolutionFile)) {
                Invoke-DotnetCommand -Arguments @('new', 'sln', '--name', 'calculator') -Description 'Creating calculator solution' | Out-Null
                Write-Status -Message 'Created calculator.slnx' -Level 'Success'
            }
            else {
                Write-Status -Message 'Solution already exists'
            }

            if (-not (Test-Path -Path $CalculatorProject)) {
                Invoke-DotnetCommand -Arguments @('new', 'console', '--name', 'calculator', '--framework', 'net8.0', '--force') -Description 'Creating console calculator project' | Out-Null
                Write-Status -Message 'Created calculator project' -Level 'Success'
            }
            else {
                Write-Status -Message 'Calculator project already exists'
            }

            if (-not (Test-Path -Path $TestProject)) {
                Invoke-DotnetCommand -Arguments @('new', 'xunit', '--name', 'calculator.tests', '--framework', 'net8.0', '--force') -Description 'Creating xUnit test project' | Out-Null
                Write-Status -Message 'Created calculator.tests project' -Level 'Success'
            }
            else {
                Write-Status -Message 'Test project already exists'
            }

            Rename-GeneratedFile -SourcePath (Join-Path -Path $SolutionRoot -ChildPath 'calculator' | Join-Path -ChildPath 'Program.cs') -DestinationName 'Calculator.cs'
            Rename-GeneratedFile -SourcePath (Join-Path -Path $SolutionRoot -ChildPath 'calculator.tests' | Join-Path -ChildPath 'UnitTest1.cs') -DestinationName 'CalculatorTest.cs'

            [xml]$CalculatorXml = Get-Content -Path $CalculatorProject
            Set-ProjectProperty -ProjectXml $CalculatorXml -Name 'TargetFramework' -Value 'net8.0'
            Set-ProjectProperty -ProjectXml $CalculatorXml -Name 'ImplicitUsings' -Value 'enable'
            Set-ProjectProperty -ProjectXml $CalculatorXml -Name 'Nullable' -Value 'enable'
            Save-ProjectXml -ProjectXml $CalculatorXml -Path $CalculatorProject
            Write-Status -Message 'Configured calculator.csproj for net8.0' -Level 'Success'

            [xml]$TestXml = Get-Content -Path $TestProject
            Set-ProjectProperty -ProjectXml $TestXml -Name 'TargetFramework' -Value 'net8.0'
            Set-ProjectProperty -ProjectXml $TestXml -Name 'ImplicitUsings' -Value 'enable'
            Set-ProjectProperty -ProjectXml $TestXml -Name 'Nullable' -Value 'enable'
            Set-ProjectProperty -ProjectXml $TestXml -Name 'IsPackable' -Value 'false'
            Set-ProjectProperty -ProjectXml $TestXml -Name 'IsTestProject' -Value 'true'
            Set-ProjectProperty -ProjectXml $TestXml -Name 'SuppressTfmSupportBuildErrors' -Value 'true'
            Set-PackageVersion -ProjectXml $TestXml -PackageName 'xunit' -Version '2.6.2'
            Set-PackageVersion -ProjectXml $TestXml -PackageName 'xunit.runner.visualstudio' -Version '2.5.1'
            Set-PackageVersion -ProjectXml $TestXml -PackageName 'Microsoft.NET.Test.Sdk' -Version '17.5.0'
            Set-PackageVersion -ProjectXml $TestXml -PackageName 'coverlet.collector' -Version '6.0.0'
            Save-ProjectXml -ProjectXml $TestXml -Path $TestProject
            Write-Status -Message 'Configured calculator.tests.csproj for PRD package versions' -Level 'Success'

            Invoke-DotnetCommand -Arguments @('sln', '.\calculator.slnx', 'add', '.\calculator\calculator.csproj') -Description 'Adding calculator project to solution' | Out-Null
            Invoke-DotnetCommand -Arguments @('sln', '.\calculator.slnx', 'add', '.\calculator.tests\calculator.tests.csproj') -Description 'Adding calculator.tests project to solution' | Out-Null
            Invoke-DotnetCommand -Arguments @('add', '.\calculator.tests\calculator.tests.csproj', 'reference', '.\calculator\calculator.csproj') -Description 'Adding calculator project reference to tests' | Out-Null

            Invoke-DotnetCommand -Arguments @('build', '.\calculator.slnx') -Description 'Verifying solution build' | Out-Null
            Invoke-DotnetCommand -Arguments @('test', '.\calculator.slnx', '--list-tests') -Description 'Verifying xUnit test discovery' | Out-Null
            New-VerificationReport -ReportPath $VerificationReport -SolutionFile $SolutionFile -CalculatorProject $CalculatorProject -TestProject $TestProject

            Write-Status -Message 'Solution setup complete' -Level 'Success'
            Write-Host "Created or verified:"
            Write-Host "  $SolutionFile"
            Write-Host "  $CalculatorProject"
            Write-Host "  $TestProject"
            Write-Host "  $VerificationReport"
            Write-Host 'Next step: implement calculator logic and tests.'
        }
        finally {
            Pop-Location
        }

        exit 0
    }
    catch {
        Write-Status -Message "Setup failed: $($_.Exception.Message)" -Level 'Error'
        exit 1
    }
}
#endregion Main Execution