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

-- ---------------------------------------------------------------------------
-- Additional billets for existing organization sections that had none,
-- plus billets for all new organizations.
-- ---------------------------------------------------------------------------
WITH additional_billet_seed AS (
    SELECT *
    FROM (
        VALUES
            -- XVIII Airborne Corps G-1
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-1', 'P001', 'G-1', 'g1', 'COL', 'Officer', 'AG', NULL, '42A', 'Active', 'WAA100', '101', '01', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-1', 'P002', 'Deputy G-1', 'deputyg1', 'LTC', 'Officer', 'AG', NULL, '42A', 'Active', 'WAA100', '101', '02', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-1', 'P003', 'Strength Management Officer', 'strengthmanagementofficer', 'MAJ', 'Officer', 'AG', NULL, '42A', 'Active', 'WAA100', '101', '03', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-1', 'P004', 'Senior Personnel NCO', 'seniorpersonnelnco', 'MSG', 'Enlisted', 'AG', '42A', NULL, 'Active', 'WAA100', '101', '04', 'Fort Liberty', 'NC'),
            -- XVIII Airborne Corps G-2
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-2', 'P001', 'G-2', 'g2', 'COL', 'Officer', 'MI', NULL, '35A', 'Active', 'WAA100', '102', '01', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-2', 'P002', 'Deputy G-2', 'deputyg2', 'LTC', 'Officer', 'MI', NULL, '35A', 'Active', 'WAA100', '102', '02', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-2', 'P003', 'All-Source Intelligence Officer', 'allsourceintelligenceofficer', 'MAJ', 'Officer', 'MI', NULL, '35A', 'Active', 'WAA100', '102', '03', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-2', 'P004', 'Intelligence Operations NCOIC', 'intelligenceoperationsncoic', 'MSG', 'Enlisted', 'MI', '35F', NULL, 'Active', 'WAA100', '102', '04', 'Fort Liberty', 'NC'),
            -- XVIII Airborne Corps G-4
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-4', 'P001', 'G-4', 'g4', 'COL', 'Officer', 'LG', NULL, '90A', 'Active', 'WAA100', '103', '01', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-4', 'P002', 'Deputy G-4', 'deputyg4', 'LTC', 'Officer', 'LG', NULL, '90A', 'Active', 'WAA100', '103', '02', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-4', 'P003', 'Supply Operations Officer', 'supplyoperationsofficer', 'MAJ', 'Officer', 'LG', NULL, '90A', 'Active', 'WAA100', '103', '03', 'Fort Liberty', 'NC'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-4', 'P004', 'Logistics Operations NCOIC', 'logisticsoperationsncoic', 'MSG', 'Enlisted', 'LG', '92A', NULL, 'Active', 'WAA100', '103', '04', 'Fort Liberty', 'NC'),
            -- 82nd Airborne Division G-1
            ('82nd Airborne Division', '82nd Airborne Division G-1', 'P001', 'G-1', 'g1', 'LTC', 'Officer', 'AG', NULL, '42A', 'Active', 'WAA200', '121', '01', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-1', 'P002', 'Personnel Officer', 'personnelofficer', 'MAJ', 'Officer', 'AG', NULL, '42A', 'Active', 'WAA200', '121', '02', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-1', 'P003', 'Senior Personnel NCO', 'seniorpersonnelnco', 'MSG', 'Enlisted', 'AG', '42A', NULL, 'Active', 'WAA200', '121', '03', 'Fort Liberty', 'NC'),
            -- 82nd Airborne Division G-2
            ('82nd Airborne Division', '82nd Airborne Division G-2', 'P001', 'G-2', 'g2', 'LTC', 'Officer', 'MI', NULL, '35A', 'Active', 'WAA200', '122', '01', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-2', 'P002', 'Intelligence Analyst Officer', 'intelligenceanalystofficer', 'CPT', 'Officer', 'MI', NULL, '35A', 'Active', 'WAA200', '122', '02', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-2', 'P003', 'Intelligence NCOIC', 'intelligencencoic', 'MSG', 'Enlisted', 'MI', '35F', NULL, 'Active', 'WAA200', '122', '03', 'Fort Liberty', 'NC'),
            -- 82nd Airborne Division G-4
            ('82nd Airborne Division', '82nd Airborne Division G-4', 'P001', 'G-4', 'g4', 'LTC', 'Officer', 'LG', NULL, '90A', 'Active', 'WAA200', '123', '01', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-4', 'P002', 'Maintenance Officer', 'maintenanceofficer', 'MAJ', 'Officer', 'OD', NULL, '91A', 'Active', 'WAA200', '123', '02', 'Fort Liberty', 'NC'),
            ('82nd Airborne Division', '82nd Airborne Division G-4', 'P003', 'Logistics NCOIC', 'logisticsncoic', 'MSG', 'Enlisted', 'LG', '92A', NULL, 'Active', 'WAA200', '123', '03', 'Fort Liberty', 'NC'),
            -- 101st Airborne Division G-6
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-6', 'P001', 'Division Signal Officer', 'divisionsignalofficer', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WAA300', '141', '01', 'Fort Campbell', 'KY'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-6', 'P002', 'Deputy Signal Officer', 'deputysignalofficer', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'WAA300', '141', '02', 'Fort Campbell', 'KY'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-6', 'P003', 'Network Operations NCOIC', 'networkoperationsncoic', 'MSG', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WAA300', '141', '03', 'Fort Campbell', 'KY'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-6', 'P004', 'Cyber Security NCO', 'cybersecuritynco', 'SFC', 'Enlisted', 'SC', '25D', NULL, 'Active', 'WAA300', '141', '04', 'Fort Campbell', 'KY'),
            -- 10th Mountain Division G-3
            ('10th Mountain Division', '10th Mountain Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Active', 'WAA400', '150', '01', 'Fort Drum', 'NY'),
            ('10th Mountain Division', '10th Mountain Division G-3', 'P002', 'Operations Officer', 'operationsofficer', 'MAJ', 'Officer', 'IN', NULL, '11A', 'Active', 'WAA400', '150', '02', 'Fort Drum', 'NY'),
            ('10th Mountain Division', '10th Mountain Division G-3', 'P003', 'Training Officer', 'trainingofficer', 'CPT', 'Officer', 'IN', NULL, '11A', 'Active', 'WAA400', '150', '03', 'Fort Drum', 'NY'),
            ('10th Mountain Division', '10th Mountain Division G-3', 'P004', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Active', 'WAA400', '150', '04', 'Fort Drum', 'NY'),
            -- 10th Mountain Division G-6
            ('10th Mountain Division', '10th Mountain Division G-6', 'P001', 'Signal Officer', 'signalofficer', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'WAA400', '151', '01', 'Fort Drum', 'NY'),
            ('10th Mountain Division', '10th Mountain Division G-6', 'P002', 'Network Engineer', 'networkengineer', 'CPT', 'Officer', 'SC', NULL, '25A', 'Active', 'WAA400', '151', '02', 'Fort Drum', 'NY'),
            ('10th Mountain Division', '10th Mountain Division G-6', 'P003', 'Signal NCOIC', 'signalncoic', 'SFC', 'Enlisted', 'SC', '25U', NULL, 'Active', 'WAA400', '151', '03', 'Fort Drum', 'NY'),
            -- I Corps G-3
            ('I Corps', 'I Corps G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Active', 'WBB100', '201', '01', 'Joint Base Lewis-McChord', 'WA'),
            ('I Corps', 'I Corps G-3', 'P002', 'Deputy G-3', 'deputyg3', 'LTC', 'Officer', 'IN', NULL, '11A', 'Active', 'WBB100', '201', '02', 'Joint Base Lewis-McChord', 'WA'),
            ('I Corps', 'I Corps G-3', 'P003', 'Current Operations Officer', 'currentoperationsofficer', 'MAJ', 'Officer', 'FA', NULL, '13A', 'Active', 'WBB100', '201', '03', 'Joint Base Lewis-McChord', 'WA'),
            ('I Corps', 'I Corps G-3', 'P004', 'Operations SGM', 'operationssgm', 'SGM', 'Enlisted', 'IN', '11Z', NULL, 'Active', 'WBB100', '201', '04', 'Joint Base Lewis-McChord', 'WA'),
            -- 7th Infantry Division G-3
            ('7th Infantry Division', '7th Infantry Division G-3', 'P001', 'G-3', 'g3', 'LTC', 'Officer', 'IN', NULL, '11A', 'Active', 'WBB200', '220', '01', 'Joint Base Lewis-McChord', 'WA'),
            ('7th Infantry Division', '7th Infantry Division G-3', 'P002', 'Plans Officer', 'plansofficer', 'MAJ', 'Officer', 'IN', NULL, '11A', 'Active', 'WBB200', '220', '02', 'Joint Base Lewis-McChord', 'WA'),
            ('7th Infantry Division', '7th Infantry Division G-3', 'P003', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Active', 'WBB200', '220', '03', 'Joint Base Lewis-McChord', 'WA'),
            -- 7th Infantry Division G-6
            ('7th Infantry Division', '7th Infantry Division G-6', 'P001', 'Signal Officer', 'signalofficer', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'WBB200', '221', '01', 'Joint Base Lewis-McChord', 'WA'),
            ('7th Infantry Division', '7th Infantry Division G-6', 'P002', 'Network Operations NCO', 'networkoperationsnco', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WBB200', '221', '02', 'Joint Base Lewis-McChord', 'WA'),
            ('7th Infantry Division', '7th Infantry Division G-6', 'P003', 'Cyber Defense NCO', 'cyberdefensenco', 'SSG', 'Enlisted', 'SC', '25D', NULL, 'Active', 'WBB200', '221', '03', 'Joint Base Lewis-McChord', 'WA'),
            -- III Armored Corps G-3
            ('III Armored Corps', 'III Armored Corps G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'AR', NULL, '19A', 'Active', 'WCC100', '211', '01', 'Fort Cavazos', 'TX'),
            ('III Armored Corps', 'III Armored Corps G-3', 'P002', 'Deputy G-3', 'deputyg3', 'LTC', 'Officer', 'AR', NULL, '19A', 'Active', 'WCC100', '211', '02', 'Fort Cavazos', 'TX'),
            ('III Armored Corps', 'III Armored Corps G-3', 'P003', 'Future Operations Officer', 'futureoperationsofficer', 'MAJ', 'Officer', 'FA', NULL, '13A', 'Active', 'WCC100', '211', '03', 'Fort Cavazos', 'TX'),
            ('III Armored Corps', 'III Armored Corps G-3', 'P004', 'Operations SGM', 'operationssgm', 'SGM', 'Enlisted', 'AR', '19Z', NULL, 'Active', 'WCC100', '211', '04', 'Fort Cavazos', 'TX'),
            -- III Armored Corps G-6
            ('III Armored Corps', 'III Armored Corps G-6', 'P001', 'G-6', 'g6', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WCC100', '212', '01', 'Fort Cavazos', 'TX'),
            ('III Armored Corps', 'III Armored Corps G-6', 'P002', 'Deputy G-6', 'deputyg6', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'WCC100', '212', '02', 'Fort Cavazos', 'TX'),
            ('III Armored Corps', 'III Armored Corps G-6', 'P003', 'Network Defense Officer', 'networkdefenseofficer', 'MAJ', 'Officer', 'SC', NULL, '17A', 'Active', 'WCC100', '212', '03', 'Fort Cavazos', 'TX'),
            ('III Armored Corps', 'III Armored Corps G-6', 'P004', 'Signal Operations NCOIC', 'signaloperationsncoic', 'MSG', 'Enlisted', 'SC', '25U', NULL, 'Active', 'WCC100', '212', '04', 'Fort Cavazos', 'TX'),
            -- 1st Cavalry Division G-3
            ('1st Cavalry Division', '1st Cavalry Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'AR', NULL, '19A', 'Active', 'WCC200', '230', '01', 'Fort Cavazos', 'TX'),
            ('1st Cavalry Division', '1st Cavalry Division G-3', 'P002', 'Aviation Operations Officer', 'aviationoperationsofficer', 'MAJ', 'Officer', 'AV', NULL, '15A', 'Active', 'WCC200', '230', '02', 'Fort Cavazos', 'TX'),
            ('1st Cavalry Division', '1st Cavalry Division G-3', 'P003', 'Current Operations NCOIC', 'currentoperationsncoic', 'MSG', 'Enlisted', 'AR', '19Z', NULL, 'Active', 'WCC200', '230', '03', 'Fort Cavazos', 'TX'),
            ('1st Cavalry Division', '1st Cavalry Division G-3', 'P004', 'Training NCO', 'trainingnco', 'SFC', 'Enlisted', 'IN', '11B', NULL, 'Active', 'WCC200', '230', '04', 'Fort Cavazos', 'TX'),
            -- 1st Cavalry Division G-6
            ('1st Cavalry Division', '1st Cavalry Division G-6', 'P001', 'Signal Officer', 'signalofficer', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'WCC200', '231', '01', 'Fort Cavazos', 'TX'),
            ('1st Cavalry Division', '1st Cavalry Division G-6', 'P002', 'Network Operations NCO', 'networkoperationsnco', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WCC200', '231', '02', 'Fort Cavazos', 'TX'),
            ('1st Cavalry Division', '1st Cavalry Division G-6', 'P003', 'Information Assurance NCO', 'informationassurancenco', 'SSG', 'Enlisted', 'SC', '25D', NULL, 'Active', 'WCC200', '231', '03', 'Fort Cavazos', 'TX'),
            -- NETCOM G-3
            ('NETCOM', 'NETCOM G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WDD100', '301', '01', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM G-3', 'P002', 'Training and Readiness Officer', 'trainingandreadinessofficer', 'MAJ', 'Officer', 'SC', NULL, '25A', 'Active', 'WDD100', '301', '02', 'Fort Huachuca', 'AZ'),
            ('NETCOM', 'NETCOM G-3', 'P003', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'SC', '25U', NULL, 'Active', 'WDD100', '301', '03', 'Fort Huachuca', 'AZ'),
            -- ARNG RC G-6
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-6', 'P001', 'G-6', 'g6', 'COL', 'Officer', 'SC', NULL, '25A', 'Guard', 'WEE100', '401', '01', 'Arlington', 'VA'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-6', 'P002', 'Deputy G-6', 'deputyg6', 'LTC', 'Officer', 'SC', NULL, '25A', 'Guard', 'WEE100', '401', '02', 'Arlington', 'VA'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-6', 'P003', 'Network Defense NCO', 'networkdefensenco', 'SFC', 'Enlisted', 'SC', '25D', NULL, 'Guard', 'WEE100', '401', '03', 'Arlington', 'VA'),
            -- 28th Infantry Division G-6
            ('28th Infantry Division', '28th Infantry Division G-6', 'P001', 'Signal Officer', 'signalofficer', 'LTC', 'Officer', 'SC', NULL, '25A', 'Guard', 'WEE200', '411', '01', 'Harrisburg', 'PA'),
            ('28th Infantry Division', '28th Infantry Division G-6', 'P002', 'Signal Operations NCO', 'signaloperationsnco', 'SFC', 'Enlisted', 'SC', '25U', NULL, 'Guard', 'WEE200', '411', '02', 'Harrisburg', 'PA'),
            ('28th Infantry Division', '28th Infantry Division G-6', 'P003', 'Automation NCO', 'automationnco', 'SSG', 'Enlisted', 'SC', '25B', NULL, 'Guard', 'WEE200', '411', '03', 'Harrisburg', 'PA'),
            -- 377th TSC G-3
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'LG', NULL, '90A', 'Reserve', 'WFF100', '501', '01', 'Belle Chasse', 'LA'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-3', 'P002', 'Operations Officer', 'operationsofficer', 'MAJ', 'Officer', 'LG', NULL, '90A', 'Reserve', 'WFF100', '501', '02', 'Belle Chasse', 'LA'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-3', 'P003', 'Readiness NCO', 'readinessnco', 'SFC', 'Enlisted', 'LG', '92A', NULL, 'Reserve', 'WFF100', '501', '03', 'Belle Chasse', 'LA'),
            -- 3rd Infantry Division G-3
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Active', 'W3ID00', '600', '01', 'Fort Stewart', 'GA'),
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P002', 'Deputy G-3', 'deputyg3', 'LTC', 'Officer', 'IN', NULL, '11A', 'Active', 'W3ID00', '600', '02', 'Fort Stewart', 'GA'),
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P003', 'Current Operations Officer', 'currentoperationsofficer', 'MAJ', 'Officer', 'IN', NULL, '11A', 'Active', 'W3ID00', '600', '03', 'Fort Stewart', 'GA'),
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P004', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Active', 'W3ID00', '600', '04', 'Fort Stewart', 'GA'),
            -- 3rd Infantry Division G-6
            ('3rd Infantry Division', '3rd Infantry Division G-6', 'P001', 'Division Signal Officer', 'divisionsignalofficer', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'W3ID00', '601', '01', 'Fort Stewart', 'GA'),
            ('3rd Infantry Division', '3rd Infantry Division G-6', 'P002', 'Network Operations Officer', 'networkoperationsofficer', 'MAJ', 'Officer', 'SC', NULL, '25A', 'Active', 'W3ID00', '601', '02', 'Fort Stewart', 'GA'),
            ('3rd Infantry Division', '3rd Infantry Division G-6', 'P003', 'Signal NCOIC', 'signalncoic', 'MSG', 'Enlisted', 'SC', '25U', NULL, 'Active', 'W3ID00', '601', '03', 'Fort Stewart', 'GA'),
            ('3rd Infantry Division', '3rd Infantry Division G-6', 'P004', 'Help Desk NCO', 'helpdesknco', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'W3ID00', '601', '04', 'Fort Stewart', 'GA'),
            -- 4th Infantry Division G-3
            ('4th Infantry Division', '4th Infantry Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Active', 'W4ID00', '620', '01', 'Fort Carson', 'CO'),
            ('4th Infantry Division', '4th Infantry Division G-3', 'P002', 'Deputy G-3', 'deputyg3', 'LTC', 'Officer', 'IN', NULL, '11A', 'Active', 'W4ID00', '620', '02', 'Fort Carson', 'CO'),
            ('4th Infantry Division', '4th Infantry Division G-3', 'P003', 'Training Officer', 'trainingofficer', 'MAJ', 'Officer', 'IN', NULL, '11A', 'Active', 'W4ID00', '620', '03', 'Fort Carson', 'CO'),
            ('4th Infantry Division', '4th Infantry Division G-3', 'P004', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Active', 'W4ID00', '620', '04', 'Fort Carson', 'CO'),
            -- 4th Infantry Division G-6
            ('4th Infantry Division', '4th Infantry Division G-6', 'P001', 'Signal Officer', 'signalofficer', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'W4ID00', '621', '01', 'Fort Carson', 'CO'),
            ('4th Infantry Division', '4th Infantry Division G-6', 'P002', 'Deputy Signal Officer', 'deputysignalofficer', 'MAJ', 'Officer', 'SC', NULL, '25A', 'Active', 'W4ID00', '621', '02', 'Fort Carson', 'CO'),
            ('4th Infantry Division', '4th Infantry Division G-6', 'P003', 'Network NCOIC', 'networkncoic', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'W4ID00', '621', '03', 'Fort Carson', 'CO'),
            ('4th Infantry Division', '4th Infantry Division G-6', 'P004', 'Cyber NCO', 'cybernco', 'SSG', 'Enlisted', 'SC', '25D', NULL, 'Active', 'W4ID00', '621', '04', 'Fort Carson', 'CO'),
            -- 25th Infantry Division G-3
            ('25th Infantry Division', '25th Infantry Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Active', 'W25D00', '640', '01', 'Schofield Barracks', 'HI'),
            ('25th Infantry Division', '25th Infantry Division G-3', 'P002', 'Operations Officer', 'operationsofficer', 'MAJ', 'Officer', 'IN', NULL, '11A', 'Active', 'W25D00', '640', '02', 'Schofield Barracks', 'HI'),
            ('25th Infantry Division', '25th Infantry Division G-3', 'P003', 'Training NCOIC', 'trainingncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Active', 'W25D00', '640', '03', 'Schofield Barracks', 'HI'),
            ('25th Infantry Division', '25th Infantry Division G-3', 'P004', 'Schools NCO', 'schoolsnco', 'SFC', 'Enlisted', 'IN', '11B', NULL, 'Active', 'W25D00', '640', '04', 'Schofield Barracks', 'HI'),
            -- 25th Infantry Division G-6
            ('25th Infantry Division', '25th Infantry Division G-6', 'P001', 'Signal Officer', 'signalofficer', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'W25D00', '641', '01', 'Schofield Barracks', 'HI'),
            ('25th Infantry Division', '25th Infantry Division G-6', 'P002', 'Network Operations NCO', 'networkoperationsnco', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'W25D00', '641', '02', 'Schofield Barracks', 'HI'),
            ('25th Infantry Division', '25th Infantry Division G-6', 'P003', 'Satellite Communications NCO', 'satellitecommunicationsnco', 'SSG', 'Enlisted', 'SC', '25S', NULL, 'Active', 'W25D00', '641', '03', 'Schofield Barracks', 'HI'),
            -- 1st Armored Division G-3
            ('1st Armored Division', '1st Armored Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'AR', NULL, '19A', 'Active', 'W1AD00', '660', '01', 'Fort Bliss', 'TX'),
            ('1st Armored Division', '1st Armored Division G-3', 'P002', 'Deputy G-3', 'deputyg3', 'LTC', 'Officer', 'AR', NULL, '19A', 'Active', 'W1AD00', '660', '02', 'Fort Bliss', 'TX'),
            ('1st Armored Division', '1st Armored Division G-3', 'P003', 'Fires Officer', 'firesofficer', 'MAJ', 'Officer', 'FA', NULL, '13A', 'Active', 'W1AD00', '660', '03', 'Fort Bliss', 'TX'),
            ('1st Armored Division', '1st Armored Division G-3', 'P004', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'AR', '19Z', NULL, 'Active', 'W1AD00', '660', '04', 'Fort Bliss', 'TX'),
            -- 1st Armored Division G-4
            ('1st Armored Division', '1st Armored Division G-4', 'P001', 'G-4', 'g4', 'LTC', 'Officer', 'LG', NULL, '90A', 'Active', 'W1AD00', '661', '01', 'Fort Bliss', 'TX'),
            ('1st Armored Division', '1st Armored Division G-4', 'P002', 'Maintenance Officer', 'maintenanceofficer', 'MAJ', 'Officer', 'OD', NULL, '91A', 'Active', 'W1AD00', '661', '02', 'Fort Bliss', 'TX'),
            ('1st Armored Division', '1st Armored Division G-4', 'P003', 'Supply NCOIC', 'supplyncoic', 'MSG', 'Enlisted', 'LG', '92A', NULL, 'Active', 'W1AD00', '661', '03', 'Fort Bliss', 'TX'),
            -- V Corps G-3
            ('V Corps', 'V Corps G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Active', 'WVC100', '700', '01', 'Fort Knox', 'KY'),
            ('V Corps', 'V Corps G-3', 'P002', 'Deputy G-3', 'deputyg3', 'LTC', 'Officer', 'IN', NULL, '11A', 'Active', 'WVC100', '700', '02', 'Fort Knox', 'KY'),
            ('V Corps', 'V Corps G-3', 'P003', 'Future Operations Officer', 'futureoperationsofficer', 'MAJ', 'Officer', 'FA', NULL, '13A', 'Active', 'WVC100', '700', '03', 'Fort Knox', 'KY'),
            ('V Corps', 'V Corps G-3', 'P004', 'Operations SGM', 'operationssgm', 'SGM', 'Enlisted', 'IN', '11Z', NULL, 'Active', 'WVC100', '700', '04', 'Fort Knox', 'KY'),
            -- V Corps G-6
            ('V Corps', 'V Corps G-6', 'P001', 'G-6', 'g6', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WVC100', '701', '01', 'Fort Knox', 'KY'),
            ('V Corps', 'V Corps G-6', 'P002', 'Deputy G-6', 'deputyg6', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'WVC100', '701', '02', 'Fort Knox', 'KY'),
            ('V Corps', 'V Corps G-6', 'P003', 'Network Operations Officer', 'networkoperationsofficer', 'MAJ', 'Officer', 'SC', NULL, '25A', 'Active', 'WVC100', '701', '03', 'Fort Knox', 'KY'),
            ('V Corps', 'V Corps G-6', 'P004', 'Senior Signal NCO', 'seniorsignalnco', 'MSG', 'Enlisted', 'SC', '25U', NULL, 'Active', 'WVC100', '701', '04', 'Fort Knox', 'KY'),
            -- Army Cyber Command G-3
            ('Army Cyber Command', 'Army Cyber Command G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'CY', NULL, '17A', 'Active', 'WCYB00', '720', '01', 'Fort Eisenhower', 'GA'),
            ('Army Cyber Command', 'Army Cyber Command G-3', 'P002', 'Cyber Operations Planner', 'cyberoperationsplanner', 'LTC', 'Officer', 'CY', NULL, '17A', 'Active', 'WCYB00', '720', '02', 'Fort Eisenhower', 'GA'),
            ('Army Cyber Command', 'Army Cyber Command G-3', 'P003', 'Training and Readiness Officer', 'trainingandreadinessofficer', 'MAJ', 'Officer', 'SC', NULL, '25A', 'Active', 'WCYB00', '720', '03', 'Fort Eisenhower', 'GA'),
            ('Army Cyber Command', 'Army Cyber Command G-3', 'P004', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'SC', '25D', NULL, 'Active', 'WCYB00', '720', '04', 'Fort Eisenhower', 'GA'),
            -- Army Cyber Command G-6
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P001', 'G-6', 'g6', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WCYB00', '721', '01', 'Fort Eisenhower', 'GA'),
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P002', 'Enterprise Architecture Officer', 'enterprisearchitectureofficer', 'LTC', 'Officer', 'SC', NULL, '25A', 'Active', 'WCYB00', '721', '02', 'Fort Eisenhower', 'GA'),
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P003', 'Network Defense NCOIC', 'networkdefensencoic', 'MSG', 'Enlisted', 'SC', '25D', NULL, 'Active', 'WCYB00', '721', '03', 'Fort Eisenhower', 'GA'),
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P004', 'Systems Administrator NCO', 'systemsadministratornco', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WCYB00', '721', '04', 'Fort Eisenhower', 'GA'),
            -- INSCOM G-2
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-2', 'P001', 'G-2', 'g2', 'COL', 'Officer', 'MI', NULL, '35A', 'Active', 'WINS00', '740', '01', 'Fort Belvoir', 'VA'),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-2', 'P002', 'Deputy G-2', 'deputyg2', 'LTC', 'Officer', 'MI', NULL, '35A', 'Active', 'WINS00', '740', '02', 'Fort Belvoir', 'VA'),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-2', 'P003', 'Collection Management Officer', 'collectionmanagementofficer', 'MAJ', 'Officer', 'MI', NULL, '35A', 'Active', 'WINS00', '740', '03', 'Fort Belvoir', 'VA'),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-2', 'P004', 'Intelligence NCOIC', 'intelligencencoic', 'MSG', 'Enlisted', 'MI', '35F', NULL, 'Active', 'WINS00', '740', '04', 'Fort Belvoir', 'VA'),
            -- INSCOM G-6
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-6', 'P001', 'Signal Officer', 'signalofficer', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WINS00', '741', '01', 'Fort Belvoir', 'VA'),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-6', 'P002', 'Cyber Systems Officer', 'cybersystemsofficer', 'MAJ', 'Officer', 'SC', NULL, '17A', 'Active', 'WINS00', '741', '02', 'Fort Belvoir', 'VA'),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-6', 'P003', 'Signal NCOIC', 'signalncoic', 'SFC', 'Enlisted', 'SC', '25B', NULL, 'Active', 'WINS00', '741', '03', 'Fort Belvoir', 'VA'),
            -- U.S. Army Pacific G-3
            ('U.S. Army Pacific', 'U.S. Army Pacific G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Active', 'WUAP00', '760', '01', 'Fort Shafter', 'HI'),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-3', 'P002', 'Deputy G-3', 'deputyg3', 'LTC', 'Officer', 'IN', NULL, '11A', 'Active', 'WUAP00', '760', '02', 'Fort Shafter', 'HI'),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-3', 'P003', 'Pacific Plans Officer', 'pacificplansofficer', 'MAJ', 'Officer', 'FA', NULL, '59A', 'Active', 'WUAP00', '760', '03', 'Fort Shafter', 'HI'),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-3', 'P004', 'Operations SGM', 'operationssgm', 'SGM', 'Enlisted', 'IN', '11Z', NULL, 'Active', 'WUAP00', '760', '04', 'Fort Shafter', 'HI'),
            -- U.S. Army Pacific G-6
            ('U.S. Army Pacific', 'U.S. Army Pacific G-6', 'P001', 'G-6', 'g6', 'COL', 'Officer', 'SC', NULL, '25A', 'Active', 'WUAP00', '761', '01', 'Fort Shafter', 'HI'),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-6', 'P002', 'Network Engineer', 'networkengineer', 'MAJ', 'Officer', 'SC', NULL, '25A', 'Active', 'WUAP00', '761', '02', 'Fort Shafter', 'HI'),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-6', 'P003', 'Signal NCOIC', 'signalncoic', 'MSG', 'Enlisted', 'SC', '25U', NULL, 'Active', 'WUAP00', '761', '03', 'Fort Shafter', 'HI'),
            -- 36th Infantry Division G-3
            ('36th Infantry Division', '36th Infantry Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Guard', 'WGG100', '800', '01', 'Camp Mabry', 'TX'),
            ('36th Infantry Division', '36th Infantry Division G-3', 'P002', 'Operations Officer', 'operationsofficer', 'LTC', 'Officer', 'IN', NULL, '11A', 'Guard', 'WGG100', '800', '02', 'Camp Mabry', 'TX'),
            ('36th Infantry Division', '36th Infantry Division G-3', 'P003', 'Training NCOIC', 'trainingncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Guard', 'WGG100', '800', '03', 'Camp Mabry', 'TX'),
            ('36th Infantry Division', '36th Infantry Division G-3', 'P004', 'Readiness NCO', 'readinessnco', 'SFC', 'Enlisted', 'IN', '11B', NULL, 'Guard', 'WGG100', '800', '04', 'Camp Mabry', 'TX'),
            -- 29th Infantry Division G-3
            ('29th Infantry Division', '29th Infantry Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Guard', 'WGG200', '820', '01', 'Fort Belvoir', 'VA'),
            ('29th Infantry Division', '29th Infantry Division G-3', 'P002', 'Plans Officer', 'plansofficer', 'MAJ', 'Officer', 'IN', NULL, '11A', 'Guard', 'WGG200', '820', '02', 'Fort Belvoir', 'VA'),
            ('29th Infantry Division', '29th Infantry Division G-3', 'P003', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Guard', 'WGG200', '820', '03', 'Fort Belvoir', 'VA'),
            ('29th Infantry Division', '29th Infantry Division G-3', 'P004', 'Training NCO', 'trainingnco', 'SFC', 'Enlisted', 'IN', '11B', NULL, 'Guard', 'WGG200', '820', '04', 'Fort Belvoir', 'VA'),
            -- 42nd Infantry Division G-3
            ('42nd Infantry Division', '42nd Infantry Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Guard', 'WGG300', '840', '01', 'Troy', 'NY'),
            ('42nd Infantry Division', '42nd Infantry Division G-3', 'P002', 'Operations Officer', 'operationsofficer', 'MAJ', 'Officer', 'IN', NULL, '11A', 'Guard', 'WGG300', '840', '02', 'Troy', 'NY'),
            ('42nd Infantry Division', '42nd Infantry Division G-3', 'P003', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Guard', 'WGG300', '840', '03', 'Troy', 'NY'),
            -- 34th Infantry Division G-3
            ('34th Infantry Division', '34th Infantry Division G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'IN', NULL, '11A', 'Guard', 'WGG400', '860', '01', 'Rosemount', 'MN'),
            ('34th Infantry Division', '34th Infantry Division G-3', 'P002', 'Training Officer', 'trainingofficer', 'MAJ', 'Officer', 'IN', NULL, '11A', 'Guard', 'WGG400', '860', '02', 'Rosemount', 'MN'),
            ('34th Infantry Division', '34th Infantry Division G-3', 'P003', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'IN', '11Z', NULL, 'Guard', 'WGG400', '860', '03', 'Rosemount', 'MN'),
            -- 335th Signal Command G-6
            ('335th Signal Command', '335th Signal Command G-6', 'P001', 'G-6', 'g6', 'COL', 'Officer', 'SC', NULL, '25A', 'Reserve', 'WRR100', '900', '01', 'East Point', 'GA'),
            ('335th Signal Command', '335th Signal Command G-6', 'P002', 'Signal Operations Officer', 'signaloperationsofficer', 'LTC', 'Officer', 'SC', NULL, '25A', 'Reserve', 'WRR100', '900', '02', 'East Point', 'GA'),
            ('335th Signal Command', '335th Signal Command G-6', 'P003', 'Network NCOIC', 'networkncoic', 'MSG', 'Enlisted', 'SC', '25U', NULL, 'Reserve', 'WRR100', '900', '03', 'East Point', 'GA'),
            ('335th Signal Command', '335th Signal Command G-6', 'P004', 'Satellite Systems NCO', 'satellitesystemsnco', 'SFC', 'Enlisted', 'SC', '25S', NULL, 'Reserve', 'WRR100', '900', '04', 'East Point', 'GA'),
            -- 807th Medical Command G-1
            ('807th Medical Command', '807th Medical Command G-1', 'P001', 'G-1', 'g1', 'LTC', 'Officer', 'MS', NULL, '70A', 'Reserve', 'WRR200', '920', '01', 'Seagoville', 'TX'),
            ('807th Medical Command', '807th Medical Command G-1', 'P002', 'Personnel Officer', 'personnelofficer', 'MAJ', 'Officer', 'AG', NULL, '42A', 'Reserve', 'WRR200', '920', '02', 'Seagoville', 'TX'),
            ('807th Medical Command', '807th Medical Command G-1', 'P003', 'Personnel NCOIC', 'personnelncoic', 'SFC', 'Enlisted', 'AG', '42A', NULL, 'Reserve', 'WRR200', '920', '03', 'Seagoville', 'TX'),
            -- 63rd Readiness Division G-4
            ('63rd Readiness Division', '63rd Readiness Division G-4', 'P001', 'G-4', 'g4', 'LTC', 'Officer', 'LG', NULL, '90A', 'Reserve', 'WRR300', '940', '01', 'Mountain View', 'CA'),
            ('63rd Readiness Division', '63rd Readiness Division G-4', 'P002', 'Supply Officer', 'supplyofficer', 'MAJ', 'Officer', 'LG', NULL, '90A', 'Reserve', 'WRR300', '940', '02', 'Mountain View', 'CA'),
            ('63rd Readiness Division', '63rd Readiness Division G-4', 'P003', 'Logistics NCOIC', 'logisticsncoic', 'SFC', 'Enlisted', 'LG', '92A', NULL, 'Reserve', 'WRR300', '940', '03', 'Mountain View', 'CA'),
            -- 416th Theater Engineer Command G-3
            ('416th Theater Engineer Command', '416th Theater Engineer Command G-3', 'P001', 'G-3', 'g3', 'COL', 'Officer', 'EN', NULL, '12A', 'Reserve', 'WRR400', '960', '01', 'Darien', 'IL'),
            ('416th Theater Engineer Command', '416th Theater Engineer Command G-3', 'P002', 'Engineer Operations Officer', 'engineeroperationsofficer', 'MAJ', 'Officer', 'EN', NULL, '12A', 'Reserve', 'WRR400', '960', '02', 'Darien', 'IL'),
            ('416th Theater Engineer Command', '416th Theater Engineer Command G-3', 'P003', 'Operations NCOIC', 'operationsncoic', 'MSG', 'Enlisted', 'EN', '12B', NULL, 'Reserve', 'WRR400', '960', '03', 'Darien', 'IL')
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
    additional_billet_seed.position_number,
    additional_billet_seed.billet_title,
    additional_billet_seed.normalized_billet_title,
    additional_billet_seed.grade_code,
    additional_billet_seed.rank_group,
    additional_billet_seed.branch_code,
    additional_billet_seed.mos_code,
    additional_billet_seed.aoc_code,
    additional_billet_seed.component,
    additional_billet_seed.uic,
    additional_billet_seed.paragraph_number,
    additional_billet_seed.line_number,
    additional_billet_seed.duty_location,
    additional_billet_seed.state_code
FROM additional_billet_seed
INNER JOIN organizations
    ON organizations.organization_name = additional_billet_seed.organization_name
INNER JOIN sections
    ON sections.organization_id = organizations.organization_id
   AND sections.display_name = additional_billet_seed.section_display_name;

COMMIT;
