# Agents Feature Update

## New Feature: Graph DB Memory for Full History + Extraction

### Goal
Add a graph-database-backed memory capability so agents can remember the full cross-session history and reliably extract relevant context for new tasks.

### Required Behavior
- Persist every pipeline session's key entities, decisions, artifacts, and relationships in a graph structure.
- Link sessions to issues, PRs, files, components, requirements, and outcomes.
- Support retrieval by:
  - issue/PR reference
  - feature/domain
  - decision lineage
  - file/component impact
  - time/window filters
- Provide context extraction that returns only relevant subgraphs/summaries for the active agent stage.

### Memory Model Scope
- Nodes: session, issue, PR, requirement, decision, feature, component, file, test result, risk/finding.
- Edges: `implements`, `depends_on`, `modified`, `validated_by`, `blocked_by`, `supersedes`, `references`.
- Metadata: timestamps, stage, status, confidence, source file/path, and traceability pointers.

### Pipeline Integration Expectations
- Orchestrator writes normalized memory events at each stage transition.
- Specialist agents append stage-specific facts and links as part of their normal output completion.
- Back-tracker reads graph lineage to verify requirement coverage against historical decisions and evidence.

### Safety and Quality Constraints
- Do not store secrets or sensitive credentials in graph memory.
- Preserve provenance for every extracted fact (session/file/source reference).
- Prefer deterministic extraction filters before free-form summarization.

