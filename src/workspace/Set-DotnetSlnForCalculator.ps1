#Requires -Version 7.0

<#
.SYNOPSIS
    Creates the .NET 8 calculator solution with a console app and xUnit test project.
.DESCRIPTION
    Initializes src/workspace/calculator-xunit-testing with a calculator.slnx file,
    a net8.0 console application, a net8.0 xUnit test project, pinned test package
    versions, project references, renamed starter files, and setup verification output.
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
function Write-Status {
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

function Invoke-DotNetCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$FailureMessage
    )

    $Output = & dotnet @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host $Output
        throw $FailureMessage
    }

    return $Output
}

function Set-ProjectProperty {
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

    $Node = $PropertyGroup.SelectSingleNode($Name)
    if ($null -eq $Node) {
        $Node = $ProjectXml.CreateElement($Name)
        $PropertyGroup.AppendChild($Node) | Out-Null
    }

    $Node.InnerText = $Value
}

function Set-PackageVersion {
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
        $ItemGroup = $ProjectXml.Project.ItemGroup | Select-Object -First 1
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

function Save-ProjectXml {
    param(
        [Parameter(Mandatory = $true)]
        [xml]$ProjectXml,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $Settings = [System.Xml.XmlWriterSettings]::new()
    $Settings.Indent = $true
    $Settings.Encoding = [System.Text.UTF8Encoding]::new($false)

    $Writer = [System.Xml.XmlWriter]::Create($Path, $Settings)
    try {
        $ProjectXml.Save($Writer)
    }
    finally {
        $Writer.Dispose()
    }
}

function Test-SolutionContainsProject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SolutionFile,

        [Parameter(Mandatory = $true)]
        [string]$ProjectPath
    )

    $Projects = Invoke-DotNetCommand -Arguments @('sln', $SolutionFile, 'list') -FailureMessage 'Unable to list solution projects.'
    $NormalizedProjects = $Projects | ForEach-Object { $_.ToString().Replace('\', '/') }
    $NormalizedProjectPath = $ProjectPath.Replace('\', '/')

    return $NormalizedProjects -contains $NormalizedProjectPath
}

function Add-ProjectToSolution {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SolutionFile,

        [Parameter(Mandatory = $true)]
        [string]$ProjectPath
    )

    if (Test-SolutionContainsProject -SolutionFile $SolutionFile -ProjectPath $ProjectPath) {
        Write-Status "Project already registered: $ProjectPath" 'Info'
        return
    }

    Invoke-DotNetCommand -Arguments @('sln', $SolutionFile, 'add', $ProjectPath) -FailureMessage "Failed to add project to solution: $ProjectPath" | Out-Null
    Write-Status "Registered project: $ProjectPath" 'Success'
}
#endregion Functions

#region Main Execution
if ($MyInvocation.InvocationName -ne '.') {
    try {
        $RepoRoot = (git rev-parse --show-toplevel).Trim()
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($RepoRoot)) {
            throw 'Unable to detect repository root with git rev-parse.'
        }

        $WorkspacePath = Join-Path -Path $RepoRoot -ChildPath 'src/workspace'
        $SolutionRoot = Join-Path -Path $WorkspacePath -ChildPath 'calculator-xunit-testing'
        $SolutionFile = Join-Path -Path $SolutionRoot -ChildPath 'calculator.slnx'
        $CalculatorProjectDir = Join-Path -Path $SolutionRoot -ChildPath 'calculator'
        $CalculatorTestProjectDir = Join-Path -Path $SolutionRoot -ChildPath 'calculator.tests'
        $CalculatorProjectFile = Join-Path -Path $CalculatorProjectDir -ChildPath 'calculator.csproj'
        $CalculatorTestProjectFile = Join-Path -Path $CalculatorTestProjectDir -ChildPath 'calculator.tests.csproj'
        $VerificationReport = Join-Path -Path $SolutionRoot -ChildPath 'SOLUTION_SETUP_VERIFICATION.md'

        Write-Status "Repository root: $RepoRoot" 'Info'
        New-Item -ItemType Directory -Path $SolutionRoot -Force | Out-Null
        Write-Status "Solution directory ready: $SolutionRoot" 'Success'

        Push-Location $SolutionRoot
        try {
            if (-not (Test-Path -Path $SolutionFile)) {
                Invoke-DotNetCommand -Arguments @('new', 'sln', '--name', 'calculator', '--format', 'slnx') -FailureMessage 'Failed to create solution file.' | Out-Null
                Write-Status 'Created solution: calculator.slnx' 'Success'
            }
            else {
                Write-Status 'Solution already exists: calculator.slnx' 'Info'
            }

            if (-not (Test-Path -Path $CalculatorProjectFile)) {
                Invoke-DotNetCommand -Arguments @('new', 'console', '--name', 'calculator', '--framework', 'net8.0') -FailureMessage 'Failed to create calculator console project.' | Out-Null
                Write-Status 'Created console project: calculator/calculator.csproj' 'Success'
            }
            else {
                Write-Status 'Console project already exists: calculator/calculator.csproj' 'Info'
            }

            if (-not (Test-Path -Path $CalculatorTestProjectFile)) {
                Invoke-DotNetCommand -Arguments @('new', 'xunit', '--name', 'calculator.tests', '--framework', 'net8.0') -FailureMessage 'Failed to create calculator xUnit test project.' | Out-Null
                Write-Status 'Created test project: calculator.tests/calculator.tests.csproj' 'Success'
            }
            else {
                Write-Status 'Test project already exists: calculator.tests/calculator.tests.csproj' 'Info'
            }

            [xml]$CalculatorProjectXml = Get-Content -Path $CalculatorProjectFile
            Set-ProjectProperty -ProjectXml $CalculatorProjectXml -Name 'TargetFramework' -Value 'net8.0'
            Set-ProjectProperty -ProjectXml $CalculatorProjectXml -Name 'ImplicitUsings' -Value 'enable'
            Set-ProjectProperty -ProjectXml $CalculatorProjectXml -Name 'Nullable' -Value 'enable'
            Save-ProjectXml -ProjectXml $CalculatorProjectXml -Path $CalculatorProjectFile
            Write-Status 'Configured calculator project for net8.0.' 'Success'

            [xml]$CalculatorTestProjectXml = Get-Content -Path $CalculatorTestProjectFile
            Set-ProjectProperty -ProjectXml $CalculatorTestProjectXml -Name 'TargetFramework' -Value 'net8.0'
            Set-ProjectProperty -ProjectXml $CalculatorTestProjectXml -Name 'ImplicitUsings' -Value 'enable'
            Set-ProjectProperty -ProjectXml $CalculatorTestProjectXml -Name 'Nullable' -Value 'enable'
            Set-ProjectProperty -ProjectXml $CalculatorTestProjectXml -Name 'IsPackable' -Value 'false'
            Set-ProjectProperty -ProjectXml $CalculatorTestProjectXml -Name 'IsTestProject' -Value 'true'
            Set-ProjectProperty -ProjectXml $CalculatorTestProjectXml -Name 'SuppressTfmSupportBuildErrors' -Value 'true'
            Set-PackageVersion -ProjectXml $CalculatorTestProjectXml -PackageName 'xunit' -Version '2.6.2'
            Set-PackageVersion -ProjectXml $CalculatorTestProjectXml -PackageName 'xunit.runner.visualstudio' -Version '2.5.1'
            Set-PackageVersion -ProjectXml $CalculatorTestProjectXml -PackageName 'Microsoft.NET.Test.Sdk' -Version '17.5.0'
            Set-PackageVersion -ProjectXml $CalculatorTestProjectXml -PackageName 'coverlet.collector' -Version '6.0.0'
            Save-ProjectXml -ProjectXml $CalculatorTestProjectXml -Path $CalculatorTestProjectFile
            Write-Status 'Configured test project for net8.0 and pinned xUnit packages.' 'Success'

            $ProgramFile = Join-Path -Path $CalculatorProjectDir -ChildPath 'Program.cs'
            $CalculatorFile = Join-Path -Path $CalculatorProjectDir -ChildPath 'Calculator.cs'
            if ((Test-Path -Path $ProgramFile) -and -not (Test-Path -Path $CalculatorFile)) {
                Rename-Item -Path $ProgramFile -NewName 'Calculator.cs'
                Write-Status 'Renamed Program.cs to Calculator.cs.' 'Success'
            }
            elseif (Test-Path -Path $CalculatorFile) {
                Write-Status 'Calculator.cs already exists.' 'Info'
            }

            $UnitTestFile = Join-Path -Path $CalculatorTestProjectDir -ChildPath 'UnitTest1.cs'
            $CalculatorTestFile = Join-Path -Path $CalculatorTestProjectDir -ChildPath 'CalculatorTest.cs'
            if ((Test-Path -Path $UnitTestFile) -and -not (Test-Path -Path $CalculatorTestFile)) {
                Rename-Item -Path $UnitTestFile -NewName 'CalculatorTest.cs'
                Write-Status 'Renamed UnitTest1.cs to CalculatorTest.cs.' 'Success'
            }
            elseif (Test-Path -Path $CalculatorTestFile) {
                Write-Status 'CalculatorTest.cs already exists.' 'Info'
            }

            Add-ProjectToSolution -SolutionFile $SolutionFile -ProjectPath 'calculator/calculator.csproj'
            Add-ProjectToSolution -SolutionFile $SolutionFile -ProjectPath 'calculator.tests/calculator.tests.csproj'

            $ProjectReferenceOutput = Invoke-DotNetCommand -Arguments @('add', $CalculatorTestProjectFile, 'reference', $CalculatorProjectFile) -FailureMessage 'Failed to add test project reference to calculator project.'
            Write-Status ($ProjectReferenceOutput -join ' ') 'Success'

            Invoke-DotNetCommand -Arguments @('build', $SolutionFile) -FailureMessage 'Build verification failed.' | Out-Null
            Write-Status 'Build verification succeeded.' 'Success'

            Invoke-DotNetCommand -Arguments @('test', $SolutionFile, '--list-tests', '--no-build') -FailureMessage 'Test discovery verification failed.' | Out-Null
            Write-Status 'Test discovery verification succeeded.' 'Success'

            $ReportContent = @(
                '# Solution Setup Verification',
                '',
                "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')",
                '',
                '## Created Assets',
                '',
                '- `calculator.slnx`',
                '- `calculator/calculator.csproj` targeting `net8.0`',
                '- `calculator/Calculator.cs`',
                '- `calculator.tests/calculator.tests.csproj` targeting `net8.0`',
                '- `calculator.tests/CalculatorTest.cs`',
                '',
                '## Package Versions',
                '',
                '- `xunit` 2.6.2',
                '- `xunit.runner.visualstudio` 2.5.1',
                '- `Microsoft.NET.Test.Sdk` 17.5.0',
                '- `coverlet.collector` 6.0.0',
                '',
                '## Verification',
                '',
                '- `dotnet build calculator.slnx` succeeded.',
                '- `dotnet test calculator.slnx --list-tests --no-build` succeeded.'
            )
            Set-Content -Path $VerificationReport -Value $ReportContent -Encoding UTF8
            Write-Status "Verification report written: $VerificationReport" 'Success'

            Write-Status 'Solution setup complete.' 'Success'
        }
        finally {
            Pop-Location
        }
    }
    catch {
        Write-Status "Setup failed: $($_.Exception.Message)" 'Error'
        exit 1
    }
}
#endregion Main Execution