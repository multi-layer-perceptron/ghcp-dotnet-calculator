# Product Requirements Document: Azure SQL CRUD Operations Examples

\n\nDocument Information

**Version:** 1.0

**Author:** GitHub Copilot Assistant

**Date:** November 6, 2025

**Status:** Draft

\n\n1. Executive Summary

This document defines a comprehensive set of examples and demonstrations for Azure SQL CRUD (Create, Read, Update, Delete) operations using GitHub Copilot. The demonstrations showcase how GitHub Copilot assists developers in writing T-SQL queries efficiently and safely for the `demos` table in an Azure SQL database hosted on `<redacted>.database.windows.net`.

The examples are designed to teach best practices for database operations, demonstrate GitHub Copilot's contextual awareness, and provide a hands-on learning experience for workshop participants and developers.

\n\n2. Problem Statement

Developers working with Azure SQL databases need:

\n\nA reliable way to perform CRUD operations safely and efficiently
\n\nExamples that demonstrate best practices for T-SQL query writing
\n\nGuidance on using GitHub Copilot to accelerate database development
\n\nA reference implementation for common database operations

Manual SQL query writing is time-consuming and error-prone. GitHub Copilot can significantly accelerate this process while promoting best practices.

\n\n3. Goals and Objectives

\n\nProvide comprehensive examples of CRUD operations for Azure SQL databases
\n\nDemonstrate GitHub Copilot's capabilities in T-SQL query generation
\n\nShowcase safety practices and error prevention techniques
\n\nEnable developers to quickly learn and apply database operation patterns
\n\nCreate a reusable template for Azure SQL demonstrations

\n\n4. Scope

\n\n4.1 In Scope

\n\nCRUD operations (Create, Read, Update, Delete) for the `demos` table
\n\nConnection string configuration and authentication
\n\nSafety practices including verification steps and transaction handling
\n\nGitHub Copilot prompt engineering for SQL generation
\n\nQuery optimization and performance considerations
\n\nError handling and validation
\n\nSchema discovery and documentation

\n\n4.2 Out of Scope

\n\nComplex stored procedures and functions
\n\nDatabase schema design and normalization
\n\nPerformance tuning and indexing strategies
\n\nAdvanced security configurations beyond connection string
\n\nMigration strategies or ETL processes
\n\nMulti-database operations or distributed transactions

\n\n5. Connection Details

\n\n5.1 Database Connection Information

## Connection String

