# Tech Stack

> The canonical reference for what technologies this product uses. The planning agent reads this before recommending any implementation approach. Any new technology added to the stack must be recorded here.
>
> **Updated by**: Planning agent after tech decisions are made and approved.

---

## Current Stack

> This document is pre-populated with sensible defaults for a modern full-stack TypeScript project. Replace or extend based on what is actually used in the codebase.

---

### Language

| Layer | Language | Version |
|-------|---------|---------|
| Backend | TypeScript | 5.x |
| Frontend | TypeScript | 5.x |
| Schema documentation | Markdown | — |
| Infrastructure | YAML (GitHub Actions) | — |

---

### Backend

| Category | Technology | Version | Notes |
|----------|-----------|---------|-------|
| Runtime | Node.js | 20 LTS | |
| Framework | — | — | To be selected per feature |
| HTTP | Express / Fastify / Hono | — | To be selected per feature |
| ORM / Query Builder | — | — | To be selected per feature |
| Authentication | JWT (jsonwebtoken) | — | |
| Validation | Zod | — | Schema-first validation |
| API Documentation | OpenAPI 3.1 | — | Spec-first approach |
| Background Jobs | — | — | To be selected per feature |

---

### Frontend

| Category | Technology | Version | Notes |
|----------|-----------|---------|-------|
| Framework | — | — | To be selected per feature |
| Styling | — | — | To be selected per feature |
| State Management | — | — | To be selected per feature |
| HTTP Client | fetch (native) | — | No axios unless justified |
| Forms | — | — | To be selected per feature |

---

### Database

| Category | Technology | Version | Notes |
|----------|-----------|---------|-------|
| Primary datastore | _(to be decided)_ | — | Choose the right DB for your product's access patterns |
| Cache | _(to be decided)_ | — | |
| Search index | _(to be decided)_ | — | |
| Schema change tracking | Markdown change records | — | See `docs/knowledge/schema/migrations-guide.md` |

---

### Infrastructure

| Category | Technology | Notes |
|----------|-----------|-------|
| CI/CD | GitHub Actions | |
| Containerisation | Docker | Minimal base images |
| Secret management | GitHub Actions secrets + `copilot` environment | |
| Agent environment | GitHub Copilot cloud agent | Ubuntu x64 |

---

### Testing

| Category | Technology | Notes |
|----------|-----------|-------|
| Test runner | — | To be selected per project type |
| Coverage | — | Minimum 80% on new code |
| Mocking | — | To be selected per feature |

---

### Agent Tools (MCP)

| Server | Tools Used | Notes |
|--------|-----------|-------|
| `github` | Read issues, PRs, files, repos | Read-only by default |
| `playwright` | Browser automation | Localhost only |

---

## Technology Decision Rules

When the planning agent considers adding a new technology:

1. **Prefer existing technologies.** If the current stack can solve the problem, use it.
2. **Justify new dependencies.** New packages require: a reason, the specific version, and a CVE check via the security agent.
3. **No abandoned packages.** Any dependency not maintained in the past 12 months requires explicit justification.
4. **Check licence compatibility.** All dependencies must be MIT, Apache 2.0, BSD, or ISC licensed (or explicitly approved).
5. **Record all tech decisions here** and in `docs/knowledge/requirements/past-decisions.md`.

---

## Adding a Technology

When a new technology is adopted, add it here:

```markdown
| [Category] | [Technology] | [Version] | [Notes / why chosen] |
```

And add the decision rationale to `docs/knowledge/requirements/past-decisions.md`.
