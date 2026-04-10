-- Seed people
INSERT INTO people (person_id, display_name, normalized_display_name, rank, work_email, work_phone, office_symbol)
VALUES
-- XVIII ABN Corps G-6 staff
(1,  'Johnson, Michael R.',  'johnson michael r',  'COL', 'michael.r.johnson.mil@army.mil', '910-555-0101', 'AFNC-G6'),
(2,  'Williams, Sarah T.',   'williams sarah t',   'LTC', 'sarah.t.williams.mil@army.mil',  '910-555-0102', 'AFNC-G6'),
(3,  'Garcia, David M.',     'garcia david m',     'MAJ', 'david.m.garcia.mil@army.mil',    '910-555-0103', 'AFNC-G6'),
(4,  'Chen, Lisa K.',        'chen lisa k',        'CPT', 'lisa.k.chen.mil@army.mil',       '910-555-0104', 'AFNC-G6'),
(5,  'Brown, James A.',      'brown james a',      'MSG', 'james.a.brown.mil@army.mil',     '910-555-0105', 'AFNC-G6'),
-- XVIII ABN Corps G-3 staff
(6,  'Thompson, Mark E.',    'thompson mark e',    'COL', 'mark.e.thompson.mil@army.mil',   '910-555-0201', 'AFNC-G3'),
(7,  'Anderson, Kelly J.',   'anderson kelly j',   'LTC', 'kelly.j.anderson.mil@army.mil',  '910-555-0202', 'AFNC-G3'),
-- I Corps G-6 staff
(8,  'Taylor, Brian W.',     'taylor brian w',     'COL', 'brian.w.taylor.mil@army.mil',    '253-555-0401', 'AMCC-G6'),
-- I Corps G-3 staff
(9,  'Wilson, Patrick S.',   'wilson patrick s',   'COL', 'patrick.s.wilson.mil@army.mil',  '253-555-0301', 'AMCC-G3'),
-- NETCOM G-6 staff
(10, 'Harris, Nicole M.',    'harris nicole m',    'COL', 'nicole.m.harris.mil@army.mil',   '520-555-0501', 'NETC-G6');

-- Map people to billets.
-- Some billets are intentionally left without occupants to demonstrate
-- Vacant and Unknown statuses in section detail views.
--
-- Billet IDs reference 000005_seed_billets.sql.
-- Billets without a row here will show as Vacant or Unknown.
INSERT INTO billet_occupants (billet_id, person_id, is_primary, occupancy_status, source_system)
VALUES
-- XVIII ABN Corps G-6 (section_id = 4)
-- billet 1: G-6 Chief → filled
(1,  1,  TRUE, 'active', 'seed'),
-- billet 2: Deputy G-6 → filled
(2,  2,  TRUE, 'active', 'seed'),
-- billet 3: Chief, Network Operations → filled
(3,  3,  TRUE, 'active', 'seed'),
-- billet 4: Network Operations Officer → filled
(4,  4,  TRUE, 'active', 'seed'),
-- billet 5: Senior Network NCO → filled
(5,  5,  TRUE, 'active', 'seed'),
-- billet 6: Information Systems Analyst → VACANT (no occupant row)
-- billet 7: Signal Support Specialist → VACANT (no occupant row)
-- billet 8: Cybersecurity Analyst → VACANT (no occupant row)

-- XVIII ABN Corps G-3 (section_id = 3)
-- billet 9: G-3 Chief → filled
(9,  6,  TRUE, 'active', 'seed'),
-- billet 10: Deputy G-3 → filled
(10, 7,  TRUE, 'active', 'seed'),
-- billet 11: Current Ops Officer → VACANT (no occupant row)

-- I Corps G-6 (section_id = 8)
-- billet 12: G-6 Chief → filled
(12, 8,  TRUE, 'active', 'seed'),
-- billet 13: Deputy G-6 → VACANT (no occupant row)

-- I Corps G-3 (section_id = 7)
-- billet 14: G-3 Chief → filled
(14, 9,  TRUE, 'active', 'seed'),
-- billet 15: Deputy G-3 → VACANT (no occupant row)

-- NETCOM G-6 (section_id = 10)
-- billet 16: G-6 Chief → filled
(16, 10, TRUE, 'active', 'seed');
-- billet 17: Cybersecurity Chief → VACANT (no occupant row)