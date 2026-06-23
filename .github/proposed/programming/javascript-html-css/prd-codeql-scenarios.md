# Product Requirements Document (PRD): CodeQL Custom Query Scenarios for GHAS Workshop

## Document Information

- **Version:** 1.0

- **Author(s):** GitHub Copilot

- **Date:** August 1, 2025

- **Status:** Workshop Ready

- **Target Audience:** GHAS (GitHub Advanced Security) Workshop Participants

## Executive Summary

This document defines custom CodeQL query scenarios and implementation approaches for a GitHub Advanced Security workshop. The scenarios demonstrate how to extend CodeQL's security analysis capabilities beyond standard queries, enabling participants to create targeted security checks for specific application contexts and organizational requirements.

## Problem Statement

While CodeQL provides comprehensive out-of-the-box security analysis with 200+ standard queries, organizations often need:

- Custom security rules specific to their codebase patterns

- Domain-specific vulnerability detection

- Integration of internal security policies into automated scanning

- Educational examples for security team training

## Goals and Objectives

- Demonstrate multiple approaches for implementing custom CodeQL queries

- Provide practical examples relevant to JavaScript/web application security

- Enable workshop participants to create and deploy custom security rules

- Show integration methods with existing CI/CD pipelines

- Establish best practices for custom query development and maintenance

## Scope

### In Scope

- Custom CodeQL query development approaches (3 primary methods)

- JavaScript-focused security query examples

- PowerShell script integration techniques

- Workshop demonstration scenarios using calculator application

- SARIF result integration and reporting

### Out of Scope

- Advanced CodeQL language features beyond workshop scope

- Multi-language query development

- Enterprise-scale query management systems

- Custom IDE integrations

## Implementation Approaches

### Approach 1: Direct Custom Query Files (Simple Workshop Integration)

**Use Case:** Single custom security query for specific vulnerability detection

## Implementation Steps

1. **Create Custom Query File** (`custom-security.ql`)

`\`bash

ql
/**
 * @name Potential XSS vulnerability
 * @description Finds direct DOM manipulation that could lead to XSS
 * @kind problem
 * @problem.severity warning
 * @security-severity 6.0
 * @precision medium
 * @id js/custom-xss-check
 * @tags security
 *       external/cwe/cwe-79
 */

import javascript
private import semmle.javascript.security.dataflow.DomBasedXssQuery

from Assignment assign, PropAccess prop
where prop.getPropertyName() = "innerHTML"
  and assign.getLhs() = prop
  and exists(assign.getRhs())
select assign, "Potential XSS: innerHTML assignment detected."

`\`bash

text
text

1. **PowerShell Script Integration (Enhanced v2.0)**

`\`bash

powershell

## NEW: Enhanced parameter support with three query approaches

.\codeql-javascript.ps1 -useCustomQL -customQueryPath ".\custom-queries\custom-security.ql"

`\`bash

text
text

## Workshop Advantages

- Quick implementation for targeted security checks

- Perfect for demonstrating specific vulnerability patterns

- Easy to understand and modify during live workshops

### Approach 2: Comprehensive Custom Query Suites (.qls files)

**Use Case:** Enterprise-scale organization combining standard and custom queries

## Implementation Steps

1. **Create Comprehensive Suite File** (`workshop-security-suite.qls`)

`\`bash

yaml

## workshop-security-suite.qls

## GHAS Workshop Security Suite (Comprehensive Version)

## Custom query suite that combines standard security queries with all custom queries

- description: "GHAS Workshop Security Suite - All queries"

## Include all custom queries from the current directory

- include:

```bash
queries: .
`\`bash

## Include comprehensive JavaScript security queries from the standard pack

- from: codeql/javascript-queries
  queries: codeql-suites/javascript-security-and-quality.qls

## Include additional security-focused queries

- from: codeql/javascript-queries
  queries: Security/

## Exclude noisy or non-security queries for workshop focus

- exclude:

```bash
id: js/unused-local-variable
`\`bash

- exclude:

```bash
id: js/useless-assignment-to-local
`\`bash

`\`bash

text
text

1. **Enhanced PowerShell Script Integration**

`\`bash

powershell

## NEW: Enhanced comprehensive query suite approach

.\codeql-javascript.ps1 -useCustomQLS -customQuerySuitePath ".\custom-queries\workshop-security-suite.qls"

`\`bash

text
text

## Workshop Advantages

- Demonstrates enterprise-scale query organization

- Shows comprehensive security coverage

- Combines standard and custom queries effectively

- Includes query filtering and exclusion capabilities

### Approach 3: Selective Pattern-Based Query Suites (NEW)

**Use Case:** Targeted analysis using pattern-matched custom queries for focused workshops

## Implementation Steps

1. **Create Selective Suite File** (`workshop-selected-query-suites.qls`)

`\`bash

yaml

## workshop-selected-query-suites.qls

## GHAS Workshop Security Suite (Selective Queries Version)

## Custom query suite that runs only selected custom queries with standard security patterns

- description: "GHAS Workshop Security Suite - Selected queries only"

## Include only selected custom queries using pattern matching

- include:

```bash
queries:
  - "*security*.ql"
  - "*console*.ql"
  - "*eval*.ql"
