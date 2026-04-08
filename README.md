# Green Pages Doc Set

This doc set captures the product and architecture decisions made in this thread and turns them into a usable starting point for execution.

## Files

1. [01-product-definition.md](./baselineDocs/01-product-definition.md)
   - Problem statement
   - Product vision
   - Confirmed user requirements
   - MVP boundaries

2. [02-recommended-architecture.md](./baselineDocs/02-recommended-architecture.md)
   - Recommended stack
   - Why this stack fits Green Pages
   - Why other options are not the best starting choice
   - Hosting, auth, search, and data recommendations

3. [03-mvp-requirements-and-data-model.md](./baselineDocs/03-mvp-requirements-and-data-model.md)
   - MVP requirements baseline
   - Search behavior
   - Core entities and relationships
   - Initial API and refresh model
   - Suggested phased roadmap

4. [04-organization-delivery-and-repo-baseline.md](./baselineDocs/04-organization-delivery-and-repo-baseline.md)
   - Zarf / UDS / Helm / ACR delivery requirements
   - Kubernetes-first deployment expectations
   - Repo layout guidance aligned to organizational practice

5. [05-internal-reference-patterns.md](./baselineDocs/05-internal-reference-patterns.md)
   - Internal repo patterns observed from example apps
   - What Green Pages should mirror
   - What Green Pages should intentionally not copy by default

## Current recommended build

- Front end: **React + TypeScript**
- Frontend UI: **Tailwind CSS + standard React components**
- Authentication: **Keycloak / CAC-backed sign-in via react-oidc-context**
- API: **Go** as the primary recommendation
- Alternative backend pattern allowed by org precedent: **Django**
- Database: **PostgreSQL**
- SQL access/code generation: **sqlc**
- Packaging: **Docker**
- Delivery model: **Kubernetes + Helm + Zarf + UDS**
- Registry of record: **Azure Container Registry (ACR)**
- Local development: **Docker Compose** is recommended
- Search: **PostgreSQL full-text search + `pg_trgm`** for v1
- Exports: **CSV first**

## Notes

- This doc set reflects the thread decision to build **both**:
  - a **Directory** experience for Active Duty people-and-section lookup, and
  - a **Position Explorer** experience for Army-wide billet browsing across Active, Guard, and Reserve.
- The MVP is **CAC-authenticated via Keycloak**, **desktop-first**, **current-state only**, and **uniformed military billets only**.
- For MVP, **authenticated = full access**. There is no RBAC layer in the first release.
- The deployment and repo guidance has been updated to reflect the internal patterns you shared from existing organizational applications.

