# Green Pages Internal Reference Patterns

## 1. Purpose

This file captures the internal application patterns shown by the example repositories you shared and explains what Green Pages should take from them.

This is not a command to clone those repos exactly. It is a way to separate:

- what appears to be an organizational pattern,
- what is product-specific to those apps,
- and what Green Pages should adopt intentionally.

## 2. Pattern 1: COST-style application shape

The COST example points to a strong organizational deployment pattern:

- split frontend and backend,
- multiple runtime components,
- dedicated deploy tree,
- Zarf and UDS packaging,
- Helm charts per component,
- environment-specific pipeline config,
- rich frontend structure,
- optional worker and Redis side components,
- in-repo docs and screenshots.

What Green Pages should copy from this pattern:

- separate deployable frontend and backend,
- deploy tree under `deploy/`,
- environment-specific pipeline configuration,
- Zarf + UDS + Helm delivery structure,
- support for optional worker later,
- real documentation artifacts in the repo.

What Green Pages should **not** copy by default:

- Redis unless justified,
- worker unless justified,
- extra complexity that only exists because COST has different runtime needs.

## 3. Pattern 2: React + Django example shape

The React + Django example points to a different but still useful internal pattern:

- clear split between frontend and backend,
- top-level `Makefile`,
- `compose.yml` for local dev,
- backend with environment-specific settings,
- a real `docs/` tree,
- generated design artifacts like SDD files and PDFs,
- explicit database bootstrapping for local or test flows.

What Green Pages should copy from this pattern:

- `Makefile` as a convenience layer,
- `compose.yml` for local development,
- environment-specific configuration separation,
- in-repo documentation discipline,
- clean frontend/backend boundaries.

What Green Pages should treat as optional:

- Django itself,
- database bootstrap scripts in the exact same shape,
- template rendering if the frontend remains a SPA.

## 4. What both examples agree on

These examples are different apps, but they reinforce the same baseline expectations:

- container-first development,
- multiple components rather than one flat app,
- explicit environment separation,
- documentation kept in the repo,
- frontend and backend developed independently,
- delivery discipline rather than ad hoc deployment.

That is the important takeaway.

## 5. Green Pages recommended interpretation

Green Pages should adopt the shared organizational pattern while still making product-specific choices.

### Green Pages should adopt
- React frontend
- containerized backend
- local multi-container development
- environment-specific deployment config
- Zarf + UDS + Helm delivery path
- ACR as registry of record
- strong repo docs structure

### Green Pages should default to
- Go backend
- PostgreSQL database
- optional worker only when refresh/import logic justifies it
- optional caching only when there is a measured need

### Green Pages should avoid by default
- copying every extra service from reference apps,
- adding infrastructure components without a direct product reason,
- confusing internal precedent with mandatory one-for-one duplication.

## 6. Practical repo posture for Green Pages

The right mindset is:

- follow the **delivery pattern** of internal apps,
- follow the **implementation stack** chosen for Green Pages,
- leave room for a Django-aligned variant if organizational pressure or prototyping speed changes the backend decision later.

## 7. Final takeaway

The internal examples you shared do not change the main Green Pages recommendation.

They do, however, make these things much clearer:

- Zarf + UDS + Helm + ACR is not optional,
- local multi-container development is normal in your environment,
- a structured docs tree is part of the expected repo quality bar,
- and Django is a valid organizational precedent even though Go remains the recommended backend for Green Pages.
