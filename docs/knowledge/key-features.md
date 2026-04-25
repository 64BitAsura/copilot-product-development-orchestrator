# Key Features

> A complete inventory of currently active product features. Used by the requirements agent to identify overlap with new requests, by the design agent for consistency, and by the planning agent to find existing code to extend.
>
> **Maintained by**: Requirements agent (adds features on approval), Planning agent (marks shipped).
> See `docs/knowledge/blueprint/feature-map.md` for the full feature map with dependencies and IDs.

---

## Feature Categories

- [Orchestration](#orchestration)
- [Input Handling](#input-handling)
- [Agent Pipeline](#agent-pipeline)
- [Knowledge Harness](#knowledge-harness)

---

## Orchestration

### Multi-Agent Pipeline Coordinator
**Status**: `planned`  
**Description**: The orchestrator agent (`orchestrator.agent.md`) receives a GitHub issue or prompt and coordinates a sequential pipeline of specialized agents: Requirements → Design → Planning → Security → Coding → Testing → Documentation.  
**Key behaviours**:
- Initialises pipeline state in `.copilot/pipeline/state.md`
- Enforces user approval checkpoints after Requirements, Design, and Planning
- Automatically loops Security → Planning when security issues are found (max 3 loops)
- Produces a final summary with all stage output links

---

## Input Handling

### GitHub Issue Parsing
**Status**: `planned`  
**Description**: The orchestrator can accept a GitHub issue URL or number as primary input. It reads the issue title, body, labels, and linked PRs via the `github/*` MCP server.

### Free-Form Prompt Parsing
**Status**: `planned`  
**Description**: The orchestrator accepts unstructured text prompts describing a feature or change request.

### Reference Input Support
**Status**: `planned`  
**Description**: Users can attach supplementary material to their main input:
- URLs (web pages, API docs, blog posts)
- Documents (`.md`, `.txt`)
- Repositories (`owner/repo`)
- Images (mockups, screenshots)
- Audio and video (planned for future fetching/transcription)

---

## Agent Pipeline

### Requirements Agent
**Status**: `planned` (definition shipped)  
**Description**: Analyses the input against the knowledge harness, detects gaps, presents multiple requirement options with confidence ratings, and produces acceptance criteria in Given/When/Then format.  
**Outputs**: `.copilot/pipeline/requirements.md`

### Design Agent
**Status**: `planned` (definition shipped)  
**Description**: Maps UX flows, inventories UI components, sets design budgets (UX and UI constraints), and produces wireframes and accessibility checklists.  
**Outputs**: `.copilot/pipeline/design.md`

### Planning Agent
**Status**: `planned` (definition shipped)  
**Description**: Analyses the codebase and presents 2–3 implementation options with confidence ratings. Specifies data model changes, API changes, and an ordered implementation sequence.  
**Outputs**: `.copilot/pipeline/planning.md`

### Security Agent
**Status**: `planned` (definition shipped)  
**Description**: Analyses the selected implementation plan against OWASP Top 10, checks CVEs for proposed libraries, maps trust boundary violations, and either clears the plan or sends it back to planning with mandatory fixes.  
**Outputs**: `.copilot/pipeline/security.md`

### Coding Agent
**Status**: `planned` (definition shipped)  
**Description**: Decomposes the implementation plan into tasks, delegates to language-specific developer subagents, verifies quality, enforces security constraints, and produces a complete implementation.  
**Outputs**: Code changes in repo + `.copilot/pipeline/coding.md`

### Tester Agent
**Status**: `planned` (definition shipped)  
**Description**: Generates test scenarios from acceptance criteria, writes unit and integration tests, runs the suite, enforces ≥80% coverage on new code, and loops with the coding agent until all tests pass.  
**Outputs**: Test files in repo + `.copilot/pipeline/testing.md`

### Documentation Agent
**Status**: `planned` (definition shipped)  
**Description**: Updates the OpenAPI spec for all endpoint changes, writes implementation notes, detects breaking changes, and generates changelog entries.  
**Outputs**: Updated `openapi.yaml`, `CHANGELOG.md`, `README.md` + `.copilot/pipeline/documentation.md`

---

## Knowledge Harness

### Product Vision
**Status**: `shipped`  
**Description**: `docs/knowledge/product-vision.md` defines the product's purpose, target users, core values, success metrics, and v1 scope boundaries.

### Requirements Knowledge Folder
**Status**: `shipped`  
**Description**: `docs/knowledge/requirements/` contains requirement templates, gap analysis checklist, acceptance criteria guide, user personas, approved feature patterns, and the past-decisions log.

### Blueprint Folder
**Status**: `shipped`  
**Description**: `docs/knowledge/blueprint/` contains the feature map, domain model (entities, aggregates, events, ubiquitous language), integration points (agent-to-agent + external), and capability matrix.

### Schema Folder
**Status**: `shipped`  
**Description**: `docs/knowledge/schema/` contains the base PostgreSQL schema (`base-schema.sql`), Mermaid ERD, schema conventions, and migrations guide with templates.

---

## Adding a New Feature

When a feature is approved by the requirements agent, add it here following this pattern:

```markdown
### [Feature Name]
**Status**: `planned` | `in-progress` | `shipped` | `deprecated`
**Description**: [What it does]
**Key behaviours**: [Bullet points of notable behaviours]
**Outputs**: [What it produces — files, APIs, side effects]
```
