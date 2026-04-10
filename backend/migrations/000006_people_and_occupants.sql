BEGIN;

CREATE TABLE people (
    person_id BIGSERIAL PRIMARY KEY,
    dod_id TEXT,
    display_name TEXT NOT NULL,
    normalized_display_name TEXT NOT NULL,
    rank TEXT,
    work_email TEXT,
    work_phone TEXT,
    office_symbol TEXT,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    last_refreshed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_people_normalized
    ON people
    USING gin (normalized_display_name gin_trgm_ops);

CREATE UNIQUE INDEX idx_people_dod_id_current_unique
    ON people (dod_id)
    WHERE dod_id IS NOT NULL
      AND is_current = TRUE;

CREATE UNIQUE INDEX idx_people_work_email_current_unique
    ON people (LOWER(work_email))
    WHERE work_email IS NOT NULL
      AND is_current = TRUE;

ALTER TABLE billets
    ADD COLUMN occupancy_status TEXT NOT NULL DEFAULT 'unknown';

ALTER TABLE billets
    ADD CONSTRAINT billets_occupancy_status_chk
    CHECK (occupancy_status IN ('filled', 'vacant', 'unknown'));

CREATE TABLE billet_occupants (
    billet_occupant_id BIGSERIAL PRIMARY KEY,
    billet_id BIGINT NOT NULL REFERENCES billets(billet_id) ON DELETE CASCADE,
    person_id BIGINT NOT NULL REFERENCES people(person_id) ON DELETE CASCADE,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    assignment_status TEXT NOT NULL DEFAULT 'active',
    source_system TEXT NOT NULL DEFAULT 'seed',
    effective_date DATE,
    last_refreshed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT billet_occupants_assignment_status_chk
        CHECK (assignment_status IN ('active', 'inactive')),
    CONSTRAINT billet_occupants_billet_person_unique
        UNIQUE (billet_id, person_id)
);

CREATE INDEX idx_billet_occupants_billet
    ON billet_occupants (billet_id);

CREATE INDEX idx_billet_occupants_person
    ON billet_occupants (person_id);

CREATE UNIQUE INDEX idx_billet_occupants_one_active_primary_per_billet
    ON billet_occupants (billet_id)
    WHERE is_primary = TRUE
      AND assignment_status = 'active';

COMMIT;