#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
	Sets up the .NET 8 calculator solution with an xUnit test project.
.DESCRIPTION
	Creates and configures the calculator-xunit-testing workspace, including the
	console application, xUnit test project, project references, package versions,
	and build/test discovery verification required by the setup PRD.
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
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]$Message,

		[Parameter(Mandatory = $false)]
		[ValidateSet('Info', 'Success', 'Warning', 'Error')]
		[string]$Kind = 'Info'
	)

	$Color = switch ($Kind) {
		'Success' { 'Green' }
		'Warning' { 'Yellow' }
		'Error' { 'Red' }
		default { 'Cyan' }
	}

	Write-Host "[$Kind] $Message" -ForegroundColor $Color
}

function Invoke-CheckedCommand {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]$FilePath,

		[Parameter(Mandatory = $true)]
		[string[]]$ArgumentList,

		[Parameter(Mandatory = $false)]
		[string]$WorkingDirectory = (Get-Location).Path
	)

	Push-Location $WorkingDirectory
	try {
		$Output = & $FilePath @ArgumentList 2>&1
		if ($LASTEXITCODE -ne 0) {
			throw "$FilePath $($ArgumentList -join ' ') failed with exit code $LASTEXITCODE.`n$Output"
		}

		return $Output
	}
	finally {
		Pop-Location
	}
}

function Get-RepositoryRoot {
	[CmdletBinding()]
	param()

	$RepoRoot = & git rev-parse --show-toplevel 2>$null
	if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($RepoRoot)) {
		throw 'Unable to determine repository root. Run this script from inside a Git repository.'
	}

	return $RepoRoot.Trim()
}

function Set-ProjectProperty {
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

	$Node = $PropertyGroup.SelectSingleNode($Name)
	if ($null -eq $Node) {
		$Node = $ProjectXml.CreateElement($Name)
		$PropertyGroup.AppendChild($Node) | Out-Null
	}

	if ($Node.InnerText -eq $Value) {
		return $false
	}

	$Node.InnerText = $Value
	return $true
}

function Set-PackageVersion {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[xml]$ProjectXml,

		[Parameter(Mandatory = $true)]
		[string]$PackageName,

		[Parameter(Mandatory = $true)]
		[string]$Version
	)

	$Changed = $false
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
		$Changed = $true
	}

	if ($PackageNode.GetAttribute('Version') -eq $Version) {
		return $Changed
	}

	$PackageNode.SetAttribute('Version', $Version)
	return $true
}

function Save-ProjectXml {
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
	$Writer = [System.Xml.XmlWriter]::Create($Path, $Settings)
	try {
		$ProjectXml.Save($Writer)
	}
	finally {
		$Writer.Dispose()
	}
}

function Test-SolutionContainsProject {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]$SolutionFile,

		[Parameter(Mandatory = $true)]
		[string]$ProjectPath
	)

	if ($SolutionFile.EndsWith('.slnx', [System.StringComparison]::OrdinalIgnoreCase)) {
		[xml]$SolutionXml = Get-Content -Path $SolutionFile -Raw
		return $null -ne $SolutionXml.SelectSingleNode("//Project[@Path='$ProjectPath']")
	}

	$SolutionContent = Get-Content -Path $SolutionFile -Raw
	return $SolutionContent -match [regex]::Escape($ProjectPath.Replace('/', '\'))
}

function Add-ProjectToSolution {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]$SolutionFile,

		[Parameter(Mandatory = $true)]
		[string]$ProjectPath,

		[Parameter(Mandatory = $true)]
		[string]$SolutionDir
	)

	if (Test-SolutionContainsProject -SolutionFile $SolutionFile -ProjectPath $ProjectPath) {
		Write-Status "Solution already includes $ProjectPath" 'Info'
		return
	}

	Invoke-CheckedCommand -FilePath 'dotnet' -ArgumentList @('sln', $SolutionFile, 'add', $ProjectPath) -WorkingDirectory $SolutionDir | Out-Null
	Write-Status "Added $ProjectPath to solution" 'Success'
}

