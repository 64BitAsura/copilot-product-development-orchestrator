# Design Principles

> Principles that guide all UX and UI decisions in this product. The design agent reads these before producing any design spec. All new design work must justify its decisions against these principles or explicitly note a deviation with a rationale.
>
> **Output format:** Every design specification produced by the design agent must be structured as a `DESIGN.md` file following the [Google Stitch DESIGN.md format](https://stitch.withgoogle.com/docs/design-md/overview). See [`design.md`](./design.md) for the required sections, template, and agent instructions.

---

## 1. Clarity Over Cleverness

Every interaction should be immediately understandable without explanation. Clever animations, metaphors, or micro-interactions that require the user to learn them are a cost, not a feature.

**In practice:**
- Labels use plain language, not jargon or product-specific terms.
- Actions have clear, verb-based labels: "Create draft", not "Draft".
- Errors explain what went wrong AND what the user can do next.
- Empty states tell the user exactly what to do to get started.

---

## 2. Progressive Disclosure

Show users what they need at the moment they need it. Hide complexity until it is requested.

**In practice:**
- Primary flows are exposed immediately; advanced options are behind "Advanced" or secondary screens.
- Forms show only required fields by default; optional fields are accessible but not prominent.
- Error details are expandable, not always visible.
- Long lists are paginated or virtualised; do not dump 1000 rows on screen.

---

## 3. Consistency is Kindness

Consistent patterns reduce cognitive load. When the same action works the same way everywhere, users do not have to think.

**In practice:**
- Reuse existing components before creating new ones. New components require explicit justification.
- Destructive actions always require confirmation and are always red.
- Navigation patterns are identical across sections.
- The same data is always displayed the same way (e.g., dates are always in the same format).

---

## 4. Accessibility Is Non-Negotiable

Every surface must be usable by people with visual, motor, cognitive, or hearing impairments. This is not optional — it is a legal requirement in many jurisdictions and a moral requirement everywhere.

**Minimum standards:**
- WCAG 2.1 Level AA compliance on every screen.
- Colour contrast ratio ≥ 4.5:1 for normal text, ≥ 3:1 for large text.
- Every interactive element is keyboard accessible.
- Every non-text element has a descriptive text alternative.
- Focus indicators are always visible.
- No content is conveyed by colour alone.
- Screen reader announcements for dynamic content changes.

---

## 5. Performance Is a Feature

A slow UI is a broken UI. Perceived performance matters as much as actual performance.

**Design-level performance requirements:**
- Loading states are shown within 200ms of an action.
- Skeletons are preferred over spinners for content-heavy loads.
- Optimistic updates are used for low-risk mutations (list adds, status changes).
- Pagination or infinite scroll for any list that may exceed 50 items.
- Heavy content (images, rich text) is lazy-loaded.

---

## 6. Forgiving Interactions

Users make mistakes. Good design makes recovery easy.

**In practice:**
- Destructive actions (delete, cancel, revoke) require confirmation.
- Undo is provided where technically feasible (within a session).
- Forms remember user input on validation errors — never clear the form.
- Progress is saved automatically in multi-step flows.
- Navigation away from unsaved changes triggers a warning.

---

## 7. Feedback for Every Action

Users must always know what the system is doing and whether their action succeeded or failed.

**In practice:**
- Every form submission shows a loading state during the request.
- Every successful mutation shows a success message (toast or inline).
- Every error shows a specific, actionable message — not "Something went wrong".
- Background operations (uploads, jobs) have visible progress indicators.
- Actions that cannot be undone are labelled as such before the user commits.

---

## Design Budgets (Product-Wide Defaults)

These defaults apply to all features unless the design agent specifies overrides for a specific feature:

| Metric | Default Limit |
|--------|-------------|
| Primary flow steps | ≤ 5 steps |
| Form fields per screen | ≤ 7 visible fields |
| Decision points per flow | ≤ 3 |
| Minimum touch target size | 44 × 44px |
| Animation duration | 150ms – 400ms |
| Maximum list items without pagination | 50 |
| Toast notification duration | 4 seconds |
| Modal width | ≤ 600px for forms; ≤ 960px for content |

---

## What NOT To Do

| Anti-Pattern | Why |
|-------------|-----|
| Infinite scroll for destructive or task-focused lists | Users lose their position; hard to return to a specific item |
| Auto-submit forms | Unexpected — always let users review before submitting |
| Disabling submit buttons without explanation | Users don't know why they can't proceed |
| Removing content to "simplify" loading | Causes layout shift; use skeletons instead |
| Using colour as the only differentiator | Fails colour-blind users |
| Generic error messages ("Error 500") | Leaves users with no path forward |
| Navigation that changes without user action | Disorienting and breaks back-button expectations |
