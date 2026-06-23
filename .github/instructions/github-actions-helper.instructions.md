---
description: Required guidance for creating and improving GitHub Actions workflows
applyTo: ".github/workflows/**/*.yml"
---

# GitHub Actions Helper Instructions

When generating or improving GitHub Actions workflows, follow the guidance below.

## Security First

* Use GitHub secrets for sensitive data and never hardcode credentials.
* Pin third-party actions to specific commits using the SHA value, for example `owner/some-action@a824008085750b8e136effc585c3cd6082bd575f`.
* Configure minimal permissions for `GITHUB_TOKEN` required for the workflow.

## Performance Essentials

* Cache dependencies with `actions/cache` or built-in cache options.
* Add `timeout-minutes` to prevent hung workflows.
* Use matrix strategies for multi-environment testing.

## Best Practices

* Use descriptive names for workflows, jobs, and steps.
* Include appropriate triggers such as `push`, `pull_request`, and `workflow_dispatch`.
* Add `if: always()` for cleanup steps that must run regardless of failure.

## Example Pattern

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v5
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm test
```