function Write-VerificationReport {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]$ReportPath,

		[Parameter(Mandatory = $true)]
		[string]$SolutionDir,

		[Parameter(Mandatory = $true)]
		[string]$SolutionFile
	)

	$ReportDate = Get-Date -Format 'yyyy-MM-dd'
	$RelativeSolutionDir = 'src/workspace/calculator-xunit-testing'
	$RelativeSolutionFile = "$RelativeSolutionDir/$(Split-Path -Path $SolutionFile -Leaf)"
	$CodeFence = '```'
	$ContentLines = @(
		'---',
		'title: Solution Setup Verification',
		'description: Verification report for the .NET 8 calculator solution setup workflow',
		'author: GitHub Copilot',
		"ms.date: $ReportDate",
		'ms.topic: reference',
		'---',
		'',
		'## Summary',
		'',
		'The .NET 8 calculator solution setup completed successfully. The setup script',
		'created or verified the solution structure, configured the console and xUnit',
		'projects, pinned required test packages, established the project reference, and',
		'validated build plus test discovery.',
		'',
		'## Verified Artifacts',
		'',
		"* Solution directory: ``$RelativeSolutionDir``",
		"* Solution file: ``$RelativeSolutionFile``",
		"* Console project: ``$RelativeSolutionDir/calculator/calculator.csproj``",
		"* Console source file: ``$RelativeSolutionDir/calculator/Calculator.cs``",
		"* Test project: ``$RelativeSolutionDir/calculator.tests/calculator.tests.csproj``",
		"* Test source file: ``$RelativeSolutionDir/calculator.tests/CalculatorTest.cs``",
		'',
		'## Configuration',
		'',
		'* Console project targets `net8.0`',
		'* Test project targets `net8.0`',
		'* Test project sets `SuppressTfmSupportBuildErrors` to `true`',
		'* Test project references `../calculator/calculator.csproj`',
		'* xUnit package version is `2.6.2`',
		'* xUnit Visual Studio runner package version is `2.5.1`',
		'* Microsoft.NET.Test.Sdk package version is `17.5.0`',
		'* coverlet.collector package version is `6.0.0`',
		'',
		'## Validation Commands',
		'',
		"${CodeFence}powershell",
		'pwsh src/workspace/Set-DotnetSlnForCalculator.ps1',
		"dotnet build $RelativeSolutionFile",
		"dotnet test $RelativeSolutionFile --list-tests",
		$CodeFence,
		'',
		'## Result',
		'',
		"All setup verification checks passed on $ReportDate."
	)
	$Content = $ContentLines -join [Environment]::NewLine

	Set-Content -Path $ReportPath -Value $Content -Encoding utf8
	Write-Status "Verification report updated: $ReportPath" 'Success'
}
#endregion Functions

