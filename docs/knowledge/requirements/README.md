# Requirements Knowledge Base

> **Purpose**: This folder is the refinement agent's primary knowledge source. It contains templates, guidelines, past decisions, and approved requirement patterns that the refinement agent uses to produce consistent, high-quality output.

---

## Folder Contents

| File | Purpose |
|------|---------|
| `README.md` | This file — index and usage guide |
| `requirement-template.md` | Standard template for writing a requirements document |
| `acceptance-criteria-guide.md` | How to write good acceptance criteria |
| `gap-analysis-checklist.md` | Checklist for identifying gaps in inputs |
| `approved-patterns.md` | Pre-approved requirement patterns for common feature types |
| `past-decisions.md` | Log of significant product decisions and their rationale |
| `personas.md` | User personas the product serves |

---

## How the Refinement Agent Uses This Folder

1. **On every invocation**, the refinement agent reads `personas.md` and `past-decisions.md` to ensure new requirements align with established product direction.
2. **During gap analysis**, the agent uses `gap-analysis-checklist.md` as its checklist structure.
3. **When writing requirements**, the agent follows `requirement-template.md`.
4. **When writing acceptance criteria**, the agent follows `acceptance-criteria-guide.md`.
5. **For common feature types** (auth, CRUD, search, notifications, etc.), the agent consults `approved-patterns.md` to ensure consistency.

---

## How to Update This Folder

- After every approved requirements session, the refinement agent updates `past-decisions.md` with the key decisions made.
- When a new user persona is identified, add it to `personas.md`.
- When a new pattern is approved (e.g., a new way of handling pagination), add it to `approved-patterns.md`.
- The `past-decisions.md` file is append-only — never delete entries, only add new ones.

---

## Requirements Quality Standards

A requirements document is considered complete when:

- [ ] Problem statement is clear and user-validated
- [ ] Target user/persona is identified
- [ ] Success criteria are measurable
- [ ] All edge cases are enumerated
- [ ] Non-functional requirements are specified (performance, security, accessibility)
- [ ] Out-of-scope items are explicitly listed
- [ ] Dependencies on other features or systems are identified
- [ ] Multiple implementation options were presented to the user
- [ ] User selected a specific option
- [ ] Acceptance criteria follow the Given/When/Then format
