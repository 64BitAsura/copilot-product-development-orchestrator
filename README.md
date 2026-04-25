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

1. Open a GitHub issue describing the feature or change you want to build.
2. Assign it to Copilot and select the **`orchestrator`** agent.
3. The orchestrator will begin the pipeline, pause at approval checkpoints, and open a PR when done.

Or start from the Copilot chat panel:

```
@orchestrator Build a user authentication feature. Reference: https://github.com/myorg/myapi
```

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

Agents read from and write to the `docs/knowledge/` folder to stay aligned with the product:

```
docs/knowledge/
├── product-vision.md          # What we're building and why
├── key-features.md            # Inventory of current features
├── design-principles.md       # UX/UI design rules
├── tech-stack.md              # Technology choices
├── security-best-practices.md # Security patterns and findings log
├── testing-guidelines.md      # Test standards and framework patterns
│
├── requirements/              # Requirements agent's knowledge base
│   ├── README.md
│   ├── requirement-template.md
│   ├── gap-analysis-checklist.md
│   ├── acceptance-criteria-guide.md
│   ├── personas.md
│   ├── approved-patterns.md
│   └── past-decisions.md      # Append-only decision log
│
├── blueprint/                 # How all features tie together
│   ├── README.md
│   ├── feature-map.md         # All features, statuses, dependencies
│   ├── domain-model.md        # Entities, aggregates, ubiquitous language
│   ├── integration-points.md  # Agent-to-agent + external integrations
│   └── capability-matrix.md   # Which agent owns what
│
└── schema/                    # Base database schema
    ├── README.md
    ├── base-schema.sql        # Full PostgreSQL schema
    ├── erd.md                 # Mermaid Entity Relationship Diagram
    ├── schema-conventions.md  # Naming rules and design patterns
    ├── migrations-guide.md    # How to write and run migrations
    └── migrations/            # Incremental migration files
```

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

## Customising the Knowledge Harness

Before running the pipeline for the first time, update these files to reflect your product:

1. **`docs/knowledge/product-vision.md`** — replace placeholder content with your product's vision, users, and goals.
2. **`docs/knowledge/key-features.md`** — list your existing features.
3. **`docs/knowledge/tech-stack.md`** — fill in your actual technology choices.
4. **`docs/knowledge/requirements/personas.md`** — describe your real users.
5. **`docs/knowledge/schema/base-schema.sql`** — replace with your actual database schema.

---

## Environment Setup

Secrets and environment variables for agents are set in the `copilot` GitHub Actions environment in your repository settings. See [Setting environment variables in Copilot's environment](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/customize-the-agent-environment#setting-environment-variables-in-copilots-environment).

The `.github/workflows/copilot-setup-steps.yml` pre-installs Node.js, Python, PostgreSQL client tools, Docker, and the GitHub CLI for all agent runs.

---

## Contributing

See the [blueprint](docs/knowledge/blueprint/README.md) for how features are planned and [past-decisions](docs/knowledge/requirements/past-decisions.md) for architectural history.