#region Main Execution
if ($MyInvocation.InvocationName -ne '.') {
	try {
		$RepoRoot = Get-RepositoryRoot
		Write-Status "Repository root: $RepoRoot"

		$WorkspacePath = Join-Path -Path $RepoRoot -ChildPath 'src' | Join-Path -ChildPath 'workspace'
		$SolutionDir = Join-Path -Path $WorkspacePath -ChildPath 'calculator-xunit-testing'
		$ConsoleProjectDir = Join-Path -Path $SolutionDir -ChildPath 'calculator'
		$TestProjectDir = Join-Path -Path $SolutionDir -ChildPath 'calculator.tests'
		$ConsoleProjectFile = Join-Path -Path $ConsoleProjectDir -ChildPath 'calculator.csproj'
		$TestProjectFile = Join-Path -Path $TestProjectDir -ChildPath 'calculator.tests.csproj'
		$VerificationReport = Join-Path -Path $RepoRoot -ChildPath 'SOLUTION_SETUP_VERIFICATION.md'

		New-Item -ItemType Directory -Path $SolutionDir -Force | Out-Null
		Write-Status "Solution directory ready: $SolutionDir" 'Success'

		$SolutionFile = Join-Path -Path $SolutionDir -ChildPath 'calculator.slnx'
		if (-not (Test-Path -Path $SolutionFile)) {
			Invoke-CheckedCommand -FilePath 'dotnet' -ArgumentList @('new', 'sln', '--name', 'calculator') -WorkingDirectory $SolutionDir | Out-Null
			$GeneratedSln = Join-Path -Path $SolutionDir -ChildPath 'calculator.sln'
			if ((Test-Path -Path $GeneratedSln) -and -not (Test-Path -Path $SolutionFile)) {
				$SolutionFile = $GeneratedSln
			}
			Write-Status "Created solution file: $SolutionFile" 'Success'
		}
		else {
			Write-Status "Solution file already exists: $SolutionFile" 'Info'
		}

		if (-not (Test-Path -Path $ConsoleProjectFile)) {
			Invoke-CheckedCommand -FilePath 'dotnet' -ArgumentList @('new', 'console', '--name', 'calculator', '--framework', 'net8.0', '--force') -WorkingDirectory $SolutionDir | Out-Null
			Write-Status "Created console project: $ConsoleProjectFile" 'Success'
		}
		else {
			Write-Status "Console project already exists: $ConsoleProjectFile" 'Info'
		}

		if (-not (Test-Path -Path $TestProjectFile)) {
			Invoke-CheckedCommand -FilePath 'dotnet' -ArgumentList @('new', 'xunit', '--name', 'calculator.tests', '--framework', 'net8.0', '--force') -WorkingDirectory $SolutionDir | Out-Null
			Write-Status "Created xUnit project: $TestProjectFile" 'Success'
		}
		else {
			Write-Status "Test project already exists: $TestProjectFile" 'Info'
		}

		[xml]$ConsoleProjectXml = Get-Content -Path $ConsoleProjectFile -Raw
		$ConsoleProjectChanged = $false
		$ConsoleProjectChanged = (Set-ProjectProperty -ProjectXml $ConsoleProjectXml -Name 'TargetFramework' -Value 'net8.0') -or $ConsoleProjectChanged
		$ConsoleProjectChanged = (Set-ProjectProperty -ProjectXml $ConsoleProjectXml -Name 'ImplicitUsings' -Value 'enable') -or $ConsoleProjectChanged
		if ($ConsoleProjectChanged) {
			Save-ProjectXml -ProjectXml $ConsoleProjectXml -Path $ConsoleProjectFile
		}
		Write-Status 'Configured console project for net8.0' 'Success'

		[xml]$TestProjectXml = Get-Content -Path $TestProjectFile -Raw
		$TestProjectChanged = $false
		$TestProjectChanged = (Set-ProjectProperty -ProjectXml $TestProjectXml -Name 'TargetFramework' -Value 'net8.0') -or $TestProjectChanged
		$TestProjectChanged = (Set-ProjectProperty -ProjectXml $TestProjectXml -Name 'ImplicitUsings' -Value 'enable') -or $TestProjectChanged
		$TestProjectChanged = (Set-ProjectProperty -ProjectXml $TestProjectXml -Name 'Nullable' -Value 'enable') -or $TestProjectChanged
		$TestProjectChanged = (Set-ProjectProperty -ProjectXml $TestProjectXml -Name 'IsPackable' -Value 'false') -or $TestProjectChanged
		$TestProjectChanged = (Set-ProjectProperty -ProjectXml $TestProjectXml -Name 'IsTestProject' -Value 'true') -or $TestProjectChanged
		$TestProjectChanged = (Set-ProjectProperty -ProjectXml $TestProjectXml -Name 'SuppressTfmSupportBuildErrors' -Value 'true') -or $TestProjectChanged
		$TestProjectChanged = (Set-PackageVersion -ProjectXml $TestProjectXml -PackageName 'xunit' -Version '2.6.2') -or $TestProjectChanged
		$TestProjectChanged = (Set-PackageVersion -ProjectXml $TestProjectXml -PackageName 'xunit.runner.visualstudio' -Version '2.5.1') -or $TestProjectChanged
		$TestProjectChanged = (Set-PackageVersion -ProjectXml $TestProjectXml -PackageName 'Microsoft.NET.Test.Sdk' -Version '17.5.0') -or $TestProjectChanged
		$TestProjectChanged = (Set-PackageVersion -ProjectXml $TestProjectXml -PackageName 'coverlet.collector' -Version '6.0.0') -or $TestProjectChanged
		if ($TestProjectChanged) {
			Save-ProjectXml -ProjectXml $TestProjectXml -Path $TestProjectFile
		}
		Write-Status 'Configured xUnit project for net8.0 and required package versions' 'Success'

		$ProgramFile = Join-Path -Path $ConsoleProjectDir -ChildPath 'Program.cs'
		if (Test-Path -Path $ProgramFile) {
			Rename-Item -Path $ProgramFile -NewName 'Calculator.cs' -Force
			Write-Status 'Renamed Program.cs to Calculator.cs' 'Success'
		}
		elseif (Test-Path -Path (Join-Path -Path $ConsoleProjectDir -ChildPath 'Calculator.cs')) {
			Write-Status 'Calculator.cs already exists' 'Info'
		}

		$UnitTestFile = Join-Path -Path $TestProjectDir -ChildPath 'UnitTest1.cs'
		if (Test-Path -Path $UnitTestFile) {
			Rename-Item -Path $UnitTestFile -NewName 'CalculatorTest.cs' -Force
			Write-Status 'Renamed UnitTest1.cs to CalculatorTest.cs' 'Success'
		}
		elseif (Test-Path -Path (Join-Path -Path $TestProjectDir -ChildPath 'CalculatorTest.cs')) {
			Write-Status 'CalculatorTest.cs already exists' 'Info'
		}

		Add-ProjectToSolution -SolutionFile $SolutionFile -ProjectPath 'calculator/calculator.csproj' -SolutionDir $SolutionDir
		Add-ProjectToSolution -SolutionFile $SolutionFile -ProjectPath 'calculator.tests/calculator.tests.csproj' -SolutionDir $SolutionDir

		Invoke-CheckedCommand -FilePath 'dotnet' -ArgumentList @('add', $TestProjectFile, 'reference', $ConsoleProjectFile) -WorkingDirectory $SolutionDir | Out-Null
		Write-Status 'Project reference ready: calculator.tests -> calculator' 'Success'

		Invoke-CheckedCommand -FilePath 'dotnet' -ArgumentList @('build', $SolutionFile) -WorkingDirectory $SolutionDir | Out-Null
		Write-Status 'Build verification succeeded' 'Success'

		Invoke-CheckedCommand -FilePath 'dotnet' -ArgumentList @('test', $SolutionFile, '--list-tests') -WorkingDirectory $SolutionDir | Out-Null
		Write-Status 'Test discovery verification succeeded' 'Success'

		Write-VerificationReport -ReportPath $VerificationReport -SolutionDir $SolutionDir -SolutionFile $SolutionFile

		Write-Status 'Solution setup complete. Ready for calculator implementation and tests.' 'Success'
		exit 0
	}
	catch {
		Write-Status $_.Exception.Message 'Error'
		exit 1
	}
}
#endregion Main Execution
