# Green Pages

Green Pages is an Army directory and position explorer built around the model:

**Organization -> Section -> Billet -> Person**

The app currently supports two main workflows:

- **Directory** for section and person lookup
- **Position Explorer** for browsing billets across Active, Guard, and Reserve

The current stack is:

- **Frontend:** React + TypeScript + Tailwind + Vite
- **Backend:** Go + `database/sql` + pgx stdlib
- **Database:** PostgreSQL
- **Local packaging:** Docker Compose

## Current product surfaces

### Directory
The directory is built to answer questions like:

- Who works in a section?
- What billet does this person occupy?
- What does the full shop look like?
- Is a billet filled, vacant, or unknown?

Current surfaces:

- section search
- section detail
- people search
- person detail

### Position Explorer
The explorer is built to answer questions like:

- Show me billets by component, grade, branch, MOS, AOC, state, or organization
- Let me browse positions even if I do not know the exact unit structure yet

Current surfaces:

- filter-first explorer
- CSV export for explorer results
- CSV export for section rosters

## Current status

Green Pages is still in the MVP shaping phase.

Current repo reality:

- seed-data driven
- current-state only
- desktop-first
- no RBAC in MVP
- auth is part of the target platform direction, but not wired into the current frontend shell yet

The repo intentionally favors simple, explicit code over premature abstraction.

## Local development

The backend project owns the local Compose stack. Run it from this combined
working copy with the project Compose file:

Start Postgres and backend with Compose:

```bash
docker compose -f app/backend/compose.yaml up --build postgres backend
```

In another terminal, start the frontend natively:

```bash
cd app/frontend/frontend
npm run dev
```

URLs:

- Frontend dev server: `http://localhost:5173`
- Backend API: `http://localhost:8080`
- Backend health: `http://localhost:8080/api/health`

The frontend remains native during local development so Vite hot reload stays
fast. The backend Compose project intentionally contains only Postgres and the
backend service.

## Common commands

Start native-dev backend dependencies:

```bash
docker compose -f app/backend/compose.yaml up --build postgres backend
```

Stop the stack:

```bash
docker compose -f app/backend/compose.yaml down
```

Stop the stack and remove volumes:

```bash
docker compose -f app/backend/compose.yaml down -v
```

Quick health check:

```bash
curl http://localhost:8080/api/health
```

Expected response:

```json
{"status":"ok"}
```

## Repo notes

### Frontend container posture
The frontend Dockerfile remains available for frontend image builds, but the
backend project's Compose file does not build or run the frontend container.
Native Vite remains the primary daily frontend development loop.

### Current delivery direction
Target platform direction remains:

- separate frontend and backend images
- Azure Container Registry (ACR)
- Helm
- Zarf
- UDS
- Kubernetes
- Keycloak with CAC-backed sign-in

Those delivery pieces are not fully wired yet. The repo is still moving in deliberate slices.

## Documentation

Current baseline docs in this repo:

- `01-product-definition-final.md`
- `02-architecture-and-delivery-final.md`
- `03-data-model-and-api-final.md`
- `04-engineering-standards-final.md`

These docs capture the current project posture and should be treated as the source of truth when older notes or earlier recommendations conflict.

## Engineering posture

Green Pages follows a few simple rules:

- keep it simple
- build in vertical slices
- build the consumer before the producer
- avoid abstractions that have not earned their existence
- prefer explicit, maintainable code over cleverness

That means this repo intentionally avoids adding extra services, layers, or frameworks before they are justified by real product needs.
