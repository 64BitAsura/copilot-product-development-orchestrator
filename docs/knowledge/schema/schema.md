# Data Schema

> **Fill this in.** This file describes your product's data entities, their fields, and how they relate to each other.
>
> This is **not** a SQL file or tied to any specific storage technology. Use whatever database fits your product — relational (PostgreSQL, MySQL, SQLite), document (MongoDB, Firestore), graph (Neo4j, ArangoDB), columnar (Cassandra, DynamoDB), time-series (InfluxDB, TimescaleDB), or a mix.
>
> This file is the **source of truth** for all agents that work with data. It must stay in sync with `erd.md` and `docs/knowledge/blueprint/domain-model.md`.

---

## Storage Technology

<!-- Record the database(s) your product actually uses. Update this when tech decisions are made. -->

| Role | Technology | Notes |
|------|-----------|-------|
| Primary datastore | _(to be decided)_ | |
| Cache | _(to be decided)_ | |
| Search index | _(to be decided)_ | |

---

## Entities

<!-- Define each core entity. Copy this block for each one.
     "Type" uses logical types (string, integer, boolean, timestamp, uuid, enum, object, array, reference) rather than DB-specific types. -->

### [EntityName]

**Description**: [What this concept stores and why it exists]

**Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | uuid | yes | Unique identifier |
| [field] | [type] | yes / no | [description] |
| created_at | timestamp | yes | When the record was created |
| updated_at | timestamp | no | When the record was last modified (nullable on immutable entities) |
| deleted_at | timestamp | no | Soft-delete marker; `null` means not deleted |

**Constraints / rules**:
- [e.g., "email must be unique across active records"]
- [e.g., "status must be one of: active, suspended, deleted"]

---

### [EntityName2]

**Description**: [What this concept stores and why it exists]

**Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | uuid | yes | Unique identifier |
| [entity_name]_id | reference → [EntityName] | yes | Foreign reference |
| [field] | [type] | yes / no | [description] |
| created_at | timestamp | yes | When the record was created |

**Constraints / rules**:
- [e.g., "one record per (user, organization) pair"]

---

<!-- Add more entity blocks as needed -->

---

## Relationships

| Entity A | Cardinality | Entity B | Notes |
|---------|------------|---------|-------|
| [EntityName] | one-to-many | [EntityName2] | [e.g., "A user creates many posts"] |
| [EntityA] | many-to-many | [EntityC] | [e.g., "via the entity_a_entity_c junction"] |

---

## Indexes & Access Patterns

<!-- Describe which fields need fast lookups. This section informs DB-specific index or partition decisions made later. -->

| Entity | Field(s) | Access pattern | Notes |
|--------|---------|----------------|-------|
| [EntityName] | email | Lookup by email on login | Must be unique on active records |
| [EntityName2] | [entity_name]_id | List all children of a parent | High-frequency query |

---

## Notes

- Replace all placeholder brackets with your product's actual entities.
- "reference" fields point to another entity's `id`. How this is physically stored (foreign key, embedded ID, etc.) depends on the chosen database.
- Add new entities to both this file and `erd.md` whenever the data model changes.
- Record breaking changes in `docs/knowledge/requirements/past-decisions.md`.
