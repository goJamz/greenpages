# Green Pages Product Definition

## 1. Problem

Throughout Army work, people constantly need answers to questions like:

- Who works at XVIII Airborne Corps G-6?
- Who is the S-3 at a given division or brigade?
- Who is the G-3 at I Corps?
- What billet exists at a given organization, and where does it sit in force structure?

Today, those answers are often found through tribal knowledge, side messages, email chains, or asking around.

That creates friction for coordination, staffing, and general Army awareness.

## 2. Product vision

**Green Pages** is a CAC-authenticated Army web application that lets soldiers search people, sections, billets, and organizations, view section-level org charts, and browse Army-wide positions across components.

It combines two user experiences in one platform:

### A. Directory
A person-first directory for **Active Duty Army** that helps users answer:

- Who is in this seat?
- How do I contact this office?
- What does this whole section look like?

### B. Position Explorer
An Army-wide billet explorer for **Active Duty, Army National Guard, and Army Reserve** that helps users answer:

- What positions exist in the force?
- Show me all CPT Engineer billets.
- Show me all 11B SPC billets in the Reserve.
- Let me drill down by component, grade, branch/MOS/AOC, location, unit, and state.

## 3. Core product idea

The product is **not just a people finder**.

It is a **person-first directory layered on top of a billet-and-organization model**.

That means the backend is modeled like this:

**Organization → Section → Billet → Person**

This matters because the app must still work when:

- a billet is vacant,
- a billet exists but the occupant is unknown,
- multiple people are tied to one billet,
- users want to browse billets even when there is no occupant,
- users want to view an entire section instead of a single person.

## 4. Authentication and access

- CAC authentication through **Keycloak**.
- Keycloak sits in front of the CAC trust chain and acts as the identity provider.
- Any user who can successfully CAC authenticate can use the application.
- For MVP, **authenticated = full access**. There is no RBAC layer. Any authenticated user has full read access to all available directory and explorer data.
- Access is limited to users with a `.mil` email associated with the certificate.

Auth is not yet wired into the frontend. Keycloak integration will arrive after the core product loop is proven.

## 5. Scope

### In scope for MVP
- Active Duty directory experience
- Army-wide position explorer across Active, Guard, and Reserve
- current organizations only
- uniformed military billets only
- section search and section detail pages
- people search and person detail pages
- position explorer with filter-first browsing
- billet status labels: Filled, Vacant, Unknown
- CSV export from the explorer and from section detail
- daily refresh (design, not yet built)
- desktop-first
- Zarf + UDS delivery packaging (not yet built)

### Out of scope for MVP
- civilians and contractors
- assignment history
- mobile-first design
- inactive / legacy organizations
- advanced analytics dashboards
- complex manual data stewardship tooling
- RBAC or role-based visibility restrictions

## 6. What the MVP answers

The MVP should answer these questions well:

- Who is this person?
- What billet do they occupy?
- What does this section look like?
- Is this billet filled, vacant, or unknown?
- What billets exist across the force for a given component, grade, MOS, AOC, state, or unit?

## 7. Current product state

The following product surfaces are built and working end to end:

- **Search page** — section search and people search with tab toggle, results link to detail pages.
- **Section detail page** — section metadata, every billet in the section, occupants with primary/secondary badges, status labels, CSV export button.
- **Person detail page** — person metadata, all active assignments with billet and section context, links to section detail.
- **Position explorer** — filter-first browsing by component, grade, branch, MOS, AOC, state, status, and organization. Table results with links to sections and people. CSV export button.
- **CSV export** — positions export (full filtered set, no pagination cap beyond 10,000 rows) and section roster export (all billets with all occupants, one row per occupant).

### Intentionally not built

- **Standalone billet search** (`GET /api/billets/search`) — billets are already discoverable through the explorer (filter-based) and through section detail pages. A standalone billet text search was in the original API spec but adds limited product value given what the explorer already provides.
- **Standalone billet detail page** (`GET /api/billets/{id}`) — every billet is fully rendered on its section detail page with all metadata and occupants. A standalone billet page would show the same data without section context.
- **Unified search** (`GET /api/search?q=`) — the search page uses separate section and people search tabs. A unified endpoint that ranks across entity types is Phase 3 work. Separate searches are still clearer for now.

These decisions can be revisited if the product loop reveals a real gap.

## 8. Product principles

1. **Search should accept Army shorthand.**
   Users should not be forced to type only official names.

2. **The whole section is a first-class result.**
   The app should not reduce section searches to one person card.

3. **Vacant and unknown are still valuable answers.**
   A seat with no occupant is still part of the truth.

4. **People data must sit on top of billet data, not replace it.**

5. **The explorer must support curiosity and discovery.**
   It should be possible to browse positions even without a search term.

6. **The delivery model must match the organization's platform.**
   The app should be designed from the beginning for ACR, Zarf, UDS, Helm, and Kubernetes-based deployment.

7. **Older recommendations should not override newer repo reality.**
   The codebase should move forward from the current working state, not from an earlier mental model.

## 9. Data freshness

- Daily refresh is acceptable.
- MVP shows current state only.
- Assignment history is out of scope for MVP.
- The ingestion pipeline from external sources (Vantage, AOS) has not been built yet and should not be built until the product loop proves the canonical model.

## 10. Final product statement

**Green Pages is a CAC-authenticated Army directory and billet explorer that lets soldiers search people, sections, billets, and organizations, view full section-level org charts, and browse Army-wide positions across components using current billet, occupant, and force-structure data, packaged and deployed through the organization's Zarf/UDS delivery model.**
