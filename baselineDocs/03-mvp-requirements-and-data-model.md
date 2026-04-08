# Green Pages MVP Requirements and Data Model

## 1. MVP goal

Deliver a first usable release of Green Pages that allows authenticated Army users to:

- find people,
- find the right section,
- find the right billet,
- browse force-wide positions,
- understand billet status,
- export results,
- do all of this from a desktop-first web application.

## 2. MVP scope

### In scope
- CAC-authenticated access via **Keycloak**
- Active Duty directory experience
- Army-wide position explorer across Active, Guard, and Reserve
- current organizations only
- uniformed military billets only
- person search
- organization search
- section search
- billet search
- browse-with-filters mode
- org chart style section pages
- billet status labels:
  - Filled
  - Vacant
  - Unknown
- export/download
- daily refresh
- current-state-only data model
- Zarf + UDS delivery packaging
- ACR-backed image publication

### MVP access note
- There is **no RBAC in the MVP**.
- Any successfully authenticated user has full read access to all available Green Pages data.

### Out of scope for MVP
- civilians and contractors
- assignment history
- mobile-first design
- inactive / legacy organizations
- advanced analytics dashboards
- complex manual data stewardship tooling

## 3. Primary user stories

### Directory user stories
1. As a soldier, I want to search a person by name so I can find who they are assigned to and how to contact them.
2. As a soldier, I want to search `XVIII Airborne Corps G-6` and open the whole G-6 section so I can see the full shop, not just one billet.
3. As a soldier, I want to search a broad term like `G6` and get a ranked list of matching sections.
4. As a soldier, I want vacant and unknown billets to still appear so I can understand the section even when data is incomplete.

### Explorer user stories
5. As a soldier, I want to browse billets without entering a search term so I can explore positions across the force.
6. As a soldier, I want to start with **Component** and then drill down by grade, branch/MOS/AOC, state, unit, and billet title.
7. As a soldier, I want to see occupant information when available, but still see the billet if nobody is tied to it.
8. As a soldier, I want to export the results so I can use them outside the application.

## 4. Required search behavior

### Supported search inputs
- person names
- organization names
- official names
- shorthand names
- aliases
- section names
- billet titles
- UICs
- paragraph/line references when available

### Examples the system should handle
- `18th Airborne Corps G6`
- `XVIII Airborne Corps G-6`
- `I Corps G3`
- person names
- `NETCOM G6`
- broad searches like `G6`

### Expected behavior rules
1. Section searches return the **whole section view**.
2. Broad searches return a **list of matching sections**.
3. Vacant billets are searchable.
4. Alias and shorthand matching must be supported.
5. Explorer browsing must work with no search term.

## 5. Required result views

### A. Search results list
Used for broad or ambiguous searches.

Should support:
- ranked results,
- section results,
- person results,
- billet results,
- clear type labels,
- filter refinement.

### B. Person page / panel
Should show, if available:
- name
- rank
- duty title
- organization
- section
- office symbol
- work email
- work phone
- billet status
- UIC
- paragraph
- line
- location
- last refreshed

### C. Section page
This is one of the most important pages in the app.

Should show:
- section name
- parent organization
- org-chart-style layout
- every billet in the section
- occupant or occupants if available
- one clearly marked primary occupant if multiple are tied to the billet
- status label: Filled / Vacant / Unknown
- billet metadata

### D. Position Explorer page
Should support:
- browse mode,
- filter-first workflows,
- table/grid results,
- export.

Should show:
- billet title
- grade
- branch / MOS / AOC
- component
- organization
- UIC
- paragraph / line
- location / state if available
- occupant if available
- status

## 6. Delivery and packaging requirements

These requirements are now part of the MVP baseline.

### Container build and publish
- Frontend and backend should each build as container images.
- Additional worker image should be optional and only added if needed.
- Images should be pushed to the organization’s **Azure Container Registry (ACR)**.

### Kubernetes packaging
- The application should be packaged for deployment through **Zarf**.
- The deployment should be wrapped through **UDS** bundle/package conventions.
- Helm charts should be the primary deployment template mechanism for app components.

### Environment layout
The repo should support environment-specific deployment overlays or pipeline configuration for at least:
- dev
- test
- prod

### Runtime expectation
- The runtime target is a Kubernetes environment compatible with **UDS Core**.
- The app should be designed for Kubernetes-style services, config maps, secrets, and ingress patterns.

## 7. Core data model

The application should be modeled around:

**Organization → Section → Billet → Person**

### Recommended core entities

#### organizations
Represents canonical organizations.

Suggested fields:
- `organization_id`
- `organization_name`
- `normalized_name`
- `short_name`
- `parent_organization_id`
- `component`
- `echelon`
- `uic`
- `location_name`
- `state_code`
- `is_current`
- `last_refreshed_at`

#### organization_aliases
Supports shorthand and alternate naming.

Suggested fields:
- `organization_alias_id`
- `organization_id`
- `alias_text`
- `alias_type`
- `normalized_alias_text`

Examples:
- XVIII Airborne Corps
- 18th Airborne Corps
- 18 ABN Corps
- I Corps

#### sections
Represents staff sections within organizations.

Suggested fields:
- `section_id`
- `organization_id`
- `section_code`
- `section_name`
- `normalized_section_name`
- `display_name`
- `parent_section_id` (optional, if sub-branches matter later)
- `is_current`

