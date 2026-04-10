-- backend/migrations/000002_organizations_and_sections.sql
-- Enable trigram extension for fuzzy search.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Organizations
CREATE TABLE organizations (
    organization_id        BIGSERIAL PRIMARY KEY,
    organization_name      TEXT NOT NULL,
    normalized_name        TEXT NOT NULL,
    short_name             TEXT,
    parent_organization_id BIGINT REFERENCES organizations(organization_id),
    component              TEXT,
    echelon                TEXT,
    uic                    TEXT,
    location_name          TEXT,
    state_code             TEXT,
    is_current             BOOLEAN NOT NULL DEFAULT TRUE,
    last_refreshed_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_organizations_normalized_name ON organizations USING gin (normalized_name gin_trgm_ops);
CREATE INDEX idx_organizations_uic ON organizations (uic);
CREATE INDEX idx_organizations_parent ON organizations (parent_organization_id);
CREATE INDEX idx_organizations_component ON organizations (component);

-- Organization aliases
CREATE TABLE organization_aliases (
    organization_alias_id  BIGSERIAL PRIMARY KEY,
    organization_id        BIGINT NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
    alias_text             TEXT NOT NULL,
    alias_type             TEXT,
    normalized_alias_text  TEXT NOT NULL
);

CREATE INDEX idx_org_aliases_normalized ON organization_aliases USING gin (normalized_alias_text gin_trgm_ops);
CREATE INDEX idx_org_aliases_org_id ON organization_aliases (organization_id);

-- Sections
CREATE TABLE sections (
    section_id              BIGSERIAL PRIMARY KEY,
    organization_id         BIGINT NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
    section_code            TEXT,
    section_name            TEXT NOT NULL,
    normalized_section_name TEXT NOT NULL,
    display_name            TEXT,
    parent_section_id       BIGINT REFERENCES sections(section_id),
    is_current              BOOLEAN NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sections_org_id ON sections (organization_id);
CREATE INDEX idx_sections_normalized ON sections USING gin (normalized_section_name gin_trgm_ops);
CREATE INDEX idx_sections_code ON sections (section_code);