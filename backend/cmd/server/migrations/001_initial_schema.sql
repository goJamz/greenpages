-- Enable extensions
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Organizations
CREATE TABLE organizations (
    organization_id     BIGSERIAL PRIMARY KEY,
    organization_name   TEXT NOT NULL,
    normalized_name     TEXT NOT NULL,
    short_name          TEXT,
    parent_organization_id BIGINT REFERENCES organizations(organization_id),
    component           TEXT,
    echelon             TEXT,
    uic                 TEXT,
    location_name       TEXT,
    state_code          TEXT,
    is_current          BOOLEAN NOT NULL DEFAULT TRUE,
    last_refreshed_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_organizations_normalized_name ON organizations USING gin (normalized_name gin_trgm_ops);
CREATE INDEX idx_organizations_uic ON organizations (uic);
CREATE INDEX idx_organizations_parent ON organizations (parent_organization_id);
CREATE INDEX idx_organizations_component ON organizations (component);

-- Organization aliases
CREATE TABLE organization_aliases (
    organization_alias_id BIGSERIAL PRIMARY KEY,
    organization_id       BIGINT NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
    alias_text            TEXT NOT NULL,
    alias_type            TEXT,
    normalized_alias_text TEXT NOT NULL
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

-- Billets
CREATE TABLE billets (
    billet_id              BIGSERIAL PRIMARY KEY,
    organization_id        BIGINT NOT NULL REFERENCES organizations(organization_id) ON DELETE CASCADE,
    section_id             BIGINT REFERENCES sections(section_id),
    position_number        TEXT,
    billet_title           TEXT NOT NULL,
    normalized_billet_title TEXT NOT NULL,
    grade_code             TEXT,
    rank_group             TEXT,
    branch_code            TEXT,
    mos_code               TEXT,
    aoc_code               TEXT,
    component              TEXT,
    uic                    TEXT,
    paragraph_number       TEXT,
    line_number            TEXT,
    duty_location          TEXT,
    state_code             TEXT,
    is_current             BOOLEAN NOT NULL DEFAULT TRUE,
    last_refreshed_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_billets_org_id ON billets (organization_id);
CREATE INDEX idx_billets_section_id ON billets (section_id);
CREATE INDEX idx_billets_component ON billets (component);
CREATE INDEX idx_billets_grade ON billets (grade_code);
CREATE INDEX idx_billets_mos ON billets (mos_code);
CREATE INDEX idx_billets_normalized_title ON billets USING gin (normalized_billet_title gin_trgm_ops);

-- People
CREATE TABLE people (
    person_id              BIGSERIAL PRIMARY KEY,
    display_name           TEXT NOT NULL,
    normalized_display_name TEXT NOT NULL,
    rank                   TEXT,
    work_email             TEXT,
    work_phone             TEXT,
    office_symbol          TEXT,
    is_current             BOOLEAN NOT NULL DEFAULT TRUE,
    last_refreshed_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_people_normalized ON people USING gin (normalized_display_name gin_trgm_ops);

-- Billet occupants (join table)
CREATE TABLE billet_occupants (
    billet_occupant_id BIGSERIAL PRIMARY KEY,
    billet_id          BIGINT NOT NULL REFERENCES billets(billet_id) ON DELETE CASCADE,
    person_id          BIGINT NOT NULL REFERENCES people(person_id) ON DELETE CASCADE,
    is_primary         BOOLEAN NOT NULL DEFAULT TRUE,
    occupancy_status   TEXT NOT NULL DEFAULT 'active',
    source_system      TEXT,
    effective_date     DATE,
    last_refreshed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_billet_occupants_billet ON billet_occupants (billet_id);
CREATE INDEX idx_billet_occupants_person ON billet_occupants (person_id);

-- Search documents (denormalized search projection)
CREATE TABLE search_documents (
    search_document_id BIGSERIAL PRIMARY KEY,
    document_type      TEXT NOT NULL,
    entity_id          BIGINT NOT NULL,
    search_text        TEXT NOT NULL,
    ts_document        TSVECTOR,
    display_name       TEXT NOT NULL,
    subtitle           TEXT,
    status             TEXT,
    last_refreshed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_search_docs_ts ON search_documents USING gin (ts_document);
CREATE INDEX idx_search_docs_trgm ON search_documents USING gin (search_text gin_trgm_ops);
CREATE INDEX idx_search_docs_type ON search_documents (document_type);
