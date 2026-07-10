---
name: validate-calculator-with-playwright
description: "Validate the Blazor calculator with Playwright and recover its local server when needed. Use when: Use Playwright to open http://localhost:5000, click 7 + 3 =, and confirm the display shows 10; test calculator buttons; verify a calculator result; run the calculator UI smoke test; troubleshoot ERR_CONNECTION_REFUSED on localhost:5000."
---

# Validate Calculator With Playwright

Use this skill to run a browser-level calculator smoke test against the Blazor
app. Reuse a running app when available, recover the local server when the URL
is unavailable, interact through accessible Playwright locators, and report the
observed display value.

## When To Use

Use this skill when the user asks to:

* Open the calculator with Playwright and click an expression
* Verify that `7 + 3 =` displays `10`
* Test calculator keypad behavior at `http://localhost:5000`
* Run a calculator UI smoke test
* Recover from `ERR_CONNECTION_REFUSED` before a Playwright calculator test

## Prerequisites

* The Playwright MCP server is configured and enabled
* The .NET SDK required by `calculator.web` is available through `dotnet`
* The calculator web project exists under
  `src/workspace/calculator-xunit-testing/calculator.web/`
* Port 5000 is available or already hosts this calculator

Use the `configure-mcp-servers` skill if Playwright tools are unavailable.

## Parameters Reference

| Parameter | Default | Description |
|-----------|---------|-------------|
| URL | `http://localhost:5000` | Calculator URL from the user request |
| Expression | `7 + 3 =` | Ordered keypad actions to perform |
| Expected display | `10` | Exact trimmed text expected in the status element |

Honor values supplied by the user instead of these defaults.

## Required Procedure

1. Try to open or reuse the requested URL with a browser tool.
2. If navigation succeeds, confirm the page title is `Calculator` and continue
   to the browser interaction. If another page occupies the requested port,
   report its title and stop without starting a second server.
3. If navigation fails with `ERR_CONNECTION_REFUSED`, locate the current web
   project with a targeted file search for `**/calculator.web.csproj`.
4. Prefer the project under `src/workspace/calculator-xunit-testing/`. Use a
   project under `src/completed/` only when the file actually exists.
5. Start the project in an asynchronous persistent terminal with the requested
   origin, and retain its terminal ID so the process can be monitored and
   stopped:

   ```powershell
   dotnet run --project src/workspace/calculator-xunit-testing/calculator.web/calculator.web.csproj --urls http://localhost:5000
   ```

6. Wait up to 120 seconds for the server to report
   `Now listening on: http://localhost:5000` before retrying navigation. Do not
   launch a second server while the first is still building. If the process
   exits or the deadline expires, report the captured terminal output and fail.
7. Reuse the active calculator page when possible. Reload or open a new page
   only when necessary.
8. Scope keypad actions to the `Current Calculation` region. Verify the Blazor
   circuit is interactive by clicking `Seven`, waiting for the status to show
   `7`, then clicking the scoped `Clear` button and waiting for status `0`.
   Retry this readiness probe within the same 120-second startup deadline if
   the first click occurs before interactivity attaches.
9. Clear prior input with the scoped `Clear` button, then click these accessible
   buttons in order for the default expression:

   * `Seven`
   * `Add`
   * `Three`
   * `Equals`

10. Read the element with the `status` role. Trim its text and compare it with
    the expected display value.
11. Treat any value other than the exact expected value as a failed test. Report
   the expected and observed values before cleanup.
12. On success, report the URL, expression, and confirmed display value.

## Playwright Interaction

Prefer role-based locators because the calculator exposes stable accessible
names. The equivalent Playwright flow is:

```javascript
const calculator = page.getByRole('region', { name: 'Current Calculation' });
await calculator.getByRole('button', { name: 'Seven', exact: true }).click();
await expect(page.getByRole('status')).toHaveText('7');
await calculator.getByRole('button', { name: 'Clear', exact: true }).click();
await expect(page.getByRole('status')).toHaveText('0');

await calculator.getByRole('button', { name: 'Clear', exact: true }).click();
await calculator.getByRole('button', { name: 'Seven', exact: true }).click();
await calculator.getByRole('button', { name: 'Add', exact: true }).click();
await calculator.getByRole('button', { name: 'Three', exact: true }).click();
await calculator.getByRole('button', { name: 'Equals', exact: true }).click();

const observedDisplay = (await page.getByRole('status').innerText()).trim();
if (observedDisplay !== '10') {
  throw new Error(`Expected display 10, observed ${observedDisplay}`);
}
```

Use one concise Playwright execution when the browser tool supports it. When
only individual click tools are available, follow the same locator order and
perform the display assertion as a separate final action.

## Validation Result

A successful result must include all of the following evidence:

* URL: `http://localhost:5000`
* Expression: `7 + 3 =`
* Expected display: `10`
* Observed display: `10`
* Verdict: passed

Do not report success from the expected arithmetic alone. The observed value
must come from the rendered page after the clicks.

## Troubleshooting

### Connection Refused

Confirm the project path before starting `dotnet run`. The active exercise
project is under `src/workspace/`; a previously documented `src/completed/`
path might not exist.

### Page Opens Before The Build Finishes

Keep the original server process running and wait for its readiness output.
Retry browser navigation only after Kestrel reports that it is listening.

### Clear Selects The History Button

The page contains two buttons named `Clear`. Scope the keypad clear action to
the `Current Calculation` region.

### Display Assertion Cannot Find The Result

Use `getByRole('status')`. The calculator renders its display with an HTML
`output` element, which Playwright exposes with the `status` role.

## Cleanup

For a one-off validation request, stop only the terminal process started by
this workflow after reporting success or failure. Leave it running only when
the user explicitly requests continued manual access. Never stop a server that
was already running before this workflow began.