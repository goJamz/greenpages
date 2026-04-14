# Green Pages Data Model and API

## 1. Core data model

The application is modeled around:

**Organization → Section → Billet → Person**

### organizations

Represents canonical organizations.

Fields: `organization_id`, `organization_name`, `normalized_name`, `short_name`, `parent_organization_id`, `component`, `echelon`, `uic`, `location_name`, `state_code`, `is_current`, `last_refreshed_at`, `created_at`.

### organization_aliases

Supports shorthand and alternate naming so searches like "18th Airborne Corps", "XVIII Airborne Corps", and "18 ABN Corps" all resolve correctly.

Fields: `organization_alias_id`, `organization_id`, `alias_text`, `alias_type`, `normalized_alias_text`.

### sections

Represents staff sections within organizations (G-1, G-3, G-6, etc.).

Fields: `section_id`, `organization_id`, `section_code`, `section_name`, `normalized_section_name`, `display_name`, `parent_section_id`, `is_current`, `created_at`.

### billets

Represents the authorized position, independent of who occupies it.

Fields: `billet_id`, `organization_id`, `section_id`, `position_number`, `billet_title`, `normalized_billet_title`, `grade_code`, `rank_group`, `branch_code`, `mos_code`, `aoc_code`, `component`, `uic`, `paragraph_number`, `line_number`, `duty_location`, `state_code`, `occupancy_status`, `is_current`, `created_at`, `updated_at`.

### people

Represents person identity and contact details shown in the directory.

Fields: `person_id`, `dod_id`, `display_name`, `normalized_display_name`, `rank`, `work_email`, `work_phone`, `office_symbol`, `is_current`, `last_refreshed_at`, `created_at`.

### billet_occupants

Maps people to billets. Supports multiple occupants per billet with one primary.

Fields: `billet_occupant_id`, `billet_id`, `person_id`, `is_primary`, `assignment_status`, `source_system`, `effective_date`, `last_refreshed_at`, `created_at`.

Key constraints:
- `occupancy_status` CHECK: `filled`, `vacant`, `unknown`
- `assignment_status` CHECK: `active`, `inactive`
- Partial unique index: one active primary occupant per billet
- Unique constraint: `(billet_id, person_id)` prevents duplicate mappings
- Partial unique indexes on `people` prevent duplicate active records by `dod_id` and `work_email`

## 2. Occupancy status rules

### Filled
The billet exists and there is at least one active occupant mapping. The API overrides stored status to `Filled` whenever an occupant is present, as occupant data is more trustworthy than a potentially stale status column.

### Vacant
The billet exists and the data source clearly indicates no current occupant.

### Unknown
The billet exists but occupant data is missing, conflicting, stale, or not strong enough to declare filled or vacant.

The API returns status with title case (`Filled`, `Vacant`, `Unknown`) regardless of how it is stored in the database. The `normalizeBilletStatus` function handles this conversion.

## 3. Data quality rules

### Multiple people on one billet
Show all current linked people, mark one as primary, do not hide secondary links.

### Missing person data
Do not suppress the billet. Show the billet with status and structural metadata.

### Missing structural data
Avoid returning people without organization context where possible.

## 4. API surface

### Built and working

| Endpoint | Purpose |
|---|---|
| `GET /api/health` | Liveness probe. Returns 200 if the process is alive. |
| `GET /api/readyz` | Readiness probe. Pings the database. Returns 503 if unreachable. |
| `GET /api/sections/search?q=` | Search sections by name, code, display name, organization. |
| `GET /api/sections/{sectionID}` | Section metadata + all billets + all occupants. |
| `GET /api/people/search?q=` | Search people by name, rank, office symbol, billet, org context. |
| `GET /api/people/{personID}` | Person metadata + all active assignments with billet/section/org context. |
| `GET /api/explorer/positions` | Browse/filter billets. Params: component, grade, branch, mos, aoc, state, status, organization, limit, offset. |
| `GET /api/exports/positions` | CSV export of filtered positions. Same filters as explorer, no pagination (capped at 10,000 rows). |
| `GET /api/exports/section/{sectionID}` | CSV export of a section's billet roster. One row per occupant. Includes occupant email, phone, office symbol. |

