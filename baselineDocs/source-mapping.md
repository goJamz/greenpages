# Green Pages Source Mapping
**Live investigation notebook for mapping Vantage source data into the Green Pages canonical model**

Last updated: 2026-04-17

---

## 1. Purpose

This document is the working source-mapping notebook for Green Pages.

The goal is to stop guessing at source fields and instead map the actual Vantage datasets to the current Green Pages canonical model.

Green Pages should **not** become the place where raw-source extraction and source-specific transformation logic lives. The better design is:

**raw source datasets -> Vantage transforms -> Green Pages-shaped dataset(s) -> Go backend consumes cleaned data**

That keeps Green Pages as the clean normalized read model.

---

## 2. Current Green Pages canonical model

Green Pages is built around:

**Organization -> Section -> Billet -> Person**

### 2.1 Canonical tables

#### organizations
- organization_id
- organization_name
- normalized_name
- short_name
- parent_organization_id
- component
- echelon
- uic
- location_name
- state_code
- is_current
- last_refreshed_at
- created_at

#### organization_aliases
- organization_alias_id
- organization_id
- alias_text
- alias_type
- normalized_alias_text

#### sections
- section_id
- organization_id
- section_code
- section_name
- normalized_section_name
- display_name
- parent_section_id
- is_current
- created_at

#### billets
- billet_id
- organization_id
- section_id
- position_number
- billet_title
- normalized_billet_title
- grade_code
- rank_group
- branch_code
- mos_code
- aoc_code
- component
- uic
- paragraph_number
- line_number
- duty_location
- state_code
- occupancy_status
- is_current
- created_at
- updated_at

#### people
- person_id
- dod_id
- display_name
- normalized_display_name
- rank
- work_email
- work_phone
- office_symbol
- is_current
- last_refreshed_at
- created_at

#### billet_occupants
- billet_occupant_id
- billet_id
- person_id
- is_primary
- assignment_status
- source_system
- effective_date
- last_refreshed_at
- created_at

---

## 3. Investigation rules

1. Use real source field names, not guessed names.
2. Distinguish carefully between:
   - organization truth
   - billet truth
   - person truth
   - assignment / occupant truth
3. Mark every target mapping as one of:
   - **direct**
   - **transformed**
   - **derived**
   - **unresolved**
   - **not used**
4. Prefer Vantage transforms for:
   - source cleanup
   - deduplication
   - normalization
   - occupancy derivation
   - section derivation
5. Do not push raw-source parsing into Go unless there is no realistic alternative.

---

## 4. Very important file-pair warning

Two of the newly uploaded file pairs appear to be **swapped or mislabeled**:

### 4.1 `organizations.*`
- `organizations.csv` contains **position-style** columns such as:
  - `organization_id`
  - `ippsa_deptid`
  - `organization_data_history_uic`
  - `organization_data_history_uic_short_description`
  - `organization_data_history_uic_long_description`
  - parent FMIDs and parent UICs
  - location fields
- `organizations.json` contains the **position-data schema** with fields such as:
  - `position_id`
  - `positions_ippsa_position_num`
  - `positions_parno`
  - `positions_perln`
  - `positions_posco`
  - `positions_mil_grade`
  - `positions_branch`

### 4.2 `position_data_positions.*`
- `position_data_positions.csv` contains **hierarchy / organization-style** columns such as:
  - `uic`
  - `administrative_control_parent_uic`
  - `operational_control_parent_uic`
  - `parent_uic`
  - `uic_hierarchy`
  - `uic_long_name`
  - `uic_short_name`
  - `uic_name_aliases`
- `position_data_positions.json` contains the **hierarchy schema**, not the positions schema

### 4.3 Practical conclusion
Do not trust the filename alone. Trust the **actual column headers and schema body**.

For the rest of this document:
- **`position_data_positions.json` + `position_data_positions.csv` are treated as hierarchy-like files**
- **`organizations.csv` is treated as organization-history / org-detail data**
- **`organizations.json` is treated as position-data schema**

