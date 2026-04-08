# Green Pages Recommended Architecture

## 1. Recommended stack

For version 1, the recommended stack is:

- **Front end:** React + TypeScript
- **Frontend UI:** Tailwind CSS with standard React components
- **Authentication:** Keycloak with CAC-backed sign-in, using `react-oidc-context` (or `keycloak-js`)
- **API / backend:** Go
- **Primary database:** PostgreSQL
- **SQL access / query code generation:** `sqlc`
- **Packaging:** Docker
- **Local development:** Docker Compose
- **Deployment model:** Kubernetes packaged with Helm, Zarf, and UDS
- **Registry of record:** Azure Container Registry (ACR)
- **Search:** PostgreSQL full-text search + `pg_trgm`
- **Exports:** CSV first

This stack is the best fit for the product decisions made in this thread because Green Pages is a search-heavy, relationship-heavy internal web application with structured data, daily refreshes, section hierarchy, authenticated user access, and an organizational requirement to deliver through a Kubernetes + UDS + Zarf path.

## 2. Why this stack fits Green Pages

### React + TypeScript + Tailwind CSS
React is a good fit because the app needs:

- a search-heavy UI,
- rich filters,
- section pages,
- person detail panels,
- org-chart views,
- explorer tables,
- export actions,
- authenticated routes.

Tailwind CSS is a strong fit for the frontend UI layer because it is a utility-first CSS framework designed to compose layouts and visual styles directly in markup, which works well for React/TypeScript applications that need many reusable interface patterns.[^1][^2]

### Keycloak + OIDC client library
You selected CAC-authenticated access for the app.

Keycloak is the right fit for this thread because it is an open-source identity and access management platform that supports standard identity protocols such as OIDC and SAML, and its server administration guidance explicitly covers X.509 client certificate user authentication.[^3] That matches the requirement for CAC-backed authentication with Keycloak sitting in front of the CAC trust chain.

On the frontend, a standard OIDC client library is the right match instead of MSAL. `react-oidc-context` is a lightweight React SPA auth library built on `oidc-client-ts`; it provides an auth context provider, redirect handling, and token lifecycle support for OIDC-based apps.[^4]

### Go backend
Go is the primary recommendation because the backend workload is mostly:

- API endpoints,
- search requests,
- structured joins,
- refresh/import jobs,
- auth token validation,
- export generation,
- predictable service operations.

Go’s standard `database/sql` package gives a generic interface for SQL databases, and it is designed to be used with database drivers while supporting the service patterns expected in API applications.[^5]

### PostgreSQL + sqlc
PostgreSQL is the right main database because Green Pages is built around **relationships**:

- organizations contain sections,
- sections contain billets,
- billets can have zero, one, or multiple people tied to them,
- aliases need to point to canonical names,
- org charts and hierarchy matter,
- section-level lookups need tree traversal.

PostgreSQL supports:

- **recursive queries** through `WITH RECURSIVE`, which is useful for org trees and hierarchy traversal,[^6]
- **full-text search** via `tsvector` and `tsquery`,[^7][^8]
- **trigram similarity** via `pg_trgm` for fuzzy matching of unit names and aliases,[^9]
- **GIN indexes** for efficient text-search-related indexing,[^10]
- **materialized views** for persisted derived data such as daily-refreshed search projections.[^11]

`sqlc` is a strong match for the Go + PostgreSQL pairing because it lets you write plain SQL, then generate type-safe Go code for those queries. That keeps the data layer explicit and SQL-first without giving up type safety in the Go service.[^12]

### Kubernetes + Helm + Zarf + UDS
This is now a **hard organizational fit requirement**, not an optional platform preference.

Green Pages should be built for the same deployment shape used in your organization:

- images built per component,
- images pushed to ACR,
- app components templated through Helm,
- application packaged through Zarf,
- delivery wrapped through UDS,
- deployed into a Kubernetes environment that supports the organization’s UDS model.

Zarf deploys to Kubernetes and supports Helm-based packaging, and UDS packages bundle OCI images, Helm charts, and Kubernetes manifests as first-class package contents.[^13][^14][^15]

