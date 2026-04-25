# Testing Guidelines

> Standards and patterns for all tests written in this repository. The tester agent reads this before writing any test. When a new testing pattern is established, the tester agent appends it here.

---

## Core Principles

1. **Tests prove behaviour, not implementation.** Test what the code does, not how it does it.
2. **One assertion per concept.** A test can have multiple `expect` calls if they together verify one logical behaviour.
3. **Tests are documentation.** A test name should describe the scenario so completely that reading the test file gives you a behaviour specification.
4. **Tests must be deterministic.** A test that passes sometimes is worse than no test.
5. **Tests must be fast.** Unit tests < 10ms. Integration tests < 1s per test.

---

## Test Structure

Use the **Arrange / Act / Assert** (AAA) pattern:

```typescript
it('returns the resource when the authenticated owner requests it', async () => {
  // Arrange
  const user = await createUser();
  const resource = await createResource({ ownerId: user.id, title: 'My Resource' });
  const token = generateToken(user);

  // Act
  const response = await request(app)
    .get(`/api/resources/${resource.id}`)
    .set('Authorization', `Bearer ${token}`);

  // Assert
  expect(response.status).toBe(200);
  expect(response.body.id).toBe(resource.id);
  expect(response.body.title).toBe('My Resource');
});
```

---

## Test Naming

Format: `'<verb> <result> when <condition>'`

```
✅ 'returns 401 when request has no auth token'
✅ 'creates a draft and returns 201 when all required fields are provided'
✅ 'does not delete the resource when user is not the owner'

❌ 'test auth'
❌ 'works correctly'
❌ 'should return the right thing'
```

---

## Unit Tests

**Scope**: A single function, class, or module with all external dependencies mocked.

**Use when**:
- Testing business logic with branching conditions
- Testing error handling paths
- Testing data transformation functions
- Testing validation logic

**Do not use for**:
- Testing that a database query returns the right rows (use integration tests)
- Testing HTTP routing (use integration tests)

```typescript
// Good unit test: tests pure business logic
describe('calculatePipelineProgress', () => {
  it('returns 0 when no stages are completed', () => {
    const stages = [
      { type: 'requirements', status: 'pending' },
      { type: 'design', status: 'pending' },
    ];
    expect(calculatePipelineProgress(stages)).toBe(0);
  });

  it('returns 100 when all stages are completed', () => {
    const stages = STAGE_TYPES.map(type => ({ type, status: 'completed' }));
    expect(calculatePipelineProgress(stages)).toBe(100);
  });
});
```

---

## Integration Tests

**Scope**: A component tested with its real dependencies (database, file system). Use a test database, not a mock.

**Use when**:
- Testing API endpoints end-to-end (HTTP request → response)
- Testing database queries (real SQL against test database)
- Testing service-to-service interactions within the application

**Setup requirements**:
- Test database is seeded and torn down per test (or per suite with cleanup)
- No shared state between tests
- Use factories to create test data — no hardcoded IDs

```typescript
// Good integration test: tests the full HTTP request/response cycle
describe('POST /api/pipeline-runs', () => {
  let db: TestDatabase;
  let app: Express;

  beforeAll(async () => {
    db = await createTestDatabase();
    app = createApp({ db });
  });

  afterAll(() => db.destroy());

  beforeEach(() => db.truncateAll());

  it('creates a pipeline run and returns 201 with the run ID', async () => {
    const user = await db.factories.user.create();
    const input = await db.factories.input.create({ ownerId: user.id });

    const response = await request(app)
      .post('/api/pipeline-runs')
      .set('Authorization', `Bearer ${generateToken(user)}`)
      .send({ inputId: input.id });

    expect(response.status).toBe(201);
    expect(response.body.id).toMatch(UUID_PATTERN);
    expect(response.body.status).toBe('in_progress');

    const run = await db.pipelineRuns.findById(response.body.id);
    expect(run).not.toBeNull();
  });
});
```

---

## Coverage Requirements

| Scope | Minimum Coverage |
|-------|----------------|
| New files created in this pipeline run | 80% line coverage |
| Modified files (changed lines) | 80% branch coverage |
| Overall repository | No regression from baseline |

---

## Test Data

### Factories
Use factory functions to create test data. Never hardcode UUIDs or user IDs.

```typescript
// ✅ Use factories
const user = await factory.user.create({ role: 'admin' });

// ❌ Hardcoded
const userId = '550e8400-e29b-41d4-a716-446655440000';
```

### Test Database
- Use a separate test database (never the development or production database).
- Truncate between tests — never delete; truncation is faster.
- Run migrations against the test database before the test suite.

### Time
- Mock `Date.now()` and `new Date()` when testing time-dependent logic.
- Never write assertions that depend on wall clock time (e.g., checking that a timestamp is "close to now").

---

## What NOT to Test

| Anti-Pattern | Reason |
|-------------|--------|
| Testing framework or library behaviour | Trust the library's own tests |
| Testing getter/setter boilerplate | No logic = no test value |
| Testing constants | They don't change |
| Snapshot testing for complex objects | Brittle; fails on any output change |
| Testing private methods directly | Refactor the test, not the encapsulation |
| E2E browser tests | Out of scope for this pipeline |

---

## Security Test Patterns

See `docs/knowledge/security-best-practices.md` for context. Always include these for features with auth:

1. **Auth bypass**: Request without a token → 401
2. **Expired token**: Request with expired JWT → 401
3. **Cross-user access**: User A accessing User B's resource → 403
4. **Role escalation**: User with read-only role attempting write → 403
5. **SQL injection payload in input**: Should return 400 without side effects
6. **Oversized input**: Should return 400 within a reasonable time (no DoS)

---

## Appendix: Framework-Specific Patterns

> Tester agent appends language/framework-specific patterns here after each session.

_No entries yet. Patterns will be added after the first pipeline run._

<!-- Example entry:
### Node.js + Express + Jest (added 2025-01-15)
- Use `supertest` for HTTP integration tests
- Use `jest.useFakeTimers()` for time-dependent tests
- Database: `pg` with a test schema, truncated via `TRUNCATE ... CASCADE`
-->
