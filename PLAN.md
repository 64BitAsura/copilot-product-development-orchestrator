# Copilot Product Development Orchestrator — Implementation Plan

## Overview

A GitHub Copilot Extension (VS Code `@orchestrator` custom agent) that orchestrates the full product
development lifecycle through a pipeline of specialised AI agents.

**Entry point:** user types `@orchestrator <GitHub Issue URL or prompt>` in VS Code Copilot Chat.
Reference inputs (images, docs, videos, URLs, audio, repos) can be attached or linked inline.

---

## Tech Stack

| Concern | Choice |
|---|---|
| Runtime | Python 3.12 |
| Copilot Extension SDK | `copilot-extensions` Python preview SDK — HMAC signature verification, SSE streaming, Copilot message payload parsing |
| Web framework | FastAPI + Uvicorn (webhook `POST /` handler) |
| Agent framework | LangGraph — stateful multi-agent graph with human-in-the-loop (HITL) nodes |
| Tool protocol | Model Context Protocol (MCP) via `mcp[fastmcp]` — one FastMCP server per tool integration |
| Vector store / RAG | ChromaDB + `langchain-community` embeddings |
| State store | Redis (`redis-py`) for local dev; GitHub Discussions API for production |
| GitHub API | PyGitHub (`PyGithub`) |
| Deployment | GitHub App registered as a **Copilot Extension**, type = `agent`; appears as `@orchestrator` in VS Code Copilot Chat |
| Local dev tunnel | ngrok or `gh codespace port-forward` |
| Containerisation | Docker Compose — orchestrator service + Redis + per-phase MCP tool containers |

### Key Python Packages

```
fastapi uvicorn python-dotenv pydantic redis
langgraph langchain-core langchain-openai langchain-community
chromadb pypdf pytesseract pillow openai
pygithub mcp[fastmcp] httpx deepdiff
ruff mypy pytest pytest-asyncio pytest-cov
```

---

## How the VS Code Agent Works (End-to-End)

```
VS Code Copilot Chat
       │  @orchestrator <issue-url> [ref: image.png, repo: org/repo]
       ▼
GitHub Copilot API
       │  signed POST /   (Copilot message envelope)
       ▼
FastAPI webhook  ──►  HMAC signature verification (Copilot SDK)
       │
       ▼
LangGraph orchestration graph
  ├─ Requirements Agent node  ──►  [HITL: gap approval]
  ├─ Design Agent node         ──►  [HITL: design approval]
  ├─ Planning Agent node       ──►  [HITL: implementation option selection]
  ├─ Security Agent node       ──►  [loop back to Planning if critical findings]
  ├─ Coding Agent node         ──►  [sub-agent fan-out via LangGraph Send API]
  ├─ Tester Agent node         ──►  [loop back to Coding on failures]
  └─ Documentation Agent node  ──►  [emit completion]
       │
       ▼  SSE stream  (each node streams partial markdown to VS Code Chat)
VS Code Copilot Chat  ──  incremental rendered response
```

Human-in-the-loop nodes pause the graph and stream a structured Markdown prompt with
numbered options + confidence ratings. The graph resumes when the user replies in chat.

---

## Phase 0 — Project Setup & Core Infrastructure

> Bootstrap the project and build the shared plumbing every agent depends on.

### Issues

- **[0.1]** Initialise Python project — `pyproject.toml` (uv), `src/orchestrator/` package layout,
  Ruff + mypy config, `Dockerfile`, Docker Compose (orchestrator + Redis)
- **[0.2]** Register GitHub App as Copilot Extension — `copilot.yml`, required scopes
  (issues, wiki, code, pull-requests, metadata), Extension type = `agent`, ngrok tunnel for local dev
- **[0.3]** FastAPI webhook entry point — `POST /` handler, HMAC signature verification via
  Copilot Extensions Python SDK, SSE response helper (`EventSourceResponse`)
- **[0.4]** Pydantic input models — `PrimaryInput` (Issue URL | prompt) and
  `ReferenceInput` union (image | doc | video | URL | audio | repo)
- **[0.5]** LangGraph orchestration graph skeleton — `OrchestratorState` TypedDict,
  agent node stubs, conditional edges between phases, graph compilation
- **[0.6]** Agent lifecycle manager — LangGraph state fields for agent status
  (`idle | running | waiting_user | done | error`), handoff via state mutation
