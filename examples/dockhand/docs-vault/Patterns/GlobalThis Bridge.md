---
title: GlobalThis Bridge
type: pattern
language:
  - "javascript"
  - "typescript"
status: generated
complexity: medium
dependencies:
  - "[[Production Server]]"
  - "[[Hawser Edge]]"
  - "[[Docker Engine]]"
related-notes:
  - "[[System Overview]]"
canonical-source: server.js
generated-by: code-to-docs
generated-at: 2026-03-28T12:00:00Z
mode: full
tags:
  - code-docs
  - pattern
---

# GlobalThis Bridge

A runtime communication pattern where separately-loaded modules register and consume functions via `globalThis`, avoiding static import dependencies and surviving HMR reloads.

## Beginner

> [!tip] Prerequisites
> Before reading this section, you should be comfortable with:
> - What `globalThis` is (the global object in JavaScript, accessible everywhere)
> - Why modules can't always import each other directly (circular dependencies, separate build outputs)

### What Is This?

Some parts of Dockhand can't import each other directly. The production server (`server.js`) starts before SvelteKit loads, but needs SvelteKit's Docker and Hawser functionality for WebSocket handling. The solution: SvelteKit modules register functions on `globalThis` during initialization, and `server.js` calls them at runtime.

### How It Works

1. SvelteKit starts and `hawser.ts` registers `globalThis.__hawserHandleMessage`.
2. SvelteKit starts and `docker.ts` registers `globalThis.__terminalCreateExec`.
3. A WebSocket upgrade arrives at `server.js`.
4. `server.js` calls `globalThis.__hawserHandleMessage(ws, msg, connId, ip)`.

## Intermediate

### Where It Appears

**Producer → Consumer:**
- `hawser.ts` registers → `server.js` calls: `__hawserSendMessage`, `__hawserHandleMessage`, `__hawserHandleDisconnect`, `__hawserHandleContainerEvent`, `__hawserHandleMetrics`
- `docker.ts` registers → `server.js` calls: `__terminalGetTarget`, `__terminalCreateExec`, `__terminalResizeExec`
- HMR: `event-collector.ts` stores the EventEmitter on `globalThis` to survive hot reloads

### Why This Pattern

SvelteKit's adapter-node produces a compiled handler module. `server.js` wraps this handler but cannot import SvelteKit's internal modules directly (they're compiled into the build output with different paths). The `globalThis` bridge decouples the two codebases at runtime.

For HMR survival, Vite re-executes modules on change. Module-level singletons (EventEmitters, Maps, intervals) would be duplicated. Storing them on `globalThis` with existence checks ensures one instance persists.

### Risks

- **Startup race**: `server.js` may receive WebSocket connections before SvelteKit registers its handlers. Mitigated by fallback logic (local Docker socket for terminal, silent failure for Hawser).
- **No type safety**: `globalThis` functions are untyped. TypeScript can't verify the contract between producer and consumer.
- **Hidden dependencies**: `grep` for a function name won't find the `globalThis` registration unless you know to search for the double-underscore prefix convention.

## Advanced

### Naming Convention

All bridge functions use the `__` prefix (e.g., `__hawserSendMessage`). This signals "framework-internal, do not call from application code." The prefix also makes grep-based discovery straightforward.

### Lifecycle

Functions registered on `globalThis` persist for the process lifetime. There is no deregistration mechanism. In development, HMR may re-register functions, but the old references are simply overwritten.
