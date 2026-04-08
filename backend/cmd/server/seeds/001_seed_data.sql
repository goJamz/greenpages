-- Seed data for Green Pages MVP development
-- This provides realistic Army structure for local development and testing.

-- Clear existing data
TRUNCATE search_documents, billet_occupants, people, billets, sections, organization_aliases, organizations RESTART IDENTITY CASCADE;

-- ============================================================
-- Organizations
-- ============================================================
INSERT INTO organizations (organization_id, organization_name, normalized_name, short_name, parent_organization_id, component, echelon, uic, location_name, state_code) VALUES
(1,  'XVIII Airborne Corps',           'xviii airborne corps',           '18 ABN Corps',  NULL, 'Active', 'Corps',     'WAA100', 'Fort Liberty',       'NC'),
(2,  '82nd Airborne Division',         '82nd airborne division',         '82nd ABN',      1,    'Active', 'Division',  'WAA200', 'Fort Liberty',       'NC'),
(3,  '101st Airborne Division',        '101st airborne division',        '101st ABN',     1,    'Active', 'Division',  'WAA300', 'Fort Campbell',      'KY'),
(4,  'I Corps',                        'i corps',                        'I Corps',       NULL, 'Active', 'Corps',     'WBB100', 'Joint Base Lewis-McChord', 'WA'),
(5,  '2nd Infantry Division',          '2nd infantry division',          '2ID',           4,    'Active', 'Division',  'WBB200', 'Camp Humphreys',     'KR'),
(6,  'III Corps',                      'iii corps',                      'III Corps',     NULL, 'Active', 'Corps',     'WCC100', 'Fort Cavazos',       'TX'),
(7,  'NETCOM',                         'netcom',                        'NETCOM',         NULL, 'Active', 'Command',   'WDD100', 'Fort Huachuca',      'AZ'),
(8,  '28th Infantry Division',         '28th infantry division',         '28th ID',       NULL, 'Guard',  'Division',  'WEE100', 'Harrisburg',         'PA'),
(9,  '81st Readiness Division',        '81st readiness division',        '81st RD',       NULL, 'Reserve','Division',  'WFF100', 'Fort Jackson',       'SC'),
(10, '1st Brigade Combat Team, 82nd',  '1st brigade combat team 82nd',  '1BCT 82nd',     2,    'Active', 'Brigade',   'WAA210', 'Fort Liberty',       'NC');

-- ============================================================
-- Organization aliases
-- ============================================================
INSERT INTO organization_aliases (organization_id, alias_text, alias_type, normalized_alias_text) VALUES
(1, 'XVIII Airborne Corps',      'official',   'xviii airborne corps'),
(1, '18th Airborne Corps',       'common',     '18th airborne corps'),
(1, '18 ABN Corps',              'shorthand',  '18 abn corps'),
(2, '82nd Airborne Division',    'official',   '82nd airborne division'),
(2, '82nd ABN DIV',              'shorthand',  '82nd abn div'),
(2, 'All American Division',     'nickname',   'all american division'),
(3, '101st Airborne Division',   'official',   '101st airborne division'),
(3, 'Screaming Eagles',          'nickname',   'screaming eagles'),
(4, 'I Corps',                   'official',   'i corps'),
(4, '1st Corps',                 'common',     '1st corps'),
(5, '2nd Infantry Division',     'official',   '2nd infantry division'),
(5, '2ID',                       'shorthand',  '2id'),
(5, 'Indianhead Division',       'nickname',   'indianhead division'),
(6, 'III Corps',                 'official',   'iii corps'),
(6, '3rd Corps',                 'common',     '3rd corps'),
(6, 'Phantom Corps',             'nickname',   'phantom corps'),
(7, 'NETCOM',                    'official',   'netcom'),
(7, 'Network Enterprise Technology Command', 'full', 'network enterprise technology command'),
(8, '28th Infantry Division',    'official',   '28th infantry division'),
(8, 'Keystone Division',         'nickname',   'keystone division'),
(10, '1BCT 82nd',                'shorthand',  '1bct 82nd'),
(10, '1st Brigade Combat Team',  'common',     '1st brigade combat team');

