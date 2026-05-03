# Pipeline Files

This directory contains the inter-agent handoff files for the product development pipeline.

## Format

**All files in this directory are Markdown (`.md`).** Agents read and write plain Markdown — not JSON, not YAML, not any other structured format. This is deliberate: Markdown files are human-readable, git-diffable, and can be inspected or edited directly without parsing tools.

## File Index

| File | Written by | Read by | Purpose |
|------|-----------|---------|---------|
| `state.md` | Orchestrator | All agents | Session ID, current stage, status, reference inputs, stage history |
| `requirements.md` | Refinement Agent | Design, Planning, Coding, Security, Performance, Tester, E2E, Back Tracker | Approved requirements and acceptance criteria |
| `design.md` | Design Agent | Planning, Coding, Performance, Design Review | UX/UI specification, design budgets, wireframes |
| `design-ac.md` | Design Agent | Design Review | Verifiable design acceptance criteria (DAC-*) |
| `planning.md` | Planning Agent | Security, Performance, Coding, Tester, Build, E2E, Back Tracker | Technical implementation plan with selected option |
| `performance.md` | Performance Agent | Orchestrator, Coding | Bottleneck findings, conditions for implementation |
| `security.md` | Security Agent | Orchestrator, Coding | Security findings, verdict, conditions for coding |
| `coding.md` | Coding Agent | Linting, Tester, Documentation, Build, E2E, Back Tracker | Implementation report — files changed, API changes, DB changes |
| `linting.md` | Linting Agent | Orchestrator | Linting report — issues fixed, loops completed |
| `testing.md` | Tester Agent | Documentation, Back Tracker | Test results, coverage, breaking changes |
| `documentation.md` | Documentation Agent | Orchestrator | Documentation changes, OpenAPI updates, changelog entries |
| `build.md` | Build Agent | Local Deployment, Orchestrator | Artifact inventory, sizes, verification results |
| `local-deployment.md` | Local Deployment Agent | E2E, Design Review, Back Tracker | Running service URLs, health check results |
| `e2e-testing.md` | E2E Agent | Back Tracker, Orchestrator | E2E test results — scenario outcomes, gaps |
| `design-review.md` | Design Review Agent | Back Tracker, Orchestrator | DAC pass/fail evidence with screenshots |
| `back-tracker-preliminary.md` | Back Tracker (Phase 1) | Back Tracker (Phase 2) | Code-vs-requirements analysis (E2E results pending) |
| `back-tracker.md` | Back Tracker (Phase 2) | Orchestrator | Final requirements coverage verdict |

### Persistent Memory Files

These files survive across pipeline sessions and are reused on subsequent runs:

| File | Written by | Purpose |
|------|-----------|---------|
| `build-strategy.md` | Build Agent | Approved build strategy — reused on every subsequent build |
| `local-deployment-strategy.md` | Local Deployment Agent | Approved deployment strategy — reused on every subsequent deploy |
| `e2e-test-plan.md` | E2E Agent | Approved E2E test plan — extended on every subsequent run |

## Why Markdown, Not JSON

- **Human-readable**: Any team member can open a pipeline file and understand the current state without a parser.
- **Git-friendly**: Diffs show meaningful content changes, not structural JSON deltas.
- **Agent-friendly**: LLMs read and generate Markdown natively. They do not need to serialise/deserialise.
- **Inspectable**: Pipeline files can be reviewed, edited, or corrected during a run without tooling.

## Important: Agent Output Rules

Every agent **must**:
1. Write its output to the corresponding `.md` file using the `edit` tool.
2. Use the Markdown template defined in its own agent file — never JSON.
3. Complete the file write before notifying the orchestrator that the stage is done.

The orchestrator **must**:
1. Read the `.md` file to get each agent's output — never rely on the agent tool's return value as a substitute for the file.
2. Pass file paths to downstream agents, not raw agent output.