- **[0.7]** User interaction engine — `present_options(options)` SSE helper streaming a
  Markdown table with confidence ratings; HITL node blocks until user replies
- **[0.8]** State persistence — `RedisCheckpointer` for LangGraph state; fallback to
  GitHub Discussions API checkpointer for production

---

## Phase 1 — Requirements Agent

> Experienced product engineer: understands *what* to build and *how*, surfaces gaps immediately.

### Issues

- **[1.1]** Knowledge harness — `knowledge/requirements/` directory tree (product vision, personas,
  key features, known problems, past decisions); ChromaDB vector store with
  `langchain-community` embeddings; `KnowledgeHarness` retrieval class
- **[1.2]** Web search MCP tool — FastMCP server wrapping Brave Search API;
  registered as LangGraph tool for the Requirements Agent node
- **[1.3]** GitHub Wiki MCP tool — FastMCP server using PyGitHub to read existing wiki pages
  and write requirement artefacts back to the wiki
- **[1.4]** Confluence MCP tool (optional) — FastMCP server using Confluence REST API v2;
  activated only when `CONFLUENCE_URL` is configured
- **[1.5]** Gap analysis engine — compare parsed inputs against knowledge harness via RAG;
  if similarity below threshold, build gap list, stream it to chat, pause graph (HITL node)
- **[1.6]** Multi-option presenter — shared `present_options(options: list[Option]) → str`
  utility rendering a Markdown table with confidence scores; used by all agents
- **[1.7]** User approval flow — HITL node: await user choice, mutate
  `state["requirements_approved"] = True`, stream confirmation, advance to Design Agent

---

## Phase 2 — Design Agent

> Award-winning Silicon Valley product designer: UX-first, builds or iterates designs, enforces budget.

### Issues

- **[2.1]** Figma MCP tool — FastMCP server using Figma REST API to read existing frames
  and components, create new designs, export design tokens and component specs
- **[2.2]** GitHub Wiki write tool — reuse Phase 1 MCP server; persist design decisions
  and layout guides as wiki pages
- **[2.3]** UX/UI budget manager — `DesignBudget` Pydantic model (max screens, interaction
  depth, component count); constraint checker in agent node; warn user when exceeded
- **[2.4]** Design guideline output — `DesignGuide` Pydantic model serialised to Markdown;
  stored in graph state and injected into Planning Agent's context

---

## Phase 3 — Planning Agent

> Silicon Valley software architect: sole authority on technical implementation choices.

### Issues

- **[3.1]** Mermaid diagram generator — string-builder utility producing architecture,
  sequence, and ERD diagrams in fenced Mermaid blocks (rendered by VS Code Copilot Chat)
- **[3.2]** GitHub Issues MCP tool — FastMCP server using PyGitHub to read existing issues
  for context and create implementation sub-task issues
- **[3.3]** Web search + repo analysis — reuse Phase 1 web search MCP; add repo-read MCP
  using PyGitHub to inspect referenced repos
- **[3.4]** Implementation options engine — `List[ImplementationOption]` with tech stack,
  trade-offs, effort estimate, and confidence rating; rendered via `present_options`
- **[3.5]** Feedback & reiteration HITL loop — LangGraph cycle edge back to planning node
  on rejection or partial feedback; emit `plan_approved` to advance to Security Agent

---

## Phase 4 — Security Agent

> Reformed black-hat security guardian: hunts vulnerabilities before code is written.

### Issues

- **[4.1]** CVE/advisory MCP tool — FastMCP server querying OSV API (`https://api.osv.dev`) and
  GitHub Advisory DB REST API for all dependencies in the chosen implementation option
- **[4.2]** Security knowledge base — `knowledge/security/` with OWASP Top 10 and CWE Top 25
  ingested into ChromaDB; used as RAG context in the Security Agent node
- **[4.3]** Vulnerability analysis pipeline — LLM-assisted scan of implementation plan state;
  output `List[SecurityFinding]` (id, severity, description, proposed_fix); streamed to chat
- **[4.4]** Planning Agent feedback loop — if any finding is critical or high severity,
  inject `SecurityFeedback` into Planning Agent state and trigger re-plan edge in LangGraph;
  gate on `security_approved` before proceeding

---

## Phase 5 — Coding Agent

> Full-stack Fortune-10 engineer: delegates chunks to language sub-agents, verifies quality.

### Issues

