---
title: Per-Resource Locking
type: pattern
language:
  - "typescript"
  - "go"
status: generated
complexity: medium
dependencies:
  - "[[Stacks and Git]]"
  - "[[Infrastructure Services]]"
related-notes:
  - "[[Scheduler]]"
  - "[[Hawser Edge]]"
canonical-source: src/lib/server/stacks.ts
generated-by: code-to-docs
generated-at: 2026-03-28T12:00:00Z
mode: full
tags:
  - code-docs
  - pattern
---

# Per-Resource Locking

Serialization of concurrent operations on the same resource using Promise chains or semaphores, preventing race conditions without global locks.

## Beginner

> [!tip] Prerequisites
> Before reading this section, you should be comfortable with:
> - What a race condition is (two operations interfering with each other)
> - JavaScript Promises (asynchronous operations)

### What Is This?

When two users try to deploy the same stack at the same time, bad things can happen — files get overwritten, containers start twice, or configurations conflict. Per-resource locking ensures that only one operation runs on a given resource at a time, while allowing different resources to be operated on in parallel.

### How It Works

```typescript
// Only one operation per stack name at a time
const stackLocks = new Map<string, Promise<void>>();

async function withStackLock(name, fn) {
  const prev = stackLocks.get(name) || Promise.resolve();
  const next = prev.then(fn);
  stackLocks.set(name, next);
  return next;
}
```

## Intermediate

### Where It Appears

| Module | Lock Target | Mechanism |
|--------|------------|-----------|
| `stacks.ts` | Stack name | Promise chain (`withStackLock`) |
| `scanner.ts` | Scanner type | Promise queue (serial locking) |
| `scheduler/index.ts` | Environment ID | `Set<number>` for env update checks |
| Go Collector | Environment map | `sync.Mutex` |
| Hawser Edge | Environment ID | Single-connection-per-env model |

### Why This Pattern

A global lock would serialize all operations across all resources. Per-resource locks allow maximum parallelism: deploy Stack A while simultaneously deploying Stack B, scan Image X while scanning Image Y. Only concurrent operations on the *same* resource are serialized.

### Trade-offs

- **No cross-resource coordination**: Deploying a stack that depends on another stack's network being ready requires manual sequencing — the locks don't help.
- **Promise chain growth**: In `stacks.ts`, the lock Map accumulates resolved Promises. These are garbage-collected, but the Map entries persist until the process restarts.
- **No deadlock detection**: If a locked operation hangs (e.g., Docker compose timeout), the lock is held until the timeout fires. No mechanism to detect or break deadlocks.

## Advanced

### Single-Threaded Advantage

In Node.js, the event loop ensures that lock acquisition (Map lookup + set) is atomic without needing mutexes. The Go Collector, running multi-threaded, requires `sync.Mutex` for the same pattern.

### Cleanup

Stack locks and scanner locks are never explicitly cleaned up — resolved Promises in the Map are lightweight. The Hawser Edge module's connection replacement is more aggressive: connecting a new agent for the same environment immediately terminates the old connection and rejects all pending requests.
