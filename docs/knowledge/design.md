# DESIGN.md Specification

> This document defines the required structure and content for every `DESIGN.md` file produced by the design agent. It is based on the [Google Stitch DESIGN.md format](https://stitch.withgoogle.com/docs/design-md/overview). All design outputs **must** follow this template to ensure consistency across every app and feature in this product.

---

## What Is a DESIGN.md?

A `DESIGN.md` is a structured, human- and AI-readable design specification file that accompanies each feature or application. It acts as the single source of truth for UX decisions, design tokens, component specifications, layout rules, accessibility requirements, and acceptance criteria for that scope of work.

Reference: [https://stitch.withgoogle.com/docs/design-md/overview](https://stitch.withgoogle.com/docs/design-md/overview)

---

## Design Agent — Two Modes of Operation

The design agent operates in exactly one of two modes on every run. The mode is determined by checking whether a `DESIGN.md` file already exists in the project root (or the feature directory being worked on).

### Mode 1 — Create (no existing DESIGN.md)

**Trigger:** No `DESIGN.md` file is found.

**Behaviour:**
1. Generate a complete `DESIGN.md` for the current feature or application following all sections defined in this document (sections 1–11 required, 12–13 optional).
2. Commit the file as the first artefact of the design phase before passing work to the planning or coding agent.
3. Do **not** proceed to planning or coding guidance until the `DESIGN.md` is written and committed.

### Mode 2 — Follow (existing DESIGN.md found)

**Trigger:** A `DESIGN.md` file already exists.

**Behaviour:**
1. **Do not alter the existing `DESIGN.md` in any way.** The file is treated as immutable during this pipeline run.
2. Read the entire file and extract: design tokens, component specs, layout rules, accessibility requirements, user flows, and acceptance criteria.
3. Translate the spec into actionable guidance for the **planning agent** (architecture decisions, component boundaries, data models) and the **coding agent** (component implementation, token usage, accessibility constraints).
4. Surface any discovered inconsistency or gap as a comment to the orchestrator — never silently modify the spec.

> **Rule:** The design agent creates or follows — it never edits an existing `DESIGN.md`.

---

## Required Sections

Every `DESIGN.md` **must** contain all of the following sections. Optional sections are noted.

---

### 1. Overview

A concise summary of what this design covers and why.

- **Scope**: what feature, screen, or flow this file describes.
- **Goal**: the user problem being solved or the job-to-be-done.
- **Summary**: one paragraph that captures the key design decisions.

---

### 2. Design Tokens

Define all foundational visual values used in this feature. Values must reference or extend the product-wide token set.

| Token Category | Token Name | Value | Notes |
|----------------|------------|-------|-------|
| Color | `--color-primary` | `#006EE6` | Brand blue |
| Color | `--color-surface` | `#FFFFFF` | Page background |
| Typography | `--font-body` | `Inter, sans-serif` | Body copy |
| Spacing | `--spacing-md` | `16px` | Standard gap |
| Border radius | `--radius-card` | `8px` | Card corners |
| Shadow | `--shadow-card` | `0 1px 3px rgba(0,0,0,.12)` | Default elevation |

> If this feature introduces no new tokens, write: _"No new tokens. All values inherit from the product token set."_

---

### 3. Components

List every UI component used or introduced in this feature.

For each component include:

- **Name**: component identifier (e.g., `<PrimaryButton>`)
- **Variants**: list of supported variants (e.g., `default`, `destructive`, `ghost`)
- **States**: the interactive states it supports (e.g., `default`, `hover`, `focus`, `disabled`, `loading`)
- **Interactions**: any animations, transitions, or dynamic behaviours
- **Reuse vs New**: whether this reuses an existing component or introduces a new one (new components require justification)

#### Example

**`<UserCard>`** _(new component)_
- Variants: `compact`, `expanded`
- States: `default`, `hover`, `selected`
- Interactions: 150ms ease-in-out scale on hover; keyboard-focusable; focus ring visible
- Justification: no existing card component supports the two-line avatar layout required here

---

### 4. Layout & Structure

Describe the page/screen layout for this feature.

- **Grid**: column count and gutter widths at each breakpoint
- **Breakpoints**:
  - Mobile: < 640px
  - Tablet: 640px – 1024px
  - Desktop: > 1024px
- **Spacing rhythm**: the base spacing unit and how it scales (e.g., 4px grid)
- **Zones**: describe primary content zones (header, sidebar, main, footer) and their proportional widths
- **Scroll behaviour**: paged, infinite scroll, fixed headers, sticky sidebars

---

### 5. Accessibility

Document how this feature meets the [WCAG 2.1 Level AA](https://www.w3.org/TR/WCAG21/) baseline required by the [design principles](./design-principles.md).

- **Colour contrast**: confirm all text/background pairs meet the ≥ 4.5:1 (normal) / ≥ 3:1 (large) ratio
- **Keyboard navigation**: list tab order and any custom keyboard shortcuts
- **Screen reader**: describe ARIA roles, labels, and live-region announcements
- **Focus management**: explain how focus is managed after modals, dialogs, and page transitions
- **Motion**: note if animations respect `prefers-reduced-motion`

---

### 6. Patterns & Guidelines

Describe the UX patterns and content guidelines specific to this feature.

#### UX Patterns
- **Empty states**: what is shown when there is no data
- **Error states**: inline validation, toast messages, and full-page errors
- **Loading states**: skeleton screens vs. spinners and when each is used
- **Confirmation flows**: which destructive actions require a confirmation dialog

#### Content & Tone
- Voice and tone for this feature (e.g., encouraging, instructional, neutral)
- Any domain-specific terminology or labels to use consistently
- Microcopy requirements (button labels, placeholder text, helper text)

---

### 7. User Flows

Provide a step-by-step walkthrough of the primary user flow(s) for this feature.

```
Step 1 → Step 2 → Step 3 → [Branch A] → Success
                          → [Branch B] → Error → Recovery
```

- Keep each flow to ≤ 5 steps (per design budget).
- Note decision points and what triggers each branch.
- Include unhappy paths (validation errors, network failures, permission denials).

---

### 8. Examples & Usage

Provide concrete examples of the design in context.

- Annotated screen descriptions (or references to Figma/prototype links)
- Usage do's and don'ts for any new components
- Representative data examples showing how real content will look

---

### 9. Design Budget Compliance

Confirm this design stays within the [product-wide design budgets](./design-principles.md#design-budgets-product-wide-defaults). Note any approved overrides with justification.

| Metric | Budget | This Feature | Override Reason |
|--------|--------|--------------|-----------------|
| Primary flow steps | ≤ 5 | _N_ | — |
| Form fields per screen | ≤ 7 | _N_ | — |
| Decision points per flow | ≤ 3 | _N_ | — |
| Touch target size | ≥ 44×44px | ✅ | — |
| Animation duration | 150–400ms | ✅ | — |

---

### 10. Acceptance Criteria

> **This section is written by the design agent and consumed verbatim by the e2e agent.** Every criterion listed here is a mandatory check in the e2e agent's test run. The e2e agent must report pass/fail for each AC item by its ID and include the full results in its test report.

List every verifiable behaviour that the implementation must satisfy. Use the Given/When/Then format. Assign each criterion a stable ID (`AC-001`, `AC-002`, …).

#### Format

```
**AC-001** — <Short title>
- Given: <precondition>
- When: <user action or system event>
- Then: <expected observable outcome>
- E2E check: <how the e2e agent should verify this — UI assertion, API assertion, screenshot, etc.>
```

#### Example

```
**AC-001** — User can create a new item from the empty state
- Given: the user is authenticated and no items exist
- When: the user clicks "Create first item" on the empty state screen
- Then: a creation modal opens within 300ms
- E2E check: assert modal is visible; assert focus is on the first form field

**AC-002** — Form submission shows a loading state
- Given: the creation form is filled with valid data
- When: the user clicks "Save"
- Then: the submit button transitions to a loading spinner within 200ms and is disabled
- E2E check: assert button has loading attribute; assert button is not clickable during request

**AC-003** — Success toast appears after creation
- Given: the creation request completes successfully
- When: the server returns 201
- Then: a success toast reading "Item created" is visible for 4 seconds then dismisses
- E2E check: assert toast text; assert toast disappears after 4 seconds
```

> The design agent must write at minimum one AC per user flow branch (happy path and each error/edge path). Do not leave this section empty.

---

### 11. Open Questions _(optional)_

List any unresolved design decisions that need stakeholder input before implementation.

- [ ] Question 1 — owner: @name — deadline: YYYY-MM-DD
- [ ] Question 2 — owner: @name — deadline: YYYY-MM-DD

---

### 12. Changelog _(optional, recommended for long-lived features)_

| Version | Date | Author | Summary of Changes |
|---------|------|--------|--------------------|
| 1.0 | YYYY-MM-DD | — | Initial spec |

---

## Design Agent Instructions

When producing a `DESIGN.md`:

1. **Check for an existing `DESIGN.md` first** — if found, switch to Mode 2 (Follow) and do not create or edit the file. If not found, proceed to create it (Mode 1).
2. **Always output every required section** (sections 1–10). Omitting a section is a defect.
3. **Reference the product token set** — do not invent standalone pixel values. Map every visual decision to a named token.
4. **Justify new components** — if a new component is introduced, explain why no existing component satisfies the need.
5. **Apply the design principles** — every decision must be traceable to one of the principles in [`design-principles.md`](./design-principles.md). If a principle is overridden, state the reason explicitly.
6. **Fill the Design Budget Compliance table** — calculate the actual values for this feature and confirm they are within budget.
7. **Write Acceptance Criteria (section 10)** — at minimum one AC per user flow branch. Use Given/When/Then + E2E check. Assign stable IDs starting at `AC-001`. These are consumed directly by the e2e agent.
8. **Use plain language** — the spec is read by engineers and AI agents. Avoid visual design jargon that cannot be directly implemented.
9. **Keep scope tight** — one `DESIGN.md` per feature or screen group. Do not mix unrelated flows in a single file.

