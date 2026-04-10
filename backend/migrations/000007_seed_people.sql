BEGIN;

INSERT INTO people (
    dod_id,
    display_name,
    normalized_display_name,
    rank,
    work_email,
    work_phone,
    office_symbol
)
VALUES
    ('1000000001', 'Johnson, Michael R.', 'johnsonmichaelr', 'COL', 'michael.r.johnson.mil@army.mil', '910-555-0101', 'AFNC-G6'),
    ('1000000002', 'Williams, Sarah T.', 'williamssaraht', 'LTC', 'sarah.t.williams.mil@army.mil', '910-555-0102', 'AFNC-G6'),
    ('1000000003', 'Garcia, David M.', 'garciadavidm', 'MAJ', 'david.m.garcia.mil@army.mil', '910-555-0103', 'AFNC-G6'),
    ('1000000004', 'Chen, Avery L.', 'chenaveryl', 'CPT', 'avery.l.chen.mil@army.mil', '910-555-0104', 'AFNC-G6'),
    ('1000000005', 'Taylor, Brian W.', 'taylorbrianw', 'COL', 'brian.w.taylor.mil@army.mil', '253-555-0401', 'AMCC-G6'),
    ('1000000006', 'Martinez, Sofia R.', 'martinezsofiar', 'SFC', 'sofia.r.martinez.mil@army.mil', '253-555-0402', 'AMCC-G6'),
    ('1000000007', 'Harris, Nicole M.', 'harrisnicolem', 'COL', 'nicole.m.harris.mil@army.mil', '520-555-0501', 'NETC-G6'),
    ('1000000008', 'Patel, Ryan J.', 'patelryanj', 'LTC', 'ryan.j.patel.mil@army.mil', '520-555-0502', 'NETC-G6');

WITH billet_status_seed AS (
    SELECT *
    FROM (
        VALUES
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P001', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P002', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P003', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P004', 'vacant'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P005', 'unknown'),

            ('I Corps', 'I Corps G-6', 'P001', 'filled'),
            ('I Corps', 'I Corps G-6', 'P002', 'vacant'),
            ('I Corps', 'I Corps G-6', 'P003', 'unknown'),
            ('I Corps', 'I Corps G-6', 'P004', 'filled'),

            ('NETCOM', 'NETCOM G-6', 'P001', 'filled'),
            ('NETCOM', 'NETCOM G-6', 'P002', 'filled'),
            ('NETCOM', 'NETCOM G-6', 'P003', 'vacant'),
            ('NETCOM', 'NETCOM G-6', 'P004', 'unknown')
    ) AS seeded_statuses(
        organization_name,
        section_display_name,
        position_number,
        occupancy_status
    )
)
UPDATE billets
SET occupancy_status = billet_status_seed.occupancy_status
FROM billet_status_seed
INNER JOIN organizations
    ON organizations.organization_name = billet_status_seed.organization_name
INNER JOIN sections
    ON sections.organization_id = organizations.organization_id
   AND sections.display_name = billet_status_seed.section_display_name
WHERE billets.organization_id = organizations.organization_id
  AND billets.section_id = sections.section_id
  AND billets.position_number = billet_status_seed.position_number;

WITH occupant_seed AS (
    SELECT *
    FROM (
        VALUES
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P001', 'Johnson, Michael R.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P002', 'Williams, Sarah T.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P003', 'Garcia, David M.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P003', 'Chen, Avery L.', FALSE),

            ('I Corps', 'I Corps G-6', 'P001', 'Taylor, Brian W.', TRUE),
            ('I Corps', 'I Corps G-6', 'P004', 'Martinez, Sofia R.', TRUE),

            ('NETCOM', 'NETCOM G-6', 'P001', 'Harris, Nicole M.', TRUE),
            ('NETCOM', 'NETCOM G-6', 'P002', 'Patel, Ryan J.', TRUE)
    ) AS seeded_occupants(
        organization_name,
        section_display_name,
        position_number,
        person_display_name,
        is_primary
    )
)
INSERT INTO billet_occupants (
    billet_id,
    person_id,
    is_primary,
    assignment_status,
    source_system,
    effective_date,
    last_refreshed_at
)
SELECT
    billets.billet_id,
    people.person_id,
    occupant_seed.is_primary,
    'active',
    'seed',
    CURRENT_DATE,
    NOW()
FROM occupant_seed
INNER JOIN organizations
    ON organizations.organization_name = occupant_seed.organization_name
INNER JOIN sections
    ON sections.organization_id = organizations.organization_id
   AND sections.display_name = occupant_seed.section_display_name
INNER JOIN billets
    ON billets.organization_id = organizations.organization_id
   AND billets.section_id = sections.section_id
   AND billets.position_number = occupant_seed.position_number
INNER JOIN people
    ON people.display_name = occupant_seed.person_display_name;

COMMIT;