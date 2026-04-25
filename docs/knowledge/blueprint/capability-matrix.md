# Capability Matrix

> Maps every product capability to the agent responsible for it. Use this to answer: **"Which agent owns this?"**

---

## How to Read This

- **Owner**: The agent primarily responsible for this capability. Its output is the authoritative source.
- **Contributor**: An agent that provides input to or reads from this capability.
- **Consumer**: An agent that reads this output to do its own work.

---

## Capability → Agent Mapping

### Input & Initialization

| Capability | Owner | Contributors | Consumers |
|-----------|-------|-------------|----------|
| Parse GitHub issue | Orchestrator | — | Requirements |
| Parse free-form prompt | Orchestrator | — | Requirements |
| Fetch URL references | Orchestrator | — | Requirements, Planning |
| Read document references | Orchestrator | — | Requirements, Design |
| Read repository references | Orchestrator | Planning | Coding |
| Initialise pipeline state file | Orchestrator | — | All agents |
| Manage stage transitions | Orchestrator | — | All agents |
| User approval checkpoints | Orchestrator | — | — |

---

### Requirements

| Capability | Owner | Contributors | Consumers |
|-----------|-------|-------------|----------|
| Load knowledge harness | Requirements | — | Requirements |
| Gap analysis | Requirements | — | Orchestrator (pauses on gaps) |
| Generate requirement options | Requirements | — | User, Orchestrator |
| Write acceptance criteria | Requirements | — | Tester |
| Update past decisions log | Requirements | — | Future sessions |
| Update feature map (planned) | Requirements | — | All agents |
| Frame requirements by persona | Requirements | — | Design, Planning |

---

### Design

| Capability | Owner | Contributors | Consumers |
|-----------|-------|-------------|----------|
| Map UX flows | Design | — | Planning, Coding |
| Inventory UI components | Design | — | Coding |
| Set design budgets (UX/UI) | Design | — | Planning (must comply) |
| Accessibility checklist | Design | — | Coding, Tester |
| Generate wireframes / diagrams | Design | — | Planning, Coding |
| Design system alignment | Design | Requirements | Coding |

---

### Planning

| Capability | Owner | Contributors | Consumers |
|-----------|-------|-------------|----------|
| Analyse existing codebase | Planning | — | Planning |
| Define implementation options | Planning | Design (budgets) | User, Orchestrator |
| Specify data model changes | Planning | — | Coding, Schema |
| Specify API changes | Planning | — | Coding, Documentation |
| Sequence implementation steps | Planning | — | Coding |
| Tech stack recommendation | Planning | — | Coding |
| Security pre-analysis flags | Planning | — | Security |
| Update tech stack document | Planning | — | Future sessions |

---

### Security

| Capability | Owner | Contributors | Consumers |
|-----------|-------|-------------|----------|
| OWASP Top 10 analysis | Security | Planning (flags) | Orchestrator |
| CVE check on libraries | Security | Planning (lib list) | Orchestrator |
| Trust boundary analysis | Security | blueprint/integration-points | Orchestrator |
| Auth/authz gap detection | Security | Planning | Orchestrator |
| Fix recommendations | Security | — | Planning (on loop), Coding |
| Update security best practices | Security | — | Future sessions |

---

### Coding

| Capability | Owner | Contributors | Consumers |
|-----------|-------|-------------|----------|
| Task decomposition from plan | Coding | — | Subagents |
| Delegate to language subagents | Coding | — | — |
| Verify subagent code quality | Coding | — | Tester |
| API implementation | Coding | Planning (spec) | Tester, Documentation |
| Persistence layer implementation | Coding | Planning (schema) | Tester |
| UI implementation | Coding | Design (spec) | Tester |
| Create PR / commit changes | Coding | — | Orchestrator |
| Fix test failures (loop) | Coding | Tester (failures) | Tester |

---

### Testing

| Capability | Owner | Contributors | Consumers |
|-----------|-------|-------------|----------|
| Generate test scenarios | Tester | Requirements (AC) | Tester |
| Write unit tests | Tester | Developer subagents | Tester |
| Write integration tests | Tester | Developer subagents | Tester |
| Run tests + coverage report | Tester | — | Orchestrator, Documentation |
| Enforce coverage threshold | Tester | — | Orchestrator |
| Notify on test failure | Tester | — | Orchestrator → Coding |

---

### Documentation

| Capability | Owner | Contributors | Consumers |
|-----------|-------|-------------|----------|
| Update OpenAPI spec | Documentation | Coding (API changes) | — |
| Write implementation notes | Documentation | Coding, Planning | — |
| Detect breaking changes | Documentation | Planning (API spec diff) | Git commit message |
| Generate changelog entry | Documentation | All stage outputs | — |
| Update README for new features | Documentation | Requirements | — |

---

## Agent Responsibility Boundaries

**Hard rules — never cross these:**

| Rule | Rationale |
|------|----------|
| Only **Planning** defines the implementation approach | Prevents coding agent from making unchecked architecture decisions |
| Only **Requirements** updates the knowledge harness requirements folder | Keeps requirements docs authoritative |
| Only **Security** decides if an implementation is safe to build | Prevents planning or coding agents from self-approving security |
| Only **Tester** writes tests | Prevents coding agent from writing tests that pass its own bugs |
| Only **Documentation** updates API docs | Prevents coding agent from documenting what it wishes it had built |
| **Orchestrator** is the only agent that transitions pipeline state | Prevents agents from autonomously skipping stages |
