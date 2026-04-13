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
-- Additional organizations
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
    ('3rd Infantry Division', '3rdinfantrydivision', '3rd ID', 'Active', 'Division', 'W3ID00', 'Fort Stewart', 'GA'),
    ('4th Infantry Division', '4thinfantrydivision', '4th ID', 'Active', 'Division', 'W4ID00', 'Fort Carson', 'CO'),
    ('25th Infantry Division', '25thinfantrydivision', '25th ID', 'Active', 'Division', 'W25D00', 'Schofield Barracks', 'HI'),
    ('1st Armored Division', '1starmoreddivision', '1st AD', 'Active', 'Division', 'W1AD00', 'Fort Bliss', 'TX'),
    ('V Corps', 'vcorps', 'V Corps', 'Active', 'Corps', 'WVC100', 'Fort Knox', 'KY'),
    ('Army Cyber Command', 'armycybercommand', 'ARCYBER', 'Active', 'Command', 'WCYB00', 'Fort Eisenhower', 'GA'),
    ('U.S. Army Intelligence and Security Command', 'usarmyintelligenceandsecuritycommand', 'INSCOM', 'Active', 'Command', 'WINS00', 'Fort Belvoir', 'VA'),
    ('U.S. Army Pacific', 'usarmypacific', 'USARPAC', 'Active', 'Command', 'WUAP00', 'Fort Shafter', 'HI'),
    ('36th Infantry Division', '36thinfantrydivision', '36th ID', 'Guard', 'Division', 'WGG100', 'Camp Mabry', 'TX'),
    ('29th Infantry Division', '29thinfantrydivision', '29th ID', 'Guard', 'Division', 'WGG200', 'Fort Belvoir', 'VA'),
    ('42nd Infantry Division', '42ndinfantrydivision', '42nd ID', 'Guard', 'Division', 'WGG300', 'Troy', 'NY'),
    ('34th Infantry Division', '34thinfantrydivision', '34th ID', 'Guard', 'Division', 'WGG400', 'Rosemount', 'MN'),
    ('335th Signal Command', '335thsignalcommand', '335th SC', 'Reserve', 'Command', 'WRR100', 'East Point', 'GA'),
    ('807th Medical Command', '807thmedicalcommand', '807th MC', 'Reserve', 'Command', 'WRR200', 'Seagoville', 'TX'),
    ('63rd Readiness Division', '63rdreadinessdivision', '63rd RD', 'Reserve', 'Division', 'WRR300', 'Mountain View', 'CA'),
    ('416th Theater Engineer Command', '416ththeaterengineercommand', '416th TEC', 'Reserve', 'Command', 'WRR400', 'Darien', 'IL');

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
-- Additional parent relationships
-- ---------------------------------------------------------------------------
UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '3rd Infantry Division'
  AND parent.organization_name = 'XVIII Airborne Corps';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '4th Infantry Division'
  AND parent.organization_name = 'III Armored Corps';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '1st Armored Division'
  AND parent.organization_name = 'III Armored Corps';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '25th Infantry Division'
  AND parent.organization_name = 'U.S. Army Pacific';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '36th Infantry Division'
  AND parent.organization_name = 'Army National Guard Readiness Center';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '29th Infantry Division'
  AND parent.organization_name = 'Army National Guard Readiness Center';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '42nd Infantry Division'
  AND parent.organization_name = 'Army National Guard Readiness Center';

