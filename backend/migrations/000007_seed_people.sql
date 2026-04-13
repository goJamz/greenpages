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

-- ---------------------------------------------------------------------------
-- Additional people
-- ---------------------------------------------------------------------------
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
    -- XVIII ABN Corps G-1, G-2, G-4
    ('1000000036', 'Mitchell, Angela R.', 'mitchellangelar', 'COL', 'angela.r.mitchell.mil@army.mil', '910-555-1301', 'AFNC-G1'),
    ('1000000037', 'Rivera, Carlos J.', 'riveracarlosj', 'LTC', 'carlos.j.rivera.mil@army.mil', '910-555-1302', 'AFNC-G1'),
    ('1000000038', 'Thornton, Denise K.', 'thorntondenisek', 'MAJ', 'denise.k.thornton.mil@army.mil', '910-555-1303', 'AFNC-G1'),
    ('1000000039', 'Barnett, Wayne L.', 'barnettwaynel', 'COL', 'wayne.l.barnett.mil@army.mil', '910-555-1401', 'AFNC-G2'),
    ('1000000040', 'Fitzgerald, Maria C.', 'fitzgeraldmariac', 'LTC', 'maria.c.fitzgerald.mil@army.mil', '910-555-1402', 'AFNC-G2'),
    ('1000000041', 'Douglas, Kevin P.', 'douglaskevinp', 'MAJ', 'kevin.p.douglas.mil@army.mil', '910-555-1403', 'AFNC-G2'),
    ('1000000042', 'Stone, Patricia M.', 'stonepatriciam', 'COL', 'patricia.m.stone.mil@army.mil', '910-555-1501', 'AFNC-G4'),
    ('1000000043', 'Cunningham, Robert E.', 'cunninghamroberte', 'LTC', 'robert.e.cunningham.mil@army.mil', '910-555-1502', 'AFNC-G4'),
    ('1000000044', 'Powers, Lisa D.', 'powerslesad', 'MSG', 'lisa.d.powers.mil@army.mil', '910-555-1503', 'AFNC-G4'),
    -- 82nd ABN G-1, G-2, G-4
    ('1000000045', 'Malone, Derek A.', 'malonedereka', 'LTC', 'derek.a.malone.mil@army.mil', '910-555-1601', 'AAAB-G1'),
    ('1000000046', 'Reeves, Christina L.', 'reeveschristinal', 'MAJ', 'christina.l.reeves.mil@army.mil', '910-555-1602', 'AAAB-G1'),
    ('1000000047', 'Hoffman, Bradley T.', 'hoffmanbradleyt', 'LTC', 'bradley.t.hoffman.mil@army.mil', '910-555-1701', 'AAAB-G2'),
    ('1000000048', 'Santiago, Diana M.', 'santiagodianaem', 'LTC', 'diana.m.santiago.mil@army.mil', '910-555-1801', 'AAAB-G4'),
    -- 101st ABN G-6
    ('1000000049', 'Walsh, Timothy R.', 'walshtimothyr', 'COL', 'timothy.r.walsh.mil@army.mil', '270-555-1901', 'AKAA-G6'),
    ('1000000050', 'Palmer, Stephanie J.', 'palmerstephaniej', 'LTC', 'stephanie.j.palmer.mil@army.mil', '270-555-1902', 'AKAA-G6'),
    ('1000000051', 'Hicks, Ronald G.', 'hicksronaldg', 'MSG', 'ronald.g.hicks.mil@army.mil', '270-555-1903', 'AKAA-G6'),
    -- 10th MTN G-3, G-6
    ('1000000052', 'Weaver, Kenneth J.', 'weaverkennethj', 'COL', 'kenneth.j.weaver.mil@army.mil', '315-555-2001', 'WDMT-G3'),
    ('1000000053', 'Flores, Sandra E.', 'floressandrae', 'MAJ', 'sandra.e.flores.mil@army.mil', '315-555-2002', 'WDMT-G3'),
    ('1000000054', 'Grant, William H.', 'grantwilliamh', 'MSG', 'william.h.grant.mil@army.mil', '315-555-2003', 'WDMT-G3'),
    ('1000000055', 'Moreno, Teresa C.', 'morenoteresac', 'LTC', 'teresa.c.moreno.mil@army.mil', '315-555-2101', 'WDMT-G6'),
    ('1000000056', 'Webb, Joshua K.', 'webbjoshuak', 'CPT', 'joshua.k.webb.mil@army.mil', '315-555-2102', 'WDMT-G6'),
    -- I Corps G-3
    ('1000000057', 'Fuller, Craig A.', 'fullercraiga', 'COL', 'craig.a.fuller.mil@army.mil', '253-555-2201', 'AMCC-G3'),
    ('1000000058', 'Hunt, Rebecca L.', 'huntrebeccal', 'LTC', 'rebecca.l.hunt.mil@army.mil', '253-555-2202', 'AMCC-G3'),
    ('1000000059', 'Mendoza, Gabriel R.', 'mendozagabrielr', 'MAJ', 'gabriel.r.mendoza.mil@army.mil', '253-555-2203', 'AMCC-G3'),
    -- 7th ID G-3, G-6
    ('1000000060', 'Knox, Amanda S.', 'knoxamandas', 'LTC', 'amanda.s.knox.mil@army.mil', '253-555-2301', '7ID-G3'),
    ('1000000061', 'Boyd, Nathan W.', 'boydnathanw', 'MAJ', 'nathan.w.boyd.mil@army.mil', '253-555-2302', '7ID-G3'),
    ('1000000062', 'Dunn, Kelly M.', 'dunnkellym', 'LTC', 'kelly.m.dunn.mil@army.mil', '253-555-2401', '7ID-G6'),
    ('1000000063', 'Lawson, Erik J.', 'lawsonerikj', 'SFC', 'erik.j.lawson.mil@army.mil', '253-555-2402', '7ID-G6'),
    -- III AC G-3, G-6
    ('1000000064', 'Payne, Donald R.', 'paynedonaldr', 'COL', 'donald.r.payne.mil@army.mil', '254-555-2501', 'PHCC-G3'),
    ('1000000065', 'Estrada, Monica V.', 'estradamonicav', 'LTC', 'monica.v.estrada.mil@army.mil', '254-555-2502', 'PHCC-G3'),
    ('1000000066', 'Chapman, Leslie A.', 'chapmanlsliea', 'COL', 'leslie.a.chapman.mil@army.mil', '254-555-2601', 'PHCC-G6'),
    ('1000000067', 'Barker, Jason T.', 'barkerjasont', 'LTC', 'jason.t.barker.mil@army.mil', '254-555-2602', 'PHCC-G6'),
    ('1000000068', 'Cross, Vanessa N.', 'crossvannessan', 'MAJ', 'vanessa.n.cross.mil@army.mil', '254-555-2603', 'PHCC-G6'),
    -- 1st CAV G-3, G-6
    ('1000000069', 'Maxwell, George B.', 'maxwellgeorgeb', 'COL', 'george.b.maxwell.mil@army.mil', '254-555-2701', '1CAV-G3'),
    ('1000000070', 'Herrera, Paul D.', 'herrerapauld', 'MAJ', 'paul.d.herrera.mil@army.mil', '254-555-2702', '1CAV-G3'),
    ('1000000071', 'Duncan, Amy R.', 'duncanamyr', 'LTC', 'amy.r.duncan.mil@army.mil', '254-555-2801', '1CAV-G6'),
    -- NETCOM G-3
    ('1000000072', 'Cortez, Ruben M.', 'cortezrubenm', 'COL', 'ruben.m.cortez.mil@army.mil', '520-555-2901', 'NETC-G3'),
    ('1000000073', 'Wolf, Sandra K.', 'wolfsandrak', 'MAJ', 'sandra.k.wolf.mil@army.mil', '520-555-2902', 'NETC-G3'),
    -- ARNG RC G-6
    ('1000000074', 'Barton, Jeffrey L.', 'bartonjeffreyl', 'COL', 'jeffrey.l.barton.mil@army.mil', '703-555-3001', 'NGB-G6'),
    ('1000000075', 'Chandler, Michelle P.', 'chandlermichellep', 'LTC', 'michelle.p.chandler.mil@army.mil', '703-555-3002', 'NGB-G6'),
    -- 28th ID G-6
    ('1000000076', 'Holland, Scott R.', 'hollandscottr', 'LTC', 'scott.r.holland.mil@army.mil', '717-555-3101', 'PARNG-G6'),
    -- 377th TSC G-3
    ('1000000077', 'Copeland, Marcus A.', 'copelandmarcusa', 'COL', 'marcus.a.copeland.mil@army.mil', '504-555-3201', 'TSC-G3'),
    ('1000000078', 'Jennings, Tara L.', 'jenningstaral', 'MAJ', 'tara.l.jennings.mil@army.mil', '504-555-3202', 'TSC-G3'),
    -- 3rd ID G-3, G-6
    ('1000000079', 'Ramsey, Andrew C.', 'ramseyandrewc', 'COL', 'andrew.c.ramsey.mil@army.mil', '912-555-4001', '3ID-G3'),
    ('1000000080', 'Bishop, Karen E.', 'bishopkarene', 'LTC', 'karen.e.bishop.mil@army.mil', '912-555-4002', '3ID-G3'),
    ('1000000081', 'Sutton, Frank J.', 'suttonfrankj', 'MAJ', 'frank.j.sutton.mil@army.mil', '912-555-4003', '3ID-G3'),
    ('1000000082', 'Whitfield, Donna T.', 'whitfielddonnat', 'COL', 'donna.t.whitfield.mil@army.mil', '912-555-4101', '3ID-G6'),
    ('1000000083', 'Erickson, Todd M.', 'ericksontoddm', 'MAJ', 'todd.m.erickson.mil@army.mil', '912-555-4102', '3ID-G6'),
    ('1000000084', 'Guerrero, Luis R.', 'guerreroluisr', 'MSG', 'luis.r.guerrero.mil@army.mil', '912-555-4103', '3ID-G6'),
    -- 4th ID G-3, G-6
    ('1000000085', 'Norton, Richard H.', 'nortonrichardh', 'COL', 'richard.h.norton.mil@army.mil', '719-555-4201', '4ID-G3'),
    ('1000000086', 'Torres, Jessica A.', 'torresjessicaa', 'LTC', 'jessica.a.torres.mil@army.mil', '719-555-4202', '4ID-G3'),
    ('1000000087', 'Harmon, Brenda L.', 'harmonbrendal', 'MAJ', 'brenda.l.harmon.mil@army.mil', '719-555-4203', '4ID-G3'),
    ('1000000088', 'Gill, Trevor K.', 'gilltrevork', 'LTC', 'trevor.k.gill.mil@army.mil', '719-555-4301', '4ID-G6'),
    ('1000000089', 'Snow, Diane P.', 'snowdianep', 'MAJ', 'diane.p.snow.mil@army.mil', '719-555-4302', '4ID-G6'),
    -- 25th ID G-3, G-6
    ('1000000090', 'Mack, Calvin D.', 'mackcalvind', 'COL', 'calvin.d.mack.mil@army.mil', '808-555-4401', '25ID-G3'),
    ('1000000091', 'Valencia, Rosa M.', 'valenciarosam', 'MAJ', 'rosa.m.valencia.mil@army.mil', '808-555-4402', '25ID-G3'),
    ('1000000092', 'Petersen, Lori K.', 'petersenlorik', 'LTC', 'lori.k.petersen.mil@army.mil', '808-555-4501', '25ID-G6'),
    ('1000000093', 'Chung, Dennis W.', 'chungdennisw', 'SFC', 'dennis.w.chung.mil@army.mil', '808-555-4502', '25ID-G6'),
    -- 1st AD G-3, G-4
    ('1000000094', 'Graham, Nancy J.', 'grahamnancyj', 'COL', 'nancy.j.graham.mil@army.mil', '915-555-4601', '1AD-G3'),
    ('1000000095', 'Ingram, Randy B.', 'ingramrandyb', 'LTC', 'randy.b.ingram.mil@army.mil', '915-555-4602', '1AD-G3'),
    ('1000000096', 'Barrett, Katherine M.', 'barrettkatherinem', 'MAJ', 'katherine.m.barrett.mil@army.mil', '915-555-4603', '1AD-G3'),
    ('1000000097', 'Mcclure, Oscar H.', 'mcclureoscarh', 'LTC', 'oscar.h.mcclure.mil@army.mil', '915-555-4701', '1AD-G4'),
    ('1000000098', 'Shelton, Joyce A.', 'sheltonjoycea', 'MAJ', 'joyce.a.shelton.mil@army.mil', '915-555-4702', '1AD-G4'),
    -- V Corps G-3, G-6
    ('1000000099', 'Hawkins, Lawrence T.', 'hawkinslawrencet', 'COL', 'lawrence.t.hawkins.mil@army.mil', '502-555-4801', 'VCPS-G3'),
    ('1000000100', 'Byrd, Cynthia R.', 'byrdcynthiar', 'LTC', 'cynthia.r.byrd.mil@army.mil', '502-555-4802', 'VCPS-G3'),
    ('1000000101', 'Walters, Eugene M.', 'walterseugenem', 'MAJ', 'eugene.m.walters.mil@army.mil', '502-555-4803', 'VCPS-G3'),
    ('1000000102', 'Howell, Deborah S.', 'howelldeborahs', 'COL', 'deborah.s.howell.mil@army.mil', '502-555-4901', 'VCPS-G6'),
    ('1000000103', 'Pratt, Allen K.', 'prattallenk', 'LTC', 'allen.k.pratt.mil@army.mil', '502-555-4902', 'VCPS-G6'),
    ('1000000104', 'Goodman, Rita D.', 'goodmanritad', 'MAJ', 'rita.d.goodman.mil@army.mil', '502-555-4903', 'VCPS-G6'),
    -- ARCYBER G-3, G-6
    ('1000000105', 'Frost, Daryl J.', 'frostdarylj', 'COL', 'daryl.j.frost.mil@army.mil', '706-555-5001', 'CYCOM-G3'),
    ('1000000106', 'Ayers, Christine T.', 'ayerschristinet', 'LTC', 'christine.t.ayers.mil@army.mil', '706-555-5002', 'CYCOM-G3'),
    ('1000000107', 'Booth, Raymond A.', 'boothraymonda', 'COL', 'raymond.a.booth.mil@army.mil', '706-555-5101', 'CYCOM-G6'),
    ('1000000108', 'Lowe, Janet P.', 'lowejaantp', 'LTC', 'janet.p.lowe.mil@army.mil', '706-555-5102', 'CYCOM-G6'),
    ('1000000109', 'Stokes, Kenneth D.', 'stokeskennethd', 'MSG', 'kenneth.d.stokes.mil@army.mil', '706-555-5103', 'CYCOM-G6'),
    -- INSCOM G-2, G-6
    ('1000000110', 'Blair, Catherine V.', 'blaircathernev', 'COL', 'catherine.v.blair.mil@army.mil', '703-555-5201', 'INSC-G2'),
    ('1000000111', 'Yoder, Franklin W.', 'yoderfranklinw', 'LTC', 'franklin.w.yoder.mil@army.mil', '703-555-5202', 'INSC-G2'),
    ('1000000112', 'Mathis, Gloria E.', 'mathisgloriae', 'MAJ', 'gloria.e.mathis.mil@army.mil', '703-555-5203', 'INSC-G2'),
    ('1000000113', 'Stark, Wesley J.', 'starkwesleyj', 'COL', 'wesley.j.stark.mil@army.mil', '703-555-5301', 'INSC-G6'),
    ('1000000114', 'Floyd, Norma R.', 'floydnormar', 'MAJ', 'norma.r.floyd.mil@army.mil', '703-555-5302', 'INSC-G6'),
    -- USARPAC G-3, G-6
    ('1000000115', 'Shepherd, Earl M.', 'shepherdearlm', 'COL', 'earl.m.shepherd.mil@army.mil', '808-555-5401', 'USAP-G3'),
    ('1000000116', 'Kane, Victoria L.', 'kanevictorial', 'LTC', 'victoria.l.kane.mil@army.mil', '808-555-5402', 'USAP-G3'),
    ('1000000117', 'Lambert, Bruce H.', 'lambertbruceh', 'COL', 'bruce.h.lambert.mil@army.mil', '808-555-5501', 'USAP-G6'),
    ('1000000118', 'Buchanan, Alice D.', 'buchananaliced', 'MAJ', 'alice.d.buchanan.mil@army.mil', '808-555-5502', 'USAP-G6'),
    -- 36th ID G-3
    ('1000000119', 'Garza, Roberto A.', 'garzarobertoa', 'COL', 'roberto.a.garza.mil@army.mil', '512-555-5601', '36ID-G3'),
    ('1000000120', 'Padilla, Martha C.', 'padillamarthac', 'LTC', 'martha.c.padilla.mil@army.mil', '512-555-5602', '36ID-G3'),
    ('1000000121', 'Vega, Hector L.', 'vegahectorl', 'MSG', 'hector.l.vega.mil@army.mil', '512-555-5603', '36ID-G3'),
    -- 29th ID G-3
    ('1000000122', 'Conrad, Mark T.', 'conradmarkt', 'COL', 'mark.t.conrad.mil@army.mil', '703-555-5701', '29ID-G3'),
    ('1000000123', 'Hubbard, Tammy S.', 'hubbardtammys', 'MAJ', 'tammy.s.hubbard.mil@army.mil', '703-555-5702', '29ID-G3'),
    -- 42nd ID G-3
    ('1000000124', 'Russo, Anthony G.', 'russoanthonyg', 'COL', 'anthony.g.russo.mil@army.mil', '518-555-5801', '42ID-G3'),
    ('1000000125', 'Brennan, Colleen M.', 'brennancolleenm', 'MAJ', 'colleen.m.brennan.mil@army.mil', '518-555-5802', '42ID-G3'),
    -- 34th ID G-3
    ('1000000126', 'Olson, Erik P.', 'olsonerikp', 'COL', 'erik.p.olson.mil@army.mil', '651-555-5901', '34ID-G3'),
    ('1000000127', 'Lindgren, Karen A.', 'lindgrenkarena', 'MAJ', 'karen.a.lindgren.mil@army.mil', '651-555-5902', '34ID-G3'),
    -- 335th SC G-6
    ('1000000128', 'Whitaker, Dale F.', 'whitakerdalef', 'COL', 'dale.f.whitaker.mil@army.mil', '404-555-6001', '335SC-G6'),
    ('1000000129', 'Pope, Janice T.', 'popejanicet', 'LTC', 'janice.t.pope.mil@army.mil', '404-555-6002', '335SC-G6'),
    ('1000000130', 'Horton, Cedric W.', 'hortoncedricw', 'MSG', 'cedric.w.horton.mil@army.mil', '404-555-6003', '335SC-G6'),
    -- 807th MC G-1
    ('1000000131', 'Cash, Harold B.', 'cashharoldb', 'LTC', 'harold.b.cash.mil@army.mil', '972-555-6101', '807MC-G1'),
    ('1000000132', 'Underwood, Sylvia E.', 'underwoodsylviae', 'MAJ', 'sylvia.e.underwood.mil@army.mil', '972-555-6102', '807MC-G1'),
    -- 63rd RD G-4
    ('1000000133', 'Novak, Stephen R.', 'novakstephenr', 'LTC', 'stephen.r.novak.mil@army.mil', '650-555-6201', '63RD-G4'),
    ('1000000134', 'Roth, Angela M.', 'rothangelam', 'MAJ', 'angela.m.roth.mil@army.mil', '650-555-6202', '63RD-G4'),
    -- 416th TEC G-3
    ('1000000135', 'Quinn, Patrick F.', 'quinnpatrickf', 'COL', 'patrick.f.quinn.mil@army.mil', '630-555-6301', '416TE-G3'),
    ('1000000136', 'Bauer, Linda S.', 'bauerlindas', 'MAJ', 'linda.s.bauer.mil@army.mil', '630-555-6302', '416TE-G3'),
    -- Multi-assignment test people (assigned to billets across sections)
    ('1000000137', 'Salazar, Marco R.', 'salazarmarcoar', 'MSG', 'marco.r.salazar.mil@army.mil', '912-555-9001', '3ID-G3'),
    ('1000000138', 'Clay, Danielle T.', 'claydaniellet', 'SFC', 'danielle.t.clay.mil@army.mil', '706-555-9002', 'CYCOM-G6'),
    ('1000000139', 'Krueger, Hans M.', 'kruegerhansm', 'SGM', 'hans.m.krueger.mil@army.mil', '502-555-9003', 'VCPS-G3'),
    ('1000000140', 'Tran, Kim N.', 'trankimn', 'SFC', 'kim.n.tran.mil@army.mil', '808-555-9004', '25ID-G6');

