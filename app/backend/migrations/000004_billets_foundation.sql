BEGIN;

CREATE TABLE IF NOT EXISTS billets (
    billet_id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL REFERENCES organizations (organization_id) ON DELETE CASCADE,
    section_id BIGINT NOT NULL REFERENCES sections (section_id) ON DELETE CASCADE,
    position_number TEXT,
    billet_title TEXT NOT NULL,
    normalized_billet_title TEXT NOT NULL,
    grade_code TEXT,
    rank_group TEXT,
    branch_code TEXT,
    mos_code TEXT,
    aoc_code TEXT,
    component TEXT,
    uic TEXT,
    paragraph_number TEXT,
    line_number TEXT,
    duty_location TEXT,
    state_code TEXT,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_billets_organization_id
    ON billets (organization_id);

CREATE INDEX IF NOT EXISTS idx_billets_section_id
    ON billets (section_id);

CREATE INDEX IF NOT EXISTS idx_billets_normalized_billet_title
    ON billets (normalized_billet_title);

COMMIT;