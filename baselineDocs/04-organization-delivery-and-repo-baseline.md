# Green Pages Organization Delivery and Repo Baseline

## 1. Purpose

This file captures the organization-specific delivery requirements and repo-shape expectations inferred from the internal examples you shared.

These requirements should be treated as the baseline delivery model for Green Pages.

## 2. Hard requirements

Green Pages should be designed to follow this organizational delivery pattern:

- container images are built for the application components,
- those images are pushed to the organization’s **Azure Container Registry (ACR)**,
- the application is packaged through **Zarf**,
- the deployment is orchestrated through **UDS**,
- Kubernetes deployment templates are managed through **Helm**,
- the repo supports environment-specific pipeline configuration,
- local development supports multi-container execution,
- documentation artifacts are maintained in-repo.

## 3. What this changes

This means Green Pages should **not** be treated as a simple single-service web app deployed directly to a generic PaaS first.

Instead, it should be treated as:

- a multi-container internal application,
- built for Kubernetes deployment,
- packaged through Zarf,
- integrated into the organization’s UDS deployment model,
- promoted through environment-specific pipeline configuration,
- backed by ACR as the registry of record,
- supported by a local multi-service development workflow,
- documented with real project artifacts rather than just ad hoc notes.

## 4. Observed internal patterns to mirror

From the internal examples you shared, the repeated patterns are:

- separate `frontend/` and `backend/` application roots,
- one Dockerfile per runtime component,
- optional worker/background component when justified,
- optional Redis or other dependency containers only when needed,
- `deploy/pipelines/{dev,test,prod}/cdso_config.yml` style environment separation,
- `deploy/uds/uds-bundle.yaml`,
- `deploy/zarf/zarf.yaml`,
- Helm charts under `deploy/zarf/helm/`,
- a `docs/` tree for structured documentation,
- support for local multi-container development,
- a top-level `Makefile` as a convenience wrapper when useful.

## 5. Recommended Green Pages repo layout

Recommended baseline:

```text
green-pages/
├── Makefile
├── README.md
├── compose.yml
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   ├── vite.config.ts
│   └── src/
├── backend/
│   ├── Dockerfile
│   ├── go.mod
│   ├── sqlc.yaml
│   ├── cmd/
│   ├── internal/
│   ├── queries/
│   └── migrations/
├── deploy/
│   ├── pipelines/
│   │   ├── dev/
│   │   │   └── cdso_config.yml
│   │   ├── test/
│   │   │   └── cdso_config.yml
│   │   └── prod/
│   │       └── cdso_config.yml
│   ├── uds/
│   │   └── uds-bundle.yaml
│   └── zarf/
│       ├── zarf.yaml
│       └── helm/
│           ├── frontend/
│           ├── backend/
│           ├── worker/
│           └── package/
├── docs/
│   ├── sdd/
│   ├── decisions/
│   └── operations/
└── scripts/
```

## 6. Backend pattern guidance

### Preferred backend pattern
Use **Go** as the preferred Green Pages backend.

Why:
- it remains the best fit for the API/service profile of this app,
- it keeps the production service layer lean,
- it matches the earlier stack decision in this thread.

### Data access pattern
Use **sqlc** with PostgreSQL.

Why:
- it preserves SQL-first design,
- it generates type-safe Go query code,
- it fits the relationship-heavy data model Green Pages needs.

### Allowed secondary backend pattern
A **Django backend** is also acceptable if you deliberately choose to align with an internal precedent.

If you choose that route, a backend shape like this is reasonable:

```text
backend/
├── Dockerfile
├── manage.py
├── requirements.txt
├── requirements.dev.txt
├── pyproject.toml
├── app_name/
│   ├── settings/
│   │   ├── base.py
│   │   ├── dev/
│   │   ├── test/
│   │   └── prod/
│   ├── urls.py
│   ├── asgi.py
│   └── wsgi.py
├── middleware/
├── templates/
└── domain_app/
```

That pattern is especially reasonable if Green Pages needs stronger built-in admin workflows early.

## 7. Frontend guidance

Recommended as its own deployable container.

Why:
- independent UI build lifecycle,
- independent static asset packaging,
- clean separation from API deployment,
- fits the existing org pattern.

Vite-based React with **Tailwind CSS** is a good fit for this shape.

## 8. Local development baseline

Green Pages should plan for a **local multi-container development workflow**.

Recommended local baseline:
- `compose.yml` for local orchestration,
- frontend container,
- backend container,
- postgres container,
- Keycloak container for local auth testing,
- optional mock/worker container only if needed,
- `Makefile` targets as convenience wrappers for common developer commands.

The point is not to mirror production exactly. The point is to make local bring-up predictable for a multi-service app.

## 9. Component guidance

### Frontend
Keep as its own deployable container.

### Backend
Keep as its own deployable container.

### Worker
Optional.

Only include if Green Pages needs:
- scheduled ingestion work,
- export generation,
- queue-driven background jobs,
- normalization or refresh processes separated from the API.

### Redis
Optional.

Do not include by default just to mirror the COST application.

Add only if you confirm a real requirement such as:
- cache,
- queue broker,
- locking,
- transient state management.

### Database container for local dev
Recommended for local development only.

In deployed environments, the application should still target the approved organizational database service pattern.

## 10. Helm packaging expectation

Green Pages should expect to maintain Helm charts for at least:

- frontend
- backend
- package-level or integration chart

Optionally add:
- worker
- redis
- other dependencies only if required

At minimum, the charts should manage:
- deployment
- service
- config map
- secrets references
- ingress or routing resources required by the cluster

## 11. Zarf expectation

Zarf should be treated as the application packaging layer.

That means Green Pages should maintain a `zarf.yaml` that:
- references the app components,
- packages the required images and deployment resources,
- supports the environment promotion path used by the organization,
- stays aligned with the Helm chart structure.

## 12. UDS expectation

UDS should be treated as the application deployment wrapper and integration model.

That means Green Pages should maintain a `uds-bundle.yaml` that:
- references the required application package(s),
- supports environment-specific deployment configuration,
- aligns with the cluster’s UDS Core integration model,
- leaves room for future dependencies if needed.

## 13. Azure Container Registry expectation

ACR is the registry of record for the application’s OCI artifacts.

That means the delivery path should assume:
- build images,
- tag images,
- push images to the organization ACR,
- reference those images from Helm/Zarf/UDS packaging as required by the org pipeline.

## 14. Documentation baseline

Green Pages should maintain an in-repo `docs/` tree.

Recommended documentation categories:
- software design description (SDD),
- architecture diagrams,
- operational runbooks,
- deployment notes,
- decision records,
- screenshots or UI references when useful,
- security/tenant or usage agreements if your process requires them.

## 15. Recommended implementation rule

Whenever there is a tension between a generic cloud-native recommendation and the organization’s proven delivery path, prefer the organization’s delivery path.

For Green Pages, that means:

- React + TypeScript still stands,
- Tailwind CSS still stands,
- Go + PostgreSQL still stands,
- sqlc still stands,
- Django remains an allowed secondary backend pattern,
- local development should include a multi-container workflow,
- deployment should be shaped around **ACR + Helm + Zarf + UDS + Kubernetes** from the beginning.

## 16. Final takeaway

Green Pages should be built as a **containerized, Kubernetes-targeted, UDS-delivered internal application** that fits the same operational model your organization already uses, while still keeping the product-specific recommendation of **React + TypeScript + Tailwind CSS + Go + PostgreSQL + sqlc** as the default implementation path.
