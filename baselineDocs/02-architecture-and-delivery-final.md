# Green Pages Architecture and Delivery

## 1. Stack

### Current implementation stack
- **Frontend:** React 19 + TypeScript + Tailwind CSS v4 + Vite 8
- **Backend:** Go with `database/sql` and pgx stdlib driver
- **Database:** PostgreSQL
- **Search baseline:** PostgreSQL-native querying plus `pg_trgm`-backed normalization/fuzzy support
- **Exports:** CSV generated in the Go backend
- **Packaging baseline:** Docker
- **Local development:** Docker Compose for Postgres + backend, Vite dev server for frontend

### Target platform direction
- **Authentication:** Keycloak with CAC-backed sign-in
- **Deployment target:** Kubernetes
- **Packaging:** Helm + Zarf + UDS
- **Registry of record:** Azure Container Registry (ACR)

Go remains the chosen backend for this project. Django is an organizationally valid precedent, but it is not the direction of this repo.

## 2. Architecture posture

Green Pages is a **containerized internal application** with separate frontend and backend concerns.

The project should follow the organization’s delivery pattern without cargo-culting every extra service from internal examples.

### Expected components
- **Frontend** — separate deployable UI component
- **Backend** — separate deployable API component
- **PostgreSQL** — local development dependency and system of record during development

### Optional components, only when justified
- **Worker** — only when refresh or background processing truly needs it
- **Redis** — only when caching, queueing, or locking becomes a real need

## 3. Current state vs target state

### Current repo shape
```text
greenpages/
├── compose.yaml
├── backend/
│   ├── Dockerfile
│   ├── cmd/server/main.go
│   ├── internal/server/
│   └── migrations/
├── frontend/
│   ├── package.json
│   ├── vite.config.ts
│   └── src/
└── baselineDocs/
```

### Target repo shape
```text
greenpages/
├── Makefile
├── compose.yaml
├── frontend/
│   ├── Dockerfile
│   └── ...
├── backend/
│   └── ...
├── deploy/
│   ├── pipelines/
│   │   ├── dev/
│   │   ├── test/
│   │   └── prod/
│   ├── uds/
│   └── zarf/
│       └── helm/
├── docs/
│   ├── sdd/
│   ├── decisions/
│   └── operations/
└── scripts/
```

## 4. Delivery model

These are the intended delivery requirements for Green Pages:

- frontend and backend build as separate container images
- images are pushed to the organization’s **ACR**
- deployment templates are managed through **Helm**
- application packaging is handled through **Zarf**
- deployment orchestration follows **UDS** conventions
- the repo supports environment-specific promotion paths such as **dev**, **test**, and **prod**

## 5. Local development

### Current working setup
- `docker compose up` brings up **Postgres** and the **Go backend**
- the frontend currently runs through `npm run dev`
- Vite proxies `/api` to `http://localhost:8080`
- this two-terminal workflow is the current developer experience

That setup is acceptable for the current stage and matches the current repo reality.

### Important current gap
The repo’s intended delivery shape assumes a frontend container too, but the current `compose.yaml` still only runs **Postgres** and **backend**.

That is a real gap between current implementation and target delivery posture.

## 6. Delivery work not yet built

The following delivery pieces are still missing:

- `frontend/Dockerfile`
- `deploy/` tree
- Helm charts
- Zarf package definition
- UDS bundle definition
- environment-specific pipeline config
- `docs/` tree outside the temporary baseline docs folder
- top-level `Makefile`

### Current decision about sequencing
This delivery skeleton should be built as **one coherent slice**, not piecemeal.

That means the preferred sequence is:
1. finish the local multi-container gap cleanly
2. add the first deploy skeleton
3. wire in platform packaging deliberately

## 7. Backend runtime and configuration

### Backend container posture
- current backend container setup is acceptable for this stage
- database connectivity is validated at startup
- the backend supports either:
  - `DATABASE_URL`, or
  - `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_SSL_MODE`

### Migration posture
Current migrations are mounted into `/docker-entrypoint-initdb.d/` for local database bootstrapping.

That is acceptable while the schema is still settling. Once the schema stabilizes, the project should move to a real migration tool.

## 8. Internal pattern guidance

Internal reference apps establish a few real expectations:

- separate frontend and backend roots
- separate container images per runtime component
- structured deployment config
- in-repo documentation discipline
- multi-container local development
- Helm + Zarf + UDS as the delivery path

Green Pages should adopt those **delivery patterns** while keeping its own simpler product-specific implementation choices.

## 9. Final takeaway

Green Pages should be treated as:
- a multi-component internal application,
- with separate frontend and backend concerns,
- built for Kubernetes delivery,
- packaged through Helm, Zarf, and UDS,
- but implemented with only the infrastructure the product actually needs right now.