- **[5.1]** Sub-agent delegation framework — `WorkChunk` Pydantic model; LangGraph `Send` API
  for fan-out to language sub-agents; reduce results back into main graph state
- **[5.2]** Language sub-agents — Python dev sub-agent, TypeScript dev sub-agent,
  Rust dev sub-agent, Go dev sub-agent (each a specialised LangGraph subgraph with its own
  system prompt and tool set)
- **[5.3]** MCP tool set — FastMCP servers for: CLI runner (asyncio subprocess), DB client
  (SQLAlchemy), storage client (boto3 / fsspec), IDE editor (read / write / find-references /
  find-implementation via Python LSP client `pylsp` / `python-lsp-server`)
- **[5.4]** GitHub CLI MCP tool — FastMCP server wrapping `gh` CLI calls (branch, commit,
  pull request creation)
- **[5.5]** Code quality verifier — Ruff + mypy (Python), `tsc` (TypeScript), `clippy` (Rust),
  `golangci-lint` (Go); run via CLI MCP; request targeted fixes from sub-agent (max 3 retries)
- **[5.6]** Completion protocol — assert all `WorkChunk` IDs are marked done; check cross-chunk
  coherence via import graph; emit `coding_complete` with changed file list + API diff

---

## Phase 6 — Tester Agent

> Silicon Valley test engineer: finds critical cases, writes unit/integration tests (never E2E).

### Issues

- **[6.1]** Test scenario generator — LLM node producing `List[TestScenario]`
  (positive, edge, negative) from requirements + implementation state; categorised by component
- **[6.2]** Language sub-agents for test writing — reuse Phase 5 sub-agents with a
  test-writing system prompt overlay
- **[6.3]** Test runner MCP tool — FastMCP server running pytest / jest / `cargo test` /
  `go test` via CLI; parse JUnit XML or JSON coverage output
- **[6.4]** Coverage threshold enforcement — configurable `min_coverage` (default 80%) in
  `orchestrator.toml`; fail node if below threshold; report uncovered line ranges
- **[6.5]** Coding Agent collaboration loop — on failure emit `DefectReport`
  (failing test, stack trace, assertion) to Coding Agent node; LangGraph cycle edge;
  re-run tests after fix until all pass and coverage met; emit `tests_passed`

---

## Phase 7 — Documentation Agent

> Developer who loves clear, simple docs: updates API specs and implementation docs post-test.

### Issues

- **[7.1]** OpenAPI spec updater — `deepdiff` + direct YAML/JSON manipulation to update
  `openapi.yaml` with new/modified paths, request/response schemas, status codes,
  security schemes
- **[7.2]** Implementation docs updater — write to `README.md`, ADR files
  (`docs/decisions/`), and component-level module docstrings via IDE MCP tool
- **[7.3]** Breaking change detector — `deepdiff` old vs. new OpenAPI schema;
  annotate breaking changes; inject into `CHANGELOG.md` and git commit message body

---

## Cross-Cutting Concerns

> Utilities and infrastructure shared across all agents.

### Issues

- **[X.1]** Confidence rating framework — `ConfidenceScorer` abstract base class +
  `LLMConfidenceScorer` implementation; shared across all agent nodes; returns 0–100 integer
- **[X.2]** Audit trail logger — append-only `AuditEntry` Pydantic records written to Redis
  stream; surfaced in VS Code Chat via `/audit` slash command; optionally mirrored to GitHub
  Discussions
- **[X.3]** Multi-modal input parser — `Pillow` + `pytesseract` (image OCR), `pypdf` (PDF
  text extraction), `openai.audio.transcriptions` / `whisper` (audio/video transcription),
  `playwright` (URL scrape → Markdown), PyGitHub (repo file tree)
- **[X.4]** Prompt library — versioned system prompts in `prompts/<agent>/system.md`;
  loaded at startup via `PromptLoader`; hot-reloadable without service restart
- **[X.5]** End-to-end integration test harness — pytest fixtures replay a sample GitHub Issue
  through the full LangGraph graph with mocked MCP tool servers; assert correct state
  transitions and final artefact shape

---

## Suggested Delivery Order

```
Phase 0  →  Phase 1  →  Phase 3  →  Phase 5  →  Phase 6  →  Phase 7
                                ↘
                            Phase 2 (parallel with 5–7)
                                ↘
                            Phase 4 (parallel with 5–7, gates on Phase 3)
                                ↘
                            Cross-Cutting (woven in throughout)
```
