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

It is meant to combine two user experiences in one platform:

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

That means the backend should be modeled like this:

**Organization → Section → Billet → Person**

This matters because the app must still work when:

- a billet is vacant,
- a billet exists but the occupant is unknown,
- multiple people are tied to one billet,
- users want to browse billets even when there is no occupant,
- users want to view an entire section instead of a single person.

## 4. Confirmed decisions from this thread

### Authentication and access
- CAC authentication is required through **Keycloak**.
- Keycloak sits in front of the CAC trust chain and acts as the identity provider for the application.
- Any user who can successfully CAC authenticate through Keycloak can use the application.
- For MVP, **authenticated = full access**. There is no RBAC layer in the MVP; any authenticated user has full read access to all available directory and explorer data.

### Scope
- **Directory:** Active Duty Army.
- **Position Explorer:** all Army components.
- **Current organizations only** for MVP.
- **Uniformed military billets only** for MVP.
- Civilians and contractors are out of scope for the initial release.

### Search behavior
Users should be able to search by:

- person name,
- organization name,
- staff section,
- billet title,
- UIC,
- official names,
- shorthand and aliases.

Examples:

- `18th Airborne Corps G6`
- `XVIII Airborne Corps G-6`
- `I Corps G3`
- person name queries
- broad section terms like `G6`

Expected behavior:

- Searching a section like `18th Airborne Corps G6` should open the **whole G-6 section**, not just one billet.
- Broad searches like `G6` should return a **list of matching sections**.
- Vacant billets should be searchable too.
- The Position Explorer should allow browsing with **no search term**, starting from filters.

### Display expectations
- Directory results should emphasize the **person** first.
- Section pages should use an **org chart style** display.
- Every billet in the section should be shown.
- Each billet must be clearly marked as:
  - **Filled**
  - **Vacant**
  - **Unknown**
- If multiple people are tied to one billet, show all and mark one as **primary**.

### Data freshness
- Daily refresh is acceptable.
- MVP should show **current state only**.
- Assignment history can come later.

### Platform expectations
- Desktop-first for MVP.
- Export/download is in scope for MVP.

## 5. Organizational delivery constraints

These are now **hard requirements**, not optional implementation choices:

- the application must follow your organization’s **Zarf + UDS** delivery model,
- container images must be pushed to the organization’s **Azure Container Registry (ACR)**,
- deployment should target a **Kubernetes environment** that can run the organization’s UDS-based application pattern,
- the repo and deployment layout should align with how your organization already packages and deploys internal applications.

This changes one important recommendation from the earlier thread:

Green Pages should be treated as a **containerized Kubernetes application packaged for UDS**, not as a standalone App Service-first or Container Apps-first web app.

## 6. MVP definition

The MVP is:

A **CAC-authenticated, desktop-first web application** where a soldier can:

- search for a person,
- search for a section like G-6 or S-3,
- search for a billet,
- search by organization name or alias,
- browse Army-wide positions across components,
- open a section and see the entire org chart,
- view current billet status,
- view available person/contact data,
- export results.

## 7. Day-one priorities

### Priority 1: Directory
This is the first thing that should feel useful.

Key outcomes:
- Find a person.
- Find the right office.
- Open the whole section.
- Understand who occupies which billet.

### Priority 2: Position Explorer
This recreates and improves the lost Army Career Tracker-style exploration experience.

Key outcomes:
- Browse all positions by component.
- Drill down by grade, MOS/AOC/branch, location, and organization.
- View occupant when available.

## 8. Suggested result screens

### A. Person result
Displays:
- name
- rank
- duty title
- office symbol if available
- organization
- staff section
- contact details if available
- billet status
- UIC
- paragraph
- line
- location
- last refreshed date

### B. Section result
Displays:
- section header (for example, `XVIII Airborne Corps G-6`)
- org chart view
- every billet in the section
- occupant if available
- billet status
- billet metadata

### C. Position Explorer result
Displays:
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

## 9. Product principles

1. **Search should accept Army shorthand.**  
   Users should not be forced to type only official names.

2. **The whole section is a first-class result.**  
   The app should not reduce section searches to one person card.

3. **Vacant and unknown are still valuable answers.**  
   A seat with no occupant is still part of the truth.

4. **People data must sit on top of billet data, not replace it.**

5. **The explorer must support curiosity and discovery.**  
   It should be possible to browse positions even without a search term.

6. **The delivery model must match the organization’s platform.**  
   The app should be designed from the beginning for ACR, Zarf, UDS, Helm, and Kubernetes-based deployment.

## 10. External grounding for product assumptions

The thread decisions align with current official platform capabilities:

- IPPS-A documentation shows position-related search fields such as UIC, grade, MOS/AOC/POSCO, component grouping, and paragraph/line in job-opening workflows, which supports the idea that these are normal Army-facing search dimensions.[^1]
- IPPS-A/AOS documentation states that AOS provides authoritative force-structure data to IPPS-A, which matches the idea of using a billet/organization model as the structural backbone.[^2]
- Keycloak documentation covers X.509 client certificate authentication for browser flows and direct grant flows, which fits the CAC-authenticated application direction selected in this thread.[^3]
- Standard React OIDC client libraries such as `react-oidc-context` support React SPA authentication with OIDC providers and redirect handling, which fits a Keycloak-backed frontend.[^4]
- Zarf documentation describes Kubernetes deployment through Helm-backed packaging, which aligns with treating Green Pages as a packaged Kubernetes application instead of a simple website deployment.[^5]
- UDS documentation describes UDS Packages as Zarf Packages containing OCI images, Helm charts, and supplemental Kubernetes manifests, which matches the organizational requirement to package applications through UDS.[^6]

## 11. Final product statement

**Green Pages is a CAC-authenticated Army directory and billet explorer that lets soldiers search people, sections, billets, and organizations, view full section-level org charts, and browse Army-wide positions across components using current billet, occupant, and force-structure data, packaged and deployed through the organization’s Zarf/UDS delivery model.**

---

## Sources

[^1]: IPPS-A, *Job Aid: Job Opening Search*, March 4, 2024. Available from IPPS-A official documentation: <https://ipps-a.army.mil/Portals/129/Documents/Job%20Aid_Job%20Opening%20Search_20240304.pdf>

[^2]: IPPS-A, *How to Export AOS UICs and Billets*, March 5, 2024. Available from IPPS-A official documentation: <https://ipps-a.army.mil/Portals/129/Documents/How%20to%20Export%20AOS%20UICs%20and%20Billets_5MAR2024.pdf>

[^3]: Keycloak documentation, *Server Administration Guide* — X.509 client certificate user authentication. <https://www.keycloak.org/docs/latest/server_admin/index.html>

[^4]: `react-oidc-context` documentation. <https://github.com/authts/react-oidc-context>

[^5]: Zarf docs, *Deploy a Package*. <https://docs.zarf.dev/ref/deploy/>

[^6]: UDS docs, *UDS Packages*. <https://uds.defenseunicorns.com/structure/packages/>
