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
    ('1000000005', 'Brooks, Jonathan P.', 'brooksjonathanp', 'COL', 'jonathan.p.brooks.mil@army.mil', '910-555-0201', 'AFNC-G3'),
    ('1000000006', 'Reed, Melissa K.', 'reedmelissak', 'LTC', 'melissa.k.reed.mil@army.mil', '910-555-0202', 'AFNC-G3'),
    ('1000000007', 'Ellis, Marcus D.', 'ellismarcusd', 'SGM', 'marcus.d.ellis.mil@army.mil', '910-555-0203', 'AFNC-G3'),
    ('1000000008', 'Diaz, Elena V.', 'diazelenav', 'COL', 'elena.v.diaz.mil@army.mil', '910-555-0301', 'AAAB-G3'),
    ('1000000009', 'Coleman, Peter J.', 'colemanpeterj', 'MAJ', 'peter.j.coleman.mil@army.mil', '910-555-0302', 'AAAB-G3'),
    ('1000000010', 'Hayes, Robert N.', 'hayesrobertn', 'COL', 'robert.n.hayes.mil@army.mil', '910-555-0401', 'AAAB-G6'),
    ('1000000011', 'Simmons, Lauren E.', 'simmonslaurene', 'MAJ', 'lauren.e.simmons.mil@army.mil', '910-555-0402', 'AAAB-G6'),
    ('1000000012', 'Ross, Andrew T.', 'rossandrewt', 'MSG', 'andrew.t.ross.mil@army.mil', '910-555-0403', 'AAAB-G6'),
    ('1000000013', 'Foster, Daniel R.', 'fosterdanielr', 'COL', 'daniel.r.foster.mil@army.mil', '270-555-0501', 'AKAA-G3'),
    ('1000000014', 'Morgan, Claire S.', 'morganclaires', 'LTC', 'claire.s.morgan.mil@army.mil', '270-555-0502', 'AKAA-G3'),
    ('1000000015', 'Bennett, Steven M.', 'bennettstevenm', 'MSG', 'steven.m.bennett.mil@army.mil', '270-555-0503', 'AKAA-G3'),
    ('1000000016', 'Taylor, Brian W.', 'taylorbrianw', 'COL', 'brian.w.taylor.mil@army.mil', '253-555-0601', 'AMCC-G6'),
    ('1000000017', 'Martinez, Sofia R.', 'martinezsofiar', 'SFC', 'sofia.r.martinez.mil@army.mil', '253-555-0602', 'AMCC-G6'),
    ('1000000018', 'Carter, Olivia J.', 'carteroliviaj', 'COL', 'olivia.j.carter.mil@army.mil', '254-555-0701', 'PHCC-G4'),
    ('1000000019', 'Nguyen, Patrick H.', 'nguyenpatrickh', 'LTC', 'patrick.h.nguyen.mil@army.mil', '254-555-0702', 'PHCC-G4'),
    ('1000000020', 'Owens, Rachel B.', 'owensrachelb', 'MAJ', 'rachel.b.owens.mil@army.mil', '254-555-0703', 'PHCC-G4'),
    ('1000000021', 'Harris, Nicole M.', 'harrisnicolem', 'COL', 'nicole.m.harris.mil@army.mil', '520-555-0801', 'NETC-G6'),
    ('1000000022', 'Patel, Ryan J.', 'patelryanj', 'LTC', 'ryan.j.patel.mil@army.mil', '520-555-0802', 'NETC-G6'),
    ('1000000023', 'Vasquez, Miguel A.', 'vasquezmiguela', 'COL', 'miguel.a.vasquez.mil@army.mil', '520-555-0901', 'NETC-CY'),
    ('1000000024', 'Shah, Priya N.', 'shahpriyan', 'MAJ', 'priya.n.shah.mil@army.mil', '520-555-0902', 'NETC-CY'),
    ('1000000025', 'Keller, Thomas E.', 'kellerthomase', 'COL', 'thomas.e.keller.mil@army.mil', '703-555-1001', 'NGB-G3'),
    ('1000000026', 'Ward, Allison M.', 'wardallisonm', 'LTC', 'allison.m.ward.mil@army.mil', '703-555-1002', 'NGB-G3'),
    ('1000000027', 'Price, Devon L.', 'pricedevonl', 'COL', 'devon.l.price.mil@army.mil', '717-555-1101', 'PARNG-G3'),
    ('1000000028', 'Holt, Aaron C.', 'holtaaronc', 'MSG', 'aaron.c.holt.mil@army.mil', '717-555-1102', 'PARNG-G3'),
    ('1000000029', 'James, Victor S.', 'jamesvictors', 'COL', 'victor.s.james.mil@army.mil', '504-555-1201', 'TSC-G4'),
    ('1000000030', 'Long, Natalie P.', 'longnataliep', 'LTC', 'natalie.p.long.mil@army.mil', '504-555-1202', 'TSC-G4'),
    ('1000000031', 'Griffin, Omar D.', 'griffinomard', 'MSG', 'omar.d.griffin.mil@army.mil', '504-555-1203', 'TSC-G4'),
    ('1000000032', 'Davis, Hannah Q.', 'davishannahq', 'MAJ', 'hannah.q.davis.mil@army.mil', '504-555-1204', 'TSC-G4'),
    ('1000000033', 'Turner, James L.', 'turnerjamesl', 'CW3', 'james.l.turner.mil@army.mil', '520-555-9992', 'NETC-NOSC'),
    ('1000000034', 'Lopez, Karen B.', 'lopezkarenb', 'SFC', 'karen.b.lopez.mil@army.mil', '910-555-9993', 'AFNC-HHC'),
    ('1000000035', 'Murphy, Sean T.', 'murphyseant', 'MAJ', 'sean.t.murphy.mil@army.mil', '703-555-9994', 'NGB-J5');

