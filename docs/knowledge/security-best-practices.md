# Security Best Practices

> This is the security agent's reference library. It codifies security patterns that have been validated for this product. When the security agent discovers a new pattern or finding, it appends it here for future sessions.
>
> **Updated by**: Security agent after each session. **Read by**: Security agent, planning agent, coding agent.

---

## Authentication

### JWT Handling
- Use short-lived access tokens (15 min – 1 hour) with refresh token rotation.
- Store JWTs in memory (JavaScript variable) or `httpOnly` cookies — **never `localStorage`** (XSS risk).
- Validate: signature, algorithm (reject `alg: none`), expiry (`exp`), issuer (`iss`), audience (`aud`).
- Use `RS256` (asymmetric) for tokens verified by multiple services; `HS256` for single-service tokens.
- Secret must be loaded from environment variables, minimum 32 bytes of entropy.

### Session Management
- Regenerate session ID on privilege escalation (login, role change).
- Set session cookie with: `httpOnly`, `Secure`, `SameSite=Strict` (or `Lax`).
- Implement absolute timeout (e.g., 24 hours) and idle timeout (e.g., 2 hours).
- On logout: invalidate session server-side, not just clear the cookie.

### Password Storage
- Use `bcrypt` (cost factor ≥ 12), `argon2id`, or `scrypt` — **never MD5, SHA-1, or unsalted SHA-256**.
- Enforce minimum password length of 12 characters.
- Check against known breached passwords (HaveIBeenPwned API or local wordlist).

---

## Authorisation

- Enforce authorization at the resource level, not just the route level.
- Use `user_id` from the authenticated session — never trust `user_id` from the request body.
- For multi-tenant data: always filter by the authenticated user's organisation/team scope.
- Apply principle of least privilege: request only the permissions actually needed.
- Log authorization failures at INFO level (for detection), not DEBUG (too noisy).

---

## Input Validation

- Validate on the server — client-side validation is UX, not security.
- Use an allowlist approach (accept known-good values) rather than a denylist (block known-bad).
- Validate type, format, length, range, and character set for every input field.
- For file uploads: validate MIME type (content sniffing + magic bytes) AND file extension. Use an allowlist.
- For URLs: validate scheme (only `https://`), reject private IP ranges (SSRF prevention).

---

## SQL Injection

- **Always use parameterised queries / prepared statements.** No string interpolation in SQL.
- ORM query builders that generate parameterised queries are acceptable if all user data goes through parameters.
- Never use raw SQL with user input, even for `ORDER BY` or `LIMIT` — use a lookup table of allowed column names.

```typescript
// ✅ Safe
db.query('SELECT * FROM users WHERE id = $1', [userId]);

// ❌ Unsafe
db.query(`SELECT * FROM users WHERE id = '${userId}'`);
```

---

## XSS (Cross-Site Scripting)

- Escape all user-generated content before rendering in HTML (use template engine auto-escaping).
- Set a strict Content Security Policy (CSP) that blocks inline scripts.
- For rich text: use a server-side HTML sanitiser with an allowlist (e.g., DOMPurify server-side, sanitize-html).
- Never use `innerHTML`, `document.write`, or `eval()` with user data.
- Set `X-Content-Type-Options: nosniff` to prevent MIME-type sniffing.

---

## CSRF (Cross-Site Request Forgery)

- For session-based auth: use `SameSite=Strict` cookies + CSRF token for state-changing requests.
- For JWT-based auth: CSRF is not applicable if tokens are in memory (not cookies).
- For cookie-stored JWTs: implement Double Submit Cookie pattern.

---

## SSRF (Server-Side Request Forgery)

- Never make HTTP requests to user-supplied URLs without strict validation.
- Block requests to private IP ranges: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `127.0.0.0/8`, `169.254.0.0/16`.
- Use an allowlist of permitted external domains where possible.
- Set strict timeouts on outbound HTTP requests (connect: 3s, read: 10s).

---

## Secrets Management

- Secrets are **always** loaded from environment variables — never hardcoded, never committed.
- Use GitHub Actions secrets (via `copilot` environment) for agent-accessible secrets.
- Rotate secrets on suspected compromise; make rotation a documented, practised process.
- Never log secrets, even partially (mask in log output).

---

## Security Headers

Set these headers on all responses:

```
Content-Security-Policy: default-src 'self'; script-src 'self'; object-src 'none'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Strict-Transport-Security: max-age=31536000; includeSubDomains (HTTPS only)
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

---

## Dependency Security

- Run CVE checks on every new dependency before adding it.
- Enable Dependabot or similar automated vulnerability alerts on the repository.
- Pin dependency versions in `package.json` / `requirements.txt` / `Cargo.toml`.
- Audit transitive dependencies for known vulnerabilities.
- Remove unused dependencies — they are attack surface with no benefit.

---

## Logging

- Log: authentication successes and failures, authorization failures, input validation failures, exceptions.
- Never log: passwords, tokens, PII (names, emails, SSNs), payment data.
- Use structured logging (JSON) for machine-parseable audit trails.
- Include: timestamp, user ID (not name), action, resource ID, IP (hashed if privacy-sensitive), outcome.

---

## Appendix: Security Findings Log

> Security agent appends validated findings here after each session so future sessions benefit.

_No entries yet. Findings will be added after the first pipeline run._

<!-- Example entry:
### Finding: JWT algorithm confusion (discovered 2025-01-15)
**Severity**: High
**Pattern**: API accepted `alg: none` in JWT header, bypassing signature verification.
**Fix**: Explicitly specify the allowed algorithm when verifying tokens — never rely on the token's own `alg` claim.
**Applied to**: All JWT verification code.
-->
