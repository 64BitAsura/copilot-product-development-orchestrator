# Domain Model

> **Fill this in.** The domain model defines the core concepts of YOUR product — the entities, their attributes, and how they relate. Every agent uses this as the canonical vocabulary. When writing code, designing UI, or specifying requirements, use the terms defined here.
>
> This model should be reflected in your database schema (`docs/knowledge/schema/base-schema.sql`).

---

## Domain Concepts Overview

<!-- Replace the entities below with YOUR product's core concepts. Use a simple ASCII/Mermaid diagram. -->

```
┌─────────────────────────────────────────────────────────┐
│                   YOUR PRODUCT DOMAIN                    │
│                                                          │
│  ┌──────────┐    [relationship]    ┌──────────────┐     │
│  │ Entity A │─────────────────────►│   Entity B   │     │
│  └──────────┘                      └──────────────┘     │
│                                                          │
│  ┌──────────┐    [relationship]    ┌──────────────┐     │
│  │ Entity C │─────────────────────►│   Entity D   │     │
│  └──────────┘                      └──────────────┘     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Entities

<!-- Define each core entity of your product. Copy this block for each entity. -->

### [Entity Name]

**Description**: [What this concept represents in your product domain]

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | UUID | yes | Unique identifier |
| [attribute] | [type] | yes/no | [description] |

**Business rules**:
- [Rule 1 — e.g., "A user can belong to at most one organisation"]
- [Rule 2]

---

### [Entity Name 2]

**Description**: [What this concept represents]

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | UUID | yes | Unique identifier |
| [attribute] | [type] | yes/no | [description] |

**Business rules**:
- [Rule 1]

---

## Aggregates

<!-- Group related entities into aggregates. An aggregate is a cluster of entities treated as a unit for data changes. -->

| Aggregate Root | Contains | Invariant |
|---------------|---------|----------|
| [Entity A] | [Entity B, Entity C] | [Rule that must always be true within this aggregate] |

---

## Domain Events

<!-- List the key things that happen in your product. These become the basis for event-driven features. -->

| Event | Trigger | Data Payload |
|-------|---------|-------------|
| `[EntityCreated]` | When [entity] is first created | `{ id, [key fields], timestamp }` |
| `[EntityUpdated]` | When [key field] changes | `{ id, previousValue, newValue, timestamp }` |

---

## Ubiquitous Language

<!-- Define the exact terms everyone on the team (agents and humans) uses. Ambiguous terms cause bugs. -->

| Term | Definition | Do NOT say |
|------|-----------|-----------|
| [Term] | [Precise definition in your domain] | [Synonym to avoid] |
| [Term] | [Precise definition in your domain] | [Synonym to avoid] |

---

## Relationships

<!-- Summarize cardinalities between entities. -->

| Entity A | Relationship | Entity B | Notes |
|---------|-------------|---------|-------|
| [Entity A] | one-to-many | [Entity B] | [Context] |
| [Entity A] | many-to-many | [Entity C] | [Via junction table?] |
