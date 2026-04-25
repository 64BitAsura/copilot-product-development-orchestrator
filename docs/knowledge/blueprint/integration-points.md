# Integration Points

> Maps every boundary where components, agents, and external services connect. Any new integration that crosses a trust boundary must be added here. The security agent reads this to trace attack surfaces; the planning agent reads this to understand side-effects of changes.

---

## Internal Integration Points (Agent-to-Agent)

### Orchestrator → Requirements Agent

| Attribute | Value |
|-----------|-------|
| Direction | Orchestrator invokes requirements-agent |
| Mechanism | Copilot `agent` tool (`@requirements-agent`) |
| Input passed | Main input text, reference input list, pipeline state path |
| Output expected | `.copilot/pipeline/requirements.md` |
| Failure behavior | Orchestrator surfaces error to user, pauses pipeline |
| Auth | Copilot session (same permissions as orchestrator) |

---

### Orchestrator → Design Agent

| Attribute | Value |
|-----------|-------|
| Direction | Orchestrator invokes design-agent |
| Mechanism | Copilot `agent` tool (`@design-agent`) |
| Input passed | Path to `.copilot/pipeline/requirements.md`, reference inputs |
| Output expected | `.copilot/pipeline/design.md` |
| Failure behavior | Orchestrator surfaces error, user can retry |

---

### Orchestrator → Planning Agent

| Attribute | Value |
|-----------|-------|
| Direction | Orchestrator invokes planning-agent |
| Mechanism | Copilot `agent` tool (`@planning-agent`) |
| Input passed | Requirements path, design path, reference repo paths |
| Output expected | `.copilot/pipeline/planning.md` |
| Failure behavior | Orchestrator surfaces error, user can retry |

---

### Orchestrator → Security Agent

| Attribute | Value |
|-----------|-------|
| Direction | Orchestrator invokes security-agent |
| Mechanism | Copilot `agent` tool (`@security-agent`) |
| Input passed | Selected planning option from `.copilot/pipeline/planning.md` |
| Output expected | `.copilot/pipeline/security.md` |
| Loop behavior | If issues found → orchestrator reinvokes planning-agent with security feedback |
| Max loops | 3 (after 3 loops, escalate to user) |

---

### Orchestrator → Coding Agent

| Attribute | Value |
|-----------|-------|
| Direction | Orchestrator invokes coding-agent |
| Mechanism | Copilot `agent` tool (`@coding-agent`) |
| Input passed | Planning path, design path, requirements path, security constraints |
| Output expected | `.copilot/pipeline/coding.md` + actual code changes in repo |
| Failure behavior | Surfaces blocker to user if coding agent cannot proceed |

---

### Coding Agent → Developer Subagents

| Attribute | Value |
|-----------|-------|
| Direction | Coding agent delegates to language-specific subagents |
| Mechanism | Copilot `agent` tool (e.g. `@python-developer`, `@typescript-developer`) |
| Input passed | Specific implementation task with context |
| Output expected | Code written to repo |
| Failure behavior | Coding agent retries with revised instructions (max 3 attempts) |

---

### Tester Agent → Coding Agent (failure loop)

| Attribute | Value |
|-----------|-------|
| Direction | Tester agent notifies orchestrator of test failures; orchestrator re-invokes coding agent |
| Mechanism | Orchestrator mediates |
| Input passed | Failed test output + test file paths |
| Output expected | Fixed code; tester re-runs |
| Max loops | 5 (after 5 loops, escalate to user) |

---

## External Integration Points

### GitHub API (via `github` MCP server)

| Attribute | Value |
|-----------|-------|
| Used by | All agents |
| Auth | Copilot session token scoped to the repository |
| Capabilities used | Read issues, PRs, comments, wiki; read file contents; list repos |
| Write capabilities | Create/update files, create PRs (coding agent via GitHub CLI) |
| Trust boundary | GitHub.com — treated as trusted source for issue content |
| Rate limits | Standard GitHub API rate limits apply |
| Failure mode | Retry with exponential backoff; surface to user after 3 failures |

---

### Web Search / Web Fetch (via `web` tool)

| Attribute | Value |
|-----------|-------|
| Used by | Requirements agent, planning agent, security agent |
| Auth | None (public web only) |
| Capabilities | Fetch URL content, search for documentation, research libraries |
| Trust boundary | **Untrusted** — content from web must never be executed; treated as read-only reference |
| Security note | Never pass web-fetched content directly into code execution |
| Failure mode | Log warning, continue without web content |

---

### Playwright MCP Server (localhost only)

| Attribute | Value |
|-----------|-------|
| Used by | Tester agent (for integration tests requiring browser) |
| Scope | Localhost only — cannot access external URLs |
| Auth | None |
| Failure mode | Skip browser-based tests; log as limitation |

---

### CLI / Shell (`execute` tool)

| Attribute | Value |
|-----------|-------|
| Used by | Coding agent, tester agent |
| Capabilities | Run build commands, test suites, linters, Docker |
| Trust boundary | Commands must be deterministic and safe — no user-supplied shell injection |
| Security note | Never interpolate untrusted input into shell commands |
| Failure mode | Surface stderr to user with context |

---

## Knowledge Harness Read/Write Map

| Document | Read by | Written / Updated by |
|----------|---------|---------------------|
| `docs/knowledge/product-vision.md` | All agents | Human (manually) |
| `docs/knowledge/requirements/*` | Requirements agent | Requirements agent (past-decisions, feature-map updates) |
| `docs/knowledge/blueprint/feature-map.md` | All agents | Requirements agent (on approval), Planning agent (on completion) |
| `docs/knowledge/blueprint/domain-model.md` | All agents | Planning agent (on schema changes) |
| `docs/knowledge/blueprint/integration-points.md` | Planning agent, Security agent | Planning agent (on new integrations) |
| `docs/knowledge/schema/*` | Planning agent, Coding agent | Planning agent (on data model changes) |
| `docs/knowledge/design-principles.md` | Design agent, Requirements agent | Human (manually) |
| `docs/knowledge/tech-stack.md` | Planning agent | Planning agent (after tech decisions) |
| `docs/knowledge/security-best-practices.md` | Security agent | Security agent (after new findings) |
| `docs/knowledge/testing-guidelines.md` | Tester agent | Tester agent (after new test patterns) |

---

## Trust Boundary Summary

```
┌─────────────────────────────────┐
│     TRUSTED ZONE                │
│  - Copilot agents               │
│  - Repository codebase          │
│  - GitHub API (authenticated)   │
│  - Pipeline state files         │
│  - Knowledge harness docs       │
└───────────────┬─────────────────┘
                │ controlled access
┌───────────────▼─────────────────┐
│     SEMI-TRUSTED ZONE           │
│  - GitHub Issues content        │
│    (user-written, sanitized)    │
│  - Referenced repositories      │
│    (read-only)                  │
└───────────────┬─────────────────┘
                │ read-only, never executed
┌───────────────▼─────────────────┐
│     UNTRUSTED ZONE              │
│  - Web search results           │
│  - External URLs                │
│  - User-provided prompts        │
│    (validated before use)       │
└─────────────────────────────────┘
```

**Rule**: Data from the untrusted zone is **read and summarized only**. It must never be:
- Executed as code
- Passed directly into shell commands
- Written to knowledge harness documents without agent review
