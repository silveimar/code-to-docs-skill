---
title: Getting Started
type: onboarding
language:
  - "typescript"
  - "go"
status: generated
complexity: low
dependencies: []
related-notes:
  - "[[System Overview]]"
  - "[[Frontend]]"
  - "[[Docker Engine]]"
canonical-source: package.json
generated-by: code-to-docs
generated-at: 2026-03-28T12:00:00Z
mode: full
tags:
  - code-docs
  - onboarding
---

# Getting Started

How to set up a development environment for Dockhand and run the application locally.

## Prerequisites

- **Node.js** 20+ (for the SvelteKit application)
- **Bun** (for running tests)
- **Go** 1.21+ (for building the collector binary)
- **Docker** or **Podman** (for the Docker API — Dockhand needs a daemon to manage)
- **Git** (for version control and git stack features)

## Quick Start

```bash
# Clone and install
git clone <repository-url> dockhand
cd dockhand
npm install

# Start development server
npm run dev
# → http://localhost:5173
```

The dev server uses Vite with hot module replacement. Changes to Svelte components and server modules reload automatically.

## Project Structure

```
dockhand/
├── src/
│   ├── hooks.server.ts          # Global middleware (auth, compression, startup)
│   ├── routes/                   # Pages and API endpoints
│   │   ├── api/                  # 192 REST API routes
│   │   ├── containers/           # Container management page
│   │   ├── stacks/               # Stack management page
│   │   └── ...                   # 18 page routes total
│   └── lib/
│       ├── server/               # Backend modules
│       │   ├── docker.ts         # Docker API client (5,264 lines)
│       │   ├── db.ts             # Database operations (4,681 lines)
│       │   ├── auth.ts           # Authentication
│       │   ├── stacks.ts         # Compose stack management
│       │   ├── hawser.ts         # Edge agent protocol
│       │   ├── scheduler/        # Cron task scheduling
│       │   └── ...               # 25+ server modules
│       ├── components/           # UI components (shadcn-svelte + custom)
│       └── stores/               # Client-side state management
├── collector/                    # Go metrics collector
│   └── main.go                   # Single-file Go binary
├── server.js                     # Production HTTP server with WebSocket
├── drizzle/                      # SQLite migrations
├── drizzle-pg/                   # PostgreSQL migrations
└── updater/                      # Self-update sidecar container
```

## Key Commands

| Command | Purpose |
|---------|---------|
| `npm run dev` | Development server (localhost:5173) |
| `npm run build` | Production build |
| `npm start` | Run production server |
| `npm run check` | TypeScript type checking |
| `bun test tests/` | Run all tests |
| `bun test tests/api-smoke.test.ts` | Run a single test file |

## Environment Variables

For development, most defaults work out of the box. Key overrides:

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOCKER_SOCKET` | Auto-detected | Path to Docker socket |
| `DATA_DIR` | `./data` | Where SQLite DB and stack files are stored |
| `DATABASE_URL` | (none) | Set to use PostgreSQL instead of SQLite |

## Architecture at a Glance

Dockhand is a modular monolith. The 10 modules are documented individually:

1. [[Docker Engine]] — Raw Docker API client
2. [[Database]] — Drizzle ORM with SQLite/PostgreSQL
3. [[Auth and Security]] — Local, LDAP, OIDC auth + RBAC
4. [[Stacks and Git]] — Docker Compose lifecycle + Git integration
5. [[Hawser Edge]] — WebSocket tunnel for remote Docker management
6. [[Scheduler]] — Cron-based auto-updates and syncing
7. [[Go Collector]] — Metrics/events collection subprocess
8. [[Production Server]] — HTTP + WebSocket server wrapper
9. [[Infrastructure Services]] — Shared utilities (notifications, scanning, encryption, etc.)
10. [[Frontend]] — SvelteKit pages, API routes, stores
