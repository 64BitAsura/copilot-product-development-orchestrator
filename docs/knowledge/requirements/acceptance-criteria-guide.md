# Acceptance Criteria Guide

> How to write acceptance criteria that are unambiguous, independently testable, and directly usable by the tester agent to generate test cases.

---

## The Golden Rule

**A good acceptance criterion has exactly one interpretation.** If two engineers read it and could implement different behaviors, it is not good enough.

---

## Format: Given / When / Then

All acceptance criteria must follow this structure:

```
Given [a precondition or system state],
When [a user action or system event occurs],
Then [the expected, observable outcome].
```

### Why this works
- **Given** anchors the test: what state must the world be in?
- **When** identifies the trigger: what happens?
- **Then** is the verifiable assertion: what can we check?

---

## Examples

### ✅ Good Acceptance Criterion

```
Given a user is logged in and has the "editor" role,
When they submit a form with a valid title and body,
Then a new draft is created, assigned to that user, and the user is redirected to the draft detail page.
```

**Why it's good**: precondition is specific, action is specific, outcome has three verifiable parts.

---

### ❌ Bad Acceptance Criterion

```
The form should work correctly.
```

**Why it's bad**: "works correctly" is not verifiable. No precondition, no specific action, no measurable outcome.

---

### ❌ Also Bad

```
Users can create drafts.
```

**Why it's bad**: Missing precondition (which users?), no action (how?), no observable outcome (what happens after?).

---

## Category Checklist

Every feature's acceptance criteria should cover all of these categories:

### 1. Happy Path (required)
The primary success flow under normal conditions.

```
Given [normal preconditions],
When [primary action],
Then [success outcome — at minimum: visual feedback + data state change].
```

### 2. Input Validation (required if user input exists)
```
Given a user is on the [form/screen],
When they submit with [invalid/missing input],
Then [specific error message] is shown and [no data is created/modified].
```

### 3. Permission / Authorization (required if access control exists)
```
Given a user with [role X] is authenticated,
When they attempt to [action],
Then [access is granted / denied with HTTP 403 / redirect to login].
```

### 4. Error Handling (required)
```
Given [service/dependency] is unavailable,
When a user attempts [action],
Then [user-facing error message] is shown and [no partial state is left].
```

### 5. Edge Cases (required, minimum 2)
Common edge cases to always consider:
- Empty state (no items in a list)
- Maximum length input (long strings, large files)
- Concurrent actions (two users doing the same thing simultaneously)
- Idempotency (doing the same action twice)

### 6. Non-Functional (required per NFR)
```
Given [normal load conditions],
When [primary action],
Then the response is received in under [X ms] at the [p50/p95/p99] percentile.
```

---

## Measurable Outcomes

Outcomes must be **observable**. Use these patterns:

| Outcome Type | Good Pattern | Bad Pattern |
|-------------|-------------|-------------|
| API response | "returns HTTP 200 with `{ id, title, createdAt }` in the body" | "returns success" |
| UI change | "the submit button is disabled and shows a spinner" | "loading is shown" |
| Error message | "shows 'Title is required' below the title field" | "shows an error" |
| Data state | "the record is saved with `status: 'draft'` in the database" | "the draft is saved" |
| Redirect | "the user is redirected to `/drafts/:id`" | "the user goes to the draft" |
| Email/notification | "an email is sent to the user's address with subject 'Draft created'" | "a notification is sent" |

---

## Anti-Patterns to Avoid

| Anti-Pattern | Example | Fix |
|-------------|---------|-----|
| Vague outcome | "works correctly" | Specify the exact observable behavior |
| Missing precondition | "When user submits..." | "Given user is on X screen and is authenticated..." |
| Multiple outcomes in one | "Then A and B and C happen and D too" | Split into separate criteria |
| Implementation details | "Then the `createDraft()` function is called" | Focus on observable behavior, not code |
| Subjective language | "loads quickly" | "loads in under 200ms" |
| Negative-only | "the form does not crash" | Specify what DOES happen, not just what doesn't |

---

## Tester Agent Integration

The tester agent reads acceptance criteria directly to generate test cases. For each criterion, it creates:
- One unit or integration test per `Then` assertion
- Test data that satisfies the `Given` precondition
- An action that matches the `When` trigger

Well-written acceptance criteria = high-quality, comprehensive tests with no guessing.
