# Green Pages Engineering Standards

## 1. Purpose

This document captures how Green Pages code should feel, how implementation decisions should be made, and how the repo should evolve.

The goal is not maximum architecture. The goal is calm, explicit, maintainable code that grows one real slice at a time.

## 2. Core philosophy

### Keep it simple
Do not add abstractions, packages, or infrastructure until there is a concrete reason.

### Build the consumer before the producer
Prove the data model through API and UI slices first. Build ingestion later.

### Build in vertical slices
Do not build a whole backend architecture and then hope the UI fits it later. Prove one real user-facing slice at a time.

### Leave room without building the room
Use shapes that allow future growth, but do not create empty rooms for future code.

### Older recommendations should not override newer repo reality
When the repo proves a better direction, update the docs and move forward.

## 3. Abstraction timing rules

Add a new abstraction only when it:
1. removes real repetition,
2. reduces real maintenance pain,
3. makes the code easier to read,
4. supports the next real slice,
5. or prevents a well-understood failure mode.

Do **not** add abstractions just because they:
- look more enterprise,
- might be useful later,
- appear in another codebase,
- or feel cleaner in theory.

### Avoid too early
- repository wrappers with no real value
- empty service layers
- config packages before config complexity exists
- workers without a real background workload
- Redis without measured need
- dependency injection frameworks
- ORM-heavy approaches
- generic mega-search orchestration before search pain is real

## 4. Code organization

### Split by behavior, not by technical layer
Prefer files like:
- `sections_search.go`
- `sections_detail.go`
- `people_search.go`
- `people_detail.go`
- `explorer_positions.go`
- `export.go`

Avoid early splits like:
- `queries.go`
- `handlers.go`
- `types.go`
- `helpers.go`

The maintainer should be able to understand one feature without bouncing across a pile of files.

### Keep `server.go` infrastructure-focused
`server.go` should mostly contain:
- server setup
- dependency wiring
- route registration
- health and readiness handlers

Business behavior belongs in behavior-focused files.

### Do not create packages prematurely
These are not needed yet:
- `internal/repository/`
- `internal/services/`
- `internal/handlers/`
- `internal/sections/`
- `internal/config/`
- generic SQL utility packages

## 5. Go style rules for this project

These are deliberate project conventions.

### Variable declarations
Declare variables at the top of the function with explicit `var` declarations and comments.

### No short declarations
Do **not** use `:=`.

### Receiver names
Prefer descriptive receiver names like `applicationServer` over single-letter shorthand.

### Naming
Use thoughtful, descriptive names. Avoid tiny names unless the scope is truly tiny and obvious.

### Comments
Comments should explain:
- purpose,
- intent,
- contract,
- or reasoning.

If the code is hard to read, fix the code first.

### Explicit over implicit
Prefer:
- explicit `WriteHeader`
- explicit status normalization
- explicit ignored-error acknowledgement with `_ =`

### No dead state
Delete unused variables, fields, and response members.

## 6. SQL and data-access posture

### SQL first
The project is SQL-first. PostgreSQL is the system of record. Keep queries explicit.

### Current accepted stack
- `database/sql` is correct for now
- pgx stdlib driver is correct for now
- `sqlc` remains a likely future step
- `sqlc` should wait until the schema and query surface stabilize

### Query-shape rules
Prefer queries that are:
- readable,
- explicit,
- easy to trace,
- and easy to test.

If two simpler queries are clearer than one giant join, prefer the simpler shape.

### COALESCE first
Use SQL-side `COALESCE` when it keeps the Go side simpler. Use nullable scan types only when nullability truly matters to control flow.

### Clean 404s over giant joins
Prefer:
- one `QueryRow` for the main entity,
- followed by one `Query` for related rows.

If the base entity does not exist, return a clean 404.

### Row iteration rule
Always check `rows.Err()` after iterating.

## 7. Canonical model rule

Do not let shortcuts collapse the product away from its backbone:

**Organization → Section → Billet → Person**

Practical consequences:
- sections are first-class results
- billets exist even when empty
- vacant and unknown are real answers
- people views should preserve structural context

## 8. Search posture

Search should be practical before it becomes sophisticated.

Current priorities:
- accept Army shorthand
- normalize inputs
- rank obvious matches sensibly
- keep section search whole-section oriented
- keep people search deduplicated and context-aware
- keep explorer browsing useful without requiring a search term

Do not rush into a combined mega-search endpoint.

## 9. Frontend posture

The frontend should remain deliberately lightweight while the product is still being shaped.

That means:
- simple routing
- direct API fetches
- no unnecessary global state complexity
- no heavy design-system investment yet
- auth wiring added when it solves the next real problem

### Current frontend working rule
The frontend exists to pressure-test the backend model and product loop, not to win architecture points.

## 10. Delivery posture

Follow the organization’s delivery model, but do not cargo-cult every extra service from internal examples.

That means:
- frontend and backend are expected
- multi-container local development is expected
- Helm + Zarf + UDS are expected
- Redis is optional
- workers are optional
- extra services must earn their existence

### Important current sequencing decision
The delivery skeleton should come as **one coherent slice**, not a piecemeal scatter of half-built deployment files.

## 11. Seed data posture

Seed data is part of product shaping.

### Rules
- seed by business meaning when possible
- prefer joins on stable names or natural lookup fields
- exercise real edge cases, not just happy-path connectivity

### Important scenarios
- filled billets
- vacant billets
- unknown billets
- multi-occupant billets with one primary
- realistic org and section context
- multi-assignment people where useful

## 12. Source-aware without source-heavy

Stay lightly future-aware without becoming ingestion-heavy too early.

Good future-aware fields include:
- `dod_id`
- `normalized_*` fields
- `is_current`
- `last_refreshed_at`
- `source_system`
- `effective_date`

Do **not** jump yet into:
- staging frameworks
- ETL service trees
- worker ingest platforms
- search-document infrastructure that the current product does not need yet

The database is the clean room. The API should serve normalized truth, not raw source payloads.

## 13. Documentation rule

Prefer a **small number of useful documents** over a large number of overlapping ones.

That means:
- update docs when live decisions change
- remove stale docs instead of endlessly stacking new ones
- capture important decisions compactly
- keep documentation aligned to the actual repo

## 14. Practical review checklist

Before writing or merging a slice, ask:

1. Does this solve a real current problem?
2. Does this make the next maintainer’s life easier?
3. Is `server.go` still mostly infrastructure?
4. Did I add an abstraction because it helps now, or because it sounds architectural?
5. Did I preserve the canonical model instead of collapsing it into a shortcut?
6. Did I handle nullability and row iteration safely?
7. Does this support the next real product slice?

## 15. Final takeaway

Green Pages should feel:
- explicit,
- maintainable,
- product-driven,
- readable,
- lightly future-aware,
- and resistant to unnecessary complexity.

The repo should grow by proving one real slice at a time.