---

## 5. Dataset inventory and first-pass verdict

## 5.1 `unit_hierarchy`
### What it appears to be
A clean UIC hierarchy dataset.

### Strong fields
- `uic`
- `parent_uic`
- `uic_hierarchy`
- `uic_long_name`
- `uic_short_name`
- `uic_name_aliases`
- `administrative_control_parent_uic`
- `operational_control_parent_uic`

### Sample observation
The sample rows are sparse and code-like (`DJ5000`, `DJ5030`, `DJ5200`) rather than human-friendly, but the shape is excellent for hierarchy storage.

### First-pass verdict
**Best clean backbone for canonical `organizations` and `organization_aliases`.**

### Strengths
- very clean parent-child shape
- straightforward hierarchy arrays
- alias support
- fewer source-specific distractions than the bigger org datasets

### Weaknesses
- sample names may be too raw in some cases
- likely needs enrichment from other org datasets for display-quality naming

---

## 5.2 `position_data_positions` (actual CSV is hierarchy-like)
### What it appears to be
Another UIC hierarchy / organization linkage dataset.

### Strong fields
- `uic`
- `administrative_control_parent_uic`
- `operational_control_parent_uic`
- `parent_uic`
- `uic_hierarchy`
- `uic_long_name`
- `uic_short_name`
- `uic_name_aliases`
- `uic_source`

### Sample observation
Rows like `DGAAAA` and `DJ3000` show:
- direct UIC
- admin hierarchy
- operational hierarchy
- long/short name
- alias array
- parent UIC

### First-pass verdict
**Also a strong organization backbone candidate.**

### Relationship to `unit_hierarchy`
This may overlap heavily with `unit_hierarchy`. It could be:
- a cleaner or later-generation hierarchy dataset
- a near-duplicate with slightly different source coverage
- the better final choice if coverage is wider

### Action
Compare row counts, null rates, alias quality, and name quality before choosing the final org backbone.

---

## 5.3 `organizations.csv`
### What it appears to be
A richer organization-history / org-detail dataset with:
- organization FMIDs
- parent FMIDs
- parent UICs
- UIC descriptions
- location details
- document details
- category fields
- component-ish fields

### Strong fields
- `organization_id`
- `ippsa_deptid`
- `organization_data_history_uic`
- `organization_data_history_uic_short_description`
- `organization_data_history_uic_long_description`
- `organization_data_history_uic_gfm_short_description`
- `organization_data_history_uic_gfm_long_description`
- `organization_data_history_taabase_parent_uic`
- `organization_data_history_admin_parent_uic`
- `organization_data_history_dircon_parent_uic`
- `organization_data_history_gfm_component_code`
- location fields:
  - `locations_country`
  - `locations_city`
  - `locations_state`
  - `locations_postal`

### Sample observation
The Puerto Rico sample shows:
- multiple address rows for the same org record
- UIC-like fields
- long and short descriptions
- parent UIC references
- component / category / location metadata

### First-pass verdict
**Very useful enrichment dataset for organizations.**
This looks stronger for human-readable org names and location enrichment than the clean hierarchy files.

### Recommended role
- not necessarily the sole hierarchy backbone
- strong candidate for **organization display enrichment**
- strong candidate for **component and location derivation**
- possible fallback when the clean hierarchy datasets have weak display names

---

## 5.4 `all_current_units_crew`
### What it appears to be
A unit/object dataset blending unit identity, hierarchy, and GFM-style unit naming.

### Strong fields
- `uic`
- `mtoe_uic`
- `name_txt`
- `gfm_alt_nm`
- `gfm_dscr_lname`
- `gfm_sname`
- `uic_aname`
- `uic_lname`
- `parent_dircon_uic`
- `parent_admin_uic`
- `dircon_hierarchy`
- `admin_hierarchy`
- `gfm_component_cd`
- `service_code`
- `docno`
- `parno`
- `lduic`

