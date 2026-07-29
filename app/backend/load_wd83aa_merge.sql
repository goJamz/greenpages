-- Validates staged WD83AA CSV data and merges it into live Green Pages tables.
-- Expected to be run after:
--   1. backend/migrations/000008_source_keys_for_wd83aa_loader.sql has been applied
--   2. load_wd83aa_staging.sql has created staging tables
--   3. CSV files have been copied into the staging tables

-- ---------------------------------------------------------------------------
-- Staging validation. These checks happen before live tables are modified.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    people_count INTEGER;
    billets_count INTEGER;
    billet_occupants_count INTEGER;
    invalid_count INTEGER;
    duplicate_count INTEGER;
    missing_count INTEGER;
    staged_occupied_billet_count INTEGER;
    staged_vacant_billet_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO people_count
    FROM staging.greenpages_people_wd83aa;

    IF people_count <> 200 THEN
        RAISE EXCEPTION 'WD83AA people staging row count mismatch. Expected 200, got %', people_count;
    END IF;

    SELECT COUNT(*) INTO billets_count
    FROM staging.greenpages_billets_wd83aa;

    IF billets_count <> 216 THEN
        RAISE EXCEPTION 'WD83AA billets staging row count mismatch. Expected 216, got %', billets_count;
    END IF;

    SELECT COUNT(*) INTO billet_occupants_count
    FROM staging.greenpages_billet_occupants_wd83aa;

    IF billet_occupants_count <> 169 THEN
        RAISE EXCEPTION 'WD83AA billet occupants staging row count mismatch. Expected 169, got %', billet_occupants_count;
    END IF;

    SELECT COUNT(*) INTO invalid_count
    FROM staging.greenpages_people_wd83aa
    WHERE NULLIF(BTRIM(dod_id), '') IS NULL
       OR NULLIF(BTRIM(display_name), '') IS NULL
       OR NULLIF(BTRIM(normalized_display_name), '') IS NULL
       OR NULLIF(BTRIM(rank), '') IS NULL;

    IF invalid_count <> 0 THEN
        RAISE EXCEPTION 'WD83AA people staging has % rows missing required person fields', invalid_count;
    END IF;

    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT BTRIM(dod_id)
        FROM staging.greenpages_people_wd83aa
        GROUP BY BTRIM(dod_id)
        HAVING COUNT(*) > 1
    ) duplicate_people;

    IF duplicate_count <> 0 THEN
        RAISE EXCEPTION 'WD83AA people staging has % duplicate DoD IDs', duplicate_count;
    END IF;

    SELECT COUNT(*) INTO invalid_count
    FROM staging.greenpages_billets_wd83aa
    WHERE UPPER(BTRIM(COALESCE(uic, ''))) <> 'WD83AA'
       OR NULLIF(BTRIM(prototype_billet_key), '') IS NULL
       OR NULLIF(BTRIM(position_number), '') IS NULL
       OR NULLIF(BTRIM(billet_title), '') IS NULL
       OR NULLIF(BTRIM(normalized_billet_title), '') IS NULL
       OR NULLIF(BTRIM(section_name), '') IS NULL
       OR NULLIF(BTRIM(normalized_section_name), '') IS NULL
       OR LOWER(BTRIM(COALESCE(occupancy_status, ''))) NOT IN ('filled', 'vacant', 'unknown');

    IF invalid_count <> 0 THEN
        RAISE EXCEPTION 'WD83AA billets staging has % invalid required billet rows', invalid_count;
    END IF;

    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT BTRIM(prototype_billet_key)
        FROM staging.greenpages_billets_wd83aa
        GROUP BY BTRIM(prototype_billet_key)
        HAVING COUNT(*) > 1
    ) duplicate_billets;

    IF duplicate_count <> 0 THEN
        RAISE EXCEPTION 'WD83AA billets staging has % duplicate prototype billet keys', duplicate_count;
    END IF;

    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT BTRIM(position_number)
        FROM staging.greenpages_billets_wd83aa
        GROUP BY BTRIM(position_number)
        HAVING COUNT(*) > 1
    ) duplicate_positions;

    IF duplicate_count <> 0 THEN
        RAISE EXCEPTION 'WD83AA billets staging has % duplicate position numbers', duplicate_count;
    END IF;

    SELECT COUNT(*) INTO invalid_count
    FROM staging.greenpages_billet_occupants_wd83aa
    WHERE UPPER(BTRIM(COALESCE(uic, ''))) <> 'WD83AA'
       OR NULLIF(BTRIM(billet_occupant_source_key), '') IS NULL
       OR NULLIF(BTRIM(prototype_billet_key), '') IS NULL
       OR NULLIF(BTRIM(dod_id), '') IS NULL
       OR LOWER(BTRIM(COALESCE(assignment_status, ''))) <> 'active';

    IF invalid_count <> 0 THEN
        RAISE EXCEPTION 'WD83AA billet occupants staging has % invalid required occupant rows', invalid_count;
    END IF;

    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT BTRIM(billet_occupant_source_key)
        FROM staging.greenpages_billet_occupants_wd83aa
        GROUP BY BTRIM(billet_occupant_source_key)
        HAVING COUNT(*) > 1
    ) duplicate_occupants;

    IF duplicate_count <> 0 THEN
        RAISE EXCEPTION 'WD83AA billet occupants staging has % duplicate occupant source keys', duplicate_count;
    END IF;

    SELECT COUNT(*) INTO missing_count
    FROM staging.greenpages_billet_occupants_wd83aa occupants
    LEFT JOIN staging.greenpages_billets_wd83aa billets
        ON BTRIM(billets.prototype_billet_key) = BTRIM(occupants.prototype_billet_key)
    WHERE billets.prototype_billet_key IS NULL;

    IF missing_count <> 0 THEN
        RAISE EXCEPTION 'WD83AA billet occupants staging has % occupant rows without a staged billet', missing_count;
    END IF;

    SELECT COUNT(*) INTO missing_count
    FROM staging.greenpages_billet_occupants_wd83aa occupants
    LEFT JOIN staging.greenpages_people_wd83aa people
        ON BTRIM(people.dod_id) = BTRIM(occupants.dod_id)
    WHERE people.dod_id IS NULL;

    IF missing_count <> 0 THEN
        RAISE EXCEPTION 'WD83AA billet occupants staging has % occupant rows without a staged person', missing_count;
    END IF;

    -- Do not trust staged billets.occupancy_status for the first WD83AA load.
    -- The authoritative staged fill/vacancy truth is the occupant feed:
    -- one staged occupant row maps to one occupied staged billet position for WD83AA.
    SELECT COUNT(DISTINCT BTRIM(prototype_billet_key)) INTO staged_occupied_billet_count
    FROM staging.greenpages_billet_occupants_wd83aa;

    IF staged_occupied_billet_count <> 169 THEN
        RAISE EXCEPTION 'WD83AA staged occupied billet count mismatch. Expected 169, got %', staged_occupied_billet_count;
    END IF;

    SELECT COUNT(*) INTO staged_vacant_billet_count
    FROM staging.greenpages_billets_wd83aa billets
    WHERE NOT EXISTS (
        SELECT 1
        FROM staging.greenpages_billet_occupants_wd83aa occupants
        WHERE BTRIM(occupants.prototype_billet_key) = BTRIM(billets.prototype_billet_key)
    );

    IF staged_vacant_billet_count <> 47 THEN
        RAISE EXCEPTION 'WD83AA staged vacant billet count mismatch. Expected 47, got %', staged_vacant_billet_count;
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- Live merge. Everything below stays inside one transaction.
-- ---------------------------------------------------------------------------
BEGIN;

