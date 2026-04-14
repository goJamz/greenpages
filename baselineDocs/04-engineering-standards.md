# Green Pages Engineering Standards

## 1. Purpose

This document captures the engineering posture, coding standards, and implementation philosophy of Green Pages. It exists so that any developer or maintainer can understand not just what the code does, but why it is shaped the way it is and how it should evolve.

---

## 2. Core philosophy

### Keep it simple
Do not add abstractions, layers, packages, or infrastructure until there is a concrete reason. "We might need it later" is not a reason. "This file is 500 lines and covers three unrelated behaviors" is a reason.

The goal is not to write the smallest possible amount of code. The goal is to write code that is easy to understand, easy to change, hard to misread, and still capable of growing with the product.

### Build the consumer before the producer
Build the API endpoints and frontend against seed data first. Prove the data model works by using it in a real product. Only then build the ingestion pipeline to populate those tables from real sources. If the model is wrong, it is cheaper to discover that before the ingestion layer exists.

### Build in vertical slices
Build features top to bottom. Do not build the entire database layer, then the entire API layer, then the entire frontend. Prove that data flows from the database through the API for a single domain before moving to the next domain.

### Leave room without building the room
Use `cmd/server/` so that `cmd/worker/` can exist later without restructuring. Use `internal/server/` so that `internal/` can hold other packages later. But do not create `cmd/worker/` or additional packages until there is code that belongs there.

### Older recommendations should not override newer repo reality
The codebase should move forward from the current working state, not from an earlier mental model. When the facts change, revise earlier guidance.

---

## 3. Abstraction timing rules

A new abstraction should be added only when at least one of these is true:

1. The same logic is clearly repeated in multiple places.
2. The abstraction removes real maintenance pain.
3. It simplifies the code people actually read.
4. It supports an imminent product need.
5. It prevents a well-understood form of future breakage.

A new abstraction should **not** be added just because it looks more "enterprise," it might be useful later, another codebase uses it, or it feels architecturally cleaner in theory.

### Anti-patterns to avoid early
- empty interface layers
- repository wrappers that add no value
- config packages introduced before configuration complexity exists
- workers with no current background workload
- Redis with no measured need
- generic search orchestration before core search behavior is proven
- service layers without real business logic to hold
- dependency injection frameworks
- ORM libraries

---

## 4. Go code style

### Variable declarations
Declare variables at the top of each function using explicit `var` declarations with inline comments. This makes it immediately clear what every variable in the function is for.

```go
func (applicationServer *Server) handleSectionsSearch(responseWriter http.ResponseWriter, request *http.Request) {
    var rawQuery        string                // Raw q parameter from the URL.
    var normalizedQuery string                // Cleaned search term for database matching.
    var results         []sectionSearchResult // Results from the database search.
    var searchError     error                 // Error returned by the search function.
    var response        sectionSearchResponse // JSON response payload.
```

This is not standard Go style. Standard Go uses short declarations (`:=`) and declares variables at the point of first use. This project chose explicit declarations because they make each function readable as a self-contained unit. A future developer can read the top of any function and immediately understand what it works with.

### No short declarations
Do not use `:=` in this project.

### Receiver names
Receiver names on methods use the full struct name (`applicationServer`), not single-letter abbreviations. This is non-standard Go but consistent with the project's preference for clarity over brevity. Go linters like `revive` may flag this. That is expected and intentional.

### Naming
Use thoughtful, descriptive variable names. Avoid single-letter names unless the scope is truly tiny and obvious.

### Comments
- Add comments to top-of-function variable declarations.
- Add comments to struct fields.
- Comments should explain purpose, intent, contract, or reasoning.
- If the code is hard to read, fix the code first.

### Explicit over implicit
- Explicitly call `WriteHeader(http.StatusOK)` on successful responses.
- Explicitly acknowledge intentionally ignored errors with `_ =`.
- Explicitly normalize values when API consistency matters.

### No dead state
If a variable, field, or struct member is no longer used, delete it. Do not let stale fields accumulate.

### Response consistency
Every HTTP response path must include an explicit `WriteHeader` call. Every response path should look the same:

```go
responseWriter.Header().Set("Content-Type", "application/json")
responseWriter.WriteHeader(http.StatusOK)
_ = json.NewEncoder(responseWriter).Encode(payload)
```

---

## 5. Code organization

### Split by behavior, not by technical layer

When a file grows, split it by what the code does, not by what kind of code it is.

Do this:
- `sections_search.go` — search query, search types, search handler, search helper
- `sections_detail.go` — detail query, detail types, detail handler, detail helper
- `export.go` — both export handlers and their supporting functions

