# Feature Map

> Complete inventory of every product feature — its current status, which domain it belongs to, what it depends on, and which requirements document governs it.
>
> **Status values**: `idea` → `planned` → `in-progress` → `shipped` → `deprecated`
>
> **Updated by**: Requirements agent (on approval), Planning agent (on completion).

---

## Feature Domains

The product is divided into these top-level domains:

| Domain | Description |
|--------|-------------|
| **Orchestration** | Core pipeline coordination between agents |
| **Input Handling** | Parsing and normalising all input types |
| **Requirements** | Requirements analysis, gap detection, approval flow |
| **Design** | UX/UI specification and design budget management |
| **Planning** | Technical architecture and implementation planning |
| **Security** | Security analysis and vulnerability remediation |
| **Coding** | Implementation coordination and subagent delegation |
| **Testing** | Test generation, execution, and coverage reporting |
| **Documentation** | API docs, changelogs, and implementation notes |
| **State Management** | Pipeline state persistence and stage transitions |
| **Knowledge Harness** | Product knowledge base maintenance |

---

## Feature Map

### Domain: Orchestration

| ID | Feature | Status | Depends On | Issue | Session |
|----|---------|--------|-----------|-------|---------|
| ORCH-01 | Multi-agent pipeline runner (sequential) | `planned` | All agents | — | — |
| ORCH-02 | User approval checkpoints (requirements, design, planning) | `planned` | ORCH-01 | — | — |
| ORCH-03 | Pipeline state persistence to `.copilot/pipeline/` | `planned` | ORCH-01 | — | — |
| ORCH-04 | Security loop: auto-retry planning on security failure | `planned` | ORCH-01, SEC-01 | — | — |
| ORCH-05 | Branching: allow user to restart from any stage | `planned` | ORCH-03 | — | — |
| ORCH-06 | Multi-session history and comparison | `idea` | ORCH-03 | — | — |

---

### Domain: Input Handling

| ID | Feature | Status | Depends On | Issue | Session |
|----|---------|--------|-----------|-------|---------|
| INP-01 | GitHub issue parsing (title, body, labels, linked PRs) | `planned` | — | — | — |
| INP-02 | Free-form text prompt parsing | `planned` | — | — | — |
| INP-03 | URL reference ingestion (fetch and summarise) | `planned` | — | — | — |
| INP-04 | Markdown / text document reference | `planned` | — | — | — |
| INP-05 | Repository reference (read codebase structure) | `planned` | — | — | — |
| INP-06 | Image reference (mockup, screenshot, diagram) | `planned` | — | — | — |
| INP-07 | Audio reference (transcription + summary) | `idea` | — | — | — |
| INP-08 | Video reference (YouTube/Loom summary) | `idea` | — | — | — |

---

### Domain: Requirements

| ID | Feature | Status | Depends On | Issue | Session |
|----|---------|--------|-----------|-------|---------|
| REQ-01 | Knowledge harness loading (product vision, features, principles) | `shipped` | — | — | — |
| REQ-02 | Gap analysis against checklist | `shipped` | REQ-01 | — | — |
| REQ-03 | Multi-option requirements generation with confidence ratings | `shipped` | REQ-01, REQ-02 | — | — |
| REQ-04 | User approval flow with revision loop | `planned` | REQ-03 | — | — |
| REQ-05 | Past-decisions cross-reference | `shipped` | REQ-01 | — | — |
| REQ-06 | Persona-based requirement framing | `shipped` | REQ-01 | — | — |
| REQ-07 | Approved-patterns matching for common feature types | `shipped` | REQ-01 | — | — |
| REQ-08 | Acceptance criteria generation (Given/When/Then) | `shipped` | REQ-03 | — | — |
| REQ-09 | Feature map update on approval | `planned` | REQ-04 | — | — |

---

### Domain: Design

| ID | Feature | Status | Depends On | Issue | Session |
|----|---------|--------|-----------|-------|---------|
| DES-01 | UX flow mapping (happy path, error, edge cases) | `planned` | REQ-04 | — | — |
| DES-02 | UI component inventory (new vs. existing) | `planned` | DES-01 | — | — |
| DES-03 | Design budget specification (UX + UI constraints) | `planned` | DES-01 | — | — |
| DES-04 | Accessibility checklist enforcement | `planned` | DES-01 | — | — |
| DES-05 | ASCII wireframe / Mermaid diagram generation | `planned` | DES-01 | — | — |
| DES-06 | Figma MCP integration for live design sync | `idea` | DES-01 | — | — |
| DES-07 | Design system alignment check | `planned` | DES-02 | — | — |

---

### Domain: Planning

| ID | Feature | Status | Depends On | Issue | Session |
|----|---------|--------|-----------|-------|---------|
| PLA-01 | Codebase analysis (architecture, patterns, deps) | `planned` | DES-03 | — | — |
| PLA-02 | Multi-option implementation planning with confidence | `planned` | PLA-01 | — | — |
| PLA-03 | Data model change specification | `planned` | PLA-02 | — | — |
| PLA-04 | API change specification (endpoints, schemas) | `planned` | PLA-02 | — | — |
| PLA-05 | Implementation sequencing (dependency-ordered steps) | `planned` | PLA-02 | — | — |
| PLA-06 | Security pre-analysis (flags for security agent) | `planned` | PLA-02 | — | — |
| PLA-07 | Design budget compliance check | `planned` | PLA-02, DES-03 | — | — |
| PLA-08 | Tech stack recommendation with web research | `planned` | PLA-01 | — | — |