WITH organization_source AS (
    SELECT
        'WD83AA' AS uic,
        MAX(NULLIF(BTRIM(organization_name), '')) AS organization_name,
        MAX(NULLIF(BTRIM(component), '')) AS component,
        MAX(NULLIF(BTRIM(duty_location), '')) AS duty_location,
        MAX(NULLIF(BTRIM(state_code), '')) AS state_code
    FROM staging.greenpages_billets_wd83aa
)
UPDATE organizations
SET
    organization_name = organization_source.organization_name,
    normalized_name = regexp_replace(LOWER(organization_source.organization_name), '[^a-z0-9]+', '', 'g'),
    component = organization_source.component,
    location_name = organization_source.duty_location,
    state_code = organization_source.state_code,
    is_current = TRUE,
    last_refreshed_at = NOW()
FROM organization_source
WHERE organizations.uic = organization_source.uic;

WITH organization_source AS (
    SELECT
        'WD83AA' AS uic,
        MAX(NULLIF(BTRIM(organization_name), '')) AS organization_name,
        MAX(NULLIF(BTRIM(component), '')) AS component,
        MAX(NULLIF(BTRIM(duty_location), '')) AS duty_location,
        MAX(NULLIF(BTRIM(state_code), '')) AS state_code
    FROM staging.greenpages_billets_wd83aa
)
INSERT INTO organizations (
    organization_name,
    normalized_name,
    component,
    uic,
    location_name,
    state_code,
    is_current,
    last_refreshed_at
)
SELECT
    organization_source.organization_name,
    regexp_replace(LOWER(organization_source.organization_name), '[^a-z0-9]+', '', 'g'),
    organization_source.component,
    organization_source.uic,
    organization_source.duty_location,
    organization_source.state_code,
    TRUE,
    NOW()