`\`sql

text

Server=tcp:<redacted>.database.windows.net,1433;Initial Catalog=demos;Persist Security Info=False;User ID=<redacted>;Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;

`\`sql

text
text

## Connection Parameters

\n\n**Server:** svr-ghc-01.database.windows.net
\n\n**Port:** 1433 (default)
\n\n**Database:** demos
\n\n**Username:** sqladmin
\n\n**Password:** {To be prompted from user}
\n\n**Authentication:** SQL Authentication
\n\n**Encryption:** True
\n\n**Trust Server Certificate:** False
\n\n**Connection Timeout:** 30 seconds
\n\n**Multiple Active Result Sets:** False

\n\n5.2 Target Table

**Table Name:** `demos`

**Schema:** `dbo` (default)

\n\n6. User Stories / Use Cases

\n\n6.1 As a Developer

\n\nI want to connect to the Azure SQL database using sqlcmd so that I can execute T-SQL queries
\n\nI want to view all records in the demos table so that I understand the data structure
\n\nI want to insert new demo records efficiently using GitHub Copilot assistance
\n\nI want to update existing records with validation to prevent data corruption
\n\nI want to delete records safely with verification steps to avoid accidental data loss

\n\n6.2 As a Workshop Instructor

\n\nI want to demonstrate GitHub Copilot's SQL generation capabilities to attendees
\n\nI want to showcase best practices for database operations in a real-world scenario
\n\nI want to provide reusable examples that attendees can reference later
\n\nI want to emphasize safety and error prevention in database operations

\n\n6.3 As a Database Administrator

\n\nI want to ensure all operations follow security best practices
\n\nI want to verify that queries are optimized and won't impact database performance
\n\nI want to maintain audit trails for data modifications

\n\n7. Functional Requirements

| Requirement ID | Description | Priority |

| -------------- | --------------------------------------------------------------------------------------------- | -------- |

| FR-1 | System shall support connecting to Azure SQL using sqlcmd with the provided connection string | High |

| FR-2 | System shall provide examples for SELECT queries with filtering, sorting, and pagination | High |

| FR-3 | System shall demonstrate INSERT operations with automatic ID generation | High |

| FR-4 | System shall demonstrate UPDATE operations with WHERE clause validation | High |

| FR-5 | System shall demonstrate DELETE operations with verification steps | High |

| FR-6 | System shall include schema discovery queries to document table structure | Medium |

| FR-7 | System shall provide transaction-wrapped examples for critical operations | Medium |

| FR-8 | System shall include error handling patterns for each operation type | Medium |

| FR-9 | System shall demonstrate GitHub Copilot prompt patterns for SQL generation | High |

| FR-10 | System shall export query results to CSV for documentation purposes | Low |

\n\n8. Non-Functional Requirements

\n\n8.1 Security

\n\nAll examples must use parameterized queries where applicable
\n\nConnection strings must not contain hardcoded passwords
\n\nSensitive data must not be exposed in query outputs
\n\nAll operations must respect database permissions and roles

\n\n8.2 Performance

\n\nQueries should be optimized with appropriate WHERE clauses
\n\nBulk operations should use efficient batch processing
\n\nConnection timeouts should be appropriately configured
\n\nQuery execution time should be monitored and logged

\n\n8.3 Usability

\n\nExamples must be clearly documented with comments
\n\nEach operation must include usage instructions
\n\nError messages must be informative and actionable
\n\nCode must be formatted consistently following T-SQL best practices

\n\n8.4 Maintainability

\n\nExamples should be modular and reusable
\n\nCode should follow naming conventions
\n\nDocumentation should be inline and comprehensive
\n\nVersion control should track all changes

\n\n9. Demonstration Sequence

\n\n9.1 Pre-requisites Setup (5 minutes)

\n\nVerify sqlcmd installation and version
\n\nPrompt user for database password
\n\nTest database connectivity
\n\nVerify table existence and schema

\n\n9.2 Schema Discovery (5 minutes)

**Objective:** Understand the `demos` table structure

## Operations

\n\nQuery system tables to get column definitions
\n\nExport schema to CSV for reference
\n\nDocument primary keys, data types, and constraints
\n\nAdd schema file to context for subsequent operations

## GitHub Copilot Prompt

`\`sql

sql

-- Generate a query to retrieve the complete schema for the demos table including column names, data types, nullable status, and constraints

-- Save results to table_schema.csv

`\`sql

text
text

\n\n9.3 READ Operations (10 minutes)

**Objective:** Demonstrate various SELECT query patterns

\n\nExample 1: Basic SELECT

## GitHub Copilot Prompt

`\`sql

sql

-- Show all records from the demos table

`\`sql

text
text

\n\nExample 2: Filtered SELECT

## GitHub Copilot Prompt

`\`sql

sql

-- Find all demos where category is 'programming' and confidence_percent is greater than 70

`\`sql

text
text

\n\nExample 3: Sorted and Limited Results

## GitHub Copilot Prompt

`\`sql

sql

-- Show top 10 demos ordered by confidence_percent descending

`\`sql

text
text

\n\nExample 4: Pattern Matching

## GitHub Copilot Prompt

`\`sql

sql

-- Find all demos where scenario contains 'GitHub Copilot' (case-insensitive)

`\`sql

text
text

\n\nExample 5: Aggregation

## GitHub Copilot Prompt

`\`sql

sql

-- Show the average confidence_percent grouped by category

`\`sql

text
text

\n\n9.4 CREATE Operations (10 minutes)

**Objective:** Demonstrate INSERT operations with various patterns

\n\nExample 1: Single Record Insert with Auto-Increment ID

## GitHub Copilot Prompt

`\`sql

sql

-- Insert a new demo record for a Python data science workshop

-- Calculate the next available ID automatically

-- Set category='programming', language='python', scenario='Data Science with Pandas', confidence_percent=85

`\`sql

text
text

\n\nExample 2: Insert and Return Inserted Record

## GitHub Copilot Prompt

`\`sql

sql

-- Insert a new C# demo and immediately return the inserted record with its generated ID

`\`sql

text
text

\n\nExample 3: Bulk Insert

## GitHub Copilot Prompt

`\`sql

sql

-- Insert multiple demo records in a single statement for JavaScript, TypeScript, and Go workshops

`\`sql

text
text

\n\nExample 4: Insert with Transaction

## GitHub Copilot Prompt

`\`sql

sql

-- Insert a new demo within a transaction with error handling and rollback capability

`\`sql

text
text

\n\n9.5 UPDATE Operations (10 minutes)

**Objective:** Demonstrate safe UPDATE patterns with verification

\n\nExample 1: Single Record Update

## GitHub Copilot Prompt

`\`sql

sql

-- Update the confidence_percent to 90 for demo with ID 5

-- Include a verification SELECT before and after the update

`\`sql

text
text

\n\nExample 2: Multi-Column Update

## GitHub Copilot Prompt

`\`sql

sql

-- Update demo ID 5 to set confidence_percent=75, notes='Updated after workshop feedback', points=45

`\`sql

text
text

\n\nExample 3: Conditional Bulk Update

## GitHub Copilot Prompt

`\`sql

sql

-- Increase confidence_percent by 10 for all demos where category='databases' and confidence_percent < 80

`\`sql

text
text

\n\nExample 4: Update with Calculation

## GitHub Copilot Prompt

`\`sql

sql

-- For all demos with confidence_percent below 60, increase it by 15% of its current value

`\`sql

text
text

\n\n9.6 DELETE Operations (10 minutes)

**Objective:** Demonstrate safe DELETE patterns with verification

\n\nExample 1: Safe Single Record Delete

## GitHub Copilot Prompt

`\`sql

sql

-- Delete demo with ID 5 but first show what will be deleted for verification

`\`sql

text
text

\n\nExample 2: Conditional Delete with Backup

## GitHub Copilot Prompt

`\`sql

sql

-- Before deleting demos with confidence_percent < 30, save their IDs to a temporary table for audit

`\`sql

text
text

\n\nExample 3: Soft Delete Pattern

## GitHub Copilot Prompt

`\`sql

sql

-- Instead of hard deleting, show how to add an 'is_deleted' flag and update it rather than removing the record

`\`sql

text
text

\n\nExample 4: Delete with Transaction

## GitHub Copilot Prompt

`\`sql

sql

-- Delete all demos where language='obsolete' within a transaction with rollback capability

`\`sql

text
text

\n\n10. GitHub Copilot Best Practices

\n\n10.1 Effective Prompt Patterns

\n\nPattern 1: Descriptive Comments

`\`sql

sql

-- [Action] [Target] [Conditions] [Additional Requirements]

-- Example: Find all Python demos with confidence above 80% sorted by scenario name

`\`sql

text
text

\n\nPattern 2: Contextual References

`\`sql

sql

-- In the demos table, show me...

-- For the demos database, create a query that...

`\`sql

text
text

\n\nPattern 3: Incremental Complexity

\n\nStart simple: "Show all demos"
\n\nAdd filters: "Show all Python demos"
\n\nAdd sorting: "Show all Python demos sorted by confidence"
\n\nAdd limits: "Show top 5 Python demos sorted by confidence descending"

\n\nPattern 4: Safety-First Language

`\`sql

sql

-- Safely delete... (verify first)

-- Update with verification...

-- Show what would be affected before...

`\`sql

text
text

\n\n10.2 Common Prompting Mistakes to Avoid

\n\n❌ Vague: "Get data from table"
\n\n✅ Specific: "Select all columns from demos table where category='programming'"
\n\n❌ No context: "Delete records"
\n\n✅ With context: "Delete records from demos table where confidence_percent < 20 after verifying count"
\n\n❌ No safety: "Update all records"
\n\n✅ Safety-first: "Show which records would be affected, then update demos with confidence < 50"

\n\n11. Success Criteria / KPIs

\n\n11.1 Technical Success Metrics

\n\nAll CRUD operations execute successfully without errors
\n\nQueries return expected results matching test cases
\n\nNo accidental data loss or corruption occurs
\n\nConnection handles are properly managed and closed
\n\nExecution times are within acceptable ranges (< 5 seconds per query)

\n\n11.2 Learning Outcome Metrics

\n\nParticipants can independently write basic SELECT queries with Copilot assistance
\n\nParticipants understand the importance of WHERE clauses in UPDATE and DELETE operations
\n\nParticipants can craft effective GitHub Copilot prompts for SQL generation
\n\nParticipants demonstrate awareness of SQL injection prevention
\n\nParticipants can troubleshoot common SQL errors with Copilot assistance

\n\n11.3 Quality Metrics

\n\nAll generated SQL follows T-SQL best practices
\n\nCode includes appropriate comments and documentation
\n\nError handling is implemented for critical operations
\n\nTransactions are used where data integrity is critical
\n\nAll examples are reusable and modular

\n\n12. Assumptions and Dependencies

\n\n12.1 Assumptions

\n\nUser has access to the Azure SQL database with appropriate permissions
\n\nsqlcmd utility is installed and configured on the user's machine
\n\nUser has basic familiarity with SQL syntax and database concepts
\n\nGitHub Copilot extension is installed and activated
\n\nNetwork connectivity to Azure is stable and reliable

\n\n12.2 Dependencies

\n\n**sqlcmd:** Modern Go-based version or legacy sqlcmd.exe
\n\n**Azure SQL Database:** Active and accessible at svr-ghc-01.database.windows.net
\n\n**GitHub Copilot:** Active subscription and VS Code extension
\n\n**PowerShell:** For scripting connection and automation tasks
\n\n**CSV Export Capability:** For saving schema and query results

\n\n13. Milestones & Timeline

| Milestone | Description | Duration | Status |

| --------- | ----------------------------- | -------- | ----------- |

| M1 | PRD Creation and Review | 1 day | In Progress |

| M2 | Connection Setup and Testing | 0.5 days | Pending |

| M3 | Schema Discovery Examples | 0.5 days | Pending |

| M4 | READ Operation Examples | 1 day | Pending |

| M5 | CREATE Operation Examples | 1 day | Pending |

| M6 | UPDATE Operation Examples | 1 day | Pending |

| M7 | DELETE Operation Examples | 1 day | Pending |

| M8 | Documentation and Comments | 1 day | Pending |

| M9 | Testing and Validation | 1 day | Pending |

| M10 | Workshop Delivery Preparation | 0.5 days | Pending |

**Total Estimated Duration:** 8.5 days

\n\n14. Example Usage Instructions

\n\n14.1 Initial Setup

\n\nStep 1: Set Password Variable (PowerShell)

`\`sql

powershell

$password = Read-Host "Enter database password" -AsSecureString

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)

$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

`\`sql

text
text

\n\nStep 2: Test Connection

`\`sql

powershell

sqlcmd -S tcp:svr-ghc-01.database.windows.net,1433 -d demos -U sqladmin -P $plainPassword -Q "SELECT @@VERSION"

`\`sql

text
text

\n\nStep 3: Run Examples from SQL File

`\`sql

powershell
\n\nExecute the examples SQL file

sqlcmd -S tcp:svr-ghc-01.database.windows.net,1433 -d demos -U sqladmin -P $plainPassword -i "dmo-azure-sql-data-lifecycle.sql" -o "results.txt"

`\`sql

text
text

\n\n14.2 Interactive sqlcmd Session

`\`sql

powershell
\n\nStart interactive session

sqlcmd -S tcp:svr-ghc-01.database.windows.net,1433 -d demos -U sqladmin -P $plainPassword

\n\nInside sqlcmd, run queries interactively
\n\nType GO after each query to execute
\n\nType EXIT to quit

`\`sql

text
text

\n\n15. Security Considerations

\n\n15.1 Password Management

\n\n**Never hardcode passwords** in scripts or connection strings
\n\nUse secure credential storage (Azure Key Vault, environment variables)
\n\nPrompt for passwords at runtime using secure input methods
\n\nClear password variables after use

\n\n15.2 Connection Security

\n\nAlways use encrypted connections (Encrypt=True)
\n\nVerify server certificates when possible (TrustServerCertificate=False)
\n\nUse appropriate connection timeouts
\n\nImplement retry logic for transient failures

\n\n15.3 Query Security

\n\nAlways use parameterized queries when accepting user input
\n\nValidate and sanitize all input data
\n\nFollow principle of least privilege for database user permissions
\n\nImplement audit logging for sensitive operations

\n\n15.4 Data Protection

\n\nMask sensitive data in query outputs and logs
\n\nImplement row-level security where appropriate
\n\nUse database encryption for data at rest
\n\nRegularly review and rotate credentials

\n\n16. Troubleshooting Guide

\n\n16.1 Connection Issues

**Problem:** "Cannot connect to server"

## Solutions

\n\nVerify firewall rules allow your IP address
\n\nCheck connection string format
\n\nVerify server name and port
\n\nTest network connectivity with `Test-NetConnection`

**Problem:** "Login failed for user 'sqladmin'"

## Solutions

\n\nVerify password is correct
\n\nCheck if account is locked or disabled
\n\nVerify SQL authentication is enabled on the server
\n\nConfirm user has appropriate permissions

\n\n16.2 Query Execution Issues

**Problem:** "Invalid object name 'demos'"

## Solutions

\n\nVerify you're connected to the correct database
\n\nCheck table name spelling and schema (use `dbo.demos`)
\n\nConfirm table exists with `SELECT * FROM INFORMATION_SCHEMA.TABLES`

**Problem:** "Transaction deadlock"

## Solutions

\n\nImplement retry logic with exponential backoff
\n\nOptimize query order to reduce lock contention
\n\nKeep transactions short and focused
\n\nReview isolation levels

\n\n17. Key Takeaways

\n\n**GitHub Copilot accelerates SQL development** by generating accurate queries from natural language prompts
\n\n**Safety-first approach** is critical for UPDATE and DELETE operations
\n\n**Descriptive prompts** yield better Copilot suggestions
\n\n**Verification steps** should always precede destructive operations
\n\n**Transaction handling** ensures data integrity for critical operations
\n\n**Schema documentation** improves context for subsequent operations
\n\n**Incremental complexity** helps build understanding and confidence
\n\n**Error handling** should be built into all production code

\n\n18. Questions for Review

\n\nAre all CRUD operation examples comprehensive and clear?
\n\nDo the GitHub Copilot prompts effectively demonstrate best practices?
\n\nIs the security guidance sufficient for production scenarios?
\n\nShould additional operation types be included (e.g., MERGE, stored procedures)?
\n\nAre the success criteria measurable and achievable?
\n\nIs the documentation clear enough for self-service learning?

\n\n19. Call to Action

\n\n19.1 For Developers

\n\nReview the examples and adapt them to your specific scenarios
\n\nPractice writing effective GitHub Copilot prompts
\n\nImplement safety practices in all database operations
\n\nShare feedback and suggestions for improvement

\n\n19.2 For Instructors

\n\nUse this PRD as a workshop guide
\n\nCustomize examples based on audience skill level
\n\nCollect feedback from participants
\n\nContribute additional examples and patterns

\n\n19.3 For Contributors

\n\nSubmit pull requests with additional examples
\n\nReport issues or inaccuracies
\n\nSuggest improvements to documentation
\n\nShare success stories and use cases

\n\n20. Appendix

\n\n20.1 Reference Links

\n\n[Microsoft T-SQL Reference](https://docs.microsoft.com/en-us/sql/t-sql/)
\n\n[Azure SQL Database Documentation](https://docs.microsoft.com/en-us/azure/sql-database/)
\n\n[sqlcmd Utility Documentation](https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility)
\n\n[GitHub Copilot Documentation](https://docs.github.com/en/copilot)

\n\n20.2 Related Documents

\n\n[`prd-azure-sql-data-lifecycle.md`](../prd-azure-sql-data-lifecycle.md) - Original PRD reference
\n\n[`dmo-azure-sql-data-lifecycle.sql`](dmo-azure-sql-data-lifecycle.sql) - SQL implementation file
\n\n[`.github/copilot-instructions.md`](../../../../.github/copilot-instructions.md) - Repository coding standards

\n\n20.3 Glossary

\n\n**CRUD:** Create, Read, Update, Delete - basic database operations
\n\n**T-SQL:** Transact-SQL - Microsoft's SQL dialect for SQL Server and Azure SQL
\n\n**sqlcmd:** Command-line utility for executing SQL queries
\n\n**GitHub Copilot:** AI-powered code completion tool
\n\n**PRD:** Product Requirements Document
\n\n**DML:** Data Manipulation Language (SELECT, INSERT, UPDATE, DELETE)
\n\n**DDL:** Data Definition Language (CREATE, ALTER, DROP)

---

\n