`\`bash

## Include key security queries from the JavaScript query pack using directory patterns

- from: codeql/javascript-queries
  queries: Security/CWE-079/

- from: codeql/javascript-queries
  queries: Security/CWE-089/

- from: codeql/javascript-queries
  queries: Security/CWE-094/

- from: codeql/javascript-queries
  queries: Expressions/

- from: codeql/javascript-queries
  queries: Declarations/

`\`bash

text
text

1. **NEW: Selective Query Suite Integration**

`\`bash

powershell

## NEW: Pattern-based selective query approach

.\codeql-javascript.ps1 -useSelectiveQLS -selectiveQuerySuitePath ".\custom-queries\workshop-selected-query-suites.qls"

`\`bash

text
text

## Workshop Advantages

- Perfect for focused security training sessions

- Demonstrates advanced query filtering with wildcards

- Reduces noise while maintaining security focus

- Shows enterprise pattern-matching capabilities

### Approach 4: Enhanced Parameterized Integration (Updated)

**Use Case:** Flexible script allowing workshop participants to experiment with all query approaches

## Implementation

`\`bash

powershell
param(

```bash
[string]$sourcePath = "..\workspace\calculator",
[string]$customQueryPath = ".\custom-queries\custom-security.ql",
[string]$customQuerySuitePath = ".\custom-queries\workshop-security-suite.qls",
[string]$selectiveQuerySuitePath = ".\custom-queries\workshop-selected-query-suites.qls", # NEW
[switch]$useCustomQL,     # Single query approach
[switch]$useCustomQLS,    # Comprehensive suite approach
[switch]$useSelectiveQLS, # NEW: Selective pattern-based approach
[switch]$uploadToGitHub,
[switch]$autoDetectRepo,
[switch]$injectReDoSVulnerability,
[switch]$forceNewAlerts
`\`bash

)

## NEW: Enhanced validation for three query approaches

$queryOptionsCount = @($useCustomQL, $useCustomQLS, $useSelectiveQLS) | Where-Object { $_ } | Measure-Object | Select-Object -ExpandProperty Count
if ($queryOptionsCount -gt 1) {

```bash
Write-Error "Cannot use multiple query options together. Choose one: -useCustomQL, -useCustomQLS, or -useSelectiveQLS."
exit 1
`\`bash

}

## NEW: Enhanced analysis logic with three approaches

if ($useCustomQL) {

```bash
Write-Host "🔍 Using single custom query: $customQueryPath" -ForegroundColor Cyan
# Single query analysis logic
`\`bash

} elseif ($useCustomQLS) {

```bash
Write-Host "📋 Using comprehensive query suite: $customQuerySuitePath" -ForegroundColor Cyan
# Comprehensive suite analysis logic
`\`bash

} elseif ($useSelectiveQLS) {

```bash
Write-Host "🎯 Using selective query suite: $selectiveQuerySuitePath" -ForegroundColor Cyan
# NEW: Selective pattern-based analysis logic
`\`bash

} else {

```bash
Write-Host "🔧 Using standard query suite" -ForegroundColor Cyan
# Standard analysis fallback
`\`bash

}

`\`bash

text
text

## Enhanced Workshop Usage Examples

`\`bash

powershell

## Scenario 1: Single targeted query (Basic)

.\codeql-javascript.ps1 -useCustomQL

## Scenario 2: Comprehensive security analysis (Enterprise)

.\codeql-javascript.ps1 -useCustomQLS

## Scenario 3: Selective pattern-based analysis (NEW - Advanced)

.\codeql-javascript.ps1 -useSelectiveQLS

## Scenario 4: Vulnerability injection with selective queries (NEW)

.\codeql-javascript.ps1 -useSelectiveQLS -injectReDoSVulnerability -uploadToGitHub -autoDetectRepo

## Scenario 5: Force new alerts with comprehensive suite

.\codeql-javascript.ps1 -useCustomQLS -injectReDoSVulnerability -forceNewAlerts -uploadToGitHub

`\`bash

text
text

## Workshop Demonstration Scenarios

### Scenario 1: Detecting Unsafe `eval()` Usage

**Security Context:** The calculator application uses `eval()` for mathematical expression evaluation, which is a common XSS vector.

**Custom Query** (`unsafe-eval-detection.ql`):

`\`bash

ql
/**
 * @name Unsafe eval() usage in calculator
 * @description Detects eval() calls that could lead to code injection
 * @kind problem
 * @problem.severity error
 * @security-severity 9.0
 * @precision high
 * @id js/workshop-unsafe-eval
 * @tags security
 *       external/cwe/cwe-94
 */

import javascript

from CallExpr call
where call.getCallee().(GlobalVarAccess).getName() = "eval"
  and call.getParent*() instanceof Function
select call, "Unsafe eval() usage detected. Consider using safer alternatives like Function constructor with validation."

`\`bash

text
text

**Expected Finding:** Will detect the `eval(display.innerText)` in `calculateResult()` function

## Workshop Discussion Points

- Why `eval()` is dangerous

- Alternative approaches (math expression parsers)

- Input validation strategies

### Scenario 2: Hardcoded Credentials Detection

**Custom Query** (`hardcoded-credentials.ql`):

`\`bash

ql
/**
 * @name Hardcoded API keys and secrets
 * @description Finds potential hardcoded credentials in JavaScript
 * @kind problem
 * @problem.severity error
 * @security-severity 8.0
 * @precision medium
 * @id js/workshop-hardcoded-secrets
 * @tags security
 *       external/cwe/cwe-798
 */

import javascript

from StringLiteral s
where s.getValue().regexpMatch("(?i).*(api[_-]?key|token|secret|password|auth[_-]?key).*")
  and s.getValue().length() > 8
  and not s.getParent*() instanceof Comment
select s, "Potential hardcoded credential: " + s.getValue()

`\`bash

text
text

**Workshop Exercise:** Add intentional hardcoded values to calculator for detection

### Scenario 3: Console Statements in Production

**Custom Query** (`console-log-detection.ql`):

`\`bash

ql
/**
 * @name Console statements in production code
 * @description Finds console.log statements that should be removed for production
 * @kind problem
 * @problem.severity note
 * @precision high
 * @id js/workshop-console-statements
 * @tags maintainability
 *       best-practice
 */

import javascript

from CallExpr call
where call.getCallee().(PropAccess).getPropertyName() = "log"
  and call.getCallee().(PropAccess).getBase().(GlobalVarAccess).getName() = "console"
select call, "Console.log statement found - consider removing for production deployment."

`\`bash

text
text

### Scenario 4: DOM Manipulation Security

**Custom Query** (`dom-security-check.ql`):

`\`bash

ql
/**
 * @name Unsafe DOM manipulation
 * @description Detects potentially unsafe DOM content assignments
 * @kind problem
 * @problem.severity warning
 * @security-severity 6.0
 * @precision medium
 * @id js/workshop-dom-security
 * @tags security
 *       external/cwe/cwe-79
 */

import javascript

from CallExpr call, MemberExpr member
where member.getPropertyName() = "innerHTML"
  and call.getCallee() = member
  and not call.getArgument(0) instanceof StringLiteral
select call, "Dynamic innerHTML assignment detected. Verify input sanitization."

`\`bash

text
text

## Workshop Exercise Structure

### Exercise 1: Basic Custom Query Implementation (15 minutes)

**Objective:** Implement single custom query with enhanced PowerShell script

1. Create `custom-security.ql` with XSS detection pattern
1. Run analysis using: `.\codeql-javascript.ps1 -useCustomQL`
1. Review SARIF results with improved parsing (no "Level: warning warning" duplication)
1. Discuss findings and remediation approaches

## Enhanced Features Demonstrated

- Single query execution with proper error handling

- Improved SARIF parsing and display

- Clean query organization with `qlpack.yml` dependencies

### Exercise 2: Comprehensive Query Suite Creation (20 minutes)

**Objective:** Build enterprise-scale query suite combining standard and custom queries

1. Examine `workshop-security-suite.qls` configuration
1. Run comprehensive analysis: `.\codeql-javascript.ps1 -useCustomQLS`
1. Compare results with standard analysis
1. Review query inclusion/exclusion patterns

## Enhanced Features Demonstrated

- Enterprise query organization patterns

- Comprehensive security coverage

- Query filtering and exclusion capabilities

- Professional deployment approaches

### Exercise 3: NEW - Selective Pattern-Based Analysis (25 minutes)

**Objective:** Demonstrate advanced pattern-matching for targeted security analysis

1. Examine `workshop-selected-query-suites.qls` with wildcard patterns
1. Run selective analysis: `.\codeql-javascript.ps1 -useSelectiveQLS`
1. Compare performance and results with comprehensive suite
1. Modify patterns to include/exclude different query types

## NEW Enhanced Features Demonstrated

- Pattern-based query selection (`*security*.ql`, `*console*.ql`, `*eval*.ql`)

- Focused workshop scenarios with reduced noise

- Advanced query filtering for targeted training

- Wildcard pattern matching capabilities

### Exercise 4: Enhanced CI/CD Integration (25 minutes)

**Objective:** Configure advanced PowerShell script parameters and automation

1. Test all three query approaches with parameter validation
1. Configure vulnerability injection with `injectReDoSVulnerability`
1. Upload results to GitHub with enhanced SARIF categories
1. Review automation possibilities with `forceNewAlerts`

## Enhanced Features Demonstrated

- Multi-approach parameter validation

- Advanced vulnerability injection patterns

- Enhanced GitHub integration with proper error handling

- Professional automation scripting

### Exercise 5: Advanced Custom Query Development (30 minutes)

**Objective:** Create new security patterns and integrate with enhanced system

1. Identify new security pattern in calculator application
1. Write custom CodeQL query with proper metadata
1. Test query using all three approaches (single, comprehensive, selective)
1. Add to selective suite using pattern matching
1. Validate with enhanced SARIF parsing

## Enhanced Features Demonstrated

- Professional query development workflow

- Multi-approach testing and validation

- Pattern-based integration

- Quality assurance with improved tooling

## Success Criteria

### Enhanced Workshop Participant Outcomes

- Understand **four primary approaches** for custom CodeQL integration (single, comprehensive, selective, parameterized)

- Successfully create and execute custom security queries using all three PowerShell approaches

- Demonstrate ability to modify and enhance existing automation scripts

- Configure pattern-based query selection for targeted security analysis

- Integrate vulnerability injection and remediation workflows

- Identify appropriate use cases for each query approach in their organization

- Understand enterprise-scale query organization and management

### Enhanced Technical Validation

- All custom queries execute without syntax errors using proper `qlpack.yml` configuration

- SARIF results display correctly without duplication issues ("Level: warning warning" fixed)

- PowerShell script parameter validation works correctly for all three approaches

- Query suites load and execute properly with pattern matching

- GitHub integration uploads results with proper categorization

- Vulnerability injection creates detectable security patterns

- Enhanced SARIF parsing displays clean, readable results

### NEW: Advanced Integration Validation

- **Single Query Approach (`-useCustomQL`):** Executes individual queries with proper error handling

- **Comprehensive Suite (`-useCustomQLS`):** Combines standard and custom queries effectively

- **Selective Pattern Matching (`-useSelectiveQLS`):** Filters queries using wildcard patterns

- **Multi-approach Validation:** Cannot use multiple approaches simultaneously (proper error handling)

- **Enhanced SARIF Processing:** Clean display without level duplication

- **Dependency Management:** Proper CodeQL library resolution with `qlpack.yml`

## Implementation Timeline

### Pre-Workshop Setup (Instructor)

- Prepare calculator application with intentional vulnerabilities

- Configure enhanced PowerShell script with three query approaches

- Set up `qlpack.yml` dependencies for proper CodeQL integration

- Create comprehensive, selective, and single query examples

- Test all three approaches for accuracy and performance

- Validate enhanced SARIF parsing and display functionality

- Prepare GitHub integration examples with proper authentication

### Enhanced Workshop Day Timeline (Total: 135 minutes)

- **0-15 min:** CodeQL overview and enhanced PowerShell script demonstration

- **15-30 min:** Exercise 1 - Basic custom query with `-useCustomQL`

- **30-50 min:** Exercise 2 - Comprehensive suite with `-useCustomQLS`

- **50-75 min:** Exercise 3 - NEW: Selective analysis with `-useSelectiveQLS`

- **75-100 min:** Exercise 4 - Enhanced CI/CD integration and vulnerability injection

- **100-130 min:** Exercise 5 - Advanced custom query development workflow

- **130-135 min:** Wrap-up and real-world implementation strategies

### NEW: Enhanced Technical Validation Checkpoints

**Checkpoint 1 (15 min):** Verify single query execution and SARIF parsing
**Checkpoint 2 (30 min):** Validate comprehensive suite integration
**Checkpoint 3 (50 min):** Confirm selective pattern matching works correctly
**Checkpoint 4 (75 min):** Test GitHub integration and vulnerability injection
**Checkpoint 5 (100 min):** Verify custom query development workflow

## Best Practices for Workshop

### Query Development Guidelines

1. Start with simple patterns and gradually increase complexity
1. Always include comprehensive metadata in query headers
1. Use descriptive query IDs following organizational conventions
1. Test queries against known positive and negative cases
1. Document expected findings and remediation approaches

### Workshop Facilitation Tips

1. Provide pre-configured development environment
1. Have backup scenarios ready for different skill levels
1. Encourage experimentation with query modifications
1. Use live coding demonstrations for complex concepts
1. Include real-world examples from participants' organizations

## Additional Resources

### CodeQL Documentation References

- [CodeQL Query Help](https://codeql.github.com/docs/codeql-language-guides/codeql-for-javascript/)

- [Query Metadata](https://codeql.github.com/docs/writing-codeql-queries/metadata-for-codeql-queries/)

- [SARIF Output Format](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/sarif-support-for-code-scanning)

### Sample Calculator Vulnerabilities for Testing

`\`bash

javascript
// Add these to calculator for workshop demonstrations:

// 1. Hardcoded API key
const API_KEY = "sk-1234567890abcdef";

// 2. Console logging
console.log("Debug: calculation performed");

// 3. innerHTML usage
document.getElementById("display").innerHTML = userInput;

// 4. Additional eval usage
function advancedCalculate(expr) {
  return eval("Math." + expr);
}

`\`bash

text
text

## Conclusion

This enhanced PRD provides a comprehensive framework for conducting an advanced GHAS workshop focused on professional-grade custom CodeQL query development. The scenarios now progress from basic implementation through advanced enterprise patterns, including our NEW selective pattern-based approach that demonstrates cutting-edge query organization techniques.

### Key Enhancements Delivered

## Enhanced PowerShell Integration (v2.0)

- Three distinct query approaches: `-useCustomQL`, `-useCustomQLS`, and `-useSelectiveQLS`

- Improved SARIF parsing eliminating "Level: warning warning" duplication

- Professional parameter validation preventing conflicting options

- Enhanced error handling and fallback mechanisms

## Advanced Query Organization

- Pattern-based selective queries using wildcards (`*security*.ql`, `*console*.ql`, `*eval*.ql`)

- Comprehensive enterprise suite combining standard and custom queries

- Proper dependency management with `qlpack.yml` configuration

- Clean separation of concerns between different query approaches

## Professional Workshop Structure

- Five progressive exercises building from basic to advanced concepts

- Enhanced technical validation checkpoints

- Real-world integration scenarios with vulnerability injection

- Comprehensive coverage of enterprise deployment patterns

The calculator application continues to serve as an ideal teaching platform, containing realistic security patterns while remaining accessible for educational purposes. The **four implementation approaches** (single query, comprehensive suite, selective patterns, and parameterized scripts) provide unprecedented flexibility for different organizational maturity levels and specific use cases.

### NEW: Advanced Workshop Capabilities

**Selective Pattern Matching:** Participants learn enterprise-scale query filtering using wildcard patterns, enabling focused security analysis for specific training scenarios.

**Enhanced Automation:** Professional-grade PowerShell scripting with proper validation, error handling, and GitHub integration demonstrates real-world automation capabilities.

**Quality Assurance:** Improved SARIF parsing and display provides clean, professional results suitable for enterprise reporting and compliance requirements.

## Call to Action

Workshop participants should:

1. Practice all three implementation approaches
1. Develop custom queries relevant to their organization's codebase
1. Plan integration strategy for their existing CI/CD pipelines
1. Establish governance processes for custom query management
1. Share learnings with their security and development teams

---

**Document Status:** Ready for Workshop Implementation  
**Next Review:** Post-workshop feedback incorporation  
**Distribution:** GHAS Workshop Participants, Security Teams, DevOps Engineers
