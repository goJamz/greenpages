BEGIN;

-- ---------------------------------------------------------------------------
-- Organizations
-- ---------------------------------------------------------------------------
INSERT INTO organizations (
    organization_name,
    normalized_name,
    short_name,
    component,
    echelon,
    uic,
    location_name,
    state_code
) VALUES
    ('XVIII Airborne Corps', 'xviiiairbornecorps', '18 ABN Corps', 'Active', 'Corps', 'WAA100', 'Fort Liberty', 'NC'),
    ('82nd Airborne Division', '82ndairbornedivision', '82nd ABN', 'Active', 'Division', 'WAA200', 'Fort Liberty', 'NC'),
    ('101st Airborne Division (Air Assault)', '101stairbornedivisionairassault', '101st ABN DIV', 'Active', 'Division', 'WAA300', 'Fort Campbell', 'KY'),
    ('10th Mountain Division', '10thmountaindivision', '10th MTN DIV', 'Active', 'Division', 'WAA400', 'Fort Drum', 'NY'),
    ('I Corps', 'icorps', 'I Corps', 'Active', 'Corps', 'WBB100', 'Joint Base Lewis-McChord', 'WA'),
    ('7th Infantry Division', '7thinfantrydivision', '7th ID', 'Active', 'Division', 'WBB200', 'Joint Base Lewis-McChord', 'WA'),
    ('III Armored Corps', 'iiiarmoredcorps', 'III AC', 'Active', 'Corps', 'WCC100', 'Fort Cavazos', 'TX'),
    ('1st Cavalry Division', '1stcavalrydivision', '1st CAV', 'Active', 'Division', 'WCC200', 'Fort Cavazos', 'TX'),
    ('NETCOM', 'netcom', 'NETCOM', 'Active', 'Command', 'WDD100', 'Fort Huachuca', 'AZ'),
    ('Army National Guard Readiness Center', 'armynationalguardreadinesscenter', 'ARNG RC', 'Guard', 'Command', 'WEE100', 'Arlington', 'VA'),
    ('28th Infantry Division', '28thinfantrydivision', '28th ID', 'Guard', 'Division', 'WEE200', 'Harrisburg', 'PA'),
    ('377th Theater Sustainment Command', '377ththeatersustainmentcommand', '377th TSC', 'Reserve', 'Command', 'WFF100', 'Belle Chasse', 'LA');

-- ---------------------------------------------------------------------------
-- Parent relationships
-- ---------------------------------------------------------------------------
UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '82nd Airborne Division'
  AND parent.organization_name = 'XVIII Airborne Corps';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '101st Airborne Division (Air Assault)'
  AND parent.organization_name = 'XVIII Airborne Corps';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '10th Mountain Division'
  AND parent.organization_name = 'XVIII Airborne Corps';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '7th Infantry Division'
  AND parent.organization_name = 'I Corps';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '1st Cavalry Division'
  AND parent.organization_name = 'III Armored Corps';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '28th Infantry Division'
  AND parent.organization_name = 'Army National Guard Readiness Center';

-- ---------------------------------------------------------------------------
-- Organization aliases
-- Helpful later when alias matching is turned on.
-- ---------------------------------------------------------------------------
INSERT INTO organization_aliases (
    organization_id,
    alias_text,
    alias_type,
    normalized_alias_text
)
SELECT
    organizations.organization_id,
    alias_seed.alias_text,
    alias_seed.alias_type,
    alias_seed.normalized_alias_text
FROM (
    VALUES
        ('XVIII Airborne Corps', '18th Airborne Corps', 'numeric', '18thairbornecorps'),
        ('XVIII Airborne Corps', '18 ABN Corps', 'abbreviation', '18abncorps'),
        ('82nd Airborne Division', '82nd ABN', 'abbreviation', '82ndabn'),
        ('101st Airborne Division (Air Assault)', '101st Airborne', 'short', '101stairborne'),
        ('101st Airborne Division (Air Assault)', '101st ABN DIV', 'abbreviation', '101stabndiv'),
        ('10th Mountain Division', '10th Mountain', 'short', '10thmountain'),
        ('I Corps', 'First Corps', 'alternate', 'firstcorps'),
        ('III Armored Corps', '3rd Armored Corps', 'numeric', '3rdarmoredcorps'),
        ('NETCOM', 'Network Enterprise Technology Command', 'expanded', 'networkenterprisetechnologycommand'),
        ('Army National Guard Readiness Center', 'ARNG Readiness Center', 'abbreviation', 'arngreadinesscenter'),
        ('377th Theater Sustainment Command', '377 TSC', 'abbreviation', '377tsc')
) AS alias_seed(organization_name, alias_text, alias_type, normalized_alias_text)
INNER JOIN organizations
    ON organizations.organization_name = alias_seed.organization_name;

