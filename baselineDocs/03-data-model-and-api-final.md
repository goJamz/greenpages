# Green Pages Data Model and API

## 1. Canonical data model

The application is modeled around:

**Organization → Section → Billet → Person**

This is the backbone of the product, not just a schema diagram.

## 2. Core entities

### organizations
Canonical organizations.

Key fields:
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
- `created_at`

### organization_aliases
Alternate names and shorthand for organizations.

Key fields:
- `organization_alias_id`
- `organization_id`
- `alias_text`
- `alias_type`
- `normalized_alias_text`

### sections
Staff sections within organizations.

Key fields:
- `section_id`
- `organization_id`
- `section_code`
- `section_name`
- `normalized_section_name`
- `display_name`
- `parent_section_id`
- `is_current`
- `created_at`

### billets
Authorized positions independent of occupant identity.

Key fields:
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
- `occupancy_status`
- `is_current`
- `created_at`
- `updated_at`

### people
Person identity and contact data used by the directory.

Key fields:
- `person_id`
- `dod_id`
- `display_name`
- `normalized_display_name`
- `rank`
- `work_email`
- `work_phone`
- `office_symbol`
- `is_current`
- `last_refreshed_at`
- `created_at`

### billet_occupants
Mappings between people and billets.

Key fields:
- `billet_occupant_id`
- `billet_id`
- `person_id`
- `is_primary`
- `assignment_status`
- `source_system`
- `effective_date`
- `last_refreshed_at`
- `created_at`

## 3. Important integrity rules

- `occupancy_status` is constrained to `filled`, `vacant`, `unknown`
- `assignment_status` is constrained to `active`, `inactive`
- only one active primary occupant per billet
- duplicate `(billet_id, person_id)` mappings are blocked
- current-person uniqueness is enforced for `dod_id` and `work_email` where present

## 4. Occupancy status rules

### Filled
A billet exists and there is at least one active occupant mapping.

### Vacant
A billet exists and the data clearly indicates there is no current occupant.

### Unknown
A billet exists but the occupant truth is weak, missing, stale, or conflicting.

### API presentation rule
The API presents status as **Filled**, **Vacant**, or **Unknown**, even if the database stores lowercase values.

## 5. Data quality rules

### Multiple people on one billet
- show all current linked people
- mark one as primary
- do not hide secondary links

### Missing person data
- do not suppress the billet
- return the billet with its structural metadata and status

### Missing structural data
- avoid people results with no organizational context when possible

## 6. API surface

### Built and working

| Endpoint | Purpose |
|---|---|
| `GET /api/health` | Liveness probe |
| `GET /api/readyz` | Readiness probe with database ping |
| `GET /api/sections/search?q=` | Section search |
| `GET /api/sections/{sectionID}` | Section detail with billets and occupants |
| `GET /api/people/search?q=` | People search |
| `GET /api/people/{personID}` | Person detail with active assignments |
| `GET /api/explorer/positions` | Billet explorer with filters |
| `GET /api/exports/positions` | CSV export of filtered explorer positions |
| `GET /api/exports/section/{sectionID}` | CSV export of a section roster |

### Intentionally not built right now

| Endpoint | Current decision | Why |
|---|---|---|
| `GET /api/billets/search?q=` | Not built | Billets are already discoverable through explorer browsing and section detail context. |
| `GET /api/billets/{id}` | Not built | A standalone billet page would duplicate section-detail content without adding much product value. |
| `GET /api/search?q=` | Deferred | Mixed-type ranking across sections, people, and billets is a later search-refinement problem, not current MVP work. |

## 7. API conventions

- JSON endpoints return `Content-Type: application/json`
- CSV endpoints return `text/csv`
- error responses use `{"error": "message"}`
- search endpoints return `query`, `count`, and `results`
- detail endpoints return one main object and its related data
- status codes are straightforward: 200, 400, 404, 500, 503
- more specific routes must be registered before parameterized routes

## 8. Search behavior

### Supported inputs
- person names
- organization names
- official names and shorthand
- aliases
- section names and section codes
- office symbols
- UICs
- billet discovery through explorer filters

### Input normalization
All search input is normalized by:
- trimming whitespace
- lowercasing
- removing non-alphanumeric characters

That means `G-6`, `G 6`, `g6`, and `G6` collapse to the same search term.

### Ranking posture
Search ranking should stay predictable:
- exact match first
- prefix match next
- substring-style matches after that

### Deduplication posture
People search should deduplicate person results even when one person has multiple active assignments.

## 9. Export behavior

### Positions export
- uses the same filters as explorer
- returns the full filtered set instead of a paged subset
- is capped at **10,000 rows**
- reuses existing explorer query logic rather than duplicating separate export-specific SQL

### Section export
- exports the section roster
- returns one row per occupant
- returns a single blank-occupant row for vacant or unknown billets
- reuses existing section detail logic rather than inventing a separate data shape just for CSV

## 10. Seed data posture

Seed data is part of product shaping, not just testing.

### Current seed-data goals
- filled billets
- vacant billets
- unknown billets
- multi-occupant billets with one primary
- realistic section and org context
- realistic people and contact fields
- all three components represented where useful

### Working rule
Seed by business meaning and stable names, not by brittle hard-coded foreign key assumptions.

## 11. Refresh and ingestion

### Current state
- the app currently runs on seed data
- no external ingestion pipeline exists yet

### Intended future direction
- daily refresh from approved Army data sources
- refresh logic should run outside the web handlers
- the database should remain the clean normalized read model
- identity should anchor to stable identifiers such as `dod_id` where available

### Timing rule
Do **not** build the ingestion layer until the product loop proves the canonical model is correct.
