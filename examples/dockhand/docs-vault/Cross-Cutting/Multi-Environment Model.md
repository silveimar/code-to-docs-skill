---
title: Multi-Environment Model
type: cross-cutting
language:
  - "typescript"
status: generated
complexity: medium
dependencies: []
related-notes:
  - "[[Docker Engine]]"
  - "[[Hawser Edge]]"
  - "[[Database]]"
  - "[[Frontend]]"
canonical-source: src/lib/server
generated-by: code-to-docs
generated-at: 2026-03-28T12:00:00Z
mode: full
tags:
  - code-docs
  - cross-cutting
---

# Multi-Environment Model

How Dockhand manages connections to multiple Docker daemons, scoping all operations, events, and data by environment.

## Beginner

> [!tip] Prerequisites
> Before reading this section, you should understand:
> - What a Docker daemon is (the background service that manages containers)
> - The idea of managing multiple servers from a single interface

### What Is This?

Dockhand can manage Docker on multiple machines simultaneously. Each machine (or Docker daemon) is called an "environment." The multi-environment model ensures that every operation — listing containers, deploying stacks, collecting metrics — is scoped to the correct environment.

## Intermediate

### Environment Types

| Type | Connection | Use Case |
|------|-----------|----------|
| **Local socket** | Unix socket (`/var/run/docker.sock`) | Same machine as Dockhand |
| **Direct TCP** | HTTP or HTTPS with optional TLS certs | Remote Docker daemon with exposed port |
| **Hawser Standard** | HTTP through Hawser agent | Remote machine running Hawser agent (direct network access) |
| **Hawser Edge** | WebSocket initiated by remote agent | Remote machine behind firewall (agent connects outbound) |

### Environment Scoping

Almost every function in the backend accepts an `envId` parameter:

```typescript
listContainers(all, envId)      // Docker Engine
getContainerStats(id, envId)    // Docker Engine
deployStack(options, envId)     // Stacks
sendEdgeRequest(envId, ...)     // Hawser
pushMetric(envId, ...)          // Metrics Store
```

The frontend maintains a "current environment" in a Svelte store. Switching environments:
1. Updates the store and localStorage
2. Reconnects SSE to the new environment's event stream
3. Refreshes container list, stats, and dashboard data
4. Clears stale data from the previous environment

### Enterprise: Environment-Scoped Permissions

In the enterprise edition, roles can be scoped to specific environments. A user might be an Admin in "Production" but only a Viewer in "Staging." The authorization module resolves permissions per-environment:

```typescript
auth.can('containers', 'start', envId)  // Checks environment-scoped role
auth.getAccessibleEnvironmentIds()       // Returns envIds the user can access
```

## Advanced

### Caching Per Environment

Multiple caches are keyed by environment ID:
- **Docker client config** — `Map<envId, DockerClientConfig>` with 30-min TTL
- **Metrics ring buffer** — `Map<envId, RingBuffer>` per-environment time series
- **Hawser connections** — `Map<envId, EdgeConnection>` one WebSocket per environment
- **Go collector** — Per-environment goroutine sets (metrics, events, disk)

### Environment Lifecycle

1. **Create**: Insert into database, configure connection type and credentials
2. **Connect**: Docker client cache populates on first API call; Go collector configured via IPC
3. **Monitor**: Metrics, events, and disk usage collected continuously
4. **Disconnect**: Hawser connection closed, Go collector environment removed, caches cleared
5. **Delete**: Database record removed, all associated data (schedules, events, stacks) cascaded
