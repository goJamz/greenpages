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
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'FA', NULL, '13A', 'Active', 'WAA100', '110', '01', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P002', 'Deputy G-3 Plans', 'deputyg3plans', 'LTC', 'Officer', 'FA', NULL, '13A', 'Active', 'WAA100', '110', '02', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P003', 'Future Operations Officer', 'futureoperationsofficer', 'CPT', 'Officer', 'FA', NULL, '13A', 'Active', 'WAA100', '110', '03', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P004', 'Operations Sergeant Major', 'operationssergeantmajor', 'SGM', 'Enlisted', 'FA', '13Z', NULL, 'Active', 'WAA100', '110', '04', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Active', 'WAA200', '120', '01', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-3', 'P002', 'Air Operations Officer', 'airoperationsofficer', 'MAJ', 'Officer', 'AV', NULL, '15A', 'Active', 'WAA200', '120', '02', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-3', 'P003', 'Current Operations NCOIC', 'currentoperationsncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Active', 'WAA200', '120', '03', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-3', 'P004', 'Schools NCO', 'schoolsnco', 'SFC', 'Enlisted', 'IN', '11B', NULL, 'Active', 'WAA200', '120', '04', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-6', 'P001', 'Division Signal Officer', 'divisionsignalofficer', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WAA200', '130', '01', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-6', 'P002', 'Knowledge Management Officer', 'knowledgemanagementofficer', 'MAJ', 'Officer', 'SC', NULL, '25A', 'Active', 'WAA200', '130', '02', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-6', 'P003', 'Network Operations NCOIC', 'networkoperationsncoic', 'MSG', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WAA200', '130', '03', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-6', 'P004', 'Automation NCO', 'automationnco', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WAA200', '130', '04', 'Fort Liberty', 'NC'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Active', 'WAA300', '140', '01', 'Fort Campbell', 'KY'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-3', 'P002', 'Air Assault Operations Officer', 'airassaultoperationsofficer', 'LTC', 'Officer', 'AV', NULL, '15A', 'Active', 'WAA300', '140', '02', 'Fort Campbell', 'KY'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-3', 'P003', 'Current Operations Officer', 'currentoperationsofficer', 'MAJ', 'Officer', 'IN', NULL, '11A', 'Active', 'WAA300', '140', '03', 'Fort Campbell', 'KY'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-3', 'P004', 'Training NCOIC', 'trainingncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Active', 'WAA300', '140', '04', 'Fort Campbell', 'KY'),
            ('I Corps', 'I Corps G-6', 'P001', 'G-6', 'g6', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WBB100', '200', '01', 'Joint Base Lewis-McChord', 'WA'),
            ('I Corps', 'I Corps G-6', 'P002', 'Deputy G-6', 'deputyg6', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'WBB100', '200', '02', 'Joint Base Lewis-McChord', 'WA'),
            ('I Corps', 'I Corps G-6', 'P003', 'Plans Officer', 'plansofficer', 'MAJ', 'Officer', 'SC', NULL, '25A', 'Active', 'WBB100', '200', '03', 'Joint Base Lewis-McChord', 'WA'),
            ('I Corps', 'I Corps G-6', 'P004', 'Knowledge Management NCO', 'knowledgemanagementnco', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WBB100', '200', '04', 'Joint Base Lewis-McChord', 'WA'),
            ('III Armored Corps', 'III Armored Corps G-4', 'P001', 'G-4', 'g4', 'COL', 'Officer', 'LG', NULL, '90A', 'Active', 'WCC100', '210', '01', 'Fort Cavazos', 'TX'),
            ('III Armored Corps', 'III Armored Corps G-4', 'P002', 'Deputy G-4', 'deputyg4', 'LTC', 'Officer', 'LG', NULL, '90A', 'Active', 'WCC100', '210', '02', 'Fort Cavazos', 'TX'),
            ('III Armored Corps', 'III Armored Corps G-4', 'P003', 'Maintenance Operations Officer', 'maintenanceoperationsofficer', 'MAJ', 'Officer', 'OD', NULL, '91A', 'Active', 'WCC100', '210', '03', 'Fort Cavazos', 'TX'),
            ('III Armored Corps', 'III Armored Corps G-4', 'P004', 'Support Operations NCOIC', 'supportoperationsncoic', 'MSG', 'Enlisted', 'LG', '92A', NULL, 'Active', 'WCC100', '210', '04', 'Fort Cavazos', 'TX'),
            ('NETCOM', 'NETCOM G-6', 'P001', 'G-6 Director', 'g6director', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WDD100', '300', '01', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM G-6', 'P002', 'Cyber Operations Officer', 'cyberoperationsofficer', 'LTC', 'Officer', 'SC', NULL, '17A', 'Active', 'WDD100', '300', '02', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM G-6', 'P003', 'Network Defense NCOIC', 'networkdefensencoic', 'MSG', 'Enlisted', 'SC', '25D', NULL, 'Active', 'WDD100', '300', '03', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM G-6', 'P004', 'Systems Integration NCO', 'systemsintegrationnco', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WDD100', '300', '04', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM Cyber', 'P001', 'Cyber Division Chief', 'cyberdivisionchief', 'COL', 'Officer', 'CY', NULL, '17A', 'Active', 'WDD100', '310', '01', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM Cyber', 'P002', 'Defensive Cyber Operations Planner', 'defensivecyberoperationsplanner', 'MAJ', 'Officer', 'CY', NULL, '17A', 'Active', 'WDD100', '310', '02', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM Cyber', 'P003', 'Cyber Threat Analyst', 'cyberthreatanalyst', 'SFC', 'Enlisted', 'MI', '35N', NULL, 'Active', 'WDD100', '310', '03', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM Cyber', 'P004', 'Incident Response NCO', 'incidentresponsenco', 'SSG', 'Enlisted', 'SC', '25D', NULL, 'Active', 'WDD100', '310', '04', 'Fort Huachuca', 'AZ'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Guard', 'WEE100', '400', '01', 'Arlington', 'VA'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-3', 'P002', 'Domestic Operations Officer', 'domesticoperationsofficer', 'LTC', 'Officer', 'IN', NULL, '11A', 'Guard', 'WEE100', '400', '02', 'Arlington', 'VA'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-3', 'P003', 'Readiness NCOIC', 'readinessncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Guard', 'WEE100', '400', '03', 'Arlington', 'VA'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-3', 'P004', 'Training Management NCO', 'trainingmanagementnco', 'SFC', 'Enlisted', 'IN', '11B', NULL, 'Guard', 'WEE100', '400', '04', 'Arlington', 'VA'),
            ('28th Infantry Division', '28th Infantry Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Guard', 'WEE200', '410', '01', 'Harrisburg', 'PA'),
            ('28th Infantry Division', '28th Infantry Division G-3', 'P002', 'Plans Officer', 'plansofficer', 'MAJ', 'Officer', 'IN', NULL, '11A', 'Guard', 'WEE200', '410', '02', 'Harrisburg', 'PA'),
            ('28th Infantry Division', '28th Infantry Division G-3', 'P003', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Guard', 'WEE200', '410', '03', 'Harrisburg', 'PA'),
            ('28th Infantry Division', '28th Infantry Division G-3', 'P004', 'Training NCO', 'trainingnco', 'SFC', 'Enlisted', 'IN', '11B', NULL, 'Guard', 'WEE200', '410', '04', 'Harrisburg', 'PA'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P001', 'G-4', 'g4', 'COL', 'Officer', 'LG', NULL, '90A', 'Reserve', 'WFF100', '500', '01', 'Belle Chasse', 'LA'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P002', 'Sustainment Plans Officer', 'sustainmentplansofficer', 'LTC', 'Officer', 'LG', NULL, '90A', 'Reserve', 'WFF100', '500', '02', 'Belle Chasse', 'LA'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P003', 'Property Accountability NCOIC', 'propertyaccountabilityncoic', 'MSG', 'Enlisted', 'LG', '92Y', NULL, 'Reserve', 'WFF100', '500', '03', 'Belle Chasse', 'LA'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P004', 'Supply Systems NCO', 'supplysystemsnco', 'SFC', 'Enlisted', 'LG', '92A', NULL, 'Reserve', 'WFF100', '500', '04', 'Belle Chasse', 'LA')
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
