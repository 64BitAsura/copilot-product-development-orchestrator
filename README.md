# copilot-product-development-orchestrator

> Transform a GitHub issue into production-ready code — with the judgment of a full product development team — using only GitHub Copilot custom agents.

---

## What Is This?

This repository defines a **multi-agent product development pipeline** built on [GitHub Copilot custom agents](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/create-custom-agents). Each agent is a specialist in one stage of software development. The orchestrator coordinates them in an optimised sequence with parallel stages where possible.

  Main product development orchestrator. Receives GitHub issues or prompt requests (with optional
  reference inputs: images, docs, videos, URLs, audio, repos) and drives the full pipeline through
  requirements → design → planning → performance+security (parallel) → coding → linting → testing →
  review → documentation → build → local-deployment → e2e + design-review + back-tracker-phase-1
  (parallel) → back-tracker-phase-2 → pull request.

```
GitHub Issue / Prompt
        │
        ▼
┌─────────────────┐   fast-lane classification
│  Orchestrator   │────────────► (full / backend / hotfix / config)
└────────┬────────┘
         │
         ▼
┌─────────────────┐     gaps?
│  Refinement   │────────────► user (pause & ask)
└────────┬────────┘
         │ approved
         ▼
┌─────────────────┐
│     Design      │────────────► user (approve/revise)   ← skipped on backend/hotfix/config lanes
└────────┬────────┘
         │ approved
         ▼
┌─────────────────┐
│    Planning     │────────────► user (select option)
└────────┬────────┘
         │ option selected
         ▼
┌───────────────────────────────────────┐
│  Performance + Security  (parallel)   │  ← both analyze planning.md simultaneously
│  - minor perf → Planning (auto-adjust)│
│  - medium/critical perf → user        │
│  - security BLOCKED → Planning loop   │────────────► user (security approval)
└──────────────────┬────────────────────┘
                   │ both cleared
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
┌─────────────────┐     route?
│     Review      │────────────► Planning or Coding (CRAP-guided loop)
└────────┬────────┘
         │ approved
         ▼
┌─────────────────┐           ┌─────────────────┐
│  Documentation  │           │     Build       │────────────► user (approve strategy, first run)
│  (can overlap   │           └────────┬────────┘
│   with Build)   │                    │ artifacts ready
└─────────────────┘                    ▼
                          ┌─────────────────────┐     first run?
                          │  Local Deployment   │────────────► user (approve strategy)
                          └──────────┬──────────┘
                                     │ all services healthy
                    ┌────────────────┴──────────────────┬────────────────────────┐
                    ▼                                    ▼                        ▼
            ┌─────────────┐            ┌───────────────────┐   ┌──────────────────────┐
            │  E2E Agent  │            │  Design Review    │   │  Back Tracker        │  (parallel)
            │             │            │  (skipped on non- │   │  Phase 1 (code only) │
            └──────┬──────┘            │   UI lanes)       │   └──────────┬───────────┘
     gaps→re-trigger        fails→coding loop              code findings buffered
            │ all AC pass              │ all DAC pass                     │ analysis done
            └──────────────────────────┴──────────────────────────────────┘
                                       ▼
                       ┌──────────────────────────┐   medium/show-stopper?
                       │  Back Tracker Phase 2    │────────────► user (guidance)
                       │  (final verdict)         │   minor → auto-loop (max 3×)
                       └──────────────┬───────────┘
                                      │ approved
                                      ▼
                                 Pull Request
```

---

## Quick Start

> **This is a template repository.** Use it as the foundation for your product. The steps below explain how to set it up.

### 1. Use this template

Click **Use this template → Create a new repository** to create your own product repository from this template.

### 2. Build the knowledge harness

The `docs/knowledge/` folder is where you describe **your product**. Agents read these files to understand what they are building. You have two options:

#### Option A — Bootstrap Agent (recommended)

Run the **`bootstrap-agent`** once. It will:
- Detect whether this is an existing codebase or a new project.
- For existing repos: scan the code and extract as much knowledge as possible automatically.
- Ask only the questions it cannot answer from the code.
- Write every knowledge document for you.
- Create a tech-stack-aware CRAP tool config for the review stage.
- Optionally move the knowledge folder to any path you choose (and update all agent references automatically).

```
@bootstrap-agent Set up the knowledge harness for this repository.
```

#### Option B — Fill in manually

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
| `docs/knowledge/schema/schema.md` | Your data model — entities, fields, relationships, and access patterns (database-agnostic) |

The other files (`design-principles.md`, `tech-stack.md`, `security-best-practices.md`, `testing-guidelines.md`) contain sensible defaults — update them to match your stack.

### 3. Run the pipeline

Open a GitHub issue describing the feature or change you want to build, assign it to Copilot, and select the **`orchestrator`** agent:

```
@orchestrator Build a user authentication feature. Reference: https://github.com/myorg/myapi
```