### Sample observation
The samples show:
- one row with numeric-looking `uic` values
- some rows with no UIC at all
- some JOINT rows that are probably outside Green Pages scope
- descriptive naming variants that could be valuable aliases

### First-pass verdict
**Useful bridge / enrichment dataset, but not the cleanest primary org backbone.**

### Why
It appears to blend multiple object types and may contain non-Army or non-standard unit records.

### Best use
- enrich organization names and aliases
- help connect org records to document-level and GFM naming
- possibly help bridge positions to organizations through `lduic`, `docno`, or alternate UIC fields

---

## 5.5 `mtoe_unit_personnel_view`
### What it appears to be
A strong authorized-position / billet dataset.

### Strong fields
- `uic`
- `docno`
- `parno_1`
- `parno_3`
- `perln`
- `posco`
- `grade`
- `grade_code`
- `grade_text`
- `psntl`
- `brnch`
- `unit_type`
- `lname`
- `partl`
- `suttl`
- `sub_unit`
- `uicdr`
- `macom_text`

### Sample observation
The sample rows clearly look like authorized billets:
- `TEAM LEADER`
- `PSYOP SPECIALIST`
- grade codes like `E5`, `E4`
- MOS/AOC-like position code in `posco`
- billet title in `psntl`
- organization-ish name in `lname`
- paragraph and line references

### First-pass verdict
**Best first billet-authority source for Green Pages.**

### Why
It is already close to the canonical billet shape:
- UIC
- paragraph
- line
- specialty / position code
- title
- grade
- branch
- auth counts

### Caveat
The relationship between:
- `lname`
- `partl`
- `suttl`
- `sub_unit`
and the Green Pages **section** concept is still unresolved.

---

## 5.6 `fms_unit_personnel_view`
### What it appears to be
Another billet-authority view, similar to MTOE, but somewhat leaner.

### Strong fields
- `uic`
- `lname`
- `docno`
- `unit_type`
- `brnch`
- `posco`
- `grade`
- `psntl`
- `austr`
- `rqstr`
- `parno_1`
- `parno_3`
- `perln`
- `derived_mos`
- `person_type`
- `prmk_list`

### Sample observation
Rows look like valid authorized positions, but the dataset appears slightly less rich than the MTOE view for Green Pages purposes.

### First-pass verdict
**Useful comparison and validation source, but not the first billet source to build around.**

### Recommended role
- compare against MTOE for coverage
- fill gaps if MTOE misses certain units or components
- possibly support Reserve/Guard edge cases

---

## 5.7 `smallunit_billets`
### What it appears to be
A billet + small-unit placement dataset, likely closer to tactical or lower-echelon structure.

### Strong fields
- `mtoe_uic`
- `billet_id`
- `billet_name`
- `short_name`
- `description`
- `posco`
- `grade`
- `mos`
- `rank_code`
- `smallunit_id`
- `smallunit_name`
- `platoon_id`
- `platoon_name`
- `unit_description`
- `branch_code`
- `parno`
- `perln`
- `position_number`
- `assigned_soldier_ssn_hash`
- `assigned_arrival_date`
- `source_system`
- `uic_hierarchy`

### Sample observation
It contains:
- real billet records
- some “overmanning / standard excess” records
- lower-level groupings like platoon and small unit
- assignment hints based on hashed SSN and arrival date

### First-pass verdict
**Promising supplemental source, not ideal as the first canonical billet source.**

### Why
It is structurally useful, especially for lower-echelon decomposition, but it may pull Green Pages toward a different model than the current section-first design.

### Best use
- later enrichment for tactical decomposition
- possible section-derivation experiments
- possible occupancy cross-checks

---

## 5.8 `current_unit`
### What it appears to be
A current assignment / billet-occupant bridge dataset.

### Strong fields
- `member_id`
- `department_of_defense_identification_number`
- `uic`
- `position_fmid`
- `position_number`
- `designation_of_duties_performed`
- `assignment_status`
- `current_assignment_indicator`
- `authorization_document_paragraph_number`
- `authorization_document_line_number`
- `date_of_assignment_to_duty`
- `state_location_unit`

