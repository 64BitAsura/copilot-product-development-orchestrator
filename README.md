# copilot-product-development-orchestrator

> Transform a GitHub issue into production-ready code — with the judgment of a full product development team — using only GitHub Copilot custom agents.

---

## What Is This?

This repository defines a **multi-agent product development pipeline** built on [GitHub Copilot custom agents](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/create-custom-agents). Each agent is a specialist in one stage of software development. The orchestrator coordinates them in sequence.

  Main product development orchestrator. Receives GitHub issues or prompt requests (with optional
  reference inputs: images, docs, videos, URLs, audio, repos) and drives the full pipeline through
  the requirements → design → planning → performance → security → coding → linting → testing →
  documentation → build → local-deployment → e2e + design-review (parallel) → back-tracker agents.

```
GitHub Issue / Prompt
        │
        ▼
┌─────────────────┐
│  Orchestrator   │  ← your entry point
└────────┬────────┘
         │
         ▼
┌─────────────────┐     gaps?
│  Requirements   │────────────► user (pause & ask)
└────────┬────────┘
         │ approved
         ▼
┌─────────────────┐
│     Design      │────────────► user (approve/revise)
└────────┬────────┘
         │ approved
         ▼
┌─────────────────┐
│    Planning     │────────────► user (select option)
└────────┬────────┘
         │ option selected
         ▼
┌─────────────────┐     medium/critical?
│  Performance    │────────────► user (pause & select fix)
└────────┬────────┘     minor → Planning (auto-adjust)
         │ cleared
         ▼
┌─────────────────┐     issues?
│    Security     │────────────► Planning (auto-loop, max 3×)
└────────┬────────┘
         │ cleared
         ▼
┌─────────────────┐
│     Coding      │  (delegates to language subagents)
└────────┬────────┘
         │
         ▼
┌─────────────────┐     unfixable issues?
│    Linting      │────────────► Coding (auto-loop until clean)
└────────┬────────┘
         │ clean
         ▼
┌─────────────────┐     failures?
│     Testing     │────────────► Coding (auto-loop, max 5×)
└────────┬────────┘
         │ all tests pass
         ▼
┌─────────────────┐
│  Documentation  │  (OpenAPI, changelog, impl notes)
└────────┬────────┘
         │
         ▼
┌─────────────────┐     first run?
│     Build       │────────────► user (approve strategy)
└────────┬────────┘
         │ artifacts ready
         ▼
┌─────────────────┐     first run?
│ Local Deployment│────────────► user (approve strategy)
└────────┬────────┘
         │ all services healthy
    ┌────┴────────────────────────────┐
    ▼                                 ▼
┌─────────────────┐     ┌─────────────────────┐
│   E2E Agent     │     │   Design Review     │  (parallel)
└────────┬────────┘     └──────────┬──────────┘
    gaps → re-trigger         fails → coding loop
         │ all AC satisfied        │ all DAC passed
         └───────────┬─────────────┘
                     ▼
┌─────────────────┐     medium/show-stopper deviation?
│  Back Tracker   │────────────► user (guidance required)
└────────┬────────┘     minor → auto-loop (max 3×)
         │ approved
         ▼
      Pull Request
```

---

## Quick Start

> **This is a template repository.** Use it as the foundation for your product. The steps below explain how to set it up.

### 1. Use this template

Click **Use this template → Create a new repository** to create your own product repository from this template.

### 2. Fill in the knowledge harness

The `docs/knowledge/` folder is where you describe **your product**. Agents read these files to understand what they are building. Fill them in before running the pipeline for the first time:

| File | What to put in it |
|------|------------------|
| `docs/knowledge/product-vision.md` | Your product's purpose, target users, problems solved, success metrics |
| `docs/knowledge/key-features.md` | Every feature your product has or plans to have |
| `docs/knowledge/design.md` | Your product design system — colour tokens, typography, spacing, components, and patterns |
| `docs/knowledge/requirements/personas.md` | The people who use your product |
| `docs/knowledge/blueprint/feature-map.md` | Full feature inventory with IDs, statuses, and dependencies |
| `docs/knowledge/blueprint/domain-model.md` | Your core entities, their relationships, and ubiquitous language |
| `docs/knowledge/blueprint/integration-points.md` | All external services your product connects to |
| `docs/knowledge/blueprint/capability-matrix.md` | Which module/service owns each product capability |
| `docs/knowledge/schema/base-schema.sql` | Your PostgreSQL database schema (starter tables are provided) |

The other files (`design-principles.md`, `tech-stack.md`, `security-best-practices.md`, `testing-guidelines.md`) contain sensible defaults — update them to match your stack.

### 3. Run the pipeline

Open a GitHub issue describing the feature or change you want to build, assign it to Copilot, and select the **`orchestrator`** agent:

```
@orchestrator Build a user authentication feature. Reference: https://github.com/myorg/myapi
```

The orchestrator pauses at approval checkpoints and opens a PR when complete.

---

## Agents

| Agent | File | Role |
|-------|------|------|
| **Orchestrator** | `.github/agents/orchestrator.agent.md` | Coordinates the full pipeline, manages approvals and loops |
| **Requirements** | `.github/agents/requirements-agent.agent.md` | Analyses inputs, detects gaps, produces options with confidence ratings |
| **Design** | `.github/agents/design-agent.agent.md` | UX flows, UI components, design budgets, accessibility |
| **Planning** | `.github/agents/planning-agent.agent.md` | Architecture, data model, API spec, implementation sequence |
| **Performance** | `.github/agents/performance-agent.agent.md` | Vets the plan for compute/memory/network/DB/concurrency bottlenecks; escalates medium/critical issues to human |
| **Security** | `.github/agents/security-agent.agent.md` | OWASP Top 10, CVE checks, trust boundaries, fix recommendations |
| **Coding** | `.github/agents/coding-agent.agent.md` | Full-stack implementation via language-specific subagents |
| **Linting** | `.github/agents/linting-agent.agent.md` | Runs project lint/format tools, auto-fixes issues, delegates unfixable violations to coding agent |
| **Tester** | `.github/agents/tester-agent.agent.md` | Unit + integration tests, ≥80% coverage, failure loop with coding |
| **Documentation** | `.github/agents/documentation-agent.agent.md` | OpenAPI spec, changelog, implementation notes, breaking changes |
| **Build** | `.github/agents/build-agent.agent.md` | Produces cacheable, composable artifacts; first run requires human strategy approval |
| **Local Deployment** | `.github/agents/local-deployment-agent.agent.md` | Deploys artifacts locally using emulators; first run requires human strategy approval |
| **E2E** | `.github/agents/e2e-agent.agent.md` | Verifies the running deployment satisfies every acceptance criterion end-to-end; loops back through the pipeline when gaps are found |
| **Design Review** | `.github/agents/design-review-agent.agent.md` | Verifies the running deployment faithfully implements every Design DAC; runs in parallel with the E2E agent; loops with coding on failures, escalates to human after 3 unresolved DACs |
| **Back Tracker** | `.github/agents/back-tracker-agent.agent.md` | Final alignment gate — compares code changes and E2E results against original requirements; auto-routes minor deviations, escalates medium/show-stopper to human |

---

## Agent Knowledge Requirements

Each agent reads specific files from `docs/knowledge/` on every pipeline run. The table below shows which files each agent depends on and why.

### Requirements Agent
| File | Why |
|------|-----|
| `product-vision.md` | Understand purpose, users, and success metrics |
| `key-features.md` | Know what already exists to avoid duplicates |
| `requirements/personas.md` | Identify which users are affected |
| `requirements/gap-analysis-checklist.md` | Structured checklist for finding missing info |
| `requirements/requirement-template.md` | Output format to follow |
| `requirements/acceptance-criteria-guide.md` | How to write acceptance criteria |
| `requirements/approved-patterns.md` | Patterns already approved in past sessions |
| `requirements/past-decisions.md` | Architectural/product decisions to stay consistent |
| `blueprint/feature-map.md` | Existing feature landscape and dependencies |