---

### Domain: Security

| ID | Feature | Status | Depends On | Issue | Session |
|----|---------|--------|-----------|-------|---------|
| SEC-01 | OWASP Top 10 analysis of implementation plan | `planned` | PLA-02 | — | — |
| SEC-02 | CVE check on proposed libraries | `planned` | PLA-08 | — | — |
| SEC-03 | Trust boundary mapping | `planned` | PLA-04 | — | — |
| SEC-04 | Authentication / authorization gap detection | `planned` | PLA-04 | — | — |
| SEC-05 | Security fix recommendation with confidence | `planned` | SEC-01 | — | — |
| SEC-06 | Planning agent feedback loop (auto-retry) | `planned` | SEC-05, ORCH-04 | — | — |
| SEC-07 | Security best practices folder cross-reference | `planned` | SEC-01 | — | — |

---

### Domain: Coding

| ID | Feature | Status | Depends On | Issue | Session |
|----|---------|--------|-----------|-------|---------|
| COD-01 | Implementation plan parsing and task decomposition | `planned` | PLA-05, SEC-05 | — | — |
| COD-02 | Subagent delegation (language-specific developer agents) | `planned` | COD-01 | — | — |
| COD-03 | Code quality verification loop | `planned` | COD-02 | — | — |
| COD-04 | Full-stack implementation (API + persistence + UI) | `planned` | COD-01 | — | — |
| COD-05 | GitHub CLI integration (branch, commit, PR creation) | `planned` | COD-04 | — | — |
| COD-06 | Docker / container build verification | `planned` | COD-04 | — | — |

---

### Domain: Testing

| ID | Feature | Status | Depends On | Issue | Session |
|----|---------|--------|-----------|-------|---------|
| TST-01 | Test scenario generation from acceptance criteria | `planned` | REQ-08, COD-04 | — | — |
| TST-02 | Unit test writing via developer subagents | `planned` | TST-01 | — | — |
| TST-03 | Integration test writing via developer subagents | `planned` | TST-01 | — | — |
| TST-04 | Test execution and coverage reporting | `planned` | TST-02, TST-03 | — | — |
| TST-05 | Failure → coding agent feedback loop | `planned` | TST-04, COD-04 | — | — |
| TST-06 | Coverage threshold enforcement (≥ 80%) | `planned` | TST-04 | — | — |

---

### Domain: Documentation

| ID | Feature | Status | Depends On | Issue | Session |
|----|---------|--------|-----------|-------|---------|
| DOC-01 | OpenAPI spec update for changed endpoints | `planned` | COD-04 | — | — |
| DOC-02 | Implementation notes (what changed and why) | `planned` | COD-04 | — | — |
| DOC-03 | Breaking change detection and annotation | `planned` | PLA-04, COD-04 | — | — |
| DOC-04 | Changelog entry generation | `planned` | DOC-02, DOC-03 | — | — |
| DOC-05 | README update for new features | `planned` | COD-04 | — | — |

---

### Domain: State Management

| ID | Feature | Status | Depends On | Issue | Session |
|----|---------|--------|-----------|-------|---------|
| STT-01 | Pipeline state file (`.copilot/pipeline/state.md`) | `planned` | ORCH-01 | — | — |
| STT-02 | Per-stage output files in `.copilot/pipeline/` | `planned` | ORCH-01 | — | — |
| STT-03 | Stage transition logging | `planned` | STT-01 | — | — |
| STT-04 | User approval recording | `planned` | STT-01, ORCH-02 | — | — |

---

### Domain: Knowledge Harness

| ID | Feature | Status | Depends On | Issue | Session |
|----|---------|--------|-----------|-------|---------|
| KNW-01 | Product vision document | `shipped` | — | — | — |
| KNW-02 | Requirements folder (templates, personas, patterns) | `shipped` | — | — | — |
| KNW-03 | Blueprint folder (feature map, domain model, integration points) | `shipped` | KNW-01 | — | — |
| KNW-04 | Schema folder (base DB schema, conventions, migrations) | `shipped` | KNW-03 | — | — |
| KNW-05 | Design principles document | `planned` | — | — | — |
| KNW-06 | Tech stack document | `planned` | — | — | — |
| KNW-07 | Security best practices document | `planned` | — | — | — |
| KNW-08 | Testing guidelines document | `planned` | — | — | — |

---

## Feature Dependency Graph

```
INP-01,02 ──► REQ-01 ──► REQ-02 ──► REQ-03 ──► REQ-04 (user approval)
                                                      │
                                                      ▼
                                               DES-01 ──► DES-03 (user approval)
                                                                │
                                                                ▼
                                                         PLA-01 ──► PLA-02 ──► PLA-05 (user selection)
                                                                                    │
                                                                                    ▼
                                                                             SEC-01 ──► SEC-05
                                                                                 │          │
                                                                    loop back ◄──┘          ▼
                                                                                      COD-01 ──► COD-04
                                                                                                    │
                                                                                                    ▼
                                                                                             TST-01 ──► TST-04
                                                                                                           │
                                                                                                           ▼
                                                                                                    DOC-01 ──► DOC-04
```

---

## Adding a New Feature

When the requirements agent approves a new feature, add a row here:

```markdown
| [DOMAIN]-[N] | [Feature name] | `planned` | [Dependency IDs] | [GitHub issue URL] | [Session ID] |
```

When the coding agent completes implementation, update status to `shipped`.