### Sample observation
Rows show:
- a current person assignment
- linked UIC
- linked position FMID
- linked position number
- assigned duty title
- paragraph / line
- assignment date

### First-pass verdict
**Best current occupant / assignment bridge source.**

### Why
This is exactly the kind of source needed to populate:
- `billet_occupants`
- occupancy status
- current-assignment effective dates
- person-to-billet links

### Important note
This dataset looks much stronger for occupancy than trying to infer occupancy from billet-only datasets.

---

## 5.9 `person`
### What it appears to be
The richest person identity source in the upload set.

### Strong fields
- `member_id`
- `department_of_defense_identification_number`
- `edipi`
- `name_individual`
- `names_last_name`
- `names_first_name`
- `grade`
- `rank_true_abbreviation`
- `dod_email`
- `phone`
- `phone_duty`
- `uic`
- `position_fmid`
- `position_number`
- `assignment_status`
- `current_assignment_indicator`
- `component`
- specialty fields:
  - `primary_specialty_code`
  - `primary_specialty_description`
  - `assignment_area_of_concentration`
  - `basic_branch`

### Sample observation
Rows clearly contain person identity plus current assignment context:
- DoD ID / EDIPI
- full name
- rank
- email
- UIC
- position FMID
- position number
- current assignment flag

### First-pass verdict
**Best person-identity source.**

### Why
This should be the main source for canonical `people`, while `current_unit` should be the main source for current assignment linkage.

---

## 6. Recommended source roles

### 6.1 Most likely first-pass source stack

#### Organizations backbone
Primary candidates:
1. `unit_hierarchy`
2. `position_data_positions` (actual hierarchy-like CSV / JSON pair)

Support / enrichment:
3. `organizations.csv`
4. `all_current_units_crew`

#### Billets backbone
Primary candidate:
1. `mtoe_unit_personnel_view`

Comparison / fallback:
2. `fms_unit_personnel_view`

Supplemental:
3. `smallunit_billets`

#### People backbone
Primary candidate:
1. `person`

#### Billet-occupant bridge
Primary candidate:
1. `current_unit`

---

## 7. Detailed canonical mapping

## 7.1 organizations

| Target field | Primary source candidate | Mapping type | Notes |
|---|---|---|---|
| `organization_name` | `organizations.csv.organization_data_history_uic_long_description` | transformed | Prefer the best human-readable long name. Fallbacks may include `uic_long_name`, `name_txt`, `gfm_dscr_lname`, or `lname`. |
| `normalized_name` | derived from chosen org name | derived | Lowercase, trim, strip punctuation/non-alphanumeric for search. |
| `short_name` | `organizations.csv.organization_data_history_uic_short_description` | transformed | Fallback to hierarchy short names or GFM short names. |
| `parent_organization_id` | hierarchy join from `parent_uic` | transformed | Load orgs first by UIC, then resolve parent FK by UIC lookup. |
| `component` | `organizations.csv.organization_data_history_gfm_component_code` or `all_current_units_crew.gfm_component_cd` | transformed | Needs translation into Green Pages component set such as Active / Guard / Reserve. |
| `echelon` | unresolved | unresolved | May be derivable later from unit category / size / title conventions. |
| `uic` | `unit_hierarchy.uic` or equivalent | direct | UIC should be the stable natural org key in the canonical model. |
| `location_name` | `organizations.csv.locations_city` + `organizations.csv.locations_state` + `locations_country` | transformed | Could also fall back to other org/location sources if cleaner. |
| `state_code` | `organizations.csv.locations_state` | transformed | Needs normalization to canonical postal/state-like code. |

### Recommended org load strategy
1. choose one org backbone dataset keyed by `uic`
2. load one canonical org row per UIC
3. enrich display fields from the richer org-history dataset
4. resolve parents by UIC lookup
5. add aliases from alias arrays and alternate naming columns