-- ============================================================
-- Sections
-- ============================================================
INSERT INTO sections (section_id, organization_id, section_code, section_name, normalized_section_name, display_name) VALUES
-- XVIII ABN Corps staff sections
(1,  1, 'G1', 'G-1',  'g1',  'XVIII Airborne Corps G-1'),
(2,  1, 'G2', 'G-2',  'g2',  'XVIII Airborne Corps G-2'),
(3,  1, 'G3', 'G-3',  'g3',  'XVIII Airborne Corps G-3'),
(4,  1, 'G4', 'G-4',  'g4',  'XVIII Airborne Corps G-4'),
(5,  1, 'G6', 'G-6',  'g6',  'XVIII Airborne Corps G-6'),
(6,  1, 'G8', 'G-8',  'g8',  'XVIII Airborne Corps G-8'),
-- I Corps staff sections
(7,  4, 'G1', 'G-1',  'g1',  'I Corps G-1'),
(8,  4, 'G2', 'G-2',  'g2',  'I Corps G-2'),
(9,  4, 'G3', 'G-3',  'g3',  'I Corps G-3'),
(10, 4, 'G6', 'G-6',  'g6',  'I Corps G-6'),
-- 82nd ABN staff sections
(11, 2, 'G1', 'G-1',  'g1',  '82nd Airborne Division G-1'),
(12, 2, 'G3', 'G-3',  'g3',  '82nd Airborne Division G-3'),
(13, 2, 'G6', 'G-6',  'g6',  '82nd Airborne Division G-6'),
-- NETCOM
(14, 7, 'G3', 'G-3',  'g3',  'NETCOM G-3'),
(15, 7, 'G6', 'G-6',  'g6',  'NETCOM G-6'),
-- 1BCT 82nd
(16, 10, 'S3', 'S-3', 's3',  '1BCT 82nd S-3'),
(17, 10, 'S6', 'S-6', 's6',  '1BCT 82nd S-6'),
-- 28th ID (Guard)
(18, 8, 'G3', 'G-3',  'g3',  '28th Infantry Division G-3'),
(19, 8, 'G6', 'G-6',  'g6',  '28th Infantry Division G-6');

