#Requires -Version 7.0

<#
.SYNOPSIS
    Creates a PostgreSQL Docker container and imports CSV test data.

.DESCRIPTION
    Automates the manual workflow from SKILL.md:
    - Validates prerequisites (Docker + CSV file)
    - Pulls PostgreSQL image
    - Prompts securely for password (if not provided)
    - Creates/starts PostgreSQL container
    - Creates target database if needed
    - Creates a table from CSV headers (all columns as TEXT)
    - Imports CSV using PostgreSQL COPY
    - Verifies import by returning row count

.PARAMETER CsvPath
    Path to the source CSV file.

.PARAMETER ContainerName
    Docker container name for PostgreSQL.

.PARAMETER DatabaseName
    PostgreSQL database name.

.PARAMETER TableName
    Target table to import rows into.

.PARAMETER PostgresUser
    PostgreSQL user account name.

.PARAMETER PostgresPassword
    Secure string password for PostgreSQL user. If omitted, you are prompted.

.PARAMETER HostPort
    Host port mapped to PostgreSQL container port 5432.

.PARAMETER Image
    PostgreSQL Docker image to use.

.PARAMETER ForceRecreate
    Recreate container if it already exists.

.EXAMPLE
    pwsh .\scripts\Convert-CsvToPostgreSQL.ps1 `
      -CsvPath .\templates\data.csv `
      -ContainerName my-postgres `
      -DatabaseName mydatabase `
      -TableName test_data `
      -HostPort 5432
#>
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$CsvPath = (Join-Path -Path "$(git --rev-parse --show-toplevel)\programming\dotnet\csharp\workspace\calculator-xunit-testing\calculator.tests\TestData\CalculatorTestData.csv"),

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ContainerName = "test-container",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$DatabaseName = "test_db",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$TableName = "test_data",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$PostgresUser = "postgres_user",

    [Parameter(Mandatory = $false)]
    [SecureString]$PostgresPassword,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 65535)]
    [int]$HostPort = 5432,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$Image = "postgres:latest",

    [Parameter(Mandatory = $false)]
    [switch]$ForceRecreate
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

function Test-CommandAvailable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CommandName
    )

    return $null -ne (Get-Command -Name $CommandName -ErrorAction SilentlyContinue)
}
# end function

function ConvertTo-PlainText
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [SecureString]$SecureValue
    )

    $secureBstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureValue)

    try
    {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($secureBstr)
    }
    finally
    {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($secureBstr)
    }
    # end finally
}
# end function

function ConvertTo-SqlIdentifier
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Value
    )

    $normalized = ($Value -replace '[^a-zA-Z0-9_]', '_').Trim('_')
    if ([string]::IsNullOrWhiteSpace($normalized))
    {
        throw "CSV header '$Value' cannot be converted to a valid SQL identifier."
    }
    # end if

    if ($normalized -match '^[0-9]')
    {
        $normalized = "col_$normalized"
    }
    # end if

    return $normalized
}
# end function

function Wait-PostgresReady
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Container,

        [Parameter(Mandatory = $true)]
        [string]$User,

        [Parameter(Mandatory = $true)]
        [string]$Database,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 120)]
        [int]$MaxAttempts = 30
    )

    Write-Host "Waiting for PostgreSQL readiness in container '$Container'..."

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++)
    {
        $isReady = $false
        try
        {
            docker exec $Container pg_isready -U $User -d $Database *> $null
            $isReady = ($LASTEXITCODE -eq 0)
        }
        catch
        {
            $isReady = $false
        }
        # end try-catch

        if ($isReady)
        {
            Write-Host "PostgreSQL is ready."
            return
        }
        # end if

        Start-Sleep -Seconds 2
    }
    # end for

    throw "PostgreSQL did not become ready in expected time."
}
# end function

if (-not (Test-CommandAvailable -CommandName "docker"))
{
    throw "Docker is not installed or not available in PATH."
}
# end if

$resolvedCsvPath = (Resolve-Path -Path $CsvPath -ErrorAction Stop).Path
if (-not (Test-Path -Path $resolvedCsvPath -PathType Leaf))
{
    throw "CSV file not found: $resolvedCsvPath"
}
# end if

if (-not $PostgresPassword)
{
    $promptMessage = "Enter a strong password for the PostgreSQL '$PostgresUser' user"
    $PostgresPassword = Read-Host -Prompt $promptMessage -AsSecureString
}
# end if

$plainPassword = ConvertTo-PlainText -SecureValue $PostgresPassword

Write-Host "Pulling PostgreSQL image: $Image"
docker pull $Image | Out-Null

$existingContainer = docker ps -a --filter "name=^/${ContainerName}$" --format "{{.Names}}"
if ($existingContainer -and $ForceRecreate)
{
    Write-Host "Removing existing container '$ContainerName' because -ForceRecreate was specified."
    docker rm -f $ContainerName | Out-Null
    $existingContainer = ""
}
# end if

if (-not $existingContainer)
{
    Write-Host "Creating container '$ContainerName' on port $HostPort..."
    docker run --name $ContainerName `
        -e "POSTGRES_USER=$PostgresUser" `
        -e "POSTGRES_PASSWORD=$plainPassword" `
        -d -p "${HostPort}:5432" $Image | Out-Null
}
else
{
    $isRunning = docker inspect -f "{{.State.Running}}" $ContainerName
    if ($isRunning -ne "true")
    {
        Write-Host "Starting existing container '$ContainerName'..."
        docker start $ContainerName | Out-Null
    }
    # end if
}
# end else

