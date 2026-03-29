---
title: Error Handling
type: cross-cutting
language:
  - "typescript"
  - "go"
  - "javascript"
status: generated
complexity: medium
dependencies: []
related-notes:
  - "[[Docker Engine]]"
  - "[[Frontend]]"
  - "[[Auth and Security]]"
canonical-source: src/lib/server
generated-by: code-to-docs
generated-at: 2026-03-28T12:00:00Z
mode: full
tags:
  - code-docs
  - cross-cutting
---

# Error Handling

How errors are created, transformed, propagated, and presented across all Dockhand modules.

## Beginner

> [!tip] Prerequisites
> Before reading this section, you should understand:
> - JavaScript try/catch and async error handling
> - HTTP status codes (401, 403, 404, 500)

### What Is This?

Error handling in Dockhand follows a pattern: errors originate deep in the stack (Docker daemon, database, LDAP server), get caught and transformed into user-friendly messages at module boundaries, and are presented to the user as JSON responses or toast notifications.

### Key Concepts

**Error transformation** — Raw errors like `ECONNREFUSED` are caught and wrapped in descriptive error classes like `DockerConnectionError` with messages like "Docker is not reachable on this host."

**Error isolation** — Failures in non-critical operations (audit logging, notifications, metrics) are caught and logged but don't propagate to the caller. The primary operation succeeds even if side effects fail.

## Intermediate

### Error Flow

```mermaid
flowchart TD
    Docker[Docker Daemon Error] -->|raw| DockerMod[docker.ts]
    DockerMod -->|DockerConnectionError| API[API Route]
    API -->|JSON {error, status}| Frontend[Frontend Store]
    Frontend -->|toast notification| UI[User sees error]

    DB[Database Error] -->|SQLITE_BUSY| DBMod[db.ts]
    DBMod -->|throws| API
    API -->|500 JSON| Frontend

    Auth[Auth Error] -->|generic message| AuthMod[auth.ts]
    AuthMod -->|LoginResult {error}| API
    API -->|401/403 JSON| Frontend
```

### Error Categories

| Category | Handling | Example |
|----------|----------|---------|
| **Docker connection** | Caught in `dockerFetch`, wrapped as `DockerConnectionError` | Socket not found, TLS handshake failure |
| **Authentication** | Generic messages (no info leakage) | "Invalid username or password" |
| **Authorization** | `forbidden()` / `unauthorized()` helpers from `authorize.ts` | User lacks permission to start containers |
| **Database** | Propagates as-is (no transformation) | SQLite busy, unique constraint violation |
| **Side effects** | Caught and logged, not propagated | Audit log write failure, notification delivery failure |
| **Subprocess** | Logged to stderr, status sent via IPC | Go collector Docker API timeout |

### Conventions

- **Never expose internal errors to users**: Raw error messages may contain file paths, stack traces, or internal state. API routes catch errors and return sanitized messages.
- **Authentication errors are generic**: Both "user not found" and "wrong password" return the same message to prevent user enumeration.
- **Audit failures don't cascade**: If audit logging fails, the primary operation still succeeds. This is deliberate — observability should not break functionality.

## Advanced

### Error Classes

```typescript
class EnvironmentNotFoundError extends Error  // Environment ID doesn't exist
class DockerConnectionError extends Error     // Docker daemon unreachable
  .fromError(err) → DockerConnectionError     // Factory: ECONNREFUSED → friendly message
```

### Unhandled Errors

The SvelteKit error hook in `hooks.server.ts` catches unhandled errors, logs them (with request context), and returns `{ message, code }`. 404 errors are silently suppressed from logging.

### Go Collector Errors

The Go collector logs errors to stderr (visible in the subprocess manager's output) and sends `error` type messages via IPC for specific, recoverable errors. Fatal errors (panic, startup failure) cause the process to exit, which the subprocess manager detects and can restart.