### Design Agent
| File | Why |
|------|-----|
| `design.md` | Product design system — tokens, components, and patterns that all UI/UX work must follow |
| `product-vision.md` | Align designs with product goals |
| `key-features.md` | Design must cover all relevant features |
| `design-principles.md` | Supplementary UX/UI principles (philosophy and guidelines, not design tokens) |
| `requirements/personas.md` | Design for the right users |
| `blueprint/feature-map.md` | Understand how features relate |

### Planning Agent
| File | Why |
|------|-----|
| `product-vision.md` | Understand what is being built |
| `key-features.md` | Know the feature surface |
| `tech-stack.md` | Stay within the chosen technology choices |
| `blueprint/feature-map.md` | Sequence work without breaking existing features |
| `blueprint/domain-model.md` | Model entities and aggregates correctly |
| `blueprint/integration-points.md` | Know what external services are involved |
| `blueprint/capability-matrix.md` | Assign responsibilities to the right module/service |
| `schema/base-schema.sql` | Understand the existing data model |
| `schema/erd.md` | Visualise entity relationships |
| `schema/schema-conventions.md` | Follow naming and design patterns |
| `requirements/past-decisions.md` | Respect historical architectural decisions |

### Security Agent
| File | Why |
|------|-----|
| `tech-stack.md` | Know which libraries/frameworks to audit |
| `security-best-practices.md` | Apply and extend the product's security rules |
| `blueprint/integration-points.md` | Identify trust boundaries at external connections |
| `blueprint/domain-model.md` | Find sensitive entities needing access control |
| `schema/base-schema.sql` | Check for insecure schema patterns |

### Coding Agent
| File | Why |
|------|-----|
| `tech-stack.md` | Use the right languages, frameworks, and tooling |
| `blueprint/domain-model.md` | Map code to domain entities correctly |
| `blueprint/integration-points.md` | Implement integrations to the right external services |
| `blueprint/capability-matrix.md` | Put code in the right module/service |
| `schema/base-schema.sql` | Write queries/ORM models matching the real schema |
| `schema/schema-conventions.md` | Follow naming and design conventions |
| `schema/migrations-guide.md` | Write proper migrations when changing the schema |
| `security-best-practices.md` | Implement secure patterns from the start |
| `requirements/approved-patterns.md` | Reuse approved patterns instead of inventing new ones |

### Tester Agent
| File | Why |
|------|-----|
| `testing-guidelines.md` | Follow the project's test standards and coverage thresholds |
| `tech-stack.md` | Use the correct test frameworks |
| `blueprint/domain-model.md` | Write tests that reflect real business rules |
| `schema/base-schema.sql` | Set up correct fixtures and seed data |
| `requirements/acceptance-criteria-guide.md` | Derive test cases from acceptance criteria |

### Documentation Agent
| File | Why |
|------|-----|
| `product-vision.md` | Frame documentation in product context |
| `key-features.md` | Document all relevant features |
| `blueprint/integration-points.md` | Document external API contracts |
| `requirements/past-decisions.md` | Note breaking changes relative to past decisions |
| `tech-stack.md` | Reference correct tech in implementation notes |

### Performance Agent
| File | Why |
|------|-----|
| `tech-stack.md` | Understand the runtime, frameworks, and their known performance characteristics |
| `blueprint/integration-points.md` | Identify external calls that add network latency or introduce rate-limit ceilings |
| `blueprint/domain-model.md` | Understand data volume, cardinality, and access patterns for DB bottleneck analysis |
| `blueprint/feature-map.md` | Cross-check planned work against the existing feature backlog for compound load |

### Linting Agent
| File | Why |
|------|-----|
| `tech-stack.md` | Identify which languages and package managers are in use to discover the correct lint/format commands |