The orchestrator pauses at approval checkpoints and opens a PR when complete.

---

## Agents

| Agent | File | Role | Stage |
|-------|------|------|-------|
| **Bootstrap** | `.github/agents/bootstrap-agent.agent.md` | Builds the `docs/knowledge/` harness — scans existing code or interviews you for a new project, writes all knowledge files, and optionally updates agent folder-path references to a custom location | Pre-pipeline (run once on setup) |
| **Orchestrator** | `.github/agents/orchestrator.agent.md` | Coordinates the pipeline, applies fast-lane rules, manages all approvals and loops | Entry point |
| **Refinement** | `.github/agents/refinement-agent.agent.md` | Analyses inputs, detects gaps, produces a refined unambiguous ticket | 1 |
| **Design** | `.github/agents/design-agent.agent.md` | UX flows, UI components, design budgets, accessibility — skipped on non-UI lanes | 2 |
| **Planning** | `.github/agents/planning-agent.agent.md` | Architecture, data model, API spec, implementation sequence | 3 |
| **Performance** | `.github/agents/performance-agent.agent.md` | Vets plan for compute/memory/network/DB/concurrency bottlenecks; escalates medium/critical to human | 4 (parallel with Security) |
| **Security** | `.github/agents/security-agent.agent.md` | OWASP Top 10, CVE checks, trust boundaries, fix recommendations | 4 (parallel with Performance) |
| **Coding** | `.github/agents/coding-agent.agent.md` | Full-stack implementation via language-specific subagents | 5 |
| **Linting** | `.github/agents/linting-agent.agent.md` | Runs project lint/format tools, auto-fixes issues, delegates unfixable violations to coding agent | 6 |
| **Tester** | `.github/agents/tester-agent.agent.md` | Unit + integration tests, ≥80% coverage, failure loop with coding | 7 |
| **Review** | `.github/agents/review-agent.agent.md` | GitHub Copilot-style review gate that uses the CRAP tool to route issues back to coding or planning | 8 |
| **Documentation** | `.github/agents/documentation-agent.agent.md` | OpenAPI spec, changelog, implementation notes, breaking changes | 9 (can overlap Build) |
| **Build** | `.github/agents/build-agent.agent.md` | Produces cacheable, composable artifacts; first run requires human strategy approval | 10 |
| **Local Deployment** | `.github/agents/local-deployment-agent.agent.md` | Deploys artifacts locally using emulators; first run requires human strategy approval | 11 |
| **E2E** | `.github/agents/e2e-agent.agent.md` | Verifies the running deployment satisfies every acceptance criterion end-to-end | 12 (parallel) |
| **Design Review** | `.github/agents/design-review-agent.agent.md` | Verifies the running deployment implements every Design DAC; skipped on non-UI lanes | 12 (parallel, UI lanes only) |
| **Back Tracker** | `.github/agents/back-tracker-agent.agent.md` | Two-phase final gate — Phase 1 code analysis runs in parallel with E2E; Phase 2 combines all results | 12 Phase 1 (parallel) → 13 Phase 2 |

---

## Agent Knowledge Requirements

Each agent reads specific files from `docs/knowledge/` on every pipeline run. The table below shows which files each agent depends on and why.

### Refinement Agent
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
| `schema/schema.md` | Understand the existing data model |
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
| `schema/schema.md` | Check for insecure data model patterns |

### Coding Agent
| File | Why |
|------|-----|
| `tech-stack.md` | Use the right languages, frameworks, and tooling |
| `blueprint/domain-model.md` | Map code to domain entities correctly |
| `blueprint/integration-points.md` | Implement integrations to the right external services |
| `blueprint/capability-matrix.md` | Put code in the right module/service |
| `schema/schema.md` | Write queries/ORM models matching the real data model |
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
| `schema/schema.md` | Set up correct fixtures and seed data |
| `requirements/acceptance-criteria-guide.md` | Derive test cases from acceptance criteria |

### Review Agent
| File | Why |
|------|-----|
| `tech-stack.md` | Select the correct CRAP adapter and review expectations |
| `blueprint/integration-points.md` | Spot integration and change-surface risk |
| `security-best-practices.md` | Confirm risky changes still respect the security model |
| `testing-guidelines.md` | Judge whether the executed tests match the project standard |

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

| Knowledge File | Rfn | Design | Plan | Perf | Sec | Code | Lint | Test | Docs | Build | Deploy | E2E | DrRev | BackTrack |
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
| `schema/schema.md` | | | ✅ | | ✅ | ✅ | | ✅ | | | | | | |
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
├── requirements/              # Refinement agent's knowledge base
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
└── schema/                    # YOUR product's data model
    ├── README.md
    ├── schema.md              # ✏️ YOUR entities, fields, relationships (database-agnostic)
    ├── erd.md                 # ✏️ YOUR Entity Relationship Diagram
    ├── schema-conventions.md  # Naming rules and design patterns
    ├── migrations-guide.md    # How to document and track schema changes
    └── migrations/            # Incremental change records (one per schema change)
