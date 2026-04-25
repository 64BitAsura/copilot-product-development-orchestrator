# Domain Model

> The domain model defines the **core concepts** of the product — the entities, their attributes, and how they relate. Every agent uses this as the canonical vocabulary. When writing code, designing UI, or specifying requirements, always use the terms defined here.
>
> This model is reflected in the database schema (`docs/knowledge/schema/base-schema.sql`).

---

## Domain Concepts Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    ORCHESTRATOR DOMAIN                       │
│                                                              │
│  ┌──────────┐    triggers    ┌──────────────┐               │
│  │  Input   │──────────────►│   Session    │               │
│  └──────────┘                └──────┬───────┘               │
│                                     │ contains               │
│                                     ▼                        │
│                              ┌─────────────┐                │
│                              │  PipelineRun│                │
│                              └──────┬──────┘                │
│                                     │ has many               │
│                                     ▼                        │
│                              ┌─────────────┐                │
│                              │    Stage    │                │
│                              └──────┬──────┘                │
│                                     │ produces               │
│                                     ▼                        │
│                              ┌─────────────┐                │
│                              │  StageOutput│                │
│                              └─────────────┘                │
│                                                              │
│  ┌──────────────┐   governed by   ┌──────────────────┐      │
│  │  AgentProfile│◄───────────────│  PipelineRun     │      │
│  └──────────────┘                 └──────────────────┘      │
│                                                              │
│  ┌──────────────┐   stored in   ┌──────────────────────┐    │
│  │  Knowledge   │◄─────────────│ KnowledgeHarness     │    │
│  │  Document    │               └──────────────────────┘    │
│  └──────────────┘                                            │
└─────────────────────────────────────────────────────────────┘
```

---

## Entities

### Input

Represents the raw material the orchestrator receives to begin a pipeline run.

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Unique identifier |
| `type` | enum | `github_issue` \| `prompt` |
| `raw_content` | text | Full text of the issue body or prompt |
| `title` | text | Issue title or first line of prompt |
| `source_url` | text? | GitHub issue URL (if type = github_issue) |
| `issue_number` | int? | GitHub issue number |
| `repository` | text? | `owner/repo` string |
| `created_at` | timestamp | When the input was received |

**Value objects embedded in Input:**

`ReferenceInput` — a single reference item attached to an Input:

| Attribute | Type | Description |
|-----------|------|-------------|
| `type` | enum | `url` \| `document` \| `image` \| `repository` \| `audio` \| `video` |
| `source` | text | URL, file path, or repo identifier |
| `summary` | text? | Agent-generated summary of the reference |
| `fetched_at` | timestamp? | When the reference was fetched |

---

### Session

A Session is a long-lived context grouping one or more pipeline runs for the same product/repository.

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Unique identifier (also used as the pipeline state session ID) |
| `repository` | text | `owner/repo` the session operates on |
| `created_by` | text | GitHub username who initiated |
| `created_at` | timestamp | Session creation time |
| `status` | enum | `active` \| `completed` \| `failed` \| `abandoned` |

---

### PipelineRun

A single end-to-end execution of the agent pipeline for one Input.

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Unique identifier |
| `session_id` | UUID | Parent session |
| `input_id` | UUID | The Input being processed |
| `current_stage` | enum | Current stage (see StageType) |
| `status` | enum | `in_progress` \| `waiting_for_approval` \| `completed` \| `failed` \| `paused` |
| `started_at` | timestamp | |
| `completed_at` | timestamp? | |
| `selected_requirements_option` | text? | Option selected by user (e.g. "Option A") |
| `selected_design_option` | text? | |
| `selected_planning_option` | text? | |
| `security_loop_count` | int | Number of times security sent back to planning (default 0) |
| `state_file_path` | text | Path to `.copilot/pipeline/state.md` |

---

### Stage

One step in the pipeline — the execution record for a single agent within a PipelineRun.

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Unique identifier |
| `pipeline_run_id` | UUID | Parent pipeline run |
| `type` | StageType | Which stage this is |
| `agent_name` | text | Name of the agent that executed this stage |
| `status` | enum | `pending` \| `in_progress` \| `waiting_for_approval` \| `approved` \| `completed` \| `failed` \| `skipped` |
| `started_at` | timestamp? | |
| `completed_at` | timestamp? | |
| `approved_at` | timestamp? | When user approved (for approval stages) |
| `approved_by` | text? | GitHub username |
| `output_file_path` | text? | Path to the stage's output file in `.copilot/pipeline/` |
| `iteration_count` | int | How many times this stage was re-run (default 1) |

**StageType enum**: `requirements` \| `design` \| `planning` \| `security` \| `coding` \| `testing` \| `documentation`

---

### StageOutput

The persisted output produced by a stage. Separate from the stage record to allow multiple iterations.

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Unique identifier |
| `stage_id` | UUID | Parent stage |
| `iteration` | int | Which attempt this output is from (1-indexed) |
| `content` | text | Full markdown content written by the agent |
| `file_path` | text | Where this is stored in the repo |
| `created_at` | timestamp | |

---

### AgentProfile

The definition of a custom agent — corresponds to a `.agent.md` file.

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Unique identifier |
| `name` | text | Agent name (matches filename without `.agent.md`) |
| `file_path` | text | Path to `.github/agents/<name>.agent.md` |
| `description` | text | Agent's stated purpose |
| `tools` | text[] | List of tool aliases the agent has access to |
| `git_sha` | text | SHA of the agent file used (for versioning) |
| `created_at` | timestamp | |
| `updated_at` | timestamp | |

---

### KnowledgeDocument

A document in the knowledge harness consulted by agents.

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Unique identifier |
| `category` | enum | `product_vision` \| `requirements` \| `blueprint` \| `schema` \| `design` \| `security` \| `testing` \| `tech_stack` |
| `name` | text | Display name |
| `file_path` | text | Path relative to repo root |
| `description` | text | What this document contains |
| `last_updated_at` | timestamp | |
| `last_updated_by` | text | Agent name or GitHub username |

---

## Aggregates

### Pipeline Aggregate (root: PipelineRun)
- PipelineRun owns Stage[]
- Stage owns StageOutput[]
- PipelineRun references Input (does not own)
- PipelineRun references Session (does not own)

### Knowledge Aggregate (root: KnowledgeDocument)
- Standalone; read by agents, written by requirements/documentation agents

---

## Domain Events

| Event | Triggered By | Consumed By |
|-------|-------------|-------------|
| `InputReceived` | Orchestrator on start | Requirements agent |
| `GapDetected` | Requirements agent | Orchestrator (pauses pipeline, prompts user) |
| `RequirementsApproved` | User via orchestrator | Design agent |
| `DesignApproved` | User via orchestrator | Planning agent |
| `PlanSelected` | User via orchestrator | Security agent |
| `SecurityIssuesFound` | Security agent | Orchestrator (loops back to planning) |
| `SecurityCleared` | Security agent | Orchestrator (proceeds to coding) |
| `ImplementationComplete` | Coding agent | Testing agent |
| `TestsFailed` | Testing agent | Coding agent (fix loop) |
| `TestsPassed` | Testing agent | Documentation agent |
| `DocumentationComplete` | Documentation agent | Orchestrator (pipeline complete) |

---

## Ubiquitous Language

Use these terms consistently across all agents, code, and documentation:

| Term | Meaning |
|------|---------|
| **Input** | The main request (issue or prompt) + all reference inputs |
| **Reference Input** | Supplementary material attached to the main input |
| **Pipeline Run** | One end-to-end execution through all agent stages |
| **Stage** | One agent's execution within a pipeline run |
| **Stage Output** | The markdown document produced by a stage |
| **Knowledge Harness** | The folder of documents agents read for product context |
| **Gap** | Missing information that blocks requirements completion |
| **Approval Checkpoint** | A user-facing pause where explicit approval is required |
| **Confidence Rating** | A 0–100% score indicating how certain an agent is about its output |
| **Implementation Option** | One of 2–4 possible ways to implement a requirement |
| **Design Budget** | UX/UI constraints that the implementation must respect |
| **Security Loop** | Automatic cycle back to planning when security issues are found |