WITH billet_status_seed AS (
    SELECT *
    FROM (
        VALUES
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P001', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P002', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P003', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P004', 'vacant'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-6', 'P005', 'unknown'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P001', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P002', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P003', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P004', 'filled'),
            ('82nd Airborne Division', '82nd Airborne Division G-3', 'P001', 'filled'),
            ('82nd Airborne Division', '82nd Airborne Division G-3', 'P002', 'filled'),
            ('82nd Airborne Division', '82nd Airborne Division G-3', 'P003', 'vacant'),
            ('82nd Airborne Division', '82nd Airborne Division G-3', 'P004', 'unknown'),
            ('82nd Airborne Division', '82nd Airborne Division G-6', 'P001', 'filled'),
            ('82nd Airborne Division', '82nd Airborne Division G-6', 'P002', 'filled'),
            ('82nd Airborne Division', '82nd Airborne Division G-6', 'P003', 'filled'),
            ('82nd Airborne Division', '82nd Airborne Division G-6', 'P004', 'vacant'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-3', 'P001', 'filled'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-3', 'P002', 'filled'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-3', 'P003', 'unknown'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-3', 'P004', 'filled'),
            ('I Corps', 'I Corps G-6', 'P001', 'filled'),
            ('I Corps', 'I Corps G-6', 'P002', 'vacant'),
            ('I Corps', 'I Corps G-6', 'P003', 'unknown'),
            ('I Corps', 'I Corps G-6', 'P004', 'filled'),
            ('III Armored Corps', 'III Armored Corps G-4', 'P001', 'filled'),
            ('III Armored Corps', 'III Armored Corps G-4', 'P002', 'filled'),
            ('III Armored Corps', 'III Armored Corps G-4', 'P003', 'filled'),
            ('III Armored Corps', 'III Armored Corps G-4', 'P004', 'vacant'),
            ('NETCOM', 'NETCOM G-6', 'P001', 'filled'),
            ('NETCOM', 'NETCOM G-6', 'P002', 'filled'),
            ('NETCOM', 'NETCOM G-6', 'P003', 'vacant'),
            ('NETCOM', 'NETCOM G-6', 'P004', 'unknown'),
            ('NETCOM', 'NETCOM Cyber', 'P001', 'filled'),
            ('NETCOM', 'NETCOM Cyber', 'P002', 'filled'),
            ('NETCOM', 'NETCOM Cyber', 'P003', 'unknown'),
            ('NETCOM', 'NETCOM Cyber', 'P004', 'vacant'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-3', 'P001', 'filled'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-3', 'P002', 'filled'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-3', 'P003', 'vacant'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-3', 'P004', 'unknown'),
            ('28th Infantry Division', '28th Infantry Division G-3', 'P001', 'filled'),
            ('28th Infantry Division', '28th Infantry Division G-3', 'P002', 'vacant'),
            ('28th Infantry Division', '28th Infantry Division G-3', 'P003', 'filled'),
            ('28th Infantry Division', '28th Infantry Division G-3', 'P004', 'unknown'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P001', 'filled'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P002', 'filled'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P003', 'filled'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P004', 'vacant')
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
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P001', 'Brooks, Jonathan P.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P002', 'Reed, Melissa K.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P003', 'Chen, Avery L.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-3', 'P004', 'Ellis, Marcus D.', TRUE),
            ('82nd Airborne Division', '82nd Airborne Division G-3', 'P001', 'Diaz, Elena V.', TRUE),
            ('82nd Airborne Division', '82nd Airborne Division G-3', 'P002', 'Coleman, Peter J.', TRUE),
            ('82nd Airborne Division', '82nd Airborne Division G-6', 'P001', 'Hayes, Robert N.', TRUE),
            ('82nd Airborne Division', '82nd Airborne Division G-6', 'P002', 'Simmons, Lauren E.', TRUE),
            ('82nd Airborne Division', '82nd Airborne Division G-6', 'P003', 'Ross, Andrew T.', TRUE),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-3', 'P001', 'Foster, Daniel R.', TRUE),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-3', 'P002', 'Morgan, Claire S.', TRUE),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-3', 'P004', 'Bennett, Steven M.', TRUE),
            ('I Corps', 'I Corps G-6', 'P001', 'Taylor, Brian W.', TRUE),
            ('I Corps', 'I Corps G-6', 'P004', 'Martinez, Sofia R.', TRUE),
            ('III Armored Corps', 'III Armored Corps G-4', 'P001', 'Carter, Olivia J.', TRUE),
            ('III Armored Corps', 'III Armored Corps G-4', 'P002', 'Nguyen, Patrick H.', TRUE),
            ('III Armored Corps', 'III Armored Corps G-4', 'P003', 'Owens, Rachel B.', TRUE),
            ('NETCOM', 'NETCOM G-6', 'P001', 'Harris, Nicole M.', TRUE),
            ('NETCOM', 'NETCOM G-6', 'P002', 'Patel, Ryan J.', TRUE),
            ('NETCOM', 'NETCOM Cyber', 'P001', 'Vasquez, Miguel A.', TRUE),
            ('NETCOM', 'NETCOM Cyber', 'P002', 'Shah, Priya N.', TRUE),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-3', 'P001', 'Keller, Thomas E.', TRUE),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-3', 'P002', 'Ward, Allison M.', TRUE),
            ('28th Infantry Division', '28th Infantry Division G-3', 'P001', 'Price, Devon L.', TRUE),
            ('28th Infantry Division', '28th Infantry Division G-3', 'P003', 'Holt, Aaron C.', TRUE),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P001', 'James, Victor S.', TRUE),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P002', 'Long, Natalie P.', TRUE),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P003', 'Griffin, Omar D.', TRUE),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-4', 'P002', 'Davis, Hannah Q.', FALSE)
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