UPDATE organizations AS child
SET parent_organization_id = parent.organization_id
FROM organizations AS parent
WHERE child.organization_name = '34th Infantry Division'
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
-- Additional organization aliases
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
        ('3rd Infantry Division', '3 ID', 'abbreviation', '3id'),
        ('3rd Infantry Division', 'Rock of the Marne', 'nickname', 'rockofthemarne'),
        ('4th Infantry Division', '4 ID', 'abbreviation', '4id'),
        ('4th Infantry Division', 'Ivy Division', 'nickname', 'ivydivision'),
        ('25th Infantry Division', '25 ID', 'abbreviation', '25id'),
        ('25th Infantry Division', 'Tropic Lightning', 'nickname', 'tropiclightning'),
        ('1st Armored Division', '1 AD', 'abbreviation', '1ad'),
        ('1st Armored Division', 'Old Ironsides', 'nickname', 'oldironsides'),
        ('V Corps', 'Fifth Corps', 'alternate', 'fifthcorps'),
        ('V Corps', '5th Corps', 'numeric', '5thcorps'),
        ('Army Cyber Command', 'Cyber Command', 'short', 'cybercommand'),
        ('Army Cyber Command', 'ARCYBER', 'abbreviation', 'arcyber'),
        ('U.S. Army Intelligence and Security Command', 'INSCOM', 'abbreviation', 'inscom'),
        ('U.S. Army Intelligence and Security Command', 'Intelligence and Security Command', 'short', 'intelligenceandsecuritycommand'),
        ('U.S. Army Pacific', 'USARPAC', 'abbreviation', 'usarpac'),
        ('U.S. Army Pacific', 'Army Pacific', 'short', 'armypacific'),
        ('36th Infantry Division', '36 ID', 'abbreviation', '36id'),
        ('36th Infantry Division', 'Arrowhead Division', 'nickname', 'arrowheaddivision'),
        ('29th Infantry Division', '29 ID', 'abbreviation', '29id'),
        ('29th Infantry Division', 'Blue and Gray', 'nickname', 'blueandgray'),
        ('42nd Infantry Division', '42 ID', 'abbreviation', '42id'),
        ('42nd Infantry Division', 'Rainbow Division', 'nickname', 'rainbowdivision'),
        ('34th Infantry Division', '34 ID', 'abbreviation', '34id'),
        ('34th Infantry Division', 'Red Bull Division', 'nickname', 'redbulldivision'),
        ('335th Signal Command', '335 SC', 'abbreviation', '335sc'),
        ('807th Medical Command', '807 MC', 'abbreviation', '807mc'),
        ('63rd Readiness Division', '63 RD', 'abbreviation', '63rd'),
        ('416th Theater Engineer Command', '416 TEC', 'abbreviation', '416tec')
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
-- Extended sections for additional command-level organizations
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
    'V Corps',
    'Army Cyber Command',
    'U.S. Army Intelligence and Security Command',
    'U.S. Army Pacific',
    '335th Signal Command',
    '807th Medical Command',
    '416th Theater Engineer Command'
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

-- ---------------------------------------------------------------------------
-- Additional specialty sections for new organizations
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
        ('OCO', 'OCO', 'Offensive Cyber Operations', 'offensivecyberoperations'),
        ('DCO', 'DCO', 'Defensive Cyber Operations', 'defensivecyberoperations'),
        ('CPT', 'CPT', 'Cyber Protection Teams', 'cyberprotectionteams')
) AS specialty_sections(section_code, section_label, section_name, normalized_section_name)
    ON organizations.organization_name = 'Army Cyber Command';

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
        ('HUMINT', 'HUMINT', 'Human Intelligence', 'humanintelligence'),
        ('SIGINT', 'SIGINT', 'Signals Intelligence', 'signalsintelligence'),
        ('TECHINT', 'TECHINT', 'Technical Intelligence', 'technicalintelligence')
) AS specialty_sections(section_code, section_label, section_name, normalized_section_name)
    ON organizations.organization_name = 'U.S. Army Intelligence and Security Command';

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
        ('ENGR', 'Engineer', 'Engineer Operations', 'engineeroperations'),
        ('STRAT', 'Strategy', 'Strategy and Plans', 'strategyandplans')
) AS specialty_sections(section_code, section_label, section_name, normalized_section_name)
    ON organizations.organization_name = 'U.S. Army Pacific';

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
        ('NETOPS', 'NetOps', 'Network Operations', 'networkoperations'),
        ('SATCOM', 'SATCOM', 'Satellite Communications', 'satellitecommunications')
) AS specialty_sections(section_code, section_label, section_name, normalized_section_name)
    ON organizations.organization_name = '335th Signal Command';

COMMIT;
