BEGIN;

WITH billet_seed AS (
    SELECT *
    FROM (
        VALUES
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P001', 'G-6', 'g6', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WAA100', '100', '01', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P002', 'Deputy G-6', 'deputyg6', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'WAA100', '100', '02', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P003', 'Network Operations Officer', 'networkoperationsofficer', 'MAJ', 'Officer', 'SC', NULL, '25A', 'Active', 'WAA100', '100', '03', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P004', 'Senior Signal NCO', 'seniorsignalnco', 'MSG', 'Enlisted', 'SC', '25U', NULL, 'Active', 'WAA100', '100', '04', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P005', 'Help Desk NCOIC', 'helpdeskncoic', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WAA100', '100', '05', 'Fort Liberty', 'NC'),

            ('I Corps', 'I Corps G-6', 'P001', 'G-6', 'g6', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WBB100', '200', '01', 'Joint Base Lewis-McChord', 'WA'),
            ('I Corps', 'I Corps G-6', 'P002', 'Deputy G-6', 'deputyg6', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'WBB100', '200', '02', 'Joint Base Lewis-McChord', 'WA'),
            ('I Corps', 'I Corps G-6', 'P003', 'Plans Officer', 'plansofficer', 'MAJ', 'Officer', 'SC', NULL, '25A', 'Active', 'WBB100', '200', '03', 'Joint Base Lewis-McChord', 'WA'),
            ('I Corps', 'I Corps G-6', 'P004', 'Knowledge Management NCO', 'knowledgemanagementnco', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WBB100', '200', '04', 'Joint Base Lewis-McChord', 'WA'),

            ('NETCOM', 'NETCOM G-6', 'P001', 'G-6 Director', 'g6director', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WDD100', '300', '01', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM G-6', 'P002', 'Cyber Operations Officer', 'cyberoperationsofficer', 'LTC', 'Officer', 'SC', NULL, '17A', 'Active', 'WDD100', '300', '02', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM G-6', 'P003', 'Network Defense NCOIC', 'networkdefensencoic', 'MSG', 'Enlisted', 'SC', '25D', NULL, 'Active', 'WDD100', '300', '03', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM G-6', 'P004', 'Systems Integration NCO', 'systemsintegrationnco', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WDD100', '300', '04', 'Fort Huachuca', 'AZ')
    ) AS seeded_billets(
        organization_name,
        section_display_name,
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
        state_code
    )
)
INSERT INTO billets (
    organization_id,
    section_id,
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
    state_code
)
SELECT
    organizations.organization_id,
    sections.section_id,
    billet_seed.position_number,
    billet_seed.billet_title,
    billet_seed.normalized_billet_title,
    billet_seed.grade_code,
    billet_seed.rank_group,
    billet_seed.branch_code,
    billet_seed.mos_code,
    billet_seed.aoc_code,
    billet_seed.component,
    billet_seed.uic,
    billet_seed.paragraph_number,
    billet_seed.line_number,
    billet_seed.duty_location,
    billet_seed.state_code
FROM billet_seed
INNER JOIN organizations
    ON organizations.organization_name = billet_seed.organization_name
INNER JOIN sections
    ON sections.organization_id = organizations.organization_id
   AND sections.display_name = billet_seed.section_display_name;

COMMIT;