### Docker Compose for local development
For local development, Docker Compose is a good fit because Green Pages will likely have multiple local services even if production deployment is Kubernetes-based.

That local workflow is already consistent with the organizational examples you shared, and Docker documents Compose as the tool for defining and running multi-container applications.[^16]

### Azure Container Registry
ACR should be treated as the registry of record for container images and OCI artifacts used by Green Pages.

Microsoft documents ACR as a managed, private registry for container images and related OCI artifacts, which matches the delivery model you described.[^17]

## 3. Why SQL is the right database choice

For Green Pages, **SQL should be the default, not NoSQL**.

Why:

- The data is inherently relational.
- You will need joins constantly.
- Hierarchy matters.
- Canonical names and aliases matter.
- Occupancy state must be derived from structured relationships.
- Export, filtering, and reporting are easier when the base data is normalized.

A typical Green Pages query is something like:

> Find the whole G-6 section for a specific organization, then return every billet, current occupant, contact data, and paragraph/line.

That is classic relational workload.

## 4. Why not Cosmos DB first

Cosmos DB is not a bad product, but it is the wrong starting point here.

The first challenge in Green Pages is not global-scale document distribution. The first challenge is:

- modeling stable relationships,
- joining multiple data domains,
- deriving current state,
- searching structured data cleanly.

Those are better first-class fits for PostgreSQL.

## 5. Why not NoSQL first

NoSQL becomes more attractive when:

- documents are loosely structured,
- relationships are shallow,
- denormalization is desirable,
- scale and write patterns dominate query complexity.

Green Pages is the opposite.

You need strong modeling for:

- organization hierarchy,
- section membership,
- billet identity,
- occupant overlays,
- aliases,
- daily refresh,
- searchable projections.

Start relational.

## 6. Why not Rust first

Rust is powerful, fast, and safe, but it is not the best first move for this project.

Reasons:
- It increases implementation complexity for an app that is mostly data modeling, web APIs, search, and auth plumbing.
- It will likely slow down first delivery unless the team is already Rust-strong.
- The gain is not proportional to the problem.

Green Pages needs clear execution, not maximal systems-language rigor on day one.

## 7. Why not Java first

Java and Spring can absolutely do this, but they are heavier than necessary for the first version.

For Green Pages, Go gives you a smaller service footprint and less framework weight for the same type of API work.

Java would make more sense if:
- your team is already strongly invested in Spring,
- you already have a strong Java platform baseline,
- or the surrounding enterprise standards strongly prefer it.

That is not what drove this thread.

## 8. Why Django is an approved secondary backend pattern

Python is still a valid alternative, especially **Django + Django REST Framework**.

Because you showed an internal React + Django example, Django should now be treated as an **approved secondary backend pattern inside your organization**, even though Go remains the primary recommendation for Green Pages.

Use Django instead of Go if you decide you need:

- fastest internal prototype,
- more built-in admin screens quickly,
- a stronger batteries-included backend pattern,
- heavier internal operator workflows early,
- or alignment with an already-proven org repo pattern.

Django also has strong deployment guidance and a mature operational model for settings separation and production hardening.[^18]

## 9. Why not Node.js as the main backend first

Node.js is fine for the frontend build chain and could also serve as the backend.

But for this project, it is better used as:
- the React build/runtime toolchain,
- not the main API recommendation.

The selected stack keeps the frontend and backend responsibilities clean:

- React/TypeScript for the user experience,
- Go for the service/API layer.

## 10. Why not Shiny first

Shiny is strong for interactive analysis applications, data exploration, and quick analytical dashboards.

Green Pages is not primarily an analyst-facing exploratory notebook application. It is a long-lived operational directory/search product with authentication, structured relationships, multiple result views, and daily refresh pipelines.

That makes Shiny a poor primary platform choice here.

## 11. Recommended architecture shape

### Front end
React + TypeScript SPA with Tailwind CSS

Responsibilities:
- OIDC / Keycloak authentication flow,
- search input,
- explorer filters,
- result pages,
- org-chart rendering,
- exports initiation,
- user experience state.

### Backend API
Go service

Responsibilities:
- API endpoints,
- query orchestration,
- validating Keycloak-issued JWTs with standard OIDC token verification,
- search ranking,
- export generation,
- refresh control endpoints if needed.