Wait-PostgresReady -Container $ContainerName -User $PostgresUser -Database "postgres"

Write-Host "Ensuring database '$DatabaseName' exists..."
$dbExistsOutput = docker exec $ContainerName psql -U $PostgresUser -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$DatabaseName';"
$dbExists = "$dbExistsOutput".Trim()
if ($dbExists -ne "1")
{
    docker exec $ContainerName createdb -U $PostgresUser $DatabaseName | Out-Null
}
# end if

Wait-PostgresReady -Container $ContainerName -User $PostgresUser -Database $DatabaseName

Write-Host "Reviewing CSV structure and generating table schema from headers..."
$csvHeaderLine = Get-Content -Path $resolvedCsvPath -TotalCount 1
if ([string]::IsNullOrWhiteSpace($csvHeaderLine))
{
    throw "CSV file appears empty: $resolvedCsvPath"
}
# end if

$rawHeaders = $csvHeaderLine.Split(',')
if ($rawHeaders.Count -eq 0)
{
    throw "No headers found in CSV file: $resolvedCsvPath"
}
# end if

$columns = @()
foreach ($header in $rawHeaders)
{
    $cleanHeader = $header.Trim().Trim('"')
    $columns += (ConvertTo-SqlIdentifier -Value $cleanHeader)
}
# end foreach

$tableIdentifier = ConvertTo-SqlIdentifier -Value $TableName
$columnDefinitions = ($columns | ForEach-Object { "`"$_`" TEXT" }) -join ", "
$quotedColumnList = ($columns | ForEach-Object { "`"$_`"" }) -join ", "

$createTableSql = "CREATE TABLE IF NOT EXISTS `"$tableIdentifier`" ($columnDefinitions);"
$truncateTableSql = "TRUNCATE TABLE `"$tableIdentifier`";"
$copySql = "COPY `"$tableIdentifier`" ($quotedColumnList) FROM '/tmp/input.csv' WITH (FORMAT csv, HEADER true);"

Write-Host "Creating table '$tableIdentifier'..."
docker exec $ContainerName psql -U $PostgresUser -d $DatabaseName -v ON_ERROR_STOP=1 -c $createTableSql | Out-Null

$csvDataRowCount = (Get-Content -Path $resolvedCsvPath | Select-Object -Skip 1 | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count
$tableRowCountOutput = docker exec $ContainerName psql -U $PostgresUser -d $DatabaseName -tAc "SELECT COUNT(*) FROM `"$tableIdentifier`";"
$tableRowCountText = "$tableRowCountOutput".Trim()
$tableRowCount = 0
if (-not [int]::TryParse($tableRowCountText, [ref]$tableRowCount))
{
    throw "Unable to parse table row count value '$tableRowCountText' for table '$tableIdentifier'."
}
# end if

if ($tableRowCount -eq $csvDataRowCount)
{
    Write-Host "Idempotency check passed: table '$tableIdentifier' already has $tableRowCount rows (matches CSV). Skipping import."
}
else
{
    Write-Host "Idempotency check mismatch: table has $tableRowCount rows, CSV has $csvDataRowCount rows."
    Write-Host "Clearing table '$tableIdentifier' for deterministic re-import..."
    docker exec $ContainerName psql -U $PostgresUser -d $DatabaseName -v ON_ERROR_STOP=1 -c $truncateTableSql | Out-Null

    Write-Host "Copying CSV file into container..."
    docker cp $resolvedCsvPath "${ContainerName}:/tmp/input.csv"

    Write-Host "Importing CSV data into '$tableIdentifier'..."
    docker exec $ContainerName psql -U $PostgresUser -d $DatabaseName -v ON_ERROR_STOP=1 -c $copySql | Out-Null
}
# end if

Write-Host "Verifying imported row count..."
docker exec $ContainerName psql -U $PostgresUser -d $DatabaseName -c "SELECT COUNT(*) AS imported_rows FROM `"$tableIdentifier`";"

Write-Host "Completed successfully."