### Build Agent
| File | Why |
|------|-----|
| `tech-stack.md` | Determine languages, runtimes, and package managers to select the right build toolchain |

### Local Deployment Agent
| File | Why |
|------|-----|
| `tech-stack.md` | Understand the runtime stack to choose correct base images and emulators |
| `blueprint/integration-points.md` | Identify every cloud service that needs a local emulator substitute |

### E2E Agent
| File | Why |
|------|-----|
| `testing-guidelines.md` | Follow project test standards and any existing E2E conventions |
| `blueprint/integration-points.md` | Know which external integrations need to be exercised in E2E flows |

### Back Tracker Agent
| File | Why |
|------|-----|
| `product-vision.md` | Validate implementation against the product's core purpose and success metrics |
| `key-features.md` | Ensure no existing feature was broken and the new feature fits the product |
| `blueprint/feature-map.md` | Check interactions with existing features and confirm no regressions |
| `requirements/past-decisions.md` | Confirm the implementation respects historical architectural decisions |

### Design Review Agent
| File | Why |
|------|-----|
| `design.md` | Authoritative design system reference for verifying that the implementation matches tokens, components, and patterns |

### Summary Matrix

| Knowledge File | Req | Design | Plan | Perf | Sec | Code | Lint | Test | Docs | Build | Deploy | E2E | DrRev | BackTrack |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `product-vision.md` | ✅ | ✅ | ✅ | | | | | | ✅ | | | | | ✅ |
| `key-features.md` | ✅ | ✅ | ✅ | | | | | | ✅ | | | | | ✅ |
| `design.md` | | ✅ | | | | | | | | | | | ✅ | |
| `design-principles.md` | | ✅ | | | | | | | | | | | | |
| `tech-stack.md` | | | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | | | |
| `security-best-practices.md` | | | | | ✅ | ✅ | | | | | | | | |
| `testing-guidelines.md` | | | | | | | | ✅ | | | | ✅ | | |
| `requirements/personas.md` | ✅ | ✅ | | | | | | | | | | | | |
| `requirements/gap-analysis-checklist.md` | ✅ | | | | | | | | | | | | | |
| `requirements/requirement-template.md` | ✅ | | | | | | | | | | | | | |
| `requirements/acceptance-criteria-guide.md` | ✅ | | | | | | | ✅ | | | | | | |
| `requirements/approved-patterns.md` | ✅ | | | | | ✅ | | | | | | | | |
| `requirements/past-decisions.md` | ✅ | | ✅ | | | | | | ✅ | | | | | ✅ |
| `blueprint/feature-map.md` | ✅ | ✅ | ✅ | ✅ | | | | | | | | | | ✅ |
| `blueprint/domain-model.md` | | | ✅ | ✅ | ✅ | ✅ | | ✅ | | | | | | |
| `blueprint/integration-points.md` | | | ✅ | ✅ | ✅ | ✅ | | | ✅ | | ✅ | ✅ | | |
| `blueprint/capability-matrix.md` | | | ✅ | | | ✅ | | | | | | | | |
| `schema/base-schema.sql` | | | ✅ | | ✅ | ✅ | | ✅ | | | | | | |
| `schema/erd.md` | | | ✅ | | | | | | | | | | | |
| `schema/schema-conventions.md` | | | ✅ | | | ✅ | | | | | | | | |
| `schema/migrations-guide.md` | | | | | | ✅ | | | | | | | | |

---

## Knowledge Harness

`docs/knowledge/` is **your product's brain** — not documentation about this orchestrator. Fill it in with information about the product you are building. Agents read these files on every pipeline run to stay aligned with your product's purpose, existing features, design constraints, and technical decisions.

