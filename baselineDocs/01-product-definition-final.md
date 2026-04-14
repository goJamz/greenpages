# Green Pages Product Definition

## 1. Problem

Army users regularly need answers to questions like:

- Who works at XVIII Airborne Corps G-6?
- Who is the S-3 at a given division or brigade?
- Who is the G-3 at I Corps?
- What billets exist in a given organization?
- What does the whole shop look like, including vacant seats?

Today those answers are often found through tribal knowledge, side messages, email chains, or asking around.

Green Pages exists to reduce that friction.

## 2. Product vision

**Green Pages** is a CAC-authenticated Army web application that combines two experiences in one product:

### A. Directory
A person-and-section directory for **Active Duty Army** that helps users answer:
- Who is this person?
- What section are they in?
- What does the full section look like?
- Who occupies which billet?

### B. Position Explorer
An Army-wide billet explorer for **Active Duty, Army National Guard, and Army Reserve** that helps users answer:
- What positions exist across the force?
- Show me all billets that match a component, grade, branch, MOS, AOC, state, or unit.
- Let me browse positions even when I do not know the exact organization structure yet.

## 3. Core product idea

Green Pages is **not just a people finder**.

It is a **directory layered on top of a billet-and-organization model**.

The core model is:

**Organization → Section → Billet → Person**

This matters because the product must still work when:
- a billet is vacant,
- a billet exists but the occupant is unknown,
- multiple people are tied to one billet,
- users want to browse billets even when there is no occupant,
- users want to open a whole section instead of only one person.

## 4. Authentication and access

- CAC authentication will be handled through **Keycloak**.
- Keycloak sits in front of the CAC trust chain and acts as the identity provider.
- For MVP, **authenticated = full access**.
- There is **no RBAC layer** in the MVP.
- Auth is part of the intended platform direction, but it is **not yet wired into the current frontend shell**.
- The project decision is to add auth **after the core product loop is proven**.

## 5. MVP scope

### In scope
- Active Duty directory experience
- Army-wide position explorer across Active, Guard, and Reserve
- current organizations only
- uniformed military billets only
- section search and section detail
- people search and person detail
- position explorer with filter-first browsing
- billet status labels: **Filled**, **Vacant**, **Unknown**
- CSV export from explorer and section detail
- desktop-first design
- current-state-only data model

### Out of scope
- civilians and contractors
- assignment history
- mobile-first design
- inactive or legacy organizations
- advanced analytics dashboards
- complex stewardship/admin tooling
- RBAC or role-based visibility restrictions in MVP

## 6. Product principles

1. **Search should accept Army shorthand.**
   Users should not be forced to type only official names.

2. **The whole section is a first-class result.**
   A section search should resolve to the full shop, not collapse into one person card.

3. **Vacant and unknown are still valuable answers.**
   An unfilled seat is still part of the truth.

4. **People data sits on top of billet data, not in place of it.**

5. **The explorer must support curiosity and discovery.**
   Browsing with filters and no free-text term is a real product requirement.

6. **Older recommendations should not override newer repo reality.**
   The product should move forward from what the repo has already proven.

## 7. Current product state

The current repo has a real working product loop:

- **Search page** with explicit **Sections** and **People** modes
- **Section detail page** with section metadata, billets, occupants, and billet status
- **Person detail page** with person metadata and active assignment context
- **Position explorer** with filter-first billet browsing
- **CSV export** from explorer and section detail
- working cross-links between directory and detail surfaces

### What the current MVP answers well
- Who is this person?
- What billet do they occupy?
- What does this section look like?
- Is this billet filled, vacant, or unknown?
- What billets exist for a given component, grade, MOS, AOC, state, or unit?

## 8. Intentionally not built right now

These are not accidental omissions. They are current product decisions.

| Surface | Current decision | Why |
|---|---|---|
| Standalone billet search | Not built | Billets are already discoverable through the explorer and through section detail pages. |
| Standalone billet detail page | Not built | The section detail page already shows billet metadata and occupants in the billet’s natural context. |
| Unified cross-entity search | Deferred | Separate **sections** and **people** searches are clearer at the current stage. Mixed-type ranking can come later if the product reveals a real need. |

These decisions can be revisited later, but they should not be treated as missing work just because an older checklist once listed them.

## 9. Search behavior

### Supported search inputs
- person names
- organization names
- aliases and shorthand
- section names and codes
- office symbols
- UICs
- billet discovery through explorer filters

### Expected behavior
- Searches like `XVIII Airborne Corps G-6` should resolve to the **whole section**.
- Broad terms like `G6` should return a **ranked list of section matches**.
- Search should tolerate Army shorthand and formatting differences.
- The explorer should work with **no search term**.

## 10. Data freshness and ingestion posture

- MVP is **current state only**.
- Daily refresh is acceptable.
- The current system runs on seed data.
- External ingestion from systems like Vantage or AOS is **not built yet**.
- That ingestion work should begin only after the product loop proves the canonical model is correct.

## 11. Final product statement

**Green Pages is a CAC-authenticated Army directory and billet explorer that lets users search people and sections, open full section views, and browse force-wide billets across components using a current-state Organization → Section → Billet → Person model.**