-- ---------------------------------------------------------------------------
-- Billet status updates (original)
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- Additional billet status updates
-- ---------------------------------------------------------------------------
WITH additional_status_seed AS (
    SELECT *
    FROM (
        VALUES
            -- XVIII ABN G-1
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-1', 'P001', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-1', 'P002', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-1', 'P003', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-1', 'P004', 'vacant'),
            -- XVIII ABN G-2
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-2', 'P001', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-2', 'P002', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-2', 'P003', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-2', 'P004', 'unknown'),
            -- XVIII ABN G-4
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-4', 'P001', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-4', 'P002', 'filled'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-4', 'P003', 'vacant'),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-4', 'P004', 'filled'),
            -- 82nd ABN G-1
            ('82nd Airborne Division', '82nd Airborne Division G-1', 'P001', 'filled'),
            ('82nd Airborne Division', '82nd Airborne Division G-1', 'P002', 'filled'),
            ('82nd Airborne Division', '82nd Airborne Division G-1', 'P003', 'vacant'),
            -- 82nd ABN G-2
            ('82nd Airborne Division', '82nd Airborne Division G-2', 'P001', 'filled'),
            ('82nd Airborne Division', '82nd Airborne Division G-2', 'P002', 'unknown'),
            ('82nd Airborne Division', '82nd Airborne Division G-2', 'P003', 'vacant'),
            -- 82nd ABN G-4
            ('82nd Airborne Division', '82nd Airborne Division G-4', 'P001', 'filled'),
            ('82nd Airborne Division', '82nd Airborne Division G-4', 'P002', 'vacant'),
            ('82nd Airborne Division', '82nd Airborne Division G-4', 'P003', 'unknown'),
            -- 101st ABN G-6
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-6', 'P001', 'filled'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-6', 'P002', 'filled'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-6', 'P003', 'filled'),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-6', 'P004', 'vacant'),
            -- 10th MTN G-3
            ('10th Mountain Division', '10th Mountain Division G-3', 'P001', 'filled'),
            ('10th Mountain Division', '10th Mountain Division G-3', 'P002', 'filled'),
            ('10th Mountain Division', '10th Mountain Division G-3', 'P003', 'unknown'),
            ('10th Mountain Division', '10th Mountain Division G-3', 'P004', 'filled'),
            -- 10th MTN G-6
            ('10th Mountain Division', '10th Mountain Division G-6', 'P001', 'filled'),
            ('10th Mountain Division', '10th Mountain Division G-6', 'P002', 'filled'),
            ('10th Mountain Division', '10th Mountain Division G-6', 'P003', 'vacant'),
            -- I Corps G-3
            ('I Corps', 'I Corps G-3', 'P001', 'filled'),
            ('I Corps', 'I Corps G-3', 'P002', 'filled'),
            ('I Corps', 'I Corps G-3', 'P003', 'filled'),
            ('I Corps', 'I Corps G-3', 'P004', 'filled'),
            -- 7th ID G-3
            ('7th Infantry Division', '7th Infantry Division G-3', 'P001', 'filled'),
            ('7th Infantry Division', '7th Infantry Division G-3', 'P002', 'filled'),
            ('7th Infantry Division', '7th Infantry Division G-3', 'P003', 'vacant'),
            -- 7th ID G-6
            ('7th Infantry Division', '7th Infantry Division G-6', 'P001', 'filled'),
            ('7th Infantry Division', '7th Infantry Division G-6', 'P002', 'filled'),
            ('7th Infantry Division', '7th Infantry Division G-6', 'P003', 'unknown'),
            -- III AC G-3
            ('III Armored Corps', 'III Armored Corps G-3', 'P001', 'filled'),
            ('III Armored Corps', 'III Armored Corps G-3', 'P002', 'filled'),
            ('III Armored Corps', 'III Armored Corps G-3', 'P003', 'vacant'),
            ('III Armored Corps', 'III Armored Corps G-3', 'P004', 'unknown'),
            -- III AC G-6
            ('III Armored Corps', 'III Armored Corps G-6', 'P001', 'filled'),
            ('III Armored Corps', 'III Armored Corps G-6', 'P002', 'filled'),
            ('III Armored Corps', 'III Armored Corps G-6', 'P003', 'filled'),
            ('III Armored Corps', 'III Armored Corps G-6', 'P004', 'vacant'),
            -- 1st CAV G-3
            ('1st Cavalry Division', '1st Cavalry Division G-3', 'P001', 'filled'),
            ('1st Cavalry Division', '1st Cavalry Division G-3', 'P002', 'filled'),
            ('1st Cavalry Division', '1st Cavalry Division G-3', 'P003', 'vacant'),
            ('1st Cavalry Division', '1st Cavalry Division G-3', 'P004', 'unknown'),
            -- 1st CAV G-6
            ('1st Cavalry Division', '1st Cavalry Division G-6', 'P001', 'filled'),
            ('1st Cavalry Division', '1st Cavalry Division G-6', 'P002', 'vacant'),
            ('1st Cavalry Division', '1st Cavalry Division G-6', 'P003', 'unknown'),
            -- NETCOM G-3
            ('NETCOM', 'NETCOM G-3', 'P001', 'filled'),
            ('NETCOM', 'NETCOM G-3', 'P002', 'filled'),
            ('NETCOM', 'NETCOM G-3', 'P003', 'vacant'),
            -- ARNG RC G-6
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-6', 'P001', 'filled'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-6', 'P002', 'filled'),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-6', 'P003', 'unknown'),
            -- 28th ID G-6
            ('28th Infantry Division', '28th Infantry Division G-6', 'P001', 'filled'),
            ('28th Infantry Division', '28th Infantry Division G-6', 'P002', 'vacant'),
            ('28th Infantry Division', '28th Infantry Division G-6', 'P003', 'unknown'),
            -- 377th TSC G-3
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-3', 'P001', 'filled'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-3', 'P002', 'filled'),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-3', 'P003', 'vacant'),
            -- 3rd ID G-3
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P001', 'filled'),
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P002', 'filled'),
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P003', 'filled'),
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P004', 'filled'),
            -- 3rd ID G-6
            ('3rd Infantry Division', '3rd Infantry Division G-6', 'P001', 'filled'),
            ('3rd Infantry Division', '3rd Infantry Division G-6', 'P002', 'filled'),
            ('3rd Infantry Division', '3rd Infantry Division G-6', 'P003', 'filled'),
            ('3rd Infantry Division', '3rd Infantry Division G-6', 'P004', 'vacant'),
            -- 4th ID G-3
            ('4th Infantry Division', '4th Infantry Division G-3', 'P001', 'filled'),
            ('4th Infantry Division', '4th Infantry Division G-3', 'P002', 'filled'),
            ('4th Infantry Division', '4th Infantry Division G-3', 'P003', 'filled'),
            ('4th Infantry Division', '4th Infantry Division G-3', 'P004', 'unknown'),
            -- 4th ID G-6
            ('4th Infantry Division', '4th Infantry Division G-6', 'P001', 'filled'),
            ('4th Infantry Division', '4th Infantry Division G-6', 'P002', 'filled'),
            ('4th Infantry Division', '4th Infantry Division G-6', 'P003', 'vacant'),
            ('4th Infantry Division', '4th Infantry Division G-6', 'P004', 'unknown'),
            -- 25th ID G-3
            ('25th Infantry Division', '25th Infantry Division G-3', 'P001', 'filled'),
            ('25th Infantry Division', '25th Infantry Division G-3', 'P002', 'filled'),
            ('25th Infantry Division', '25th Infantry Division G-3', 'P003', 'vacant'),
            ('25th Infantry Division', '25th Infantry Division G-3', 'P004', 'unknown'),
            -- 25th ID G-6
            ('25th Infantry Division', '25th Infantry Division G-6', 'P001', 'filled'),
            ('25th Infantry Division', '25th Infantry Division G-6', 'P002', 'filled'),
            ('25th Infantry Division', '25th Infantry Division G-6', 'P003', 'vacant'),
            -- 1st AD G-3
            ('1st Armored Division', '1st Armored Division G-3', 'P001', 'filled'),
            ('1st Armored Division', '1st Armored Division G-3', 'P002', 'filled'),
            ('1st Armored Division', '1st Armored Division G-3', 'P003', 'filled'),
            ('1st Armored Division', '1st Armored Division G-3', 'P004', 'vacant'),
            -- 1st AD G-4
            ('1st Armored Division', '1st Armored Division G-4', 'P001', 'filled'),
            ('1st Armored Division', '1st Armored Division G-4', 'P002', 'filled'),
            ('1st Armored Division', '1st Armored Division G-4', 'P003', 'unknown'),
            -- V Corps G-3
            ('V Corps', 'V Corps G-3', 'P001', 'filled'),
            ('V Corps', 'V Corps G-3', 'P002', 'filled'),
            ('V Corps', 'V Corps G-3', 'P003', 'filled'),
            ('V Corps', 'V Corps G-3', 'P004', 'filled'),
            -- V Corps G-6
            ('V Corps', 'V Corps G-6', 'P001', 'filled'),
            ('V Corps', 'V Corps G-6', 'P002', 'filled'),
            ('V Corps', 'V Corps G-6', 'P003', 'filled'),
            ('V Corps', 'V Corps G-6', 'P004', 'vacant'),
            -- ARCYBER G-3
            ('Army Cyber Command', 'Army Cyber Command G-3', 'P001', 'filled'),
            ('Army Cyber Command', 'Army Cyber Command G-3', 'P002', 'filled'),
            ('Army Cyber Command', 'Army Cyber Command G-3', 'P003', 'unknown'),
            ('Army Cyber Command', 'Army Cyber Command G-3', 'P004', 'vacant'),
            -- ARCYBER G-6
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P001', 'filled'),
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P002', 'filled'),
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P003', 'filled'),
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P004', 'filled'),
            -- INSCOM G-2
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-2', 'P001', 'filled'),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-2', 'P002', 'filled'),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-2', 'P003', 'filled'),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-2', 'P004', 'vacant'),
            -- INSCOM G-6
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-6', 'P001', 'filled'),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-6', 'P002', 'filled'),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-6', 'P003', 'unknown'),
            -- USARPAC G-3
            ('U.S. Army Pacific', 'U.S. Army Pacific G-3', 'P001', 'filled'),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-3', 'P002', 'filled'),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-3', 'P003', 'unknown'),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-3', 'P004', 'vacant'),
            -- USARPAC G-6
            ('U.S. Army Pacific', 'U.S. Army Pacific G-6', 'P001', 'filled'),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-6', 'P002', 'filled'),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-6', 'P003', 'vacant'),
            -- 36th ID G-3
            ('36th Infantry Division', '36th Infantry Division G-3', 'P001', 'filled'),
            ('36th Infantry Division', '36th Infantry Division G-3', 'P002', 'filled'),
            ('36th Infantry Division', '36th Infantry Division G-3', 'P003', 'filled'),
            ('36th Infantry Division', '36th Infantry Division G-3', 'P004', 'vacant'),
            -- 29th ID G-3
            ('29th Infantry Division', '29th Infantry Division G-3', 'P001', 'filled'),
            ('29th Infantry Division', '29th Infantry Division G-3', 'P002', 'filled'),
            ('29th Infantry Division', '29th Infantry Division G-3', 'P003', 'vacant'),
            ('29th Infantry Division', '29th Infantry Division G-3', 'P004', 'unknown'),
            -- 42nd ID G-3
            ('42nd Infantry Division', '42nd Infantry Division G-3', 'P001', 'filled'),
            ('42nd Infantry Division', '42nd Infantry Division G-3', 'P002', 'filled'),
            ('42nd Infantry Division', '42nd Infantry Division G-3', 'P003', 'unknown'),
            -- 34th ID G-3
            ('34th Infantry Division', '34th Infantry Division G-3', 'P001', 'filled'),
            ('34th Infantry Division', '34th Infantry Division G-3', 'P002', 'filled'),
            ('34th Infantry Division', '34th Infantry Division G-3', 'P003', 'vacant'),
            -- 335th SC G-6
            ('335th Signal Command', '335th Signal Command G-6', 'P001', 'filled'),
            ('335th Signal Command', '335th Signal Command G-6', 'P002', 'filled'),
            ('335th Signal Command', '335th Signal Command G-6', 'P003', 'filled'),
            ('335th Signal Command', '335th Signal Command G-6', 'P004', 'vacant'),
            -- 807th MC G-1
            ('807th Medical Command', '807th Medical Command G-1', 'P001', 'filled'),
            ('807th Medical Command', '807th Medical Command G-1', 'P002', 'filled'),
            ('807th Medical Command', '807th Medical Command G-1', 'P003', 'unknown'),
            -- 63rd RD G-4
            ('63rd Readiness Division', '63rd Readiness Division G-4', 'P001', 'filled'),
            ('63rd Readiness Division', '63rd Readiness Division G-4', 'P002', 'filled'),
            ('63rd Readiness Division', '63rd Readiness Division G-4', 'P003', 'vacant'),
            -- 416th TEC G-3
            ('416th Theater Engineer Command', '416th Theater Engineer Command G-3', 'P001', 'filled'),
            ('416th Theater Engineer Command', '416th Theater Engineer Command G-3', 'P002', 'filled'),
            ('416th Theater Engineer Command', '416th Theater Engineer Command G-3', 'P003', 'vacant')
    ) AS seeded_statuses(
        organization_name,
        section_display_name,
        position_number,
        occupancy_status
    )
)
UPDATE billets
SET occupancy_status = additional_status_seed.occupancy_status
FROM additional_status_seed
INNER JOIN organizations
    ON organizations.organization_name = additional_status_seed.organization_name