### Intentionally not built

| Endpoint | Reason |
|---|---|
| `GET /api/billets/search?q=` | Billets are discoverable through the explorer (filter-based) and section detail pages. Standalone billet text search adds limited product value. |
| `GET /api/billets/{id}` | Every billet is fully rendered on its section detail page with all metadata and occupants. A standalone page would duplicate that without section context. |
| `GET /api/search?q=` | Unified cross-entity search with mixed ranking is Phase 3 work. Separate section and people searches are still clearer. |

These can be revisited if the product loop reveals a real gap.

## 5. API conventions

- All endpoints return `Content-Type: application/json` (except CSV exports which return `text/csv`).
- Error responses use the shape `{"error": "message"}`.
- Search endpoints return `query`, `count`, and `results`.
- Detail endpoints return one main object and its related data.
- Status codes: 200 success, 400 bad input, 404 not found, 500 internal error, 503 unavailable.
- Route registration order matters: specific routes before parameterized routes (e.g., `/sections/search` before `/sections/{sectionID}`).

## 6. Search behavior

### Supported search inputs
- person names
- organization names (official, shorthand, aliases)
- section names and codes
- billet titles (via explorer filters)
- UICs
- office symbols

### Input normalization
All search input is normalized before matching: trim whitespace, lowercase, strip all non-alphanumeric characters. "G-6", "G 6", "g6", and "G6" all produce the same search term.

### Concatenated matching
Queries support compound searches like "XVIII Airborne Corps G6" by concatenating normalized organization and section fields.

### Ranking
Search results are ranked using a `CASE` expression in `ORDER BY`. Exact matches rank highest, prefix matches next, then substring matches.

### Deduplication
People search uses `ROW_NUMBER() OVER (PARTITION BY person_id)` to deduplicate when a person has multiple active billet assignments.

## 7. Export behavior

### Positions export (`GET /api/exports/positions`)
- Same filters as the explorer endpoint.
- No pagination — returns full filtered set (capped at 10,000 rows).
- Reuses the existing `searchExplorerPositions` query function.
- Timestamped filename: `greenpages_explorer_positions_20260413_143022.csv`.
- Human-readable column headers.

### Section export (`GET /api/exports/section/{sectionID}`)
- Reuses the existing `getSectionDetail` function.
- One CSV row per occupant (multiple rows for multi-occupant billets).
- Vacant/unknown billets get one row with empty occupant columns.
- Filename built from section display name: `XVIII_Airborne_Corps_G-6_roster_20260413_143022.csv`.
- Includes occupant email, phone, and office symbol.

## 8. Seed data

Seed data is not just test filler. It is currently part of the product-shaping process.

### Current seed data coverage
- 28 organizations across Active, Guard, and Reserve components
- ~205 billets across multiple staff sections per organization
- 140 people with realistic names, ranks, emails, office symbols
- Filled, vacant, and unknown billet statuses distributed across all organizations
- Multi-occupant billets (one primary, one secondary) exercising the data quality rules
- People assigned across multiple sections (testing multi-assignment display)
- Organization aliases for shorthand search testing

### Rules for seed data
- Seed by business meaning, not hard-coded foreign key IDs.
- Use joins on stable names or natural lookup fields.
- Deliberately seed realistic scenarios that exercise product edge cases.

## 9. Refresh and ingestion

### Current state
The application runs entirely on seed data. No external data source integration exists yet.

### Intended direction
- Daily refresh from external Army data sources (Vantage, AOS).
- Ingestion should happen in a separate refresh or worker path that cleans and loads data into canonical tables.
- The API serves only clean, normalized data from PostgreSQL, never raw source payloads.
- Identity should be anchored to stable identifiers (`dod_id`, not display names).
- External API calls should never happen inside web request handlers.

### Timing
Ingestion work should not begin until the product loop proves the canonical model is correct. The current seed data approach is intentional and should continue until the product surfaces are stable.
