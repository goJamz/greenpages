# Green Pages Architecture and Delivery

## 1. Stack

- **Frontend:** React 19 + TypeScript + Tailwind CSS v4 + Vite 8
- **Backend:** Go with `database/sql` and pgx stdlib driver
- **Database:** PostgreSQL
- **Search:** PostgreSQL full-text search + `pg_trgm` for fuzzy matching
- **Exports:** CSV via Go's `encoding/csv`
- **Authentication:** Keycloak with CAC-backed sign-in (not yet wired)
- **Packaging:** Docker
- **Local development:** Docker Compose (backend + Postgres; frontend runs via `npm run dev`)
- **Deployment target:** Kubernetes packaged with Helm, Zarf, and UDS
- **Registry of record:** Azure Container Registry (ACR)

### Stack rationale

Go was chosen because the backend workload is mostly API endpoints, search queries, structured joins, and export generation. PostgreSQL was chosen because the data is inherently relational: organizations contain sections, sections contain billets, billets map to people, and aliases point to canonical names. The project uses raw SQL with `database/sql` rather than an ORM. `sqlc` is the intended future direction for type-safe query generation, deferred until the schema and query surface stabilize.

Django remains an approved secondary backend pattern within the organization. The decision to use Go for Green Pages is final for this project.

## 2. Delivery model

Green Pages follows the organization's delivery pattern. These are hard requirements, not optional implementation choices.

- Container images are built per component (frontend, backend).
- Images are pushed to the organization's **Azure Container Registry (ACR)**.
- The application is packaged through **Zarf**.
- Deployment is orchestrated through **UDS**.
- Kubernetes deployment templates are managed through **Helm**.
- The repo supports environment-specific pipeline configuration (dev, test, prod).
- A `docs/` tree is maintained in-repo for structured documentation.

### Component guidance

- **Frontend** — separate deployable container. Independent UI build lifecycle.
- **Backend** — separate deployable container.
- **Worker** — optional. Only add when there is a real need: scheduled ingestion, queue-driven jobs, or background refresh separated from the API.
- **Redis** — optional. Only add for a real requirement: cache, queue broker, locking, or transient state.
- **Database** — Postgres container for local development only. In deployed environments, the application targets the approved organizational database service.

Follow the organization's delivery pattern, but do not copy every service from reference apps by default. Extra infrastructure must be justified by actual product need.

## 3. Repo layout

### Current state

```text
greenpages/
├── compose.yaml
├── backend/
│   ├── Dockerfile
│   ├── go.mod
│   ├── cmd/server/main.go
│   ├── internal/server/
│   │   ├── server.go
│   │   ├── sections_search.go
│   │   ├── sections_detail.go
│   │   ├── people_search.go
│   │   ├── people_detail.go
│   │   ├── explorer_positions.go
│   │   └── export.go
│   └── migrations/
├── frontend/
│   ├── package.json
│   ├── vite.config.ts
│   └── src/
│       ├── api/greenpages.ts
│       └── pages/
│           ├── SearchPage.tsx
│           ├── SectionDetailPage.tsx
│           ├── PersonDetailPage.tsx
│           └── ExplorerPage.tsx
└── baselineDocs/
```

### Target state (not yet built)

```text
greenpages/
├── Makefile
├── compose.yaml
├── frontend/
│   ├── Dockerfile          ← not yet created
│   └── ...
├── backend/
│   └── ...
├── deploy/
│   ├── pipelines/
│   │   ├── dev/cdso_config.yml
│   │   ├── test/cdso_config.yml
│   │   └── prod/cdso_config.yml
│   ├── uds/uds-bundle.yaml
│   └── zarf/
│       ├── zarf.yaml
│       └── helm/
│           ├── frontend/
│           ├── backend/
│           └── package/
├── docs/
│   ├── sdd/
│   ├── decisions/
│   └── operations/
└── scripts/
```

### What's missing from delivery

The following delivery infrastructure has not been built yet:

- `frontend/Dockerfile` — needed before the frontend can be deployed as a container.
- `deploy/` tree — Helm charts, Zarf packaging, UDS bundle, environment-specific pipeline configs.
- `docs/` tree — structured documentation (SDD, decision records, operational runbooks).
- `Makefile` — convenience targets for common developer commands.

This work should arrive as a coherent delivery slice, not piecemeal.

## 4. Local development

### Current setup

- `docker compose up` runs Postgres and the Go backend.
- `npm run dev` (from `frontend/`) runs Vite with hot module replacement and proxies `/api` to `http://localhost:8080`.
- This two-terminal setup is the working developer experience. It works well for a one-person project because Vite's HMR is significantly faster than rebuilding a frontend container on every change.

### Vite proxy configuration

During local development, Vite proxies `/api` requests to the Go backend. This avoids CORS configuration. In production, the reverse proxy or ingress handles routing.

### Database for local dev

The Postgres container runs migrations as init scripts mounted into `/docker-entrypoint-initdb.d/`. This works during early development where the schema changes frequently and the database is regularly wiped. When the schema stabilizes, the project should switch to a real migration tool (`golang-migrate`, `goose`, or `atlas`) that tracks applied migrations.

## 5. Container images

### Backend Dockerfile

- Builder stage: `golang:1.26.2-bookworm` (Debian-based)
- Runtime stage: `debian:bookworm-slim`
- `ca-certificates` installed in runtime for outbound TLS
- Layer caching: copies `go.mod` and `go.sum` first, runs `go mod download`, then copies source
- When deploying to Kubernetes via UDS, the runtime image can switch to `distroless/static-debian12:nonroot`

### Frontend Dockerfile

Not yet created. Will be needed as part of the delivery skeleton work.

## 6. Database configuration

The application supports two patterns for database connection:

1. A single `DATABASE_URL` environment variable containing the full connection string.
2. Individual `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_SSL_MODE` variables assembled at startup.

`DATABASE_URL` is checked first. If set, individual variables are ignored. This supports both local development (where a single URL is convenient) and Kubernetes deployment (where individual secrets may be injected from Azure Key Vault).

The application pings the database at startup with a 5-second timeout. If the database is unreachable, the process exits immediately rather than starting and failing on the first request.

## 7. Internal patterns

The following organizational patterns were observed from internal reference applications and inform Green Pages:

- Separate frontend and backend as deployable components.
- One Dockerfile per runtime component.
- Environment-specific pipeline configuration under `deploy/pipelines/`.
- Zarf + UDS + Helm delivery structure.
- Real documentation artifacts maintained in-repo.
- `Makefile` as a convenience wrapper.

Green Pages adopts the shared delivery pattern while making its own product-specific stack choices. It does not copy every extra service (Redis, workers) from reference apps without a direct need.
