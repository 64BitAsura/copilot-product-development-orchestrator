# DESIGN.md Specification

> This document defines the required structure and content for every `DESIGN.md` file produced by the design agent. It is based on the [Google Stitch DESIGN.md format](https://stitch.withgoogle.com/docs/design-md/overview). All design outputs **must** follow this template to ensure consistency across every app and feature in this product.

---

## What Is a DESIGN.md?

A `DESIGN.md` is a structured, human- and AI-readable design specification file that accompanies each feature or application. It acts as the single source of truth for UX decisions, design tokens, component specifications, layout rules, and accessibility requirements for that scope of work. When the design agent produces a specification, it outputs a `DESIGN.md` following the format below.

Reference: [https://stitch.withgoogle.com/docs/design-md/overview](https://stitch.withgoogle.com/docs/design-md/overview)

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

### 10. Open Questions _(optional)_

List any unresolved design decisions that need stakeholder input before implementation.

- [ ] Question 1 — owner: @name — deadline: YYYY-MM-DD
- [ ] Question 2 — owner: @name — deadline: YYYY-MM-DD

---

### 11. Changelog _(optional, recommended for long-lived features)_

| Version | Date | Author | Summary of Changes |
|---------|------|--------|--------------------|
| 1.0 | YYYY-MM-DD | — | Initial spec |

---

## Design Agent Instructions

When producing a `DESIGN.md`:

1. **Always output every required section** (sections 1–9). Omitting a section is a defect.
2. **Reference the product token set** — do not invent standalone pixel values. Map every visual decision to a named token.
3. **Justify new components** — if a new component is introduced, explain why no existing component satisfies the need.
4. **Apply the design principles** — every decision must be traceable to one of the principles in [`design-principles.md`](./design-principles.md). If a principle is overridden, state the reason explicitly.
5. **Fill the Design Budget Compliance table** — calculate the actual values for this feature and confirm they are within budget.
6. **Use plain language** — the spec is read by engineers and AI agents. Avoid visual design jargon that cannot be directly implemented.
7. **Keep scope tight** — one `DESIGN.md` per feature or screen group. Do not mix unrelated flows in a single file.
