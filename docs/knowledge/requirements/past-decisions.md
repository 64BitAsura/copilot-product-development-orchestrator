# Past Decisions Log

> This is an **append-only** record of significant product and technical decisions made during pipeline runs. The refinement agent reads this to avoid re-litigating past decisions and to ensure new features stay consistent with established direction.
>
> **Never delete entries.** Mark superseded decisions with `[SUPERSEDED by #N]`.

---

## Decision Format

```markdown
## Decision #N — [Title]

**Date**: YYYY-MM-DD  
**Session ID**: <pipeline session ID>  
**Stage**: Requirements | Design | Planning | Security  
**Status**: `active` | `superseded` | `deprecated`  
**Related Issue**: <!-- GitHub issue URL if applicable -->

### Context
[Why was this decision needed?]

### Options Considered
- Option A: ...
- Option B: ...

### Decision
[What was decided and why]

### Consequences
- ✅ [Positive outcomes]
- ⚠️ [Tradeoffs accepted]

### Review Trigger
[What circumstance should prompt re-evaluating this decision?]
```

---

## Decisions

_No decisions recorded yet. Decisions will be added here after each completed pipeline session._

<!-- 
Example of a completed entry:

## Decision #1 — JWT vs Session Auth for API Authentication

**Date**: 2025-01-15
**Session ID**: session-20250115-143022
**Stage**: Planning
**Status**: `active`
**Related Issue**: https://github.com/org/repo/issues/42

### Context
The first authentication feature required choosing between stateless JWT tokens and server-side session management.

### Options Considered
- Option A: JWT with short expiry + refresh tokens — stateless, scales horizontally
- Option B: Server-side sessions with Redis store — stateful, simpler to revoke
- Option C: Third-party auth (Auth0) — fast to implement, adds vendor dependency

### Decision
Selected Option A (JWT). The API is consumed by multiple clients (web, mobile, CLI) and horizontal scaling is a priority. Refresh token rotation will be implemented to address revocation concerns.

### Consequences
- ✅ No shared session store needed; scales horizontally
- ✅ Works across web, mobile, and CLI clients uniformly
- ⚠️ Token revocation requires implementing a denylist or short expiry + refresh rotation
- ⚠️ More complex to implement correctly than sessions

### Review Trigger
If the product adds real-time features requiring server-side session awareness, or if token revocation becomes a significant security requirement.
-->
