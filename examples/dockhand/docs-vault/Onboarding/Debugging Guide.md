---
title: Debugging Guide
type: onboarding
language:
  - "typescript"
  - "go"
status: generated
complexity: medium
dependencies: []
related-notes:
  - "[[Getting Started]]"
  - "[[Docker Engine]]"
  - "[[Infrastructure Services]]"
canonical-source: src/lib/server
generated-by: code-to-docs
generated-at: 2026-03-28T12:00:00Z
mode: full
tags:
  - code-docs
  - onboarding
---

# Debugging Guide

Common debugging scenarios and how to investigate them.

## Docker Connection Issues

**Symptom:** "Docker is not reachable" or environment shows as offline.

**Investigation:**
1. Check the Docker socket exists: `ls -la /var/run/docker.sock`
2. Verify Docker is running: `docker info`
3. Check Dockhand logs for `DockerConnectionError` messages — they include the specific error type (ECONNREFUSED, ENOENT, ETIMEDOUT)
4. For remote environments, verify TLS certificates are valid and the port is accessible

**Key file:** `src/lib/server/docker.ts` — search for `DockerConnectionError.fromError()` to see how errors are classified.

## Authentication Problems

**Symptom:** Login fails, sessions expire unexpectedly, or permissions don't work.

**Investigation:**
1. Check if auth is enabled: look for `isAuthEnabled()` returns in the database settings
2. Rate limiting: after 5 failed attempts, the account is locked for 15 minutes. Check `isRateLimited()` in `auth.ts`
3. LDAP: use `testLdapConnection()` to validate the configuration. Check for LDAP filter injection issues
4. OIDC: verify the discovery document is reachable. Check the OIDC state store for expired states (10-minute TTL)
5. Session issues: sessions are stored in the database. Check the sessions table for the user

**Key file:** `src/lib/server/auth.ts`

## Scheduled Task Failures

**Symptom:** Auto-updates don't run, git stacks don't sync, or scheduled tasks show as failed.

**Investigation:**
1. Check the schedule executions table for error logs — the scheduler records detailed logs for every run
2. Verify the cron expression is valid: `isValidCron(expression)` in `scheduler/cron-utils.ts`
3. For container updates: check if vulnerability scanning is blocking the update (criteria-based blocking)
4. For git syncs: check if the git stack is stuck in 'syncing' state (crash recovery resets these on startup)
5. Timezone issues: each environment can have a custom timezone. Verify it matches your expectations

**Key file:** `src/lib/server/scheduler/index.ts`

## Real-Time Updates Not Working

**Symptom:** Dashboard doesn't update, containers don't show status changes.

**Investigation:**
1. Check browser DevTools Network tab for the SSE connection (`/api/events?env=...`)
2. If the connection is failing, check authentication (SSE requires a valid session)
3. For edge environments: events come through Hawser WebSocket, not SSE. Verify the agent is connected
4. Check if the Go collector subprocess is running — it provides metrics and events for local environments
5. The events store has reconnection logic (5 attempts, 3s delay). After exhaustion, switch environments or reload

**Key files:** `src/lib/stores/events.ts`, `src/lib/server/subprocess-manager.ts`

## Database Issues

**Symptom:** Errors about locked database, missing tables, or migration failures.

**Investigation:**
1. SQLite lock: WAL mode allows concurrent reads but only one writer. Check for long-running operations holding the write lock
2. Migration failure: check server startup logs. Failed migrations don't roll back automatically
3. Schema health: `checkSchemaHealth()` validates expected tables and columns
4. Encryption: if credentials are garbled, the encryption key may have changed. Check `ENCRYPTION_KEY` env var and `DATA_DIR/encryption.key` file

**Key files:** `src/lib/server/db/drizzle.ts`, `src/lib/server/encryption.ts`

## Memory and Performance

**Symptom:** Server memory grows over time, responses are slow.

**Investigation:**
1. Enable memory monitoring: set `MEMORY_MONITOR=true` environment variable
2. Check RSS stats: `getRssStats()` in `rss-tracker.ts` shows per-operation memory deltas
3. Heap snapshots: `dumpHeapSnapshot()` writes V8 heap snapshots to `DATA_DIR/snapshots/`
4. Docker client cache: check if `envCache` or `agentCache` in `docker.ts` are growing unboundedly (cleanup runs every 5 minutes)
5. Metrics ring buffer: fixed-size by design — should not grow. If metrics are stale, the Go collector may have crashed

**Key files:** `src/lib/server/rss-tracker.ts`, `src/lib/server/docker.ts`
