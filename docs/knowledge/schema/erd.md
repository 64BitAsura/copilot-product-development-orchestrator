# Entity Relationship Diagram

> **Fill this in.** Update this diagram whenever the data model changes. Keep it in sync with `schema.md` and `domain-model.md`.
>
> Rendered with [Mermaid](https://mermaid.js.org/syntax/entityRelationshipDiagram.html).
> Field types here are **logical types** (string, timestamp, enum, reference) — not tied to any specific database technology.

---

## Current ERD

```mermaid
erDiagram

    users {
        uuid      id                PK
        string    email
        timestamp email_verified_at
        string    display_name
        string    avatar_url
        enum      status
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    organizations {
        uuid      id          PK
        string    slug
        string    name
        uuid      created_by  FK
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    organization_members {
        uuid      id              PK
        uuid      organization_id FK
        uuid      user_id         FK
        enum      role
        uuid      invited_by      FK
        timestamp joined_at
    }

    %% --- Add your product's entities here ---
    %% your_entity {
    %%     uuid   id              PK
    %%     uuid   organization_id FK
    %%     uuid   created_by      FK
    %%     string name
    %% }

    %% Relationships
    users               ||--o{    organizations           : "creates"
    organizations       ||--o{    organization_members    : "has"
    users               ||--o{    organization_members    : "joins"
    users               ||--o{    organization_members    : "invites (invited_by)"

    %% Add your relationships:
    %% organizations  ||--o{ your_entity : "contains"
    %% users          ||--o{ your_entity : "creates"
```

---

## Relationship Cardinalities

| From | Relationship | To | Notes |
|------|-------------|-----|-------|
| `users` | one-to-many | `organizations` | A user can create multiple orgs |
| `organizations` | one-to-many | `organization_members` | An org has many member records |
| `users` | one-to-many | `organization_members` | A user can be in multiple orgs |

---

## Notes

- Field types in this diagram are logical (database-agnostic). Translate them to the appropriate native type when implementing in your chosen database.
- Soft-deleted entities carry a nullable `deleted_at` timestamp; `null` means the record is active.
- Add new entities to both this diagram and `schema.md` when the data model changes.