---

## 7.2 organization_aliases

| Target field | Source candidate | Mapping type | Notes |
|---|---|---|---|
| `organization_id` | resolved from canonical org row | transformed | FK lookup by UIC |
| `alias_text` | `uic_name_aliases` | transformed | Unnest alias arrays into one row per alias |
| `alias_type` | literal or derived | derived | Examples: `source_alias`, `gfm_short`, `gfm_long`, `alt_name`, `uic_code` |
| `normalized_alias_text` | derived | derived | Same normalization rules as org names |

### Useful alias sources
- `unit_hierarchy.uic_name_aliases`
- `position_data_positions.uic_name_aliases`
- `all_current_units_crew.gfm_alt_nm`
- `all_current_units_crew.gfm_sname`
- `all_current_units_crew.uic_aname`
- `all_current_units_crew.uic_lname`
- `organizations.csv` short/long description variants

---

## 7.3 sections

### Current state
**Sections are still the least proven part of the whole source landscape.**

Green Pages wants sections as first-class objects:
- searchable
- detailable
- linked to billets
- named like `G-6`, `S-3`, `J-1`, etc.

### What we do not yet have
No uploaded schema clearly exposes a native section table in the Green Pages sense.

### Candidate section signals
| Candidate source field | Why it might help | Risk |
|---|---|---|
| `mtoe_unit_personnel_view.partl` | looks like a lower grouping label | may be functional grouping, not staff section |
| `mtoe_unit_personnel_view.suttl` | unit/subunit title | may be too organizational rather than sectional |
| `mtoe_unit_personnel_view.sub_unit` | explicit sub-unit hint | sample coverage unclear |
| `smallunit_billets.smallunit_name` | lower-level grouping | may not map to staff sections |
| `smallunit_billets.platoon_name` | grouping | tactical, not staff |
| `position_data_positions.positions_drcon_reportto_title` | report-to title might reveal section context | likely not reliable enough alone |
| `current_unit.designation_of_duties_performed` | duty title hints | describes billet duties, not section |

### Current mapping status
| Target field | Mapping status | Notes |
|---|---|---|
| `organization_id` | transformed | if sections are derived, they will still anchor to orgs |
| `section_code` | unresolved | needs actual rule source |
| `section_name` | unresolved | likely derived or manually normalized |
| `normalized_section_name` | derived | only after section exists |
| `display_name` | derived | probably `org short name + section code` or `org name + section code` |
| `parent_section_id` | unresolved | probably null for first pass |

### Strong recommendation
Do **not** fake sections too early. Treat section derivation as a separate Vantage-transform problem.

### Practical first-pass options
#### Option A - defer sections
- build organizations
- build billets
- build people
- build billet occupants
- leave sections unresolved for now

#### Option B - derive sections narrowly
Only derive a section when a trusted source pattern exists, such as:
- obvious G/J/S section codes in billet titles or org titles
- a validated sub-unit field that consistently maps to staff sections

#### Option C - create a Green Pages-specific section transform
Use business rules in Vantage to convert source grouping signals into canonical sections.

At the moment, **Option A or a very narrow Option B is the safest**.

---

## 7.4 billets

