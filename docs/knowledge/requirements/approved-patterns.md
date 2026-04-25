# Approved Requirement Patterns

> Pre-approved patterns for common feature types. When a request matches one of these patterns, the requirements agent can use it as a starting point and adapt it to the specific context, rather than starting from scratch.
>
> Each pattern includes the standard scope, common gaps, accepted options, and known anti-patterns.

---

## Pattern: User Authentication

**Trigger**: Request involves login, logout, sign-up, password reset, session management, OAuth, SSO.

### Standard Scope (In)
- Email + password authentication
- Password reset via email link
- Session management (login/logout)
- Remember me (optional)
- Rate limiting on auth endpoints

### Standard Out of Scope (unless explicitly requested)
- Social login (OAuth) — separate feature
- Multi-factor authentication — separate feature
- SSO / SAML — separate feature
- Account deletion — separate feature

### Common Gaps to Check
- Password requirements (minimum length, complexity)
- Session duration / expiry policy
- What happens to existing sessions on password reset?
- Which user roles exist?

### Standard Options
- **Option A**: JWT-based stateless auth (good for APIs)
- **Option B**: Session-based auth with server-side store (good for web apps)
- **Option C**: Third-party auth provider (Auth0, Clerk, Supabase Auth)

### Anti-Patterns
- Storing passwords in plaintext
- Tokens in localStorage (use httpOnly cookies or memory)
- No CSRF protection on session-based auth

---

## Pattern: CRUD Feature (Create, Read, Update, Delete)

**Trigger**: Request involves managing a resource (creating, listing, editing, deleting items).

### Standard Scope (In)
- Create endpoint + form/UI
- List/index view with pagination
- Detail/read view
- Update endpoint + form/UI
- Delete with confirmation
- Input validation (server-side required, client-side optional)
- Authorization checks on each operation

### Standard Out of Scope (unless explicitly requested)
- Bulk operations
- Soft delete / trash / restore
- Audit log / history
- Search and filtering (separate feature)
- Export (separate feature)

### Common Gaps to Check
- Who can create / read / update / delete? (per-user? per-role? per-organization?)
- Should deletes be hard or soft?
- What fields are required vs. optional?
- Is there a maximum record count?
- What happens to related records on delete?

### Standard Options
- **Option A**: REST endpoints + standard form UI
- **Option B**: REST endpoints + inline editing UI (advanced)
- **Option C**: GraphQL mutations (if already using GraphQL)

### Anti-Patterns
- Deleting without confirmation (for destructive actions)
- No pagination on list endpoints (performance risk)
- Exposing all fields in list response (over-fetching)

---

## Pattern: Search and Filtering

**Trigger**: Request involves finding, filtering, or sorting a list of records.

### Standard Scope (In)
- Text search across specified fields
- Filter by specified attributes (status, date, category, etc.)
- Sort by specified fields (asc/desc)
- Pagination of results
- URL-persistent search state (so results are shareable)

### Standard Out of Scope (unless explicitly requested)
- Full-text search with relevance ranking (needs search engine like Elasticsearch/Typesense)
- Saved search / search history
- Faceted search with counts
- Fuzzy/typo-tolerant search

### Common Gaps to Check
- Which fields are searchable?
- Which fields are filterable?
- What is the maximum result set size?
- Should search be real-time (debounced) or on-submit?
- Empty search state: show all? show nothing?

### Standard Options
- **Option A**: Database LIKE query (simple, no external dependency)
- **Option B**: Full-text search index (PostgreSQL tsvector, SQLite FTS5)
- **Option C**: External search service (Typesense, Algolia, Elasticsearch)

### Anti-Patterns
- `SELECT * WHERE name LIKE '%query%'` without an index (performance)
- No debounce on real-time search input
- Searching across all tables/fields without boundaries

---

## Pattern: Notifications

**Trigger**: Request involves alerting users about events (email, in-app, push, webhook).

### Standard Scope (In)
- Trigger definition (which event fires the notification)
- Delivery channel (email / in-app / both)
- Notification content template
- User preference to opt-out (legal requirement in many jurisdictions)

### Standard Out of Scope (unless explicitly requested)
- Push notifications (mobile) — needs mobile app
- SMS — separate integration
- Digest/summary emails — separate feature
- Notification history / inbox — separate feature

### Common Gaps to Check
- Which events trigger notifications?
- Who receives them (author, assignees, all team members)?
- Can users opt out? Is opt-out required by law?
- What is the email sender (address, display name)?
- Are notifications real-time or batched?

### Standard Options
- **Option A**: Email only via transactional email service (SendGrid, Resend, SES)
- **Option B**: In-app notifications only (database-backed, polled or WebSocket)
- **Option C**: Both email + in-app with user preferences

### Anti-Patterns
- Sending notifications synchronously in the request/response cycle (use background jobs)
- No unsubscribe link in emails (violates CAN-SPAM / GDPR)
- No deduplication (sending the same notification multiple times)

---

## Pattern: File Upload

**Trigger**: Request involves users uploading files, images, documents, or media.

### Standard Scope (In)
- Single or multiple file upload
- File type validation (allowlist, not blocklist)
- File size limits (client + server validation)
- Storage in object storage (S3, GCS, Azure Blob)
- Serving files via signed URLs (if private)

### Standard Out of Scope (unless explicitly requested)
- Image processing / resizing / transcoding
- Virus scanning
- CDN distribution
- Large file chunked upload (> 5GB)

### Common Gaps to Check
- What file types are allowed?
- What is the maximum file size?
- Are files public or private (access control)?
- How long should files be retained?
- Is resumable upload needed (for large files)?

### Standard Options
- **Option A**: Direct upload to server, then transfer to object storage
- **Option B**: Pre-signed URL upload (client uploads directly to S3/GCS)
- **Option C**: Third-party file handling service (Uploadthing, Cloudinary)

### Anti-Patterns
- Storing user files on the application server filesystem (no persistence on restart)
- Serving user uploads from the same domain without Content-Disposition header (XSS risk)
- Trusting file extension alone for type validation (use MIME type + magic bytes)

---

## How to Add a New Pattern

```markdown
## Pattern: [Feature Type]

**Trigger**: [What kinds of requests match this pattern]

### Standard Scope (In)
- ...

### Standard Out of Scope
- ...

### Common Gaps to Check
- ...

### Standard Options
- **Option A**: ...
- **Option B**: ...

### Anti-Patterns
- ...
```
