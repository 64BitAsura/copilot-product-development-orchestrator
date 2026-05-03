# Pipeline Files

This directory contains the inter-agent handoff files for the product development pipeline.

## Format

**All files in this directory are JSON (`.json`).** Agents read and write structured JSON — not Markdown, not YAML, not any other format. This is deliberate: JSON files are machine-parseable, schema-validatable, and guarantee a consistent structure that every downstream agent can rely on without custom parsing logic.

## File Index

| File | Written by | Read by | Purpose |
|------|-----------|---------|---------|
| `state.json` | Orchestrator | All agents | Session ID, current stage, status, reference inputs, stage history |
| `requirements.json` | Refinement Agent | Design, Planning, Coding, Security, Performance, Tester, E2E, Back Tracker | Approved requirements and acceptance criteria |
| `design.json` | Design Agent | Planning, Coding, Performance, Design Review | UX/UI specification, design budgets, wireframes |
| `design-ac.json` | Design Agent | Design Review | Verifiable design acceptance criteria (DAC-*) |
| `planning.json` | Planning Agent | Security, Performance, Coding, Tester, Build, E2E, Back Tracker | Technical implementation plan with selected option |
| `performance.json` | Performance Agent | Orchestrator, Coding | Bottleneck findings, conditions for implementation |
| `security.json` | Security Agent | Orchestrator, Coding | Security findings, verdict, conditions for coding |
| `coding.json` | Coding Agent | Linting, Tester, Documentation, Build, E2E, Back Tracker | Implementation report — files changed, API changes, DB changes |
| `linting.json` | Linting Agent | Orchestrator | Linting report — issues fixed, loops completed |
| `testing.json` | Tester Agent | Documentation, Back Tracker | Test results, coverage, breaking changes |
| `documentation.json` | Documentation Agent | Orchestrator | Documentation changes, OpenAPI updates, changelog entries |
| `build.json` | Build Agent | Local Deployment, Orchestrator | Artifact inventory, sizes, verification results |
| `local-deployment.json` | Local Deployment Agent | E2E, Design Review, Back Tracker | Running service URLs, health check results |
| `e2e-testing.json` | E2E Agent | Back Tracker, Orchestrator | E2E test results — scenario outcomes, gaps |
| `design-review.json` | Design Review Agent | Back Tracker, Orchestrator | DAC pass/fail evidence with screenshots |
| `back-tracker-preliminary.json` | Back Tracker (Phase 1) | Back Tracker (Phase 2) | Code-vs-requirements analysis (E2E results pending) |
| `back-tracker.json` | Back Tracker (Phase 2) | Orchestrator | Final requirements coverage verdict |

### Persistent Memory Files

These files survive across pipeline sessions and are reused on subsequent runs:

| File | Written by | Purpose |
|------|-----------|---------|
| `build-strategy.json` | Build Agent | Approved build strategy — reused on every subsequent build |
| `local-deployment-strategy.json` | Local Deployment Agent | Approved deployment strategy — reused on every subsequent deploy |
| `e2e-test-plan.json` | E2E Agent | Approved E2E test plan — extended on every subsequent run |

## Why JSON, Not Markdown

- **Structured**: Every field has a defined key and type — no free-form text that agents must parse differently.
- **Schema-validatable**: JSON output can be validated against a schema to catch missing or malformed fields early.
- **Agent-friendly**: LLMs produce and consume JSON reliably; downstream agents can extract specific fields without scanning free-form prose.
- **Tool-compatible**: JSON files can be queried with standard tools (`jq`, IDE plugins, CI scripts) for debugging and automation.
- **Git-friendly**: Structured JSON diffs show precise field-level changes.

## Important: Agent Output Rules

Every agent **must**:
1. Write its output to the corresponding `.json` file using the `edit` tool.
2. Use the JSON schema defined in its own agent file — never Markdown.
3. Complete the file write before notifying the orchestrator that the stage is done.

The orchestrator **must**:
1. Read the `.json` file to get each agent's output — never rely on the agent tool's return value as a substitute for the file.
2. Pass file paths to downstream agents, not raw agent output.
