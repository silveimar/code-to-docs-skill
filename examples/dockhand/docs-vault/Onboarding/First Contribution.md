---
title: First Contribution
type: onboarding
language:
  - "typescript"
status: generated
complexity: low
dependencies: []
related-notes:
  - "[[Getting Started]]"
  - "[[Frontend]]"
  - "[[Docker Engine]]"
canonical-source: CONTRIBUTING.md
generated-by: code-to-docs
generated-at: 2026-03-28T12:00:00Z
mode: full
tags:
  - code-docs
  - onboarding
---

# First Contribution

A guide for making your first code change to Dockhand, oriented around the most common types of contributions.

## Adding a New API Endpoint

Most contributions involve adding or modifying API endpoints. Here's the pattern:

### 1. Create the Route File

API routes live under `src/routes/api/`. Create a `+server.ts` file at the path matching your desired URL:

```
src/routes/api/my-feature/+server.ts → GET/POST /api/my-feature
src/routes/api/my-feature/[id]/+server.ts → GET /api/my-feature/:id
```

### 2. Follow the Standard Pattern

Every API endpoint follows this structure:

```typescript
import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { authorize, forbidden } from '$lib/server/authorize';

export const GET: RequestHandler = async ({ url, cookies }) => {
  // 1. Authorize
  const auth = await authorize(cookies);
  if (auth.authEnabled && !await auth.can('resource', 'view')) {
    return forbidden();
  }

  // 2. Parse parameters
  const envId = Number(url.searchParams.get('environmentId'));

  // 3. Call backend module
  const data = await someBackendFunction(envId);

  // 4. Return JSON
  return json(data);
};
```

### 3. Add Backend Logic

If your feature needs new database operations, add functions to `src/lib/server/db.ts`. If it needs Docker operations, use functions from `src/lib/server/docker.ts`.

### 4. Run Tests

```bash
bun test tests/api-smoke.test.ts   # Basic API health checks
bun test tests/                     # All tests
npm run check                       # TypeScript type checking
```

## Adding a New Page

1. Create `src/routes/my-page/+page.svelte` for the UI.
2. Create `src/routes/my-page/+page.server.ts` if you need server-side data loading.
3. Add a sidebar entry in `src/lib/components/app-sidebar.svelte`.
4. Use existing stores from `src/lib/stores/` for state management.

## Common Gotchas

> [!warning] Things to Watch Out For
> - **Authorization**: Every API endpoint must check permissions. Copy the pattern from an existing endpoint.
> - **Environment scoping**: Most operations need an `environmentId`. Pass it through and use it in backend calls.
> - **Encryption**: If you add a new field that stores credentials, wrap it with `encrypt()`/`decrypt()` in the database functions.
> - **Dynamic imports**: If you need to import from `docker.ts` in a file that `docker.ts` imports, use `await import('./module.js')` to avoid circular dependency errors.
> - **shadcn-svelte**: UI primitives in `src/lib/components/ui/` are generated. Don't edit them directly — use the shadcn-svelte CLI to update.