```
docs/knowledge/
├── product-vision.md          # ✏️ YOUR product's purpose, users, and success metrics
├── key-features.md            # ✏️ YOUR product's feature inventory
├── design-principles.md       # UX/UI rules (sensible defaults — update to match your product)
├── design.md                  # ✏️ YOUR product design system (required for UI/UX work)
├── tech-stack.md              # ✏️ YOUR technology choices
├── security-best-practices.md # Security patterns (agents append findings here)
├── testing-guidelines.md      # Test standards (agents append framework patterns here)
│
├── requirements/              # Requirements agent's knowledge base
│   ├── README.md
│   ├── requirement-template.md
│   ├── gap-analysis-checklist.md
│   ├── acceptance-criteria-guide.md
│   ├── personas.md            # ✏️ YOUR product's user personas
│   ├── approved-patterns.md
│   └── past-decisions.md      # Append-only log — agents write here after each session
│
├── blueprint/                 # How YOUR product's features tie together
│   ├── README.md
│   ├── feature-map.md         # ✏️ YOUR features, statuses, dependencies
│   ├── domain-model.md        # ✏️ YOUR entities, aggregates, ubiquitous language
│   ├── integration-points.md  # ✏️ YOUR external service integrations
│   └── capability-matrix.md   # ✏️ Which module/service owns each capability
│
└── schema/                    # YOUR product's database schema
    ├── README.md
    ├── base-schema.sql        # ✏️ YOUR PostgreSQL schema (starter tables provided)
    ├── erd.md                 # ✏️ YOUR Entity Relationship Diagram
    ├── schema-conventions.md  # Naming rules and design patterns
    ├── migrations-guide.md    # How to write and run migrations
    └── migrations/            # Incremental migration files (one per schema change)
```

> **✏️** = files you must fill in before running the pipeline for the first time.

---

## Pipeline State

During a pipeline run, each agent writes its output to `.copilot/pipeline/` in the repository:

```
.copilot/pipeline/
├── state.md                     # Current stage, status, session ID
├── requirements.md              # Requirements agent output
├── design.md                    # Design agent output
├── design-ac.md                 # Design acceptance criteria (verified by design-review-agent)
├── planning.md                  # Planning agent output
├── performance.md               # Performance agent output (bottleneck findings)
├── security.md                  # Security agent output
├── coding.md                    # Coding agent implementation report
├── linting.md                   # Linting agent report (issues fixed, loops completed)
├── testing.md                   # Tester agent report (coverage, failures)
├── documentation.md             # Documentation agent report
├── build.md                     # Build agent report (artifact inventory, sizes)
├── local-deployment.md          # Local deployment agent report (running services)
├── e2e-testing.md               # E2E agent test results (scenario outcomes, gaps found)
├── design-review.md             # Design Review agent report (DAC pass/fail evidence)
├── back-tracker.md              # Back Tracker agent report (requirements coverage verdict)
│
│   ── Persistent memory (survive across pipeline sessions) ──
├── build-strategy.md            # Approved build strategy — reused on every subsequent build
├── local-deployment-strategy.md # Approved deployment strategy — reused on every subsequent deploy
└── e2e-test-plan.md             # Approved E2E test plan — extended on every subsequent run
```

> **Persistent memory files** (`build-strategy.md`, `local-deployment-strategy.md`, and `e2e-test-plan.md`) are written once when the human approves the strategy/plan on the first run. On all subsequent pipeline runs the relevant agents read these files directly and build on them without re-asking for approval — unless the architecture or requirements change significantly enough to warrant a new strategy.

---

## Environment Setup

Secrets and environment variables for agents are set in the `copilot` GitHub Actions environment in your repository settings. See [Setting environment variables in Copilot's environment](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/customize-the-agent-environment#setting-environment-variables-in-copilots-environment).

The `.github/workflows/copilot-setup-steps.yml` pre-installs Node.js, Python, PostgreSQL client tools, Docker, and the GitHub CLI for all agent runs.

---

## Contributing

See the [blueprint](docs/knowledge/blueprint/README.md) for how features are planned and [past-decisions](docs/knowledge/requirements/past-decisions.md) for architectural history.