Do not do this:
- `sections_types.go`
- `sections_queries.go`
- `sections_handlers.go`

The first approach keeps everything about one behavior in one file. The second forces jumping between multiple files to understand one feature.

### Do not create packages prematurely

The following package structures are not appropriate yet:

- `internal/repository/`
- `internal/services/`
- `internal/handlers/`
- `internal/sections/`
- `internal/config/`
- a generic SQL utility package

These add indirection, navigation overhead, and import complexity. The current `internal/server/` package with behavior-split files is the right level of organization for this stage.

---

## 6. Server and routing structure

### Server struct
The `Server` struct in `server.go` holds the `*http.Server` and all shared dependencies (currently `*sql.DB`). Handlers are methods on this struct so they have access to dependencies without globals or closures.

### server.go stays infrastructure-focused
`server.go` contains server setup, dependency injection, route registration, and Kubernetes probes. Business logic lives in domain files that attach handlers to the `*Server` struct.

### Route registration
All routes are registered in `registerRoutes()` in `server.go`. This is the single place to see every endpoint. More specific routes must come before parameterized routes (`GET /api/sections/search` before `GET /api/sections/{sectionID}`).

### Handler and query separation
Separate the database query function from the HTTP handler function. `searchSections` handles the query and row scanning. `handleSectionsSearch` handles the HTTP request, calls `searchSections`, and writes the response. This keeps database logic testable independently from HTTP concerns.

---

## 7. Database conventions

### Driver
The project uses `database/sql` with `github.com/jackc/pgx/v5/stdlib` as the driver. All application code depends on Go's standard `database/sql` interface. The driver can be swapped by changing one import. If there is a future demonstrated need for pgx-native features (LISTEN/NOTIFY, COPY, connection pool tuning), the project can migrate to `pgxpool`.

### SQL queries
SQL queries are declared as package-level `const` strings, not inline in handler functions. This keeps them readable, grep-able, and separated from Go control flow.

### COALESCE first
Use `COALESCE(column_name, '')` for optional strings to keep the Go side simpler. This avoids unnecessary `sql.NullString` usage. Use nullable scan types (`sql.NullInt64`) only for genuinely nullable foreign keys returned by LEFT JOINs where 0 would be misleading.

### Filtering
Filter on `is_current = TRUE` for all entity queries. Filter on `assignment_status = 'active'` when joining `billet_occupants`.

### Clean 404s over giant joins
Avoid oversized LEFT JOIN queries that make it hard to determine whether the base entity exists. Prefer: one `QueryRow` for the main entity, followed by one `Query` for related rows. If the first query returns `sql.ErrNoRows`, return a clean 404.

### Row iteration errors
After every `rows.Next()` loop, check `rows.Err()`. This is mandatory:

```go
for rows.Next() {
    // scan...
}
queryError = rows.Err()
if queryError != nil {
    return nil, queryError
}
```

### Migrations
Migrations follow the naming convention `000001_description.sql`. Schema changes and seed data are in separate files. Migrations that create multiple related objects are wrapped in `BEGIN` / `COMMIT`.

Currently executed as Postgres init scripts mounted into `/docker-entrypoint-initdb.d/`. When the schema stabilizes, switch to a real migration tool.

---

## 8. Search conventions

### Input normalization
All search inputs are normalized: trim whitespace, lowercase, strip all non-alphanumeric characters. "G-6", "G 6", "g6" all produce the same term. The same normalization is applied in SQL using `regexp_replace(LOWER(...), '[^a-z0-9]+', '', 'g')`.

### Ranking
Search results are ranked using `CASE` expressions in `ORDER BY`. Exact match → prefix match → substring match. Predictable ranking over premature cleverness.

### Concatenated matching
Queries support compound searches like "XVIII Airborne Corps G6" by concatenating normalized fields in the SQL.

### Deduplication
People search uses `ROW_NUMBER() OVER (PARTITION BY person_id)` to deduplicate when a person has multiple active assignments.

### Near-term posture
Do not rush into a combined mega-search endpoint. Separate search endpoints are still clearer during early development.

---

## 9. Frontend conventions

### Stack
React 19 + TypeScript + Tailwind CSS v4 + Vite 8.

### Tailwind v4
Tailwind v4 does not use a `tailwind.config.js` or `postcss.config.js`. Configuration is CSS-first: `@import "tailwindcss"` in the main CSS file and the `@tailwindcss/vite` plugin in `vite.config.ts`. Do not create legacy Tailwind v3 configuration files.

### TypeScript
The `verbatimModuleSyntax` setting requires `import type` syntax for interfaces and types.