-- ============================================================
-- Billets
-- ============================================================
INSERT INTO billets (billet_id, organization_id, section_id, billet_title, normalized_billet_title, grade_code, rank_group, branch_code, mos_code, component, uic, paragraph_number, line_number, duty_location, state_code) VALUES
-- XVIII ABN Corps G-6 billets
(1,  1, 5, 'G-6',                          'g6',                          'O6', 'Field Grade', 'SC', '25A', 'Active', 'WAA100', '100', '001', 'Fort Liberty', 'NC'),
(2,  1, 5, 'Deputy G-6',                   'deputy g6',                   'O5', 'Field Grade', 'SC', '25A', 'Active', 'WAA100', '100', '002', 'Fort Liberty', 'NC'),
(3,  1, 5, 'Chief, Network Operations',    'chief network operations',    'O4', 'Field Grade', 'SC', '25A', 'Active', 'WAA100', '100', '003', 'Fort Liberty', 'NC'),
(4,  1, 5, 'Network Operations Officer',   'network operations officer',  'O3', 'Company Grade','SC', '25A', 'Active', 'WAA100', '100', '004', 'Fort Liberty', 'NC'),
(5,  1, 5, 'Senior Network NCO',           'senior network nco',          'E8', 'Senior NCO',  'SC', '25B', 'Active', 'WAA100', '100', '005', 'Fort Liberty', 'NC'),
(6,  1, 5, 'Information Systems Analyst',   'information systems analyst', 'E6', 'NCO',         'SC', '25B', 'Active', 'WAA100', '100', '006', 'Fort Liberty', 'NC'),
(7,  1, 5, 'Signal Support Specialist',     'signal support specialist',   'E5', 'NCO',         'SC', '25U', 'Active', 'WAA100', '100', '007', 'Fort Liberty', 'NC'),
(8,  1, 5, 'Cybersecurity Analyst',         'cybersecurity analyst',       'E5', 'NCO',         'SC', '25D', 'Active', 'WAA100', '100', '008', 'Fort Liberty', 'NC'),
-- XVIII ABN Corps G-3 billets
(9,  1, 3, 'G-3',                          'g3',                          'O6', 'Field Grade', 'IN', '11A', 'Active', 'WAA100', '200', '001', 'Fort Liberty', 'NC'),
(10, 1, 3, 'Deputy G-3',                   'deputy g3',                   'O5', 'Field Grade', 'IN', '11A', 'Active', 'WAA100', '200', '002', 'Fort Liberty', 'NC'),
(11, 1, 3, 'Current Operations Officer',   'current operations officer',  'O4', 'Field Grade', 'IN', '11A', 'Active', 'WAA100', '200', '003', 'Fort Liberty', 'NC'),
-- I Corps G-3 billets
(12, 4, 9, 'G-3',                          'g3',                          'O6', 'Field Grade', 'IN', '11A', 'Active', 'WBB100', '200', '001', 'JBLM', 'WA'),
(13, 4, 9, 'Deputy G-3',                   'deputy g3',                   'O5', 'Field Grade', 'IN', '11A', 'Active', 'WBB100', '200', '002', 'JBLM', 'WA'),
-- I Corps G-6 billets
(14, 4, 10, 'G-6',                         'g6',                          'O6', 'Field Grade', 'SC', '25A', 'Active', 'WBB100', '100', '001', 'JBLM', 'WA'),
(15, 4, 10, 'Deputy G-6',                  'deputy g6',                   'O5', 'Field Grade', 'SC', '25A', 'Active', 'WBB100', '100', '002', 'JBLM', 'WA'),
-- NETCOM G-6 billets
(16, 7, 15, 'G-6',                         'g6',                          'O6', 'Field Grade', 'SC', '25A', 'Active', 'WDD100', '100', '001', 'Fort Huachuca', 'AZ'),
(17, 7, 15, 'Cybersecurity Chief',         'cybersecurity chief',         'O4', 'Field Grade', 'SC', '17A', 'Active', 'WDD100', '100', '002', 'Fort Huachuca', 'AZ'),
-- 1BCT 82nd S-3 billets
(18, 10, 16, 'S-3',                        's3',                          'O4', 'Field Grade', 'IN', '11A', 'Active', 'WAA210', '200', '001', 'Fort Liberty', 'NC'),
(19, 10, 16, 'Assistant S-3',              'assistant s3',                'O3', 'Company Grade','IN', '11A', 'Active', 'WAA210', '200', '002', 'Fort Liberty', 'NC'),
-- 28th ID G-6 (Guard)
(20, 8, 19, 'G-6',                         'g6',                          'O5', 'Field Grade', 'SC', '25A', 'Guard',  'WEE100', '100', '001', 'Harrisburg', 'PA'),
(21, 8, 19, 'Network Operations NCO',      'network operations nco',      'E7', 'Senior NCO',  'SC', '25B', 'Guard',  'WEE100', '100', '002', 'Harrisburg', 'PA'),
-- Reserve billets
(22, 9, NULL, 'Operations Officer',        'operations officer',          'O3', 'Company Grade','AG', '42B', 'Reserve','WFF100', '300', '001', 'Fort Jackson', 'SC'),
(23, 9, NULL, 'Human Resources NCO',       'human resources nco',         'E6', 'NCO',         'AG', '42A', 'Reserve','WFF100', '300', '002', 'Fort Jackson', 'SC');

