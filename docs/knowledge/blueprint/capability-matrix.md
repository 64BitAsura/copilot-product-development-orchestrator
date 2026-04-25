# Capability Matrix

> **Fill this in.** Maps every product capability to the team, service, or module responsible for it. Used by the planning agent to understand ownership and avoid duplicating functionality. Helps coding agents know which existing module to extend versus when to create something new.

---

## How to Read This

- **Owner**: The team, module, or service primarily responsible for this capability.
- **Exposed via**: How the capability is accessed (API endpoint, library function, event, UI screen).
- **Consumers**: Who or what calls or depends on this capability.

---

## Capability Areas

<!-- Replace these with YOUR product's capability areas. Common examples: Identity, Billing, Notifications, Content, Search, etc. -->

### [Capability Area 1 — e.g., Identity & Access]

| Capability | Owner | Exposed via | Consumers |
|-----------|-------|------------|----------|
| [e.g., User registration] | [e.g., auth-service] | [e.g., POST /api/auth/register] | [e.g., onboarding flow, mobile app] |
| [e.g., Login / token issue] | [e.g., auth-service] | [e.g., POST /api/auth/login] | [e.g., all authenticated features] |
| [e.g., Password reset] | [e.g., auth-service] | [e.g., POST /api/auth/reset-password] | [e.g., login screen] |

---

### [Capability Area 2 — e.g., Content Management]

| Capability | Owner | Exposed via | Consumers |
|-----------|-------|------------|----------|
| [Capability] | [Owner] | [Exposed via] | [Consumers] |

---

### [Capability Area 3 — e.g., Notifications]

| Capability | Owner | Exposed via | Consumers |
|-----------|-------|------------|----------|
| [Capability] | [Owner] | [Exposed via] | [Consumers] |

---

## Ownership Rules

<!-- Hard rules that prevent two modules from owning the same thing. Add your own. -->

| Rule | Rationale |
|------|----------|
| Only **[module/service]** writes to the `[entity]` table | Prevents split-brain on [entity] state |
| Only **[module/service]** sends emails | Ensures consistent email formatting and rate limiting |
| Only **[module/service]** handles payment processing | PCI compliance — payment data must not be scattered |
| [Your rule] | [Your rationale] |

---

## Planned Capabilities (Not Yet Built)

<!-- Capabilities that are on the roadmap but not yet implemented. Helps the planning agent avoid designing around missing infrastructure. -->

| Capability | Target Area | Priority | Notes |
|-----------|------------|---------|-------|
| [Capability] | [Area] | High / Medium / Low | [Why it is not built yet] |