| Target field | Primary source candidate | Mapping type | Notes |
|---|---|---|---|
| `organization_id` | org FK resolved from `uic` | transformed | Likely join billet source `uic` to canonical org UIC. |
| `section_id` | unresolved | unresolved | Section derivation still not proven. |
| `position_number` | `current_unit.position_number` or billet source `position_number` | transformed | Preserve as text in canonical model. Multiple sources may need reconciliation. |
| `billet_title` | `mtoe_unit_personnel_view.psntl` | direct | Strongest current candidate for billet title. Fallbacks: `smallunit_billets.billet_name`, `designation_of_duties_performed`. |
| `normalized_billet_title` | derived | derived | Normalize billet title for search. |
| `grade_code` | `mtoe_unit_personnel_view.grade_code` | direct | Clean and close to canonical shape. |
| `rank_group` | derived from grade | derived | O/W/E style grouping needs transform logic. |
| `branch_code` | `mtoe_unit_personnel_view.brnch` | direct | Good candidate. |
| `mos_code` | `fms_unit_personnel_view.derived_mos` or parsed `posco` | transformed | Need a consistent MOS extraction rule. |
| `aoc_code` | parsed from `posco` or officer specialty fields | derived | Depends on officer/enlisted classification rules. |
| `component` | derived from org source or billet source component field | transformed | Use canonical Active / Guard / Reserve values. |
| `uic` | `mtoe_unit_personnel_view.uic` | direct | Strong natural link back to org. |
| `paragraph_number` | combine `parno_1` and/or `parno_3`, or use source paragraph fields | transformed | Need one canonical paragraph rule. |
| `line_number` | `perln` | direct | Convert to text. |
| `duty_location` | unresolved | unresolved | Could possibly come from org/location enrichment rather than billet source. |
| `state_code` | derived from org location | transformed | Probably an org-level enrichment rather than a billet-native field. |
| `occupancy_status` | derived from assignment linkage | derived | See occupancy rules below. |

### Billet natural key candidates
For a first pass, likely candidate composite natural key:
- `uic`
- paragraph
- line
- position code / title
- or `position_fmid` when reliable

### Important note about `position_fmid`
The canonical Green Pages schema currently does **not** have a `position_fmid` column, but many source datasets clearly treat it as a stable billet identifier.

### Recommendation
Add `source_position_fmid` or `external_position_id` later if needed, but do not force that decision yet in the markdown. Just record it as a likely future need.

---

## 7.5 people

| Target field | Primary source candidate | Mapping type | Notes |
|---|---|---|---|
| `dod_id` | `person.department_of_defense_identification_number` | direct | Best canonical identity field from current uploads. |
| `display_name` | `person.name_individual` | transformed | Fallback to assembled first/middle/last if needed. |
| `normalized_display_name` | derived | derived | Standard name normalization for search. |
| `rank` | `person.rank_true_abbreviation` | transformed | Prefer short display rank like `SGT`, `PFC`, `COL`. |
| `work_email` | `person.dod_email` | direct | Strong candidate. |
| `work_phone` | `person.phone_duty` or `phone` | transformed | Needs array flattening and priority rules. |
| `office_symbol` | unresolved | unresolved | No clear first-class office-symbol source seen yet. |

### Person natural key
Best current choice:
- `department_of_defense_identification_number`

Fallbacks:
- `edipi`
- `member_id`

### Person load strategy
1. choose one current row per DoD ID
2. prefer rows with `current_assignment_indicator = true`
3. prefer non-null email and rank abbreviation
4. derive display name and normalized name

---

## 7.6 billet_occupants

| Target field | Primary source candidate | Mapping type | Notes |
|---|---|---|---|
| `billet_id` | resolved by matching assignment source to canonical billet | transformed | Requires a reliable billet natural-key strategy. |
| `person_id` | resolved from canonical person row by DoD ID | transformed | Person FK lookup. |
| `is_primary` | derived | derived | First pass can set true for one current assignment per billet/person match when no better signal exists. |
| `assignment_status` | `current_unit.assignment_status` | transformed | Translate source values into canonical `active` / `inactive`. |
| `source_system` | literal from source field or pipeline literal | direct/transformed | Use `current_unit.source` if useful, otherwise set pipeline literal like `vantage_current_unit`. |
| `effective_date` | `current_unit.date_of_assignment_to_duty` | direct | Strong candidate. |

### Occupancy bridge strategy
Best current bridge source:
- `current_unit`

### Best current matching clues
- `department_of_defense_identification_number`
- `uic`
- `position_fmid`
- `position_number`
- `authorization_document_paragraph_number`
- `authorization_document_line_number`

