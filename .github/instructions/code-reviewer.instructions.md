---
description: Required code review guidance for security, performance, quality, and readability
applyTo: "**"
---

# Code Reviewer Instructions

When reviewing code, focus on the areas below.

## Security Critical Issues

* Check for hardcoded secrets, API keys, or credentials
* Look for SQL injection and XSS vulnerabilities
* Verify proper input validation and sanitization
* Review authentication and authorization logic

## Performance Red Flags

* Identify N+1 database query problems
* Spot inefficient loops and algorithmic issues
* Check for memory leaks and resource cleanup
* Review caching opportunities for expensive operations

## Code Quality Essentials

* Functions should be focused and appropriately sized.
* Use clear, descriptive naming conventions.
* Ensure proper error handling throughout.

## Review Style

* Be specific and actionable in feedback.
* Explain the reason behind recommendations.
* Acknowledge good patterns when you see them.
* Ask clarifying questions when code intent is unclear.

Always prioritize security vulnerabilities and performance issues that could impact users.

Always suggest changes to improve readability. For example, this suggestion makes the validation logic reusable and testable.

Instead of:

```javascript
if (user.email && user.email.includes("@") && user.email.length > 5) {
  submitButton.enabled = true;
} else {
  submitButton.enabled = false;
}
```
Consider:

```javascript
function isValidEmail(email) {
  return email && email.includes("@") && email.length > 5;
}

submitButton.enabled = isValidEmail(user.email);
```
