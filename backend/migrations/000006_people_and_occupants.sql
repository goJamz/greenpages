-- People
CREATE TABLE people (
    person_id               BIGSERIAL PRIMARY KEY,
    display_name            TEXT NOT NULL,
    normalized_display_name TEXT NOT NULL,
    rank                    TEXT,
    work_email              TEXT,
    work_phone              TEXT,
    office_symbol           TEXT,
    is_current              BOOLEAN NOT NULL DEFAULT TRUE,
    last_refreshed_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_people_normalized ON people USING gin (normalized_display_name gin_trgm_ops);

-- Billet occupants (maps people to billets)
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