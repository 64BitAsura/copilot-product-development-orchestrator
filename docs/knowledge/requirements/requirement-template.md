# Requirements Document Template

> Copy this template for every new requirements session. Save the completed document to `.copilot/pipeline/requirements.md` during the pipeline run and archive it here after completion.

---

# [Feature Name] — Requirements

**Session ID**: <!-- orchestrator-assigned session ID -->  
**Issue / Input**: <!-- GitHub issue URL or prompt summary -->  
**Date**: <!-- ISO 8601 date -->  
**Refinement Agent Version**: <!-- git SHA of refinement-agent.agent.md -->  
**Status**: `draft` | `gap-analysis` | `awaiting-approval` | `approved`

---

## 1. Problem Statement

> _What problem are we solving? Why does it need to be solved now?_

**Problem**: <!-- Describe the pain point clearly, in user terms -->

**Impact without this**: <!-- What happens if we don't build it? -->

**Validated by**: <!-- How do we know this is a real problem? e.g., user feedback, metrics, stakeholder request -->

---

## 2. Target Users

> _Who specifically benefits from this?_

| Persona | Need | Benefit |
|---------|------|---------|
| <!-- e.g., Solo Developer --> | <!-- what they struggle with --> | <!-- how this helps --> |

_Reference `docs/knowledge/requirements/personas.md` for full persona definitions._

---

## 3. Scope

### In Scope
- <!-- Bullet list of what IS included -->

### Out of Scope
- <!-- Bullet list of what is explicitly NOT included — prevents scope creep -->

### Deferred
- <!-- Items that are related but intentionally left for a future iteration -->

---

## 4. Gaps Identified

> _List every ambiguity or missing piece of information found during analysis. This section is filled during gap analysis and cleared after user provides answers._

| # | Gap | Question Asked | User Response |
|---|-----|---------------|---------------|
| 1 | <!-- type: Functional / Context / Reference --> | <!-- question --> | <!-- pending / answer --> |

_If no gaps: write "None — requirements are complete."_

---

## 5. Knowledge Harness Alignment

> _How does this feature fit the overall product vision?_

- **Product vision alignment**: <!-- Reference specific section of product-vision.md -->
- **Existing features affected**: <!-- List features this touches or builds on -->
- **Design principle compliance**: <!-- Which design principles does this uphold? Any tensions? -->
- **Past decisions relevant**: <!-- Reference past-decisions.md entries -->

---

## 6. Options Considered

### Option A — [Title] (Confidence: XX%)

**What**: <!-- What gets built -->  
**Why**: <!-- Why this option solves the problem best -->  
**Scope**: <!-- Summary of in/out of scope for this option -->  
**Effort**: `XS` | `S` | `M` | `L` | `XL`  
**Reversibility**: `Easy` | `Medium` | `Hard`

**Dos**:
- <!-- Must-have behavior -->

**Don'ts**:
- <!-- What this option must NOT do -->

**Risks**:
- <!-- What could go wrong -->

---

### Option B — [Title] (Confidence: XX%)

<!-- Same structure as Option A -->

---

### Option C — [Title] (Confidence: XX%) _(if applicable)_

<!-- Same structure as Option A -->

---

## 7. Recommended Option

**Recommendation**: Option <!-- A / B / C -->  
**Selected by user**: <!-- pending / Option A / Option B -->  
**Rationale**: <!-- Why this is the right choice -->

---

## 8. Acceptance Criteria

> _Follow Given/When/Then format. Each criterion must be independently testable._

### Happy Path
- [ ] **Given** <!-- precondition -->, **When** <!-- action -->, **Then** <!-- expected outcome -->

### Error Handling
- [ ] **Given** <!-- precondition -->, **When** <!-- error condition -->, **Then** <!-- expected error behavior -->

### Edge Cases
- [ ] **Given** <!-- edge condition -->, **When** <!-- action -->, **Then** <!-- expected behavior -->

---

## 9. Non-Functional Requirements

| Category | Requirement | Measurement |
|----------|------------|-------------|
| Performance | <!-- e.g., API response < 200ms at p99 --> | <!-- metric --> |
| Security | <!-- e.g., All inputs sanitized; auth required --> | <!-- verified by security agent --> |
| Accessibility | <!-- e.g., WCAG 2.1 AA --> | <!-- verified by design agent --> |
| Scalability | <!-- e.g., supports 10k concurrent users --> | <!-- load test threshold --> |
| Reliability | <!-- e.g., 99.9% uptime --> | <!-- SLA --> |

---

## 10. Dependencies

| Dependency | Type | Status | Owner |
|-----------|------|--------|-------|
| <!-- e.g., Auth service --> | `internal` \| `external` \| `infra` | `available` \| `in-progress` \| `blocked` | <!-- team/agent --> |

---

## 11. Open Questions

> _Questions that remain unanswered after initial analysis. Must be resolved before coding begins._

- [ ] <!-- Question -->

---

## 12. Approval

| Approver | Status | Timestamp |
|---------|--------|-----------|
| User | `pending` \| `approved` \| `revisions-requested` | <!-- timestamp --> |
| Refinement Agent | `complete` | <!-- timestamp --> |