-- ============================================================
-- People
-- ============================================================
INSERT INTO people (person_id, display_name, normalized_display_name, rank, work_email, work_phone, office_symbol) VALUES
(1,  'Johnson, Michael R.',  'johnson michael r',  'COL',  'michael.r.johnson.mil@army.mil',  '910-555-0101', 'AFNC-G6'),
(2,  'Williams, Sarah T.',   'williams sarah t',   'LTC',  'sarah.t.williams.mil@army.mil',   '910-555-0102', 'AFNC-G6'),
(3,  'Garcia, David M.',     'garcia david m',     'MAJ',  'david.m.garcia.mil@army.mil',     '910-555-0103', 'AFNC-G6'),
(4,  'Chen, Lisa K.',        'chen lisa k',        'CPT',  'lisa.k.chen.mil@army.mil',        '910-555-0104', 'AFNC-G6'),
(5,  'Brown, James A.',      'brown james a',      'MSG',  'james.a.brown.mil@army.mil',      '910-555-0105', 'AFNC-G6'),
(6,  'Davis, Robert L.',     'davis robert l',     'SSG',  'robert.l.davis.mil@army.mil',     '910-555-0106', 'AFNC-G6'),
(7,  'Martinez, Ana P.',     'martinez ana p',     'SGT',  'ana.p.martinez.mil@army.mil',     '910-555-0107', 'AFNC-G6'),
(8,  'Thompson, Mark E.',    'thompson mark e',    'COL',  'mark.e.thompson.mil@army.mil',    '910-555-0201', 'AFNC-G3'),
(9,  'Anderson, Kelly J.',   'anderson kelly j',   'LTC',  'kelly.j.anderson.mil@army.mil',   '910-555-0202', 'AFNC-G3'),
(10, 'Wilson, Patrick S.',   'wilson patrick s',   'COL',  'patrick.s.wilson.mil@army.mil',   '253-555-0301', 'AMCC-G3'),
(11, 'Lee, Jennifer H.',     'lee jennifer h',     'LTC',  'jennifer.h.lee.mil@army.mil',     '253-555-0302', 'AMCC-G3'),
(12, 'Taylor, Brian W.',     'taylor brian w',     'COL',  'brian.w.taylor.mil@army.mil',     '253-555-0401', 'AMCC-G6'),
(13, 'Harris, Nicole M.',    'harris nicole m',    'COL',  'nicole.m.harris.mil@army.mil',    '520-555-0501', 'NETC-G6'),
(14, 'Clark, Steven R.',     'clark steven r',     'MAJ',  'steven.r.clark.mil@army.mil',     '910-555-0601', 'AETV-S3'),
(15, 'Robinson, Amy D.',     'robinson amy d',     'LTC',  'amy.d.robinson.mil@army.mil',     '717-555-0701', 'NGPA-G6');

-- ============================================================
-- Billet occupants
-- ============================================================
INSERT INTO billet_occupants (billet_id, person_id, is_primary, occupancy_status, source_system) VALUES
-- XVIII ABN Corps G-6 (fully staffed)
(1,  1,  true, 'active', 'seed'),
(2,  2,  true, 'active', 'seed'),
(3,  3,  true, 'active', 'seed'),
(4,  4,  true, 'active', 'seed'),
(5,  5,  true, 'active', 'seed'),
(6,  6,  true, 'active', 'seed'),
(7,  7,  true, 'active', 'seed'),
-- billet 8 (Cybersecurity Analyst) left VACANT intentionally
-- XVIII ABN Corps G-3
(9,  8,  true, 'active', 'seed'),
(10, 9,  true, 'active', 'seed'),
-- billet 11 (Current Ops Officer) left VACANT
-- I Corps G-3
(12, 10, true, 'active', 'seed'),
(13, 11, true, 'active', 'seed'),
-- I Corps G-6
(14, 12, true, 'active', 'seed'),
-- billet 15 (Deputy G-6) left VACANT
-- NETCOM G-6
(16, 13, true, 'active', 'seed'),
-- billet 17 (Cyber Chief) left VACANT
-- 1BCT S-3
(18, 14, true, 'active', 'seed'),
-- billet 19 (Asst S-3) left VACANT
-- 28th ID G-6
(20, 15, true, 'active', 'seed');
-- billets 21, 22, 23 left with no occupant data (UNKNOWN for 21, VACANT for 22-23)

