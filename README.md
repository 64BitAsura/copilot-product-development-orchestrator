# copilot-product-development-orchestrator

> Transform a GitHub issue into production-ready code — with the judgment of a full product development team — using only GitHub Copilot custom agents.

---

## What Is This?

This repository defines a **multi-agent product development pipeline** built on [GitHub Copilot custom agents](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/create-custom-agents). Each agent is a specialist in one stage of software development. The orchestrator coordinates them in sequence.

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
| **Security** | `.github/agents/security-agent.agent.md` | OWASP Top 10, CVE checks, trust boundaries, fix recommendations |
| **Coding** | `.github/agents/coding-agent.agent.md` | Full-stack implementation via language-specific subagents |
| **Tester** | `.github/agents/tester-agent.agent.md` | Unit + integration tests, ≥80% coverage, failure loop with coding |
| **Documentation** | `.github/agents/documentation-agent.agent.md` | OpenAPI spec, changelog, implementation notes, breaking changes |

---

## Knowledge Harness

`docs/knowledge/` is **your product's brain** — not documentation about this orchestrator. Fill it in with information about the product you are building. Agents read these files on every pipeline run to stay aligned with your product's purpose, existing features, design constraints, and technical decisions.

```
docs/knowledge/
├── product-vision.md          # ✏️ YOUR product's purpose, users, and success metrics
├── key-features.md            # ✏️ YOUR product's feature inventory
├── design-principles.md       # UX/UI rules (sensible defaults — update to match your product)
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
├── state.md           # Current stage, status, session ID
├── requirements.md    # Requirements agent output
├── design.md          # Design agent output
├── planning.md        # Planning agent output
├── security.md        # Security agent output
├── coding.md          # Coding agent implementation report
├── testing.md         # Tester agent report (coverage, failures)
└── documentation.md   # Documentation agent report
```

---

## Environment Setup

Secrets and environment variables for agents are set in the `copilot` GitHub Actions environment in your repository settings. See [Setting environment variables in Copilot's environment](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/customize-the-agent-environment#setting-environment-variables-in-copilots-environment).

The `.github/workflows/copilot-setup-steps.yml` pre-installs Node.js, Python, PostgreSQL client tools, Docker, and the GitHub CLI for all agent runs.

---

## Contributing

See the [blueprint](docs/knowledge/blueprint/README.md) for how features are planned and [past-decisions](docs/knowledge/requirements/past-decisions.md) for architectural history.
