# Gap Analysis Checklist

> The refinement agent uses this checklist on every input before writing requirements. A gap is any missing information that would force the coding or design agent to make an assumption. Assumptions lead to wrong implementations.

---

## How to Use

For each item below, mark:
- ✅ **Present** — information is in the input or can be inferred unambiguously
- ⚠️ **Partial** — some information is present but incomplete
- ❌ **Missing** — information is absent and must be requested from the user

Any ❌ or ⚠️ item **must** be addressed before requirements are finalized.

---

## 1. Functional Completeness

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 1.1 | The primary user action is clearly described | | |
| 1.2 | The expected system response is defined | | |
| 1.3 | Success state is measurable | | |
| 1.4 | All form fields / inputs are specified | | |
| 1.5 | All output formats are specified | | |
| 1.6 | At least one error state is described | | |
| 1.7 | Empty / zero-data state is addressed | | |
| 1.8 | Permission model is specified (who can do this?) | | |

---

## 2. User & Context

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 2.1 | Target user/persona is named | | |
| 2.2 | The problem being solved is stated (not just the feature) | | |
| 2.3 | Why now / urgency is understood | | |
| 2.4 | User's current workaround (if any) is known | | |
| 2.5 | Frequency of use is estimated (daily/weekly/rare) | | |

---

## 3. Scope Boundaries

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 3.1 | What is explicitly out of scope is stated | | |
| 3.2 | Feature is a standalone unit (not tangled with another) | | |
| 3.3 | No implicit dependencies on unbuilt features | | |
| 3.4 | No requirement for third-party services not yet integrated | | |

---

## 4. Non-Functional Requirements

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 4.1 | Performance expectations are stated (latency, throughput) | | |
| 4.2 | Security requirements are addressed | | |
| 4.3 | Accessibility level is specified | | |
| 4.4 | Browser/platform support requirements are clear | | |
| 4.5 | Data retention / privacy requirements are addressed | | |
| 4.6 | Internationalization / localization needs are addressed | | |

---

## 5. Design / UI

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 5.1 | If UI is involved: mockup or wireframe is provided OR not required | | |
| 5.2 | If UI is involved: which existing screens are affected | | |
| 5.3 | Responsive behavior expectation is stated | | |
| 5.4 | Dark mode / theme requirements addressed | | |

---

## 6. Integration & Data

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 6.1 | If data is stored: data model sketch exists | | |
| 6.2 | If external APIs used: API docs or references provided | | |
| 6.3 | If existing data is modified: migration strategy is noted | | |
| 6.4 | Existing endpoints that need modification are identified | | |

---

## 7. Reference Input Quality

| # | Check | Status | Notes |
|---|-------|--------|-------|
| 7.1 | All referenced URLs are accessible | | |
| 7.2 | All referenced repos are relevant to the request | | |
| 7.3 | Any image/mockup references show the intended outcome | | |
| 7.4 | Document references are specific (not "see the whole spec") | | |

---

## Gap Summary Template

When gaps are found, generate a message in this format:

```
⚠️ Requirements Gap Analysis — [N] gaps found

Before I can complete requirements, I need answers to the following:

### Gap 1 — [Category, e.g., Functional]
**Question**: [Specific, answerable question]
**Why it matters**: [What goes wrong if we assume]
**Options if you're unsure**: [A / B / C]

### Gap 2 — [Category]
...

Please reply with answers and I'll update the requirements draft.
```

---

## Zero-Gap Sign-Off

When all checks pass, include this line in the requirements document:

> ✅ **Gap Analysis Complete** — All [N] checklist items verified. No blocking gaps found.