INNER JOIN sections
    ON sections.organization_id = organizations.organization_id
   AND sections.display_name = additional_status_seed.section_display_name
WHERE billets.organization_id = organizations.organization_id
  AND billets.section_id = sections.section_id
  AND billets.position_number = additional_status_seed.position_number;

-- ---------------------------------------------------------------------------
-- Occupant assignments (original)
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- Additional occupant assignments
-- ---------------------------------------------------------------------------
WITH additional_occupant_seed AS (
    SELECT *
    FROM (
        VALUES
            -- XVIII ABN G-1
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-1', 'P001', 'Mitchell, Angela R.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-1', 'P002', 'Rivera, Carlos J.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-1', 'P003', 'Thornton, Denise K.', TRUE),
            -- XVIII ABN G-2
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-2', 'P001', 'Barnett, Wayne L.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-2', 'P002', 'Fitzgerald, Maria C.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-2', 'P003', 'Douglas, Kevin P.', TRUE),
            -- XVIII ABN G-4
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-4', 'P001', 'Stone, Patricia M.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-4', 'P002', 'Cunningham, Robert E.', TRUE),
            ('XVIII Airborne Corps', 'XVIII Airborne Corps G-4', 'P004', 'Powers, Lisa D.', TRUE),
            -- 82nd ABN G-1
            ('82nd Airborne Division', '82nd Airborne Division G-1', 'P001', 'Malone, Derek A.', TRUE),
            ('82nd Airborne Division', '82nd Airborne Division G-1', 'P002', 'Reeves, Christina L.', TRUE),
            -- 82nd ABN G-2
            ('82nd Airborne Division', '82nd Airborne Division G-2', 'P001', 'Hoffman, Bradley T.', TRUE),
            -- 82nd ABN G-4
            ('82nd Airborne Division', '82nd Airborne Division G-4', 'P001', 'Santiago, Diana M.', TRUE),
            -- 101st ABN G-6
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-6', 'P001', 'Walsh, Timothy R.', TRUE),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-6', 'P002', 'Palmer, Stephanie J.', TRUE),
            ('101st Airborne Division (Air Assault)', '101st Airborne Division (Air Assault) G-6', 'P003', 'Hicks, Ronald G.', TRUE),
            -- 10th MTN G-3
            ('10th Mountain Division', '10th Mountain Division G-3', 'P001', 'Weaver, Kenneth J.', TRUE),
            ('10th Mountain Division', '10th Mountain Division G-3', 'P002', 'Flores, Sandra E.', TRUE),
            ('10th Mountain Division', '10th Mountain Division G-3', 'P004', 'Grant, William H.', TRUE),
            -- 10th MTN G-6
            ('10th Mountain Division', '10th Mountain Division G-6', 'P001', 'Moreno, Teresa C.', TRUE),
            ('10th Mountain Division', '10th Mountain Division G-6', 'P002', 'Webb, Joshua K.', TRUE),
            -- I Corps G-3
            ('I Corps', 'I Corps G-3', 'P001', 'Fuller, Craig A.', TRUE),
            ('I Corps', 'I Corps G-3', 'P002', 'Hunt, Rebecca L.', TRUE),
            ('I Corps', 'I Corps G-3', 'P003', 'Mendoza, Gabriel R.', TRUE),
            ('I Corps', 'I Corps G-3', 'P004', 'Krueger, Hans M.', TRUE),
            -- 7th ID G-3
            ('7th Infantry Division', '7th Infantry Division G-3', 'P001', 'Knox, Amanda S.', TRUE),
            ('7th Infantry Division', '7th Infantry Division G-3', 'P002', 'Boyd, Nathan W.', TRUE),
            -- 7th ID G-6
            ('7th Infantry Division', '7th Infantry Division G-6', 'P001', 'Dunn, Kelly M.', TRUE),
            ('7th Infantry Division', '7th Infantry Division G-6', 'P002', 'Lawson, Erik J.', TRUE),
            -- III AC G-3
            ('III Armored Corps', 'III Armored Corps G-3', 'P001', 'Payne, Donald R.', TRUE),
            ('III Armored Corps', 'III Armored Corps G-3', 'P002', 'Estrada, Monica V.', TRUE),
            -- III AC G-6
            ('III Armored Corps', 'III Armored Corps G-6', 'P001', 'Chapman, Leslie A.', TRUE),
            ('III Armored Corps', 'III Armored Corps G-6', 'P002', 'Barker, Jason T.', TRUE),
            ('III Armored Corps', 'III Armored Corps G-6', 'P003', 'Cross, Vanessa N.', TRUE),
            -- 1st CAV G-3
            ('1st Cavalry Division', '1st Cavalry Division G-3', 'P001', 'Maxwell, George B.', TRUE),
            ('1st Cavalry Division', '1st Cavalry Division G-3', 'P002', 'Herrera, Paul D.', TRUE),
            -- 1st CAV G-6
            ('1st Cavalry Division', '1st Cavalry Division G-6', 'P001', 'Duncan, Amy R.', TRUE),
            -- NETCOM G-3
            ('NETCOM', 'NETCOM G-3', 'P001', 'Cortez, Ruben M.', TRUE),
            ('NETCOM', 'NETCOM G-3', 'P002', 'Wolf, Sandra K.', TRUE),
            -- ARNG RC G-6
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-6', 'P001', 'Barton, Jeffrey L.', TRUE),
            ('Army National Guard Readiness Center', 'Army National Guard Readiness Center G-6', 'P002', 'Chandler, Michelle P.', TRUE),
            -- 28th ID G-6
            ('28th Infantry Division', '28th Infantry Division G-6', 'P001', 'Holland, Scott R.', TRUE),
            -- 377th TSC G-3
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-3', 'P001', 'Copeland, Marcus A.', TRUE),
            ('377th Theater Sustainment Command', '377th Theater Sustainment Command G-3', 'P002', 'Jennings, Tara L.', TRUE),
            -- 3rd ID G-3
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P001', 'Ramsey, Andrew C.', TRUE),
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P002', 'Bishop, Karen E.', TRUE),
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P003', 'Sutton, Frank J.', TRUE),
            ('3rd Infantry Division', '3rd Infantry Division G-3', 'P004', 'Salazar, Marco R.', TRUE),
            -- 3rd ID G-6
            ('3rd Infantry Division', '3rd Infantry Division G-6', 'P001', 'Whitfield, Donna T.', TRUE),
            ('3rd Infantry Division', '3rd Infantry Division G-6', 'P002', 'Erickson, Todd M.', TRUE),
            ('3rd Infantry Division', '3rd Infantry Division G-6', 'P003', 'Guerrero, Luis R.', TRUE),
            -- 4th ID G-3
            ('4th Infantry Division', '4th Infantry Division G-3', 'P001', 'Norton, Richard H.', TRUE),
            ('4th Infantry Division', '4th Infantry Division G-3', 'P002', 'Torres, Jessica A.', TRUE),
            ('4th Infantry Division', '4th Infantry Division G-3', 'P003', 'Harmon, Brenda L.', TRUE),
            -- 4th ID G-6
            ('4th Infantry Division', '4th Infantry Division G-6', 'P001', 'Gill, Trevor K.', TRUE),
            ('4th Infantry Division', '4th Infantry Division G-6', 'P002', 'Snow, Diane P.', TRUE),
            -- 25th ID G-3
            ('25th Infantry Division', '25th Infantry Division G-3', 'P001', 'Mack, Calvin D.', TRUE),
            ('25th Infantry Division', '25th Infantry Division G-3', 'P002', 'Valencia, Rosa M.', TRUE),
            -- 25th ID G-6
            ('25th Infantry Division', '25th Infantry Division G-6', 'P001', 'Petersen, Lori K.', TRUE),
            ('25th Infantry Division', '25th Infantry Division G-6', 'P002', 'Chung, Dennis W.', TRUE),
            ('25th Infantry Division', '25th Infantry Division G-6', 'P002', 'Tran, Kim N.', FALSE),
            -- 1st AD G-3
            ('1st Armored Division', '1st Armored Division G-3', 'P001', 'Graham, Nancy J.', TRUE),
            ('1st Armored Division', '1st Armored Division G-3', 'P002', 'Ingram, Randy B.', TRUE),
            ('1st Armored Division', '1st Armored Division G-3', 'P003', 'Barrett, Katherine M.', TRUE),
            -- 1st AD G-4
            ('1st Armored Division', '1st Armored Division G-4', 'P001', 'Mcclure, Oscar H.', TRUE),
            ('1st Armored Division', '1st Armored Division G-4', 'P002', 'Shelton, Joyce A.', TRUE),
            -- V Corps G-3
            ('V Corps', 'V Corps G-3', 'P001', 'Hawkins, Lawrence T.', TRUE),
            ('V Corps', 'V Corps G-3', 'P002', 'Byrd, Cynthia R.', TRUE),
            ('V Corps', 'V Corps G-3', 'P003', 'Walters, Eugene M.', TRUE),
            ('V Corps', 'V Corps G-3', 'P004', 'Krueger, Hans M.', FALSE),
            -- V Corps G-6
            ('V Corps', 'V Corps G-6', 'P001', 'Howell, Deborah S.', TRUE),
            ('V Corps', 'V Corps G-6', 'P002', 'Pratt, Allen K.', TRUE),
            ('V Corps', 'V Corps G-6', 'P003', 'Goodman, Rita D.', TRUE),
            -- ARCYBER G-3
            ('Army Cyber Command', 'Army Cyber Command G-3', 'P001', 'Frost, Daryl J.', TRUE),
            ('Army Cyber Command', 'Army Cyber Command G-3', 'P002', 'Ayers, Christine T.', TRUE),
            -- ARCYBER G-6
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P001', 'Booth, Raymond A.', TRUE),
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P002', 'Lowe, Janet P.', TRUE),
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P003', 'Stokes, Kenneth D.', TRUE),
            ('Army Cyber Command', 'Army Cyber Command G-6', 'P004', 'Clay, Danielle T.', TRUE),
            -- INSCOM G-2
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-2', 'P001', 'Blair, Catherine V.', TRUE),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-2', 'P002', 'Yoder, Franklin W.', TRUE),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-2', 'P003', 'Mathis, Gloria E.', TRUE),
            -- INSCOM G-6
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-6', 'P001', 'Stark, Wesley J.', TRUE),
            ('U.S. Army Intelligence and Security Command', 'U.S. Army Intelligence and Security Command G-6', 'P002', 'Floyd, Norma R.', TRUE),
            -- USARPAC G-3
            ('U.S. Army Pacific', 'U.S. Army Pacific G-3', 'P001', 'Shepherd, Earl M.', TRUE),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-3', 'P002', 'Kane, Victoria L.', TRUE),
            -- USARPAC G-6
            ('U.S. Army Pacific', 'U.S. Army Pacific G-6', 'P001', 'Lambert, Bruce H.', TRUE),
            ('U.S. Army Pacific', 'U.S. Army Pacific G-6', 'P002', 'Buchanan, Alice D.', TRUE),
            -- 36th ID G-3
            ('36th Infantry Division', '36th Infantry Division G-3', 'P001', 'Garza, Roberto A.', TRUE),
            ('36th Infantry Division', '36th Infantry Division G-3', 'P002', 'Padilla, Martha C.', TRUE),
            ('36th Infantry Division', '36th Infantry Division G-3', 'P003', 'Vega, Hector L.', TRUE),
            -- 29th ID G-3
            ('29th Infantry Division', '29th Infantry Division G-3', 'P001', 'Conrad, Mark T.', TRUE),
            ('29th Infantry Division', '29th Infantry Division G-3', 'P002', 'Hubbard, Tammy S.', TRUE),
            -- 42nd ID G-3
            ('42nd Infantry Division', '42nd Infantry Division G-3', 'P001', 'Russo, Anthony G.', TRUE),
            ('42nd Infantry Division', '42nd Infantry Division G-3', 'P002', 'Brennan, Colleen M.', TRUE),
            -- 34th ID G-3
            ('34th Infantry Division', '34th Infantry Division G-3', 'P001', 'Olson, Erik P.', TRUE),
            ('34th Infantry Division', '34th Infantry Division G-3', 'P002', 'Lindgren, Karen A.', TRUE),
            -- 335th SC G-6
            ('335th Signal Command', '335th Signal Command G-6', 'P001', 'Whitaker, Dale F.', TRUE),
            ('335th Signal Command', '335th Signal Command G-6', 'P002', 'Pope, Janice T.', TRUE),
            ('335th Signal Command', '335th Signal Command G-6', 'P003', 'Horton, Cedric W.', TRUE),
            -- 807th MC G-1
            ('807th Medical Command', '807th Medical Command G-1', 'P001', 'Cash, Harold B.', TRUE),
            ('807th Medical Command', '807th Medical Command G-1', 'P002', 'Underwood, Sylvia E.', TRUE),
            -- 63rd RD G-4
            ('63rd Readiness Division', '63rd Readiness Division G-4', 'P001', 'Novak, Stephen R.', TRUE),
            ('63rd Readiness Division', '63rd Readiness Division G-4', 'P002', 'Roth, Angela M.', TRUE),
            -- 416th TEC G-3
            ('416th Theater Engineer Command', '416th Theater Engineer Command G-3', 'P001', 'Quinn, Patrick F.', TRUE),
            ('416th Theater Engineer Command', '416th Theater Engineer Command G-3', 'P002', 'Bauer, Linda S.', TRUE)
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
    additional_occupant_seed.is_primary,
    'active',
    'seed',
    CURRENT_DATE,
    NOW()
FROM additional_occupant_seed
INNER JOIN organizations
    ON organizations.organization_name = additional_occupant_seed.organization_name
INNER JOIN sections
    ON sections.organization_id = organizations.organization_id
   AND sections.display_name = additional_occupant_seed.section_display_name
INNER JOIN billets
    ON billets.organization_id = organizations.organization_id
   AND billets.section_id = sections.section_id
   AND billets.position_number = additional_occupant_seed.position_number
INNER JOIN people
    ON people.display_name = additional_occupant_seed.person_display_name;

COMMIT;