### API client
`src/api/greenpages.ts` is the single API client. It contains all types, response parsing, and fetch functions. Error parsing extracts the backend's `{"error": "message"}` body when present. Export URL builders return strings for `window.location.href` navigation (no fetch needed for CSV downloads since the backend sets `Content-Disposition: attachment`).

### Naming conventions in the API client
Functions follow a consistent pattern: `searchSections`, `searchPeople`, `getSectionDetail`, `getPersonDetail`, `getExplorerPositions`. Export URL builders: `buildExportPositionsURL`, `buildExportSectionURL`.

### Variable style
Frontend code follows the same explicit style: `let` declarations with inline comments describing purpose, mirroring the Go backend's approach.

### Frontend posture
The frontend goal is to pressure-test the backend model, not to win architecture points. No auth wiring, no heavy state library, no large design system. Direct API fetches and simple routing.

### Auth timing
Keycloak and OIDC remain part of the intended platform direction but are not in the current frontend. Auth should arrive when the basic product loop already works.

---

## 10. Seed data posture

Seed data is not just test filler. It is currently part of the product-shaping process.

### Rules
- Seed by business meaning when possible.
- Prefer joins on stable names or natural lookup fields over hard-coded foreign key IDs.
- Deliberately seed realistic scenarios.
- Use seed data to exercise product truth, not just database connectivity.

### Scenarios the seed data demonstrates
- Filled billets with a single occupant.
- Filled billets with multiple occupants (one primary, one non-primary).
- Vacant billets with no occupant rows.
- Unknown billets with no occupant rows.
- People assigned across multiple sections (multi-assignment display).
- Shorthand-friendly organization and section names.
- All three components: Active, Guard, Reserve.

---

## 11. Source-aware without source-heavy

The project should remain source-aware but not prematurely source-heavy. Low-cost future-proofing is good: `dod_id`, `normalized_display_name`, `is_current`, `last_refreshed_at`, `source_system`, `effective_date`. Broader source-ingestion systems should be deferred until product value and canonical model shape are proven.

The database is the clean room. External data sources are messy. The API serves only clean, normalized data from PostgreSQL. If external ingestion is added later, it happens in a separate refresh or worker path. Identity should be anchored to stable identifiers (`dod_id`), not display names.

---

## 12. What this project avoids

- Premature abstraction
- Service layers without business logic to put in them
- Repository patterns without multiple data sources to abstract
- Interface definitions without multiple implementations
- Dependency injection frameworks
- ORM libraries
- Global state or package-level mutable variables (except compiled regexes)
- Framework-heavy approaches when the standard library is sufficient
- Short assignment operators (`:=`)

---

## 13. Code review checklist

Before merging code, ask:

1. Is `server.go` still strictly infrastructure?
2. Are all variables declared at the top of the function with comments?
3. Did I explicitly handle or explicitly ignore (`_ =`) all errors?
4. Did I write `WriteHeader` on every response path?
5. Does every `rows.Next()` loop have a `rows.Err()` check after it?
6. Can my SQL query safely handle a null value without crashing the Go scanner?
7. Did I split by behavior, not by technical layer?
8. If I added an external dependency, did I genuinely need it, or could I have solved the problem with the standard library?
9. Am I preserving the canonical model instead of collapsing it into a shortcut?
10. Does this change make the code easier for the next maintainer to understand?

---

## 14. When to revisit these decisions

These decisions are right for the current stage: one developer, seed data, no production deployment yet. Revisit when:

- The team grows beyond 2-3 developers and package boundaries would reduce merge conflicts.
- The schema stabilizes and init-script migrations should be replaced with a proper migration tool.
- Production deployment requires `distroless` images, graceful shutdown, or structured logging.
- The ingestion pipeline justifies `cmd/worker/` as a separate binary.
- A real need for connection pool tuning justifies switching from `database/sql` to `pgxpool`.
- Test coverage requires mocking the database, which may justify an interface for the data layer.
- The query and response surface stabilizes enough to justify adopting `sqlc` for type-safe query generation.

---

## 15. Practical test for future decisions

When deciding whether to add a new layer, dependency, abstraction, or service, ask:

1. Does this solve a real current problem?
2. Does this make the code easier for the next maintainer to understand?
3. Does this support the next real product slice?
4. Would the project be worse off in the next few weeks if we did not add it?
5. Are we adding room for growth, or are we building future complexity too early?

If those answers are weak, the feature should wait.

---

## 16. Final takeaway

Green Pages should be built with a calm, deliberate engineering style. It should feel explicit, maintainable, product-driven, readable, lightly future-aware, and resistant to unnecessary complexity.

The project grows by proving one real slice at a time.