### Best first-pass occupant join strategy
Match `current_unit` to canonical billets using:
1. `uic`
2. paragraph
3. line
4. optional position number
5. optional `position_fmid` if introduced later

---

## 8. Occupancy status derivation

### Canonical display states
- `filled`
- `vacant`
- `unknown`

### Recommended first-pass rules
#### `filled`
Set to `filled` when:
- there is at least one current active occupant mapping for the billet

#### `vacant`
Set to `vacant` when:
- billet authority exists
- billet expected quantity exists
- no current occupant mapping exists
- no conflicting evidence indicates unknown quality

#### `unknown`
Set to `unknown` when:
- assignment linkage is incomplete
- source rows conflict
- billet identity is ambiguous
- occupant linkage cannot be trusted

### Important note
Do not overclaim vacancy just because no occupant row matched. A missing match can mean either:
- truly vacant
- identity mismatch
- source lag
- section/billet derivation failure

So for early loads, it may be safer to produce more `unknown` than false `vacant`.

---

## 9. Join hypotheses and candidate keys

## 9.1 Organization joins
Most likely natural key:
- `uic`

Likely org-parent join:
- child `uic` -> parent `parent_uic`

Possible enrichment joins:
- `uic`
- `mtoe_uic`
- `lduic`
- document fields like `docno`

## 9.2 Billet joins
Candidate billet identity fields across sources:
- `position_fmid`
- `position_number`
- `uic`
- paragraph
- line
- `posco`
- title

### First-pass canonical billet key recommendation
Try to derive a stable upstream billet identity in Vantage using one of these:
1. `position_fmid` if available and trustworthy
2. otherwise composite key:
   - `uic`
   - normalized paragraph
   - normalized line
   - normalized title or position code

## 9.3 Person joins
Most likely:
- `department_of_defense_identification_number`

Fallback:
- `edipi`
- `member_id`

## 9.4 Occupant joins
Best current path:
- `current_unit.department_of_defense_identification_number` -> `people.dod_id`
- `current_unit` assignment clues -> canonical billet

---

## 10. Source-by-target recommendation

## 10.1 Recommended first implementation order

### Phase 1
**Organizations**
- backbone from `unit_hierarchy` or `position_data_positions` hierarchy data
- display enrichment from `organizations.csv`
- optional alias enrichment from `all_current_units_crew`

### Phase 2
**Billets**
- primary load from `mtoe_unit_personnel_view`
- validation against `fms_unit_personnel_view`

### Phase 3
**People**
- primary load from `person`

### Phase 4
**Billet occupants**
- current assignment bridge from `current_unit`

### Phase 5
**Sections**
- separate transform problem after org/billet/person truth is stable

---

## 11. What should happen in Vantage

## 11.1 Must happen in Vantage
- UIC-based org deduplication
- parent-child org resolution
- name selection and alias expansion
- component normalization
- state / location normalization
- billet natural-key creation
- grade-to-rank-group derivation
- MOS / AOC extraction from source position codes
- current assignment matching to billets
- occupancy-status derivation
- section derivation, if sections are not natively sourced

## 11.2 Should not happen in Go
- raw-source hierarchy cleanup
- source-specific parent resolution
- source-specific billet key reconciliation
- source-specific person matching
- complex occupancy inference

---

## 12. Most important unresolved questions

1. **Which org hierarchy dataset is the better backbone?**
   - `unit_hierarchy`
   - or the hierarchy-like `position_data_positions`

2. **Is `organizations.csv` enrichment-only, or should it be the main org source?**

3. **What is the true stable billet key?**
   - `position_fmid`
   - `position_number`
   - UIC + paragraph + line
   - something else

4. **How should paragraph be normalized?**
   - `parno_1` + `parno_3`
   - source paragraph text
   - zero-padded merged form
   - preserve both source components separately

5. **How do sections get created?**
   - native field not yet found
   - derivation from `sub_unit`, `suttl`, `partl`
   - custom Green Pages transform rules