FROM organization_source
WHERE NOT EXISTS (
    SELECT 1
    FROM organizations
    WHERE organizations.uic = organization_source.uic
);

WITH section_source AS (
    SELECT
        CONCAT(
            UPPER(BTRIM(uic)),
            '|',
            NULLIF(BTRIM(normalized_section_name), '')
        ) AS source_section_key,
        UPPER(BTRIM(uic)) AS uic,
        MIN(NULLIF(BTRIM(section_code), '')) AS section_code,
        MIN(NULLIF(BTRIM(section_name), '')) AS section_name,
        NULLIF(BTRIM(normalized_section_name), '') AS normalized_section_name,
        COALESCE(
            MIN(NULLIF(BTRIM(section_display_name), '')),
            MIN(NULLIF(BTRIM(section_name), ''))
        ) AS display_name,
        MAX(NULLIF(BTRIM(source_lineage), '')) AS source_lineage
    FROM staging.greenpages_billets_wd83aa
    GROUP BY
        UPPER(BTRIM(uic)),
        NULLIF(BTRIM(normalized_section_name), '')
), section_with_organization AS (
    SELECT
        organizations.organization_id,
        section_source.source_section_key,
        section_source.section_code,
        section_source.section_name,
        section_source.normalized_section_name,
        section_source.display_name,
        section_source.source_lineage
    FROM section_source
    INNER JOIN organizations
        ON organizations.uic = section_source.uic
       AND organizations.is_current = TRUE
)
INSERT INTO sections (
    organization_id,
    source_section_key,
    section_code,
    section_name,
    normalized_section_name,
    display_name,
    is_current,
    source_lineage
)
SELECT
    section_with_organization.organization_id,
    section_with_organization.source_section_key,
    section_with_organization.section_code,
    section_with_organization.section_name,
    section_with_organization.normalized_section_name,
    section_with_organization.display_name,
    TRUE,
    section_with_organization.source_lineage
FROM section_with_organization
ON CONFLICT (source_section_key) WHERE source_section_key IS NOT NULL AND is_current = TRUE
DO UPDATE SET
    organization_id = EXCLUDED.organization_id,
    section_code = EXCLUDED.section_code,
    section_name = EXCLUDED.section_name,
    normalized_section_name = EXCLUDED.normalized_section_name,
    display_name = EXCLUDED.display_name,
    is_current = TRUE,
    source_lineage = EXCLUDED.source_lineage;

WITH active_section_keys AS (
    SELECT DISTINCT
        CONCAT(
            UPPER(BTRIM(uic)),
            '|',
            NULLIF(BTRIM(normalized_section_name), '')
        ) AS source_section_key
    FROM staging.greenpages_billets_wd83aa
), wd83aa_organization AS (
    SELECT organization_id
    FROM organizations
    WHERE uic = 'WD83AA'
      AND is_current = TRUE
)
UPDATE sections
SET is_current = FALSE
FROM wd83aa_organization
WHERE sections.organization_id = wd83aa_organization.organization_id
  AND sections.source_section_key IS NOT NULL
  AND sections.source_section_key NOT IN (
      SELECT source_section_key
      FROM active_section_keys
  );

