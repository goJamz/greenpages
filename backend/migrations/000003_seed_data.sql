-- backend/migrations/000003_seed_data.sql
-- Seed organizations
INSERT INTO organizations (organization_id, organization_name, normalized_name, short_name, component, echelon, uic, location_name, state_code)
VALUES
(1, 'XVIII Airborne Corps',    'xviii airborne corps',    '18 ABN Corps', 'Active', 'Corps',    'WAA100', 'Fort Liberty',                'NC'),
(2, '82nd Airborne Division',  '82nd airborne division',  '82nd ABN',     'Active', 'Division', 'WAA200', 'Fort Liberty',                'NC'),
(3, 'I Corps',                 'i corps',                 'I Corps',      'Active', 'Corps',    'WBB100', 'Joint Base Lewis-McChord',    'WA'),
(4, 'NETCOM',                  'netcom',                  'NETCOM',       'Active', 'Command',  'WDD100', 'Fort Huachuca',               'AZ');

-- Set parent relationships
UPDATE organizations SET parent_organization_id = 1 WHERE organization_id = 2;

-- Seed sections
INSERT INTO sections (section_id, organization_id, section_code, section_name, normalized_section_name, display_name)
VALUES
-- XVIII ABN Corps
(1,  1, 'G1', 'G-1', 'g1', 'XVIII Airborne Corps G-1'),
(2,  1, 'G2', 'G-2', 'g2', 'XVIII Airborne Corps G-2'),
(3,  1, 'G3', 'G-3', 'g3', 'XVIII Airborne Corps G-3'),
(4,  1, 'G6', 'G-6', 'g6', 'XVIII Airborne Corps G-6'),
-- 82nd ABN
(5,  2, 'G3', 'G-3', 'g3', '82nd Airborne Division G-3'),
(6,  2, 'G6', 'G-6', 'g6', '82nd Airborne Division G-6'),
-- I Corps
(7,  3, 'G3', 'G-3', 'g3', 'I Corps G-3'),
(8,  3, 'G6', 'G-6', 'g6', 'I Corps G-6'),
-- NETCOM
(9,  4, 'G3', 'G-3', 'g3', 'NETCOM G-3'),
(10, 4, 'G6', 'G-6', 'g6', 'NETCOM G-6');