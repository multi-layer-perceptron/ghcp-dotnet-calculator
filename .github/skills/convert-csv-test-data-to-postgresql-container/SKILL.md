---
name: convert-csv-test-data-to-postgresql-container
description: Convert CSV test data to PostgreSQL database container
license: MIT
disable-model-invocation: true
user-invokable: true
compatibility: 
  - powershell-7
  - docker
---

# Convert CSV Test Data to PostgreSQL Container

Create a PostgreSQL database container and import CSV test data into it. This skill will help you set up a local PostgreSQL instance for testing and development purposes.

## Automated Option (Recommended)

Use the script in `.\scripts\Convert-CsvToPostgreSQL.ps1` to automate container setup and CSV import.

### Script Location
- `.\scripts\Convert-CsvToPostgreSQL.ps1`

### Prerequisites
- PowerShell 7+
- Docker Desktop running
- CSV test data file available: "(Join-Path -Path "$(git --rev-parse --show-toplevel)\programming\dotnet\csharp\workspace\calculator-xunit-testing\calculator.tests\TestData\CalculatorTestData.csv")

### Example Usage

```pwsh
pwsh .\scripts\Convert-CsvToPostgreSQL.ps1
```

If `-PostgresPassword` is not provided, the script securely prompts for it.

### Script Parameters
- `-CsvPath`: Path to the CSV file: "$(git --rev-parse --show-toplevel)\programming\dotnet\csharp\workspace\calculator-xunit-testing\calculator.tests\TestData\CalculatorTestData.csv"
- `-ContainerName`: PostgreSQL container name (default: `test-container`).
- `-DatabaseName`: Target database name (default: `test_db`).
- `-TableName`: Target table name for import (default: `test_data`).
- `-PostgresUser`: PostgreSQL user name (default: `postgres_user`).
- `-PostgresPassword`: Secure password value; if omitted, script prompts securely.
- `-HostPort`: Host port mapped to container port `5432` (default: `5432`).
- `-Image`: PostgreSQL Docker image tag (default: `postgres:latest`).
- `-ForceRecreate`: Recreates an existing container with the same name.

### What the Script Does
1. Validates Docker availability and CSV file path.
2. Creates or starts the PostgreSQL container.
3. Waits for PostgreSQL readiness.
4. Creates a table from CSV headers (as `TEXT` columns).
5. Performs an idempotency check by comparing CSV row count and current table row count.
6. If counts match, skips import and reports data is already seeded.
7. If counts differ, truncates the target table and re-imports rows using `COPY`.
8. Prints imported row count for verification.

### Idempotent Re-runs
- Re-running the script does not create duplicate rows.
- Matching row counts skip import.
- Mismatched row counts trigger deterministic reset (`TRUNCATE`) and clean re-import.

### Troubleshooting
- **Port already in use (`5432`)**: use `-HostPort 5433`.
- **Container exists with old settings**: rerun with `-ForceRecreate`.
- **Docker not running**: start Docker Desktop and run the script again.
- **Invalid CSV headers**: ensure headers are present and not empty.

### Quick Verification Command

```pwsh
docker exec -it test-container psql -U postgres_user -d test_db -c "SELECT COUNT(*) FROM test_data;"
```