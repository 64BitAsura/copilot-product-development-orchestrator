# Copilot Pipeline SDK

TypeScript implementation of the parallel Copilot product-development pipeline
using the **[GitHub Copilot SDK](https://github.com/github/copilot-sdk)**.

## Overview

`sdk/src/pipeline.ts` is the orchestrator.  It creates one `CopilotSession` per
agent and uses `Promise.all()` to run independent stages concurrently:

```
refinement → [design?] → planning
                              │
          ┌───────────────────┤  ← Promise.all (Stage 4)
          ▼                   ▼
     performance          security
          └───────────────────┤
                              ▼
                          coding → linting → testing
                                                │
                       ┌───────────────────────┤  ← Promise.all (Stage 8)
                       ▼                        ▼
                 documentation               build
                                                │
                                      local-deployment
                                                │
         ┌──────────────────────────────────────┤  ← Promise.all (Stage 10)
         ▼                   ▼                  ▼
        e2e          design-review?   back-tracker-phase-1
         └──────────────────────────────────────┤
                                                ▼
                                     back-tracker-phase-2
```

`design` and `design-review` are only included on the `full` lane.

## Prerequisites

- Node.js ≥ 20
- A GitHub Copilot subscription (or a BYOK provider token)
- The Copilot CLI — bundled automatically by the SDK

## Setup

```bash
cd sdk
npm install
```

## Run

```bash
# Build then run
npm run build
GITHUB_TOKEN=ghp_... node dist/pipeline.js <issue-number> [lane]

# Or run directly with tsx (no build step)
GITHUB_TOKEN=ghp_... npm run dev -- <issue-number> [lane]
```

**Examples:**

```bash
# Full pipeline for issue #42
GITHUB_TOKEN=ghp_... npm run dev -- 42 full

# Backend-only lane for issue #7
GITHUB_TOKEN=ghp_... npm run dev -- 7 backend
```

## Environment variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `GITHUB_TOKEN` | Yes* | — | GitHub token for Copilot authentication |
| `REPO_ROOT` | No | `cwd` | Path to the repository root |
| `COPILOT_MODEL` | No | `gpt-5` | Model used for all agent sessions |

*Not required when using BYOK (Bring Your Own Key).  See the
[Copilot SDK auth docs](https://github.com/github/copilot-sdk/blob/main/docs/auth/index.md).

## Pipeline output

Each agent writes a JSON file to `.copilot/pipeline/` in the repo root.  The
orchestrator reads these files to pass context between stages — matching the
same file conventions used by the `.github/agents/` custom agents.

| File | Written by |
|---|---|
| `state.json` | Orchestrator (updated after every stage) |
| `requirements.json` | `refinement-agent` |
| `design.json` | `design-agent` |
| `planning.json` | `planning-agent` |
| `performance.json` | `performance-agent` |
| `security.json` | `security-agent` |
| `coding.json` | `coding-agent` |
| `linting.json` | `linting-agent` |
| `testing.json` | `tester-agent` |
| `documentation.json` | `documentation-agent` |
| `build.json` | `build-agent` |
| `local-deployment.json` | `local-deployment-agent` |
| `e2e-testing.json` | `e2e-agent` |
| `design-review.json` | `design-review-agent` |
| `back-tracker-preliminary.json` | `back-tracker-agent` (phase 1) |
| `back-tracker.json` | `back-tracker-agent` (phase 2) |

## Programmatic use

```typescript
import { runPipeline } from "./src/pipeline.js";

await runPipeline({
  issueNumber: 42,
  lane: "full",
  repoRoot: "/path/to/repo",
  githubToken: process.env.GITHUB_TOKEN,
  model: "claude-sonnet-4.5",
});
```
