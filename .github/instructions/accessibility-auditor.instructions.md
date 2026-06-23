---
applyTo: **/*.html
---
## Accessibility Auditor Guidelines

When evaluating code or content for accessibility compliance, follow these priorities.

### Semantic HTML first

- Use semantic elements: `<nav>`, `<main>`, `<section>`, `<article>`, `<header>`, `<footer>`.
- Structure headings sequentially (h1 → h2 → h3); do not skip levels.
- Use one `<h1>` per page with descriptive text.

### Essential ARIA requirements

- Add `alt` text to all images.
- Label form inputs with `<label>` or `aria-label`.
- Ensure interactive elements have accessible names.
- Use `aria-expanded` for collapsible content.
- Add `role`, `aria-labelledby`, and `aria-describedby` when semantic HTML isn't sufficient.

### Keyboard navigation

- All interactive elements must be keyboard accessible.
- Provide visible focus indicators (minimum 2px outline).
- Include skip links: `<a href="#main">Skip to main content</a>`.
- Use logical tab order that matches the visual layout.

### Color and contrast

- Ensure 4.5:1 contrast ratio for normal text; 3:1 for large text.
- Do not rely solely on color to convey information.

### Quick test questions

- Can you navigate the entire interface using only Tab/Shift+Tab/Enter?
- Are all images and icons properly described?
- Can screen reader users understand the content and functionality?

### Screen reader compatibility

- Provide descriptive text for all non-text content.
- Images: use alt text describing function, not just appearance.
	- Good: `alt="Submit form"`
	- Avoid: `alt="Blue button"`
- Form inputs: associate every input with a `<label>` element.
- Links: use descriptive link text (e.g., "Download the accessibility report (PDF, 2MB)") — avoid "Click here".

#### Announce dynamic content updates

- Use `aria-live="polite"` for status updates.
- Use `aria-live="assertive"` for urgent notifications.
- Notify screen reader users when content changes without a page reload.

---

## Color and contrast requirements

### Meet these specific ratios

- Normal text (under 18pt): minimum 4.5:1 contrast ratio.
- Large text (18pt+ or 14pt+ bold): minimum 3:1 contrast ratio.
- UI components and graphics: minimum 3:1 contrast ratio.

### Provide multiple visual cues

- Use color + icon + text for status indicators.
- Add patterns or textures to distinguish chart elements.
- Include text labels on graphs and data visualizations.

---

## Testing integration steps

### Automated checks

- Run the `axe-core` accessibility scanner in CI/CD.
- Test with Lighthouse accessibility audit.
- Validate HTML markup for semantic correctness.

### Manual tests

- Navigate the entire interface using only Tab and arrow keys.
- Test with a screen reader (NVDA on Windows, VoiceOver on Mac).
- Verify 200% zoom does not break layout or hide content.
- Check color contrast with tools like the WebAIM Color Contrast Checker.

---

## Form design standards

- Place labels above or to the left of form fields.
- Group related fields with `<fieldset>` and `<legend>`.
- Display validation errors immediately after the field using `aria-describedby`.
- Use `aria-required="true"` for required fields.
- Provide clear instructions before users start filling out forms.

### Error message example

```html
<input aria-describedby="email-error" aria-invalid="true" />
<div id="email-error">Please enter a valid email address</div>
```

---

**Code generation rule:** Always include accessibility comments explaining ARIA attributes and semantic choices. Test code with keyboard navigation before suggesting it is complete.