Examples:
- G-6
- G-3
- S-3

#### billets
Represents the authorized position, independent of who occupies it.

Suggested fields:
- `billet_id`
- `organization_id`
- `section_id`
- `position_number`
- `billet_title`
- `normalized_billet_title`
- `grade_code`
- `rank_group`
- `branch_code`
- `mos_code`
- `aoc_code`
- `component`
- `uic`
- `paragraph_number`
- `line_number`
- `duty_location`
- `state_code`
- `is_current`
- `last_refreshed_at`

#### people
Represents person identity details that are shown in the directory.

Suggested fields:
- `person_id`
- `display_name`
- `normalized_display_name`
- `rank`
- `work_email`
- `work_phone`
- `office_symbol`
- `is_current`
- `last_refreshed_at`

#### billet_occupants
Maps people to billets.

Suggested fields:
- `billet_occupant_id`
- `billet_id`
- `person_id`
- `is_primary`
- `occupancy_status`
- `source_system`
- `effective_date`
- `last_refreshed_at`

#### search_documents
Optional denormalized search projection for v1 ranking/search speed.

Suggested fields:
- `search_document_id`
- `document_type`
- `entity_id`
- `search_text`
- `ts_document`
- `display_name`
- `subtitle`
- `status`
- `last_refreshed_at`

## 8. Occupancy status rules

Billet status should be derived cleanly.

### Filled
Use when:
- the billet exists, and
- there is at least one acceptable current occupant mapping.

### Vacant
Use when:
- the billet exists, and
- the data source clearly indicates no current occupant.

### Unknown
Use when:
- the billet exists, but
- occupant data is missing, conflicting, stale, or not strong enough to declare filled or vacant.

## 9. Data quality rules

### Multiple people on one billet
- show all current linked people,
- mark one as primary,
- do not hide secondary links.

### Missing person data
- do not suppress the billet,
- show the billet with status and structural metadata.

### Missing structural data
- avoid returning people without organization context where possible,
- flag low-confidence records for later review.

## 10. Search implementation baseline

For MVP, use PostgreSQL-native search first.

### Why
- PostgreSQL supports built-in text search types and full-text search operations.[^1][^2]
- `pg_trgm` supports similarity matching for fuzzy name/alias search.[^3]
- recursive queries support hierarchy traversal.[^4]

### Practical search strategy
Use a combined approach:
- exact match boost,
- alias match boost,
- trigram similarity for fuzzy strings,
- full-text search for broader matching,
- entity-type-aware ranking.

## 11. Refresh model

### Refresh frequency
- Daily.

### Refresh pattern
Recommended pattern:
1. ingest into staging tables,
2. normalize names and keys,
3. update canonical entities,
4. recompute occupant links,
5. recompute search projections/materialized views,
6. promote refreshed current-state views.

### Why this pattern works
PostgreSQL materialized views persist derived query results, which can be useful for search/read models and daily refresh projections.[^5]

## 12. Export requirements

### MVP export recommendation
- CSV first.

### Initial export targets
- explorer results
- section roster / billet list
- search result tables where appropriate

## 13. Initial API surface

### Search endpoints
- `GET /api/search?q=`
- `GET /api/sections/search?q=`
- `GET /api/people/search?q=`
- `GET /api/billets/search?q=`

### Read endpoints
- `GET /api/sections/{id}`
- `GET /api/people/{id}`
- `GET /api/billets/{id}`

### Explorer endpoints
- `GET /api/explorer/positions`
- filter params for component, grade, branch, MOS/AOC, state, organization, and status

### Export endpoints
- `GET /api/exports/positions?...`
- `GET /api/exports/section/{id}`

## 14. Suggested phased roadmap

### Phase 1: Directory foundation
- Keycloak integration for CAC-authenticated access
- organizations
- sections
- billets
- people lookup
- whole-section page
- status labels
- ACR image publication
- basic Zarf/Helm packaging skeleton

### Phase 2: Explorer
- component-first browsing
- filter stack
- export
- broader Army-wide dataset coverage
- UDS bundle integration refinement

### Phase 3: Search refinement
- stronger alias handling
- better relevance tuning
- richer result ranking

### Phase 4: Post-MVP enhancements
- assignment history
- civilians / contractors
- mobile support
- admin stewardship workflows

## 15. Final MVP summary

The MVP should answer these questions well:

- Who is this person?
- What billet do they occupy?
- What does this section look like?
- Is this billet filled, vacant, or unknown?
- What billets exist across the force for a given component / grade / MOS / AOC / state / unit?

If the first release can do those things reliably, Green Pages will already be useful.

---

## Sources

[^1]: PostgreSQL documentation, *Text Search Types*. <https://www.postgresql.org/docs/current/datatype-textsearch.html>

[^2]: PostgreSQL documentation, *Full Text Search*. <https://www.postgresql.org/docs/current/textsearch.html>

[^3]: PostgreSQL documentation, *pg_trgm — support for similarity of text using trigram matching*. <https://www.postgresql.org/docs/current/pgtrgm.html>

[^4]: PostgreSQL documentation, *WITH Queries (Common Table Expressions)*. <https://www.postgresql.org/docs/current/queries-with.html>

[^5]: PostgreSQL documentation, *Materialized Views*. <https://www.postgresql.org/docs/current/rules-materializedviews.html>
