# E2E Testing Guidelines

> Standards and instructions for the e2e agent when executing end-to-end tests. The e2e agent reads this document before every test run. Acceptance criteria sourced from `DESIGN.md` are mandatory checks and must appear in all test reports.

---

## Core Responsibilities

The e2e agent verifies that the running application satisfies the original requirements. Its primary input sources are:

1. The original feature requirements from the requirements agent.
2. The **Acceptance Criteria section of `DESIGN.md`** — these are mandatory and take precedence as the verifiable contract between design and implementation.
3. Any supplemental scenarios identified during test planning.

---

## DESIGN.md Acceptance Criteria — Mandatory Verification

### Locating the AC

Before writing or executing any test plan, the e2e agent **must**:

1. Check for a `DESIGN.md` file in the project root or the feature directory.
2. If found, extract **Section 10 — Acceptance Criteria** in its entirety.
3. Treat every `AC-NNN` item as a required test case. No AC item may be skipped without an explicit, documented reason.

### Executing the AC Checks

For each AC item:

- Map the **E2E check** field to a concrete test assertion (UI element visible, API response code, timing behaviour, etc.).
- Execute the test against the running deployment.
- Record the result as **PASS** or **FAIL** with:
  - The AC ID (`AC-001`, `AC-002`, …)
  - The AC short title
  - The actual observed behaviour
  - A screenshot or log excerpt if the check fails

### Handling a Missing DESIGN.md

If no `DESIGN.md` is found, the e2e agent logs a warning:

```
⚠️  No DESIGN.md found. Skipping DESIGN.md acceptance criteria checks.
    Proceeding with requirement-based test plan only.
```

This is not a test failure, but it must be surfaced in the report.

---

## Test Report Structure

Every e2e test report **must** include the following sections in order:

### 1. Summary

| Item | Value |
|------|-------|
| Run date | YYYY-MM-DD HH:MM UTC |
| Deployment URL | https://... |
| DESIGN.md found | Yes / No |
| Total AC items | N |
| AC PASS | N |
| AC FAIL | N |
| AC SKIPPED | N |
| Total scenarios | N |
| Scenarios PASS | N |
| Scenarios FAIL | N |
| Overall result | ✅ PASS / ❌ FAIL |

> **Overall result is FAIL if any AC item fails**, regardless of other scenario results.

---

### 2. DESIGN.md Acceptance Criteria Results

List every AC item from `DESIGN.md` section 10 with its result.

```
AC-001 — User can create a new item from the empty state        ✅ PASS
AC-002 — Form submission shows a loading state                  ✅ PASS
AC-003 — Success toast appears after creation                   ❌ FAIL
         Actual: toast appeared but did not dismiss after 4s
         Evidence: screenshot-ac-003-toast.png
```

If `DESIGN.md` was not found, write:

```
DESIGN.md not found — AC checks skipped (see warning above)
```

---

### 3. Full Scenario Results

List all additional scenarios tested (beyond AC items) with pass/fail and a one-line description of any failure.

---

### 4. Failures Detail

For every FAIL item (AC or scenario), include:

- **ID**: AC-NNN or SCENARIO-NNN
- **Title**: short description
- **Expected**: what the spec or requirement stated should happen
- **Actual**: what the running system did
- **Evidence**: screenshot filename, API response body, or log excerpt
- **Severity**: `blocker` | `major` | `minor`

---

### 5. Recommendations

List any follow-up actions required:

- Bugs to fix before sign-off
- Open questions to resolve
- AC items that need clarification in `DESIGN.md`

---

## Test Planning Rules

1. **AC items are not optional** — do not build a test plan that omits any `AC-NNN` item unless the item is explicitly marked as out-of-scope in `DESIGN.md` itself.
2. **Test unhappy paths** — every AC item with an error branch must be tested for both the happy path and the error path.
3. **Use the E2E check field** — the design agent provides a verification hint in the `E2E check` field of each AC item. Use it as the starting point for the assertion, but supplement with additional checks as needed.
4. **Do not modify `DESIGN.md`** — if an AC item is ambiguous or untestable, report it as a gap in section 5 (Recommendations) and test it as best as possible.
5. **Report before escalating** — always produce a complete test report even if failures are found. The back-tracker agent uses this report to route issues.

---

## Relationship to Other Agents

| Agent | Interaction |
|-------|-------------|
| Design agent | Writes `DESIGN.md` section 10 (AC). The e2e agent reads it verbatim. |
| Coding agent | Implements the feature. The e2e agent tests the running result. |
| Back-tracker agent | Receives the full e2e report and routes failures back to the appropriate agent. |
| Orchestrator | Receives the overall pass/fail verdict to decide whether to ship or iterate. |