6. **Can office symbol be sourced reliably, or is that out of scope for first load?**

7. **How aggressively should vacancy be claimed versus `unknown`?**

---

## 13. Recommended immediate next tests

## 13.1 Org backbone comparison
Compare:
- row counts
- distinct UIC counts
- null rates for names
- alias coverage
- parent coverage

Between:
- `unit_hierarchy`
- hierarchy-like `position_data_positions`
- `organizations.csv`

## 13.2 Position-to-org overlap test
Test overlap between:
- org UICs
- billet UICs from `mtoe_unit_personnel_view`
- billet/position parent UICs
- `lduic`
- `mtoe_uic`

## 13.3 Occupant-to-billet bridge test
Test match rates between `current_unit` and the chosen billet source using:
- UIC
- paragraph
- line
- position number
- position FMID when present

## 13.4 Person-to-assignment bridge test
Test match rates between:
- `person.department_of_defense_identification_number`
- `current_unit.department_of_defense_identification_number`

## 13.5 Section derivation test
Take a sample org and examine:
- `psntl`
- `partl`
- `suttl`
- `sub_unit`
- `smallunit_name`
- `platoon_name`
- report-to titles

Look specifically for consistent section-like patterns such as:
- `G-1`
- `G-2`
- `G-3`
- `G-6`
- `S-1`
- `S-3`
- `J-1`
- `J-6`

---

## 14. First-pass recommended Green Pages dataset design in Vantage

## 14.1 Dataset A - `greenpages_organizations`
One row per canonical organization.

Suggested outputs:
- canonical organization fields
- source UIC
- source parent UIC
- selected long name
- selected short name
- canonical component
- canonical location fields
- source lineage fields

## 14.2 Dataset B - `greenpages_organization_aliases`
One row per alias.

Suggested outputs:
- org UIC or canonical org key
- alias text
- alias type
- normalized alias text

## 14.3 Dataset C - `greenpages_billets`
One row per canonical billet.

Suggested outputs:
- source billet identity
- canonical org linkage
- billet title
- normalized billet title
- grade code
- rank group
- branch code
- MOS code
- AOC code
- paragraph
- line
- position number
- source lineage fields

## 14.4 Dataset D - `greenpages_people`
One row per canonical person.

Suggested outputs:
- DoD ID
- display name
- normalized display name
- rank abbreviation
- email
- phone
- source lineage fields

## 14.5 Dataset E - `greenpages_billet_occupants`
One row per current assignment linkage.

Suggested outputs:
- canonical billet identity
- canonical person identity
- assignment status
- effective date
- source system
- matching-confidence flags if helpful

## 14.6 Dataset F - `greenpages_sections` (optional later)
Only after section derivation rules are proven.

---

## 15. Bottom-line conclusions

### Strongest current findings
- **Best org backbone candidates:** `unit_hierarchy` and hierarchy-like `position_data_positions`
- **Best org enrichment candidate:** `organizations.csv`
- **Best first billet source:** `mtoe_unit_personnel_view`
- **Best person source:** `person`
- **Best assignment / occupancy bridge:** `current_unit`
- **Best supplemental lower-echelon billet source:** `smallunit_billets`

### Biggest current gap
**Sections are not yet proven as a native source object.**

### Best next move
Build the first Vantage transform around:
- organizations
- billets
- people
- billet_occupants

Treat sections as a separate derivation problem once the org/billet/person spine is stable.

---

## 16. Short working summary

If I had to choose a first-pass mapping today:

- `organizations` <- hierarchy backbone (`unit_hierarchy` or hierarchy-like `position_data_positions`) + enrichment from `organizations.csv`
- `organization_aliases` <- hierarchy alias arrays + GFM alternate names
- `billets` <- `mtoe_unit_personnel_view`
- `people` <- `person`
- `billet_occupants` <- `current_unit`
- `sections` <- unresolved / derived later

That is the most honest mapping based on the uploaded schemas and sample rows.

