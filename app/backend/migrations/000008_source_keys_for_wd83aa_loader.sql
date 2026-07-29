BEGIN;

-- ---------------------------------------------------------------------------
-- Source identity columns for repeatable Vantage-to-Postgres loads
-- ---------------------------------------------------------------------------
-- These columns let the WD83AA loader merge Green Pages-shaped Vantage rows
-- into the existing app tables without relying only on display names or
-- position numbers.

ALTER TABLE sections
    ADD COLUMN IF NOT EXISTS source_section_key TEXT;

ALTER TABLE sections
    ADD COLUMN IF NOT EXISTS source_lineage TEXT;

COMMENT ON COLUMN sections.source_section_key IS
    'Stable source key used by the Vantage-to-Postgres loader for repeatable section syncs. For the first WD83AA loader this is built as UIC plus normalized section name.';

COMMENT ON COLUMN sections.source_lineage IS
    'Optional lineage/debug text emitted by the upstream Vantage transform.';

CREATE UNIQUE INDEX IF NOT EXISTS idx_sections_source_section_key_current_unique
    ON sections (source_section_key)
    WHERE source_section_key IS NOT NULL
      AND is_current = TRUE;

ALTER TABLE billets
    ADD COLUMN IF NOT EXISTS source_billet_key TEXT;

ALTER TABLE billets
    ADD COLUMN IF NOT EXISTS source_lineage TEXT;

COMMENT ON COLUMN billets.source_billet_key IS
    'Stable source key used by the Vantage-to-Postgres loader for repeatable billet syncs.';

COMMENT ON COLUMN billets.source_lineage IS
    'Optional lineage/debug text emitted by the upstream Vantage transform.';

CREATE UNIQUE INDEX IF NOT EXISTS idx_billets_source_billet_key_current_unique
    ON billets (source_billet_key)
    WHERE source_billet_key IS NOT NULL
      AND is_current = TRUE;

CREATE INDEX IF NOT EXISTS idx_billets_uic_position_number
    ON billets (uic, position_number);

ALTER TABLE billet_occupants
    ADD COLUMN IF NOT EXISTS source_billet_occupant_key TEXT;

ALTER TABLE billet_occupants
    ADD COLUMN IF NOT EXISTS source_lineage TEXT;

COMMENT ON COLUMN billet_occupants.source_billet_occupant_key IS
    'Stable source key used by the Vantage-to-Postgres loader for repeatable occupant syncs.';

COMMENT ON COLUMN billet_occupants.source_lineage IS
    'Optional lineage/debug text emitted by the upstream Vantage transform.';

CREATE UNIQUE INDEX IF NOT EXISTS idx_billet_occupants_source_key_unique
    ON billet_occupants (source_billet_occupant_key)
    WHERE source_billet_occupant_key IS NOT NULL;

COMMIT;