### Alternative backend
Django service

Responsibilities:
- same business capability as the Go service,
- plus stronger built-in admin/operator surface if you choose that path.

### Data layer
PostgreSQL with `sqlc`-generated query code

Responsibilities:
- canonical organizations,
- aliases,
- sections,
- billets,
- occupants,
- search projections,
- daily-refresh staging and merges.

### Ingestion / refresh
Scheduled daily refresh jobs

Responsibilities:
- call Vantage APIs,
- ingest force-structure/billet feeds from approved sources,
- normalize aliases and keys,
- compute status,
- publish current-state tables/materialized views.

### Packaging / deployment
Containerized multi-component application

Expected components:
- frontend,
- backend,
- optional worker,
- optional supporting services only when justified.

Expected delivery path:
- build images,
- push to ACR,
- deploy through Helm,
- package through Zarf,
- bundle/integrate through UDS,
- run on Kubernetes.

## 12. Search approach for v1

Start with PostgreSQL search.

### Use these pieces
- `tsvector` / `tsquery` full-text search for names, billet titles, organization names, and searchable text projections.[^7][^8]
- `pg_trgm` for fuzzy matches and alias similarity.[^9]
- materialized search projections refreshed daily.[^11]

### Examples it should support
- `18th Airborne Corps G6`
- `XVIII Airborne Corps G-6`
- `I Corps G3`
- person-name search
- billet-title search
- no-term browsing in the position explorer with filter-only navigation

## 13. Final recommendation

The recommended production-aligned direction is:

- **React + TypeScript** for the frontend,
- **Tailwind CSS** for the UI layer,
- **Keycloak + `react-oidc-context`** for CAC-backed sign-in,
- **Go** for the primary API/backend,
- **PostgreSQL** for the system of record,
- **`sqlc`** for SQL-first type-safe data access in Go,
- **Docker Compose** for local multi-service development,
- **Helm + Zarf + UDS + Kubernetes** for deployment,
- **ACR** as the registry of record,
- **Django** as an allowed secondary backend pattern when organizational fit or prototyping speed matters more than keeping Go as the primary service choice.

---

## References

[^1]: React documentation, "React". https://react.dev/
[^2]: Tailwind CSS documentation, "Rapidly build modern websites without ever leaving your HTML". https://tailwindcss.com/
[^3]: Keycloak documentation, "Server Administration Guide" — X.509 client certificate user authentication. https://www.keycloak.org/docs/latest/server_admin/index.html
[^4]: `react-oidc-context` documentation. https://github.com/authts/react-oidc-context
[^5]: Go documentation, `database/sql`. https://pkg.go.dev/database/sql
[^6]: PostgreSQL documentation, "Queries with `WITH`". https://www.postgresql.org/docs/current/queries-with.html
[^7]: PostgreSQL documentation, "Text Search Types". https://www.postgresql.org/docs/current/datatype-textsearch.html
[^8]: PostgreSQL documentation, "Text Search Functions and Operators". https://www.postgresql.org/docs/current/functions-textsearch.html
[^9]: PostgreSQL documentation, "pg_trgm". https://www.postgresql.org/docs/current/pgtrgm.html
[^10]: PostgreSQL documentation, "GIN Indexes". https://www.postgresql.org/docs/current/gin.html
[^11]: PostgreSQL documentation, "Materialized Views". https://www.postgresql.org/docs/current/rules-materializedviews.html
[^12]: sqlc documentation. https://docs.sqlc.dev/en/latest/
[^13]: Zarf documentation, "Deploy a package". https://docs.zarf.dev/ref/deploy/
[^14]: Zarf documentation, "Create a package". https://docs.zarf.dev/ref/create/
[^15]: UDS documentation, "UDS packages". https://uds.defenseunicorns.com/reference/packages/overview/
[^16]: Docker documentation, "Docker Compose". https://docs.docker.com/compose/
[^17]: Microsoft Learn, "Azure Container Registry documentation". https://learn.microsoft.com/en-us/azure/container-registry/
[^18]: Django documentation, "Deployment checklist". https://docs.djangoproject.com/en/6.0/howto/deployment/checklist/
