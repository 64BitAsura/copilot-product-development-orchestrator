# Integration Points

> **Fill this in.** Maps every boundary where your product's components and external services connect. The security agent reads this to identify attack surfaces; the planning agent reads this to understand the side-effects of changes. Any integration that crosses a trust boundary must be documented here.

---

## How to Add an Integration

```markdown
### [Your Service] → [External Service]

| Attribute | Value |
|-----------|-------|
| Direction | [Which side initiates the connection] |
| Protocol | [HTTP, WebSocket, gRPC, message queue, etc.] |
| Auth mechanism | [API key, OAuth 2.0, mTLS, etc.] |
| Data sent | [What data crosses this boundary] |
| Data received | [What data comes back] |
| Failure behavior | [What happens when this integration is unavailable] |
| Rate limits | [Any known rate limits] |
| Trust level | Trusted / Semi-trusted / Untrusted |
```

---

## Internal Integrations (Service-to-Service)

<!-- List how internal services/modules communicate with each other. -->

### [Service A] → [Service B]

| Attribute | Value |
|-----------|-------|
| Direction | [Service A] calls [Service B] |
| Protocol | [e.g., HTTP REST] |
| Auth mechanism | [e.g., internal service token] |
| Data sent | [description] |
| Data received | [description] |
| Failure behavior | [e.g., return cached result, surface error to user] |
| Trust level | Trusted |

---

## External Integrations (Third-Party Services)

<!-- List every external service your product calls or receives calls from. -->

### [Your Product] → [External Service e.g., Email Provider]

| Attribute | Value |
|-----------|-------|
| Direction | Outbound |
| Protocol | [e.g., HTTPS REST] |
| Auth mechanism | [e.g., API key in header] |
| Data sent | [e.g., recipient address, subject, HTML body] |
| Data received | [e.g., message ID, delivery status] |
| Failure behavior | [e.g., queue for retry, notify admin after 3 failures] |
| Rate limits | [e.g., 100 emails/hour on free tier] |
| Trust level | Semi-trusted |

---

### [External Service e.g., Payment Provider] → [Your Product]

| Attribute | Value |
|-----------|-------|
| Direction | Inbound webhook |
| Protocol | [e.g., HTTPS POST] |
| Auth mechanism | [e.g., webhook signature verification] |
| Data received | [e.g., payment status events] |
| Validation | [e.g., verify HMAC-SHA256 signature before processing] |
| Trust level | Semi-trusted — validate all payloads |

---

## Trust Boundary Map

<!-- Define the trust zones for your product. Customize these based on your architecture. -->

```
┌──────────────────────────────────┐
│         TRUSTED ZONE             │
│  - Core application services     │
│  - Internal databases            │
│  - Background job workers        │
└──────────────┬───────────────────┘
               │ controlled access
┌──────────────▼───────────────────┐
│       SEMI-TRUSTED ZONE          │
│  - Authenticated user requests   │
│  - Verified partner webhooks     │
│  - Internal admin tools          │
└──────────────┬───────────────────┘
               │ validate all input
┌──────────────▼───────────────────┐
│        UNTRUSTED ZONE            │
│  - Public API requests           │
│  - Third-party webhook payloads  │
│  - User-uploaded content         │
│  - Web search / scraped content  │
└──────────────────────────────────┘
```

**Rule**: Data from the untrusted zone must be validated and sanitized before use. It must never be:
- Executed as code
- Passed directly into database queries (use parameterised statements)
- Rendered as HTML without sanitization

---

## Integration Inventory

| Integration | Direction | Protocol | Trust Level | Status |
|------------|----------|---------|------------|--------|
| [Service] | Outbound | [Protocol] | [Level] | planned / live |