-- ---------------------------------------------------------------------------
-- Core staff sections
-- These go on every seeded organization.
-- section_code = machine-friendly code
-- section_name = human-friendly office name
-- display_name = what users see in results
-- ---------------------------------------------------------------------------
WITH core_sections AS (
    SELECT *
    FROM (
        VALUES
            ('G1', 'G-1', 'Personnel', 'personnel'),
            ('G2', 'G-2', 'Intelligence', 'intelligence'),
            ('G3', 'G-3', 'Operations', 'operations'),
            ('G4', 'G-4', 'Logistics', 'logistics'),
            ('G6', 'G-6', 'Signal', 'signal')
    ) AS section_template(section_code, section_label, section_name, normalized_section_name)
)
INSERT INTO sections (
    organization_id,
    section_code,
    section_name,
    normalized_section_name,
    display_name
)
SELECT
    organizations.organization_id,
    core_sections.section_code,
    core_sections.section_name,
    core_sections.normalized_section_name,
    organizations.organization_name || ' ' || core_sections.section_label
FROM organizations
CROSS JOIN core_sections;

-- ---------------------------------------------------------------------------
-- Extended headquarters sections
-- These go only on larger headquarters / command-level organizations.
-- ---------------------------------------------------------------------------
WITH extended_sections AS (
    SELECT *
    FROM (
        VALUES
            ('G5', 'G-5', 'Plans', 'plans'),
            ('G8', 'G-8', 'Resource Management', 'resourcemanagement'),
            ('PAO', 'PAO', 'Public Affairs', 'publicaffairs'),
            ('SAFETY', 'Safety', 'Safety', 'safety'),
            ('CH', 'Chaplain', 'Chaplain', 'chaplain')
    ) AS section_template(section_code, section_label, section_name, normalized_section_name)
)
INSERT INTO sections (
    organization_id,
    section_code,
    section_name,
    normalized_section_name,
    display_name
)
SELECT
    organizations.organization_id,
    extended_sections.section_code,
    extended_sections.section_name,
    extended_sections.normalized_section_name,
    organizations.organization_name || ' ' || extended_sections.section_label
FROM organizations
CROSS JOIN extended_sections
WHERE organizations.organization_name IN (
    'XVIII Airborne Corps',
    'I Corps',
    'III Armored Corps',
    'NETCOM',
    'Army National Guard Readiness Center',
    '377th Theater Sustainment Command'
);

-- ---------------------------------------------------------------------------
-- A few extra specialty sections to create more interesting search cases.
-- ---------------------------------------------------------------------------
INSERT INTO sections (
    organization_id,
    section_code,
    section_name,
    normalized_section_name,
    display_name
)
SELECT
    organizations.organization_id,
    specialty_sections.section_code,
    specialty_sections.section_name,
    specialty_sections.normalized_section_name,
    organizations.organization_name || ' ' || specialty_sections.section_label
FROM organizations
INNER JOIN (
    VALUES
        ('G9', 'G-9', 'Civil Affairs Operations', 'civilaffairsoperations'),
        ('SURG', 'Surgeon', 'Surgeon', 'surgeon')
) AS specialty_sections(section_code, section_label, section_name, normalized_section_name)
    ON organizations.organization_name = 'XVIII Airborne Corps';

INSERT INTO sections (
    organization_id,
    section_code,
    section_name,
    normalized_section_name,
    display_name
)
SELECT
    organizations.organization_id,
    specialty_sections.section_code,
    specialty_sections.section_name,
    specialty_sections.normalized_section_name,
    organizations.organization_name || ' ' || specialty_sections.section_label
FROM organizations
INNER JOIN (
    VALUES
        ('CYBER', 'Cyber', 'Cyber Operations', 'cyberoperations'),
        ('NOSC', 'NOSC', 'Network Operations and Security Center', 'networkoperationsandsecuritycenter')
) AS specialty_sections(section_code, section_label, section_name, normalized_section_name)
    ON organizations.organization_name = 'NETCOM';

COMMIT;