WITH people_source AS (
    SELECT
        NULLIF(BTRIM(dod_id), '') AS dod_id,
        NULLIF(BTRIM(display_name), '') AS display_name,
        NULLIF(BTRIM(normalized_display_name), '') AS normalized_display_name,
        NULLIF(BTRIM(rank), '') AS rank,
        NULLIF(BTRIM(work_email), '') AS work_email,
        NULLIF(BTRIM(work_phone), '') AS work_phone,
        NULLIF(BTRIM(office_symbol), '') AS office_symbol
    FROM staging.greenpages_people_wd83aa
)
INSERT INTO people (
    dod_id,
    display_name,
    normalized_display_name,
    rank,
    work_email,
    work_phone,
    office_symbol,
    is_current,
    last_refreshed_at
)
SELECT
    people_source.dod_id,
    people_source.display_name,
    people_source.normalized_display_name,
    people_source.rank,
    people_source.work_email,
    people_source.work_phone,
    people_source.office_symbol,
    TRUE,
    NOW()
FROM people_source
ON CONFLICT (dod_id) WHERE dod_id IS NOT NULL AND is_current = TRUE
DO UPDATE SET
    display_name = EXCLUDED.display_name,
    normalized_display_name = EXCLUDED.normalized_display_name,
    rank = EXCLUDED.rank,
    work_email = EXCLUDED.work_email,
    work_phone = EXCLUDED.work_phone,
    office_symbol = EXCLUDED.office_symbol,
    is_current = TRUE,
    last_refreshed_at = NOW();

WITH billet_source AS (
    SELECT
        NULLIF(BTRIM(prototype_billet_key), '') AS source_billet_key,
        CONCAT(
            UPPER(BTRIM(uic)),
            '|',
            NULLIF(BTRIM(normalized_section_name), '')
        ) AS source_section_key,
        UPPER(BTRIM(uic)) AS uic,
        NULLIF(BTRIM(position_number), '') AS position_number,
        NULLIF(BTRIM(billet_title), '') AS billet_title,
        NULLIF(BTRIM(normalized_billet_title), '') AS normalized_billet_title,
        NULLIF(BTRIM(grade_code), '') AS grade_code,
        NULLIF(BTRIM(rank_group), '') AS rank_group,
        NULLIF(BTRIM(branch_code), '') AS branch_code,
        NULLIF(BTRIM(mos_code), '') AS mos_code,
        NULLIF(BTRIM(aoc_code), '') AS aoc_code,
        NULLIF(BTRIM(component), '') AS component,
        NULLIF(BTRIM(paragraph_number), '') AS paragraph_number,
        NULLIF(BTRIM(line_number), '') AS line_number,
        NULLIF(BTRIM(duty_location), '') AS duty_location,
        NULLIF(BTRIM(state_code), '') AS state_code,
        LOWER(BTRIM(occupancy_status)) AS occupancy_status,
        NULLIF(BTRIM(source_lineage), '') AS source_lineage
    FROM staging.greenpages_billets_wd83aa
), resolved_billet_source AS (
    SELECT
        organizations.organization_id,
        sections.section_id,
        billet_source.source_billet_key,
        billet_source.position_number,
        billet_source.billet_title,
        billet_source.normalized_billet_title,
        billet_source.grade_code,
        billet_source.rank_group,
        billet_source.branch_code,
        billet_source.mos_code,
        billet_source.aoc_code,
        billet_source.component,
        billet_source.uic,
        billet_source.paragraph_number,
        billet_source.line_number,
        billet_source.duty_location,
        billet_source.state_code,
        billet_source.occupancy_status,
        billet_source.source_lineage
    FROM billet_source
    INNER JOIN organizations
        ON organizations.uic = billet_source.uic
       AND organizations.is_current = TRUE
    INNER JOIN sections
        ON sections.organization_id = organizations.organization_id
       AND sections.source_section_key = billet_source.source_section_key
       AND sections.is_current = TRUE
)
INSERT INTO billets (
    organization_id,
    section_id,
    source_billet_key,
    position_number,
    billet_title,
    normalized_billet_title,
    grade_code,
    rank_group,
    branch_code,
    mos_code,
    aoc_code,
    component,
    uic,
    paragraph_number,
    line_number,
    duty_location,
    state_code,
    occupancy_status,
    is_current,
    source_lineage,
    updated_at
)
SELECT
    resolved_billet_source.organization_id,
    resolved_billet_source.section_id,
    resolved_billet_source.source_billet_key,
    resolved_billet_source.position_number,
    resolved_billet_source.billet_title,
    resolved_billet_source.normalized_billet_title,
    resolved_billet_source.grade_code,
    resolved_billet_source.rank_group,
    resolved_billet_source.branch_code,
    resolved_billet_source.mos_code,
    resolved_billet_source.aoc_code,
    resolved_billet_source.component,
    resolved_billet_source.uic,
    resolved_billet_source.paragraph_number,
    resolved_billet_source.line_number,
    resolved_billet_source.duty_location,
    resolved_billet_source.state_code,
    resolved_billet_source.occupancy_status,
    TRUE,
    resolved_billet_source.source_lineage,
    NOW()
FROM resolved_billet_source
ON CONFLICT (source_billet_key) WHERE source_billet_key IS NOT NULL AND is_current = TRUE
DO UPDATE SET
    organization_id = EXCLUDED.organization_id,
    section_id = EXCLUDED.section_id,
    position_number = EXCLUDED.position_number,
    billet_title = EXCLUDED.billet_title,
    normalized_billet_title = EXCLUDED.normalized_billet_title,
    grade_code = EXCLUDED.grade_code,
    rank_group = EXCLUDED.rank_group,
    branch_code = EXCLUDED.branch_code,
    mos_code = EXCLUDED.mos_code,
    aoc_code = EXCLUDED.aoc_code,
    component = EXCLUDED.component,
    uic = EXCLUDED.uic,
    paragraph_number = EXCLUDED.paragraph_number,
    line_number = EXCLUDED.line_number,
    duty_location = EXCLUDED.duty_location,
    state_code = EXCLUDED.state_code,
    occupancy_status = EXCLUDED.occupancy_status,
    is_current = TRUE,
    source_lineage = EXCLUDED.source_lineage,
    updated_at = NOW();

WITH active_billet_keys AS (
    SELECT BTRIM(prototype_billet_key) AS source_billet_key
    FROM staging.greenpages_billets_wd83aa
)
UPDATE billets
SET
    is_current = FALSE,
    occupancy_status = 'unknown',
    updated_at = NOW()
WHERE uic = 'WD83AA'
  AND source_billet_key IS NOT NULL
  AND source_billet_key NOT IN (
      SELECT source_billet_key
      FROM active_billet_keys
  );

WITH active_occupant_keys AS (
    SELECT BTRIM(billet_occupant_source_key) AS source_billet_occupant_key
    FROM staging.greenpages_billet_occupants_wd83aa
)
UPDATE billet_occupants
SET
    assignment_status = 'inactive',
    last_refreshed_at = NOW()
FROM billets
WHERE billet_occupants.billet_id = billets.billet_id
  AND billets.uic = 'WD83AA'
  AND billet_occupants.source_billet_occupant_key IS NOT NULL
  AND billet_occupants.source_billet_occupant_key NOT IN (
      SELECT source_billet_occupant_key
      FROM active_occupant_keys
  );

WITH occupant_source AS (
    SELECT
        NULLIF(BTRIM(billet_occupant_source_key), '') AS source_billet_occupant_key,
        NULLIF(BTRIM(prototype_billet_key), '') AS source_billet_key,
        NULLIF(BTRIM(dod_id), '') AS dod_id,
        LOWER(BTRIM(is_primary)) IN ('true', 't', '1', 'yes') AS is_primary,
        LOWER(BTRIM(assignment_status)) AS assignment_status,
        COALESCE(NULLIF(BTRIM(source_system), ''), 'vantage') AS source_system,
        NULLIF(BTRIM(effective_date), '')::DATE AS effective_date,
        NULLIF(BTRIM(source_lineage), '') AS source_lineage
    FROM staging.greenpages_billet_occupants_wd83aa
), resolved_occupant_source AS (
    SELECT
        billets.billet_id,
        people.person_id,
        occupant_source.source_billet_occupant_key,
        occupant_source.is_primary,
        occupant_source.assignment_status,
        occupant_source.source_system,
        occupant_source.effective_date,
        occupant_source.source_lineage
    FROM occupant_source
    INNER JOIN billets
        ON billets.source_billet_key = occupant_source.source_billet_key
       AND billets.is_current = TRUE
    INNER JOIN people
        ON people.dod_id = occupant_source.dod_id
       AND people.is_current = TRUE
)
INSERT INTO billet_occupants (
    billet_id,
    person_id,
    source_billet_occupant_key,
    is_primary,
    assignment_status,
    source_system,
    effective_date,
    last_refreshed_at,
    source_lineage
)
SELECT
    resolved_occupant_source.billet_id,
    resolved_occupant_source.person_id,
    resolved_occupant_source.source_billet_occupant_key,
    resolved_occupant_source.is_primary,
    resolved_occupant_source.assignment_status,
    resolved_occupant_source.source_system,
    resolved_occupant_source.effective_date,
    NOW(),
    resolved_occupant_source.source_lineage
