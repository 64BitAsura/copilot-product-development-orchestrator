# Blueprint

> The blueprint is the **single source of truth for how all features, requirements, and domains fit together** as a coherent product. It is the big picture that the refinement agent, planning agent, and design agent all consult before making decisions.
>
> Think of it as the product's architectural blueprint — like the master drawing on a construction site that every subcontractor refers to.

---

## Folder Contents

| File | Purpose |
|------|---------|
| `README.md` | This file — index and usage guide |
| `feature-map.md` | Complete map of all product features, their status, and how they relate |
| `domain-model.md` | Core domain concepts (entities, aggregates, value objects) and their relationships |
| `integration-points.md` | How features, services, and agents connect and depend on each other |
| `capability-matrix.md` | Which agents are responsible for which capabilities |
| `evolution-roadmap.md` | How the product is expected to evolve (v1 → v2 → v3) |

---

## How Agents Use the Blueprint

### Refinement Agent
- Reads `feature-map.md` to check if a requested feature already exists (fully or partially)
- Reads `domain-model.md` to ensure new requirements use the correct domain language
- Reads `integration-points.md` to identify dependencies and affected systems
- Updates `feature-map.md` after requirements are approved (new feature → `planned` status)

### Planning Agent
- Reads `domain-model.md` to align data model changes with existing entities
- Reads `integration-points.md` to identify which services/modules will be touched
- Reads `capability-matrix.md` to know which agent to delegate to
- Updates `feature-map.md` after implementation is complete (status → `shipped`)

### Design Agent
- Reads `feature-map.md` to understand adjacent features and design consistency needs
- Reads `domain-model.md` to use correct terminology in UI copy

### Security Agent
- Reads `integration-points.md` to identify all trust boundaries a new feature crosses
- Reads `domain-model.md` to identify which entities hold sensitive data

---

## Blueprint Maintenance Rules

1. **No agent modifies the blueprint without updating the relevant section.** After every pipeline run, the feature map must be updated.
2. **The domain model is append-first.** New entities are added; existing entities are modified only with strong justification (domain model changes are breaking).
3. **Integration points must be kept current.** Any new service-to-service call, MCP integration, or external API dependency must be added to `integration-points.md`.
4. **The evolution roadmap is owned by the refinement agent.** Only approved user decisions update it.
5. **The blueprint is source-controlled.** Its history tells the story of how the product evolved.

---

## Blueprint Health Checklist

Run this check at the start of every pipeline session:

- [ ] `feature-map.md` reflects the current state of the codebase (no phantom features)
- [ ] `domain-model.md` matches the database schema in `docs/knowledge/schema/`
- [ ] `integration-points.md` lists all active external integrations
- [ ] No features are marked `in-progress` for more than 30 days (stale work)
- [ ] Every `planned` feature has a corresponding GitHub issue