-- ============================================================
-- Search documents (denormalized for search)
-- ============================================================

-- Organizations
INSERT INTO search_documents (document_type, entity_id, search_text, ts_document, display_name, subtitle, status)
SELECT
    'organization',
    o.organization_id,
    o.organization_name || ' ' || COALESCE(o.short_name, '') || ' ' || COALESCE(o.uic, ''),
    to_tsvector('english', o.organization_name || ' ' || COALESCE(o.short_name, '') || ' ' || COALESCE(o.uic, '')),
    o.organization_name,
    COALESCE(o.component, '') || ' ' || COALESCE(o.echelon, '') || ' — ' || COALESCE(o.location_name, ''),
    NULL
FROM organizations o;

-- Sections
INSERT INTO search_documents (document_type, entity_id, search_text, ts_document, display_name, subtitle, status)
SELECT
    'section',
    s.section_id,
    COALESCE(s.display_name, s.section_name) || ' ' || o.organization_name || ' ' || COALESCE(s.section_code, ''),
    to_tsvector('english', COALESCE(s.display_name, s.section_name) || ' ' || o.organization_name || ' ' || COALESCE(s.section_code, '')),
    COALESCE(s.display_name, s.section_name),
    o.organization_name,
    NULL
FROM sections s JOIN organizations o ON s.organization_id = o.organization_id;

-- People
INSERT INTO search_documents (document_type, entity_id, search_text, ts_document, display_name, subtitle, status)
SELECT
    'person',
    p.person_id,
    p.display_name || ' ' || COALESCE(p.rank, '') || ' ' || COALESCE(p.office_symbol, ''),
    to_tsvector('english', p.display_name || ' ' || COALESCE(p.rank, '') || ' ' || COALESCE(p.office_symbol, '')),
    COALESCE(p.rank, '') || ' ' || p.display_name,
    COALESCE(p.office_symbol, ''),
    NULL
FROM people p;

-- Billets
INSERT INTO search_documents (document_type, entity_id, search_text, ts_document, display_name, subtitle, status)
SELECT
    'billet',
    b.billet_id,
    b.billet_title || ' ' || COALESCE(b.grade_code, '') || ' ' || COALESCE(b.mos_code, '') || ' ' || COALESCE(b.uic, '') || ' ' || o.organization_name,
    to_tsvector('english', b.billet_title || ' ' || COALESCE(b.grade_code, '') || ' ' || COALESCE(b.mos_code, '') || ' ' || COALESCE(b.uic, '') || ' ' || o.organization_name),
    b.billet_title,
    COALESCE(b.grade_code, '') || ' ' || COALESCE(b.mos_code, '') || ' — ' || o.organization_name,
    CASE
        WHEN EXISTS (SELECT 1 FROM billet_occupants bo WHERE bo.billet_id = b.billet_id AND bo.occupancy_status = 'active') THEN 'Filled'
        ELSE 'Vacant'
    END
FROM billets b JOIN organizations o ON b.organization_id = o.organization_id;

-- Aliases as search docs pointing to organizations
INSERT INTO search_documents (document_type, entity_id, search_text, ts_document, display_name, subtitle, status)
SELECT
    'organization',
    oa.organization_id,
    oa.alias_text,
    to_tsvector('english', oa.alias_text),
    o.organization_name,
    oa.alias_type || ' alias',
    NULL
FROM organization_aliases oa JOIN organizations o ON oa.organization_id = o.organization_id;