FROM resolved_occupant_source
ON CONFLICT (source_billet_occupant_key) WHERE source_billet_occupant_key IS NOT NULL
DO UPDATE SET
    billet_id = EXCLUDED.billet_id,
    person_id = EXCLUDED.person_id,
    is_primary = EXCLUDED.is_primary,
    assignment_status = EXCLUDED.assignment_status,
    source_system = EXCLUDED.source_system,
    effective_date = EXCLUDED.effective_date,
    last_refreshed_at = NOW(),
    source_lineage = EXCLUDED.source_lineage;

UPDATE billets
SET
    occupancy_status = CASE
        WHEN EXISTS (
            SELECT 1
            FROM billet_occupants
            WHERE billet_occupants.billet_id = billets.billet_id
              AND billet_occupants.assignment_status = 'active'
        ) THEN 'filled'
        ELSE 'vacant'
    END,
    updated_at = NOW()
WHERE billets.uic = 'WD83AA'
  AND billets.is_current = TRUE;

-- ---------------------------------------------------------------------------
-- Post-merge validation. Any failure rolls back the transaction.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    live_people_count INTEGER;
    live_billets_count INTEGER;
    live_occupants_count INTEGER;
    live_filled_count INTEGER;
    live_vacant_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO live_people_count
    FROM people
    INNER JOIN staging.greenpages_people_wd83aa staged_people
        ON staged_people.dod_id = people.dod_id
    WHERE people.is_current = TRUE;

    IF live_people_count <> 200 THEN
        RAISE EXCEPTION 'WD83AA post-merge people count mismatch. Expected 200, got %', live_people_count;
    END IF;

    SELECT COUNT(*) INTO live_billets_count
    FROM billets
    WHERE uic = 'WD83AA'
      AND is_current = TRUE;

    IF live_billets_count <> 216 THEN
        RAISE EXCEPTION 'WD83AA post-merge billet count mismatch. Expected 216, got %', live_billets_count;
    END IF;

    SELECT COUNT(*) INTO live_occupants_count
    FROM billet_occupants
    INNER JOIN billets
        ON billets.billet_id = billet_occupants.billet_id
    WHERE billets.uic = 'WD83AA'
      AND billets.is_current = TRUE
      AND billet_occupants.assignment_status = 'active';

    IF live_occupants_count <> 169 THEN
        RAISE EXCEPTION 'WD83AA post-merge occupant count mismatch. Expected 169, got %', live_occupants_count;
    END IF;

    SELECT COUNT(*) INTO live_filled_count
    FROM billets
    WHERE uic = 'WD83AA'
      AND is_current = TRUE
      AND occupancy_status = 'filled';

    IF live_filled_count <> 169 THEN
        RAISE EXCEPTION 'WD83AA post-merge filled billet count mismatch. Expected 169, got %', live_filled_count;
    END IF;

    SELECT COUNT(*) INTO live_vacant_count
    FROM billets
    WHERE uic = 'WD83AA'
      AND is_current = TRUE
      AND occupancy_status = 'vacant';

    IF live_vacant_count <> 47 THEN
        RAISE EXCEPTION 'WD83AA post-merge vacant billet count mismatch. Expected 47, got %', live_vacant_count;
    END IF;
END $$;

COMMIT;