```

> **✏️** = files you must fill in before running the pipeline for the first time.

---

## Pipeline State

During a pipeline run, each agent writes its output to `.copilot/pipeline/` in the repository:

```
.copilot/pipeline/
├── state.json                     # Current stage, status, session ID
├── requirements.json              # Refinement agent output
├── design.json                    # Design agent output
├── design-ac.json                 # Design acceptance criteria (verified by design-review-agent)
├── planning.json                  # Planning agent output
├── performance.json               # Performance agent output (bottleneck findings)
├── security.json                  # Security agent output
├── coding.json                    # Coding agent implementation report
├── linting.json                   # Linting agent report (issues fixed, loops completed)
├── testing.json                   # Tester agent report (coverage, failures)
├── review.json                    # Review agent report (CRAP-guided routing verdict)
├── documentation.json             # Documentation agent report
├── build.json                     # Build agent report (artifact inventory, sizes)
├── local-deployment.json          # Local deployment agent report (running services)
├── e2e-testing.json               # E2E agent test results (scenario outcomes, gaps found)
├── design-review.json             # Design Review agent report (DAC pass/fail evidence)
├── back-tracker-preliminary.json  # Back Tracker Phase 1 report (code analysis, runs in parallel)
├── back-tracker.json              # Back Tracker Phase 2 report (final requirements coverage verdict)
│
│   ── Persistent memory (survive across pipeline sessions) ──
├── build-strategy.json            # Approved build strategy — reused on every subsequent build
├── local-deployment-strategy.json # Approved deployment strategy — reused on every subsequent deploy
└── e2e-test-plan.json             # Approved E2E test plan — extended on every subsequent run
```

> **Persistent memory files** (`build-strategy.json`, `local-deployment-strategy.json`, and `e2e-test-plan.json`) are written once when the human approves the strategy/plan on the first run. On all subsequent pipeline runs the relevant agents read these files directly and build on them without re-asking for approval — unless the architecture or requirements change significantly enough to warrant a new strategy.

---

## MCP Servers

The pipeline uses two MCP (Model Context Protocol) servers for browser automation and GitHub operations. Both are available **out-of-the-box** in Copilot cloud agent — no additional configuration is required for cloud-hosted runs.

| MCP Server | Tool Namespace | Used By | Purpose |
|-----------|---------------|---------|---------|
| **Playwright** | `playwright/*` | `e2e-agent`, `design-review-agent` | Browser automation: navigate, interact, screenshot running local deployments |
| **GitHub** | `github/*` | All agents | Repository operations: read issues, files, PRs; write PRs and comments |

### Playwright MCP Server

The Playwright MCP server gives agents a real browser to test the running local deployment. It is pre-configured in Copilot cloud agent to only access `localhost` (safe for local deployment testing).

**Cloud agent (GitHub-hosted)**: The Playwright MCP server is available out-of-the-box. The `copilot-setup-steps.yml` workflow pre-installs Chromium so the server has a browser to drive:

```yaml
# Already in .github/workflows/copilot-setup-steps.yml
- name: Install Playwright browsers for E2E and design review agents
  run: npx --yes playwright install --with-deps chromium
```

**VS Code (local development)**: Install the [Playwright MCP extension](https://marketplace.visualstudio.com/items?itemName=ms-playwright.playwright) from the VS Code Marketplace. Once installed, `playwright/*` tools will be available to custom agents running in VS Code.

```
VS Code Extension ID: ms-playwright.playwright
```

After installing, reload VS Code and the `playwright/*` tools will appear automatically in any custom agent that lists `playwright/*` in its `tools` property.

### GitHub MCP Server

The GitHub MCP server provides read/write access to the repository. It is available out-of-the-box in Copilot cloud agent with a token scoped to the source repository. No setup is required.

**VS Code**: The GitHub MCP server is available through the built-in GitHub Copilot extension. Ensure you are signed in to GitHub Copilot in VS Code.

### MCP Server Readiness Check

At pipeline start (Step 0), the orchestrator verifies that both MCP servers are reachable before launching any agents. If either is unavailable, the pipeline halts and reports which server is missing with remediation instructions.

---

## Environment Setup

Secrets and environment variables for agents are set in the `copilot` GitHub Actions environment in your repository settings. See [Setting environment variables in Copilot's environment](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/customize-the-agent-environment#setting-environment-variables-in-copilots-environment).

The `.github/workflows/copilot-setup-steps.yml` pre-installs Node.js, Python, PostgreSQL client tools, Docker, the GitHub CLI, Playwright (Chromium), and the portable CRAP review tool for all agent runs.

---

## Contributing

See the [blueprint](docs/knowledge/blueprint/README.md) for how features are planned and [past-decisions](docs/knowledge/requirements/past-decisions.md) for architectural history.
