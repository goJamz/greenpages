# Green Pages Source Mapping

**Live investigation notebook for mapping Vantage source data into the Green Pages canonical model**

Last updated: 2026-05-11

Merge note: final merged draft incorporating the verified WD83AA MTOE pull, the verified MTOE ↔ current_unit composite-key bridge, corrected `partl`/`sub_unit` evidence handling, explicit occupancy derivation rules, and safer treatment of person identifiers.

Update note (2026-04-30): merged the `WD83AA` person admin-data bridge, the phone-display product decision, strict allowlist guidance for `greenpages_people`, and a pending model/API delta for splitting `work_phone` into separate `phone` and `duty_phone` fields before production-shaped person data is loaded. Latest phone update: full `WD83AA` 4-column person phone pull counted `phone`, `phone_duty`, and `phone_home`; product policy is now rank-gated and uses `phone_home` only as a fallback source for the general `Phone` display value.

Update note (2026-05-01): added three new dataset inspections (`army_unit_auth_fms`, `army_mtoe_aos_position_mapping`, `hrc_curated_org_hierarchy`) and a captured data-lineage observation. The headline finding is that `army_unit_auth_fms` is a strict superset of `mtoe_unit_personnel_view` for billet authority — already-computed `parno_concat`, clean `grade_code`, populated `derived_mos`, and `partl` all 178/178 — and per the lineage tree it unions MTOE + TDA + FMS billets in one place. This is the leading candidate billet-authority source for the future billets transform, pending a 178-vs-182 row-count reconciliation against `mtoe_unit_personnel_view` and a TDA-UIC verification. The current `greenpages_people` transform plan does not change.

Update note (2026-05-01 v3 merge): merged the stronger integrated v2 findings into the regenerated source map, retained the explicit FMS-to-AOS quantity-parity finding (`sum(austr)=216` and 216 current AOS rows across 178 auth-line keys), updated the source-by-target recommendation to reflect `army_unit_auth_fms` as the leading billet-authority candidate, and made the multiple-occupant language more cautious now that AOS position cardinality explains some paragraph/line duplicates.

Update note (2026-05-01 v4 transform validation): built and validated the first Vantage PySpark prototype output, `greenpages_people_wd83aa_prototype`, from the `person` dataset using the strict allowlist and WD83AA filter. The first validation exposed that `person.grade` arrived as long rank text rather than canonical grade code, so the transform now derives canonical `E/O/W` grade codes from `rank_true_abbreviation`/source grade text before applying phone policy. Final validation: 200 rows, 200 distinct `person_id`s, 200 distinct `dod_id`s, no missing display names/ranks/grades, 2 missing work emails, `work_phone` equals `phone`, and rank-gated phone policy behaves as intended.

Update note (2026-05-01 v5 person display cleanup): finalized the person-display convention for the prototype transform. `rank` remains a separate field (for example `MAJ`), `display_name` is now a user-friendly name without rank (for example `Nathan J. Hogan`), and Green Pages should render the user-facing label by combining `rank` + `display_name` in UI/backend presentation. `normalized_display_name` remains search/index-only and should never be shown to users. Temporary inspection field `source_grade` was renamed to `source_grade_normalized` to make clear that it is machine-normalized validation/debug data, not a display field.

Update note (2026-05-06 v6 Q17/Q18 closeout): both outstanding billet-authority blockers are cleared for the next prototype. **Q17(a):** the 178-vs-182 row gap at WD83AA is explained — the 4 MTOE-only rows are all paragraph 107 / `partl=AIR SUPPORT` Air Force liaison billets tagged `prmk1='NON-ARMY POSITION (OTHER-PERS)'`; this is a scope/design difference, not a data-quality failure. **Q17(b):** `army_unit_auth_fms` contains both MTOE and TDA rows (`mtoe`: 441,689 rows / 8,146 UICs; `tda`: 433,577 rows / 2,444 UICs). TDA test UIC `W8A5AA` returned 182 rows with 100% coverage on `parno_concat`, `perln`, `grade_code`, `partl`, and `derived_mos`; its FMS↔current_unit bridge is semantically valid but has expected overstrength/attached/unmapped personnel rows. There is no `joint` `unit_type` value in FMS, so the earlier "joint half" is N/A for this dataset rather than a blocker. **Q18:** `army_mtoe_aos_position_mapping.ipps_position_number` ↔ `current_unit.position_number` is verified for WD83AA at 98.8% using a real-billet filter and effectively 100% once the paragraph-pattern backstop excludes two mislabeled `999E` rows. Net decision: adopt `army_unit_auth_fms` as primary billet authority, adopt `army_mtoe_aos_position_mapping` as IPPS-A position-cardinality and MOS enrichment source, use `current_unit` as the occupancy bridge, and build the next prototype from `army_unit_auth_fms → army_mtoe_aos_position_mapping → current_unit → greenpages_people_wd83aa_prototype`.

Merge cleanup note (2026-05-06 final): accepted the stronger Q17/Q18 closeout language from the reviewed update, added the real-billet filter as explicit OR-style exclusion logic to avoid ambiguity, clarified that FMS has no `joint` `unit_type`, and corrected the next prototype chain to a single `greenpages_people_wd83aa_prototype` join.

Update note (2026-05-08 v7 WD83AA vertical completion): the narrow WD83AA Green Pages vertical is now built and validated end-to-end in Vantage. Three Green Pages-shaped prototype outputs exist: `greenpages_people_wd83aa_prototype` with 200 rows, `greenpages_billets_wd83aa_prototype` with 216 position-grain billet rows, and `greenpages_billet_occupants_wd83aa_prototype` with 169 occupant-grain rows. The occupant output RID is `ri.foundry.main.dataset.fd7f2a5e-e69d-43ab-a3e9-704bac1c8846`.

The validated source chain is now: `army_unit_auth_fms` → `army_mtoe_aos_position_mapping` → `current_unit` → `greenpages_people_wd83aa_prototype`. FMS remains the authorization-line authority. AOS expands FMS authorization lines into current IPPS-A position rows. `current_unit` remains the authoritative occupancy bridge. The people prototype remains the identity/contact/person enrichment source.

The billet transform is position-grain: 178 FMS authorization-line keys expand to 216 current AOS/IPPS-A positions. The occupant transform joins those billet-position rows to real-billet `current_unit` rows by `position_number`, asserts that `current_unit` auth-line keys agree with the billet auth-line keys after the position join, and then joins to people by DoD ID.

Current `current_unit` source truth for WD83AA drifted from the earlier handoff counts. As of 2026-05-08, WD83AA validates as 198 total `current_unit` rows, 29 excluded special/non-canonical rows, 169 real-billet occupant rows, and 47 vacant/AOS-only billet positions. The bridge remains clean: 169/169 real-billet `current_unit` rows match billet positions, with 0 orphan current_unit rows, 0 auth-line mismatches, and 0 unresolved people joins.

The transforms now follow a stricter contract posture. Required columns fail loudly, expected row counts are asserted per stage, FMS↔AOS and current_unit↔billet orphan checks are explicit, join keys are normalized consistently on both sides, null is preserved for missing/not-applicable values, and non-deterministic row timestamps were removed from deterministic output content.

Update note (2026-05-11 v8 WD83AA Postgres sync/load validation): the first WD83AA Vantage-to-Postgres load slice is now validated end-to-end against DEV Azure PostgreSQL Flexible Server. The three validated Vantage outputs were exported to local CSVs, loaded into staging tables, validated, and merged into the Green Pages live PostgreSQL read-model tables. DEV now contains the real WD83AA slice only: 1 organization, 32 sections, 216 billets, 200 people, and 169 active billet occupants. Occupancy validates as 169 filled billets and 47 vacant billets. Orphan checks passed with 0 billets missing organizations, 0 billets missing sections, and 0 billet occupants missing either billet or person. Duplicate source-key checks returned 0 rows for `source_section_key`, `source_billet_key`, and `source_billet_occupant_key`.

The runtime data path is now proven as: Vantage Green Pages-shaped outputs → CSV/manual sync-load step → staging validation → Azure PostgreSQL Flexible Server live tables → Go backend API → React/NGINX frontend. Vantage remains the upstream data-processing layer; Azure PostgreSQL Flexible Server is the runtime read database for Green Pages. Normal page-load backend requests should not query Vantage directly.

The loader was rerun against the unchanged CSV set and counts stayed stable at 1 organization, 32 sections, 216 billets, 200 people, and 169 billet occupants, with 0 retired sections, 0 retired billets, and 0 inactive occupants. This validates the current WD83AA loader as repeatable/idempotent for the unchanged CSV set.

Source identity columns were added by migration `000008_source_keys_for_wd83aa_loader.sql`: `sections.source_section_key`, `sections.source_lineage`, `billets.source_billet_key`, `billets.source_lineage`, `billet_occupants.source_billet_occupant_key`, and `billet_occupants.source_lineage`.

Section display naming was corrected upstream in `greenpages_billets_wd83aa_prototype.py`: `section_display_name` now uses `section_name`, so numbered staff sections display consistently as `S1 SECTION`, `S2 SECTION`, `S3 SECTION`, `S4 SECTION`, and `S6 SECTION` instead of the short `S1`/`S2`/`S3` form. Because `greenpages_billet_occupants_wd83aa_prototype` consumes `greenpages_billets_wd83aa_prototype` and requires `section_display_name`, rerun the occupant transform after billet section-display changes.

---

## 1. Purpose

This is the working source-mapping notebook for Green Pages.

The goal is to stop guessing at source fields and instead map the actual Vantage datasets to the Green Pages canonical model.

Green Pages should **not** become the place where raw-source extraction and source-specific transform logic lives. The intended pipeline is:

**raw source datasets → Vantage transforms → Green Pages-shaped dataset(s) → sync/load step → Azure PostgreSQL Flexible Server → Go backend consumes the runtime read model**

That keeps Vantage as the source-processing layer and keeps Green Pages backed by a clean normalized PostgreSQL read model at runtime.

---

## 2. Current Green Pages canonical model

Green Pages is built around: **Organization → Section → Billet → Person**, plus an occupant join.

### 2.1 Canonical tables (current schema)

#### organizations
- `organization_id`, `organization_name`, `normalized_name`, `short_name`
- `parent_organization_id`, `component`, `echelon`, `uic`
- `location_name`, `state_code`
- `is_current`, `last_refreshed_at`, `created_at`

#### organization_aliases
- `organization_alias_id`, `organization_id`, `alias_text`, `alias_type`, `normalized_alias_text`

#### sections
- `section_id`, `organization_id`, `section_code`, `section_name`, `normalized_section_name`, `display_name`
- `parent_section_id`, `is_current`, `created_at`
- `source_section_key`, `source_lineage`

#### billets
- `billet_id`, `organization_id`, `section_id`, `position_number`, `billet_title`, `normalized_billet_title`
- `grade_code`, `rank_group`, `branch_code`, `mos_code`, `aoc_code`, `component`
- `uic`, `paragraph_number`, `line_number`
- `duty_location`, `state_code`, `occupancy_status`
- `is_current`, `created_at`, `updated_at`
- `source_billet_key`, `source_lineage`

#### people
- `person_id`, `dod_id`, `display_name`, `normalized_display_name`
- `rank`, `work_email`, `work_phone`, `office_symbol`
- `is_current`, `last_refreshed_at`, `created_at`

**Phone implementation delta:** the current Green Pages Postgres/API model still has a single `work_phone` field. The source-mapping target now needs separate `phone` and `duty_phone` values because the `person` source exposes `phone`, `phone_home`, and `phone_duty` arrays and the product decision is to display a rank-gated general phone plus a separate duty phone when allowed. `phone_home` is a fallback source only for the general `Phone` value; it is not displayed as `Home phone`. This requires a future schema/API/UI migration before production-shaped person data is loaded.

#### billet_occupants
- `billet_occupant_id`, `billet_id`, `person_id`
- `is_primary`, `assignment_status`, `source_system`, `effective_date`
- `last_refreshed_at`, `created_at`
- `source_billet_occupant_key`, `source_lineage`


### 2.1.1 Source identity columns

Migration `000008_source_keys_for_wd83aa_loader.sql` adds stable source-key columns to `sections`, `billets`, and `billet_occupants`. The WD83AA Vantage-to-Postgres loader populates these columns and uses them as upsert conflict keys.

| Table | Column | Source | Construction |
|---|---|---|---|
| `sections` | `source_section_key` | derived | `UIC \| normalized_section_name` |
| `billets` | `source_billet_key` | `greenpages_billets_wd83aa_prototype.prototype_billet_key` | direct |
| `billet_occupants` | `source_billet_occupant_key` | `greenpages_billet_occupants_wd83aa_prototype.billet_occupant_source_key` | direct |
| all three | `source_lineage` | upstream transform `source_lineage` | direct/debug |

For sections, use the two-part key `uic|normalized_section_name`, for example `WD83AA|s3section`. Do not include `section_display_name` in the identity key because display text can be corrected without changing section identity.

### 2.2 Current constraints and API surfaces worth preserving in the mapping

These constraints matter because the Vantage output should already be shaped so the Go app can load/read it without source-specific inference:

- `occupancy_status` must resolve to one of `filled`, `vacant`, or `unknown`.
- `assignment_status` must resolve to one of `active` or `inactive`.
- Only one active primary occupant should exist per billet.
- Duplicate billet/person mappings should be prevented before they reach the app.
- Current-person uniqueness should be based on `dod_id` and, where present, `work_email`.

Loader/read-model constraints now also worth preserving:

- Vantage prototype keys are source keys, not Postgres primary keys.
- `prototype_billet_key` maps to `billets.source_billet_key`.
- `billet_occupant_source_key` maps to `billet_occupants.source_billet_occupant_key`.
- Section source identity should be based on `uic|normalized_section_name`, not display text.
- Loader validation must pass in staging before live tables are changed.
- Azure PostgreSQL Flexible Server is the runtime read database; Vantage should not be queried live by normal backend page-load/API requests.

The mapping should support the current working API surfaces first:

- `GET /api/health`
- `GET /api/readyz`
- `GET /api/sections/search?q=`
- `GET /api/sections/{sectionID}`
- `GET /api/people/search?q=`
- `GET /api/people/{personID}`
- `GET /api/explorer/positions`
- `GET /api/exports/positions`
- `GET /api/exports/section/{sectionID}`

Do not design the transform around future surfaces that Green Pages intentionally does not have yet, such as standalone billet detail or unified mega-search.

---

## 3. Investigation rules

1. Use real source field names, not guessed names.
2. Distinguish carefully between organization truth, billet truth, person truth, and assignment/occupant truth — these come from different datasets and must not be conflated.
3. Mark every target mapping as one of: **direct**, **transformed**, **derived**, **unresolved**, or **not used**.
4. Prefer Vantage transforms for: source cleanup, deduplication, normalization, occupancy derivation, section derivation.
5. Do not push raw-source parsing into Go unless there is no realistic alternative.

### 3.1 Legacy target-shape correction

An older source mapping used target names like `gp_users`, `gp_units`, and `gp_roster`. Those were useful as an early sketch, but they do **not** match the current Green Pages repo model.

The current target shape is:

- `organizations`
- `organization_aliases`
- `sections`
- `billets`
- `people`
- `billet_occupants`

Use those current canonical tables for the Vantage output design. Do not continue the older `gp_*` vocabulary.

### 3.2 Fact / assumption discipline

This notebook should be read with a hard distinction between:

- **verified facts**: observed in schema or sample rows,
- **working assumptions**: plausible but not proven,
- **product decisions**: choices Green Pages must make even if the data can support multiple options.

The most important verified facts right now are the file-pair mismatch, the hierarchy duplication between `unit_hierarchy` and `position_data_positions`, the confirmed absence of any `office_symbol` source field in `person`, the verified status of `mtoe.partl` as a section source for `WD83AA`, the broken `position_fmid` ↔ `smallunit_billets.billet_id` bridge, the **verified MTOE ↔ current_unit composite-key bridge** at 98.6% match rate for `WD83AA` (see §5.2), and the **verified person admin-data bridge** from `current_unit.dod_id` → `person.department_of_defense_identification_number` on the `WD83AA` sample for names, rank, email, branch, and assignment fields (see §5.3).

---

## 4. File-pair warnings (DO NOT trust filenames)

Two of the uploaded file pairs are **mislabeled**. Trust the actual column headers, not the filenames.

### 4.1 `organizations.*`
- `organizations.csv` is **org-history data**. Columns are prefixed `organization_data_history_*`, anchored on `uic`, with a `locations_*` block and `leader_position` fields.
- `organizations.json` is **NOT** the schema for that CSV. It describes a different dataset entirely — a positions/billet dataset with `positions_*` columns, anchored on `position_id`, including `positions_req_qty`, `positions_auth_qty`, `positions_pmad_qty` (authorization counts).

The two files share only 3 fields, all Foundry boilerplate (`partition`, `offset`, `source_file_path`).

### 4.2 `position_data_positions.*`
- Both `.csv` and `.json` describe **hierarchy** data, not positions. The 18-field schema is identical to `unit_hierarchy`.

### 4.3 The IPPS-A positions dataset is real but its RID is unknown
The schema returned as `organizations.json` describes a real and very useful dataset — the IPPS-A positions master with authorization counts. Locating its actual RID is an open task (see §13 Q10).

#### Known strong fields in the unlocated IPPS-A positions schema

The schema that appeared under `organizations.json` contains enough useful columns that it should be actively hunted in Vantage. Strong fields observed in that schema include:

- `position_id`
- `positions_ippsa_position_num`
- `positions_effdt`
- `positions_effdt_to`
- `positions_posn_start_dt`
- `positions_posn_term_dt`
- `positions_taabase_fmid_parent`
- `positions_admin_fmid_parent`
- `positions_drcon_fmid_parent`
- `positions_gfm_oe_long_name`
- `positions_gmf_oe_short_name`
- `positions_taabase_fmid_doc_hdr`
- `positions_taabase_parent_uic`
- `positions_taabase_parent_uic_fmid`
- `positions_admin_parent_uic`
- `positions_admin_parent_uic_fmid`
- `positions_dircon_parent_uic`
- `positions_dircon_parent_uic_fmid`
- `positions_dircon_parent_state_fmid`
- `positions_parno`
- `positions_perln`
- `positions_posco`
- `positions_mil_grade`
- `positions_branch`
- `positions_identify_cd`
- `positions_lduic`
- `positions_multi_compo_uic`
- `positions_cmd_uniq`
- `positions_fmid_reportto_drcon`
- `positions_drcon_reportto_title`
- `positions_mil_comp_cd`
- `positions_req_qty`
- `positions_auth_qty`
- `positions_pmad_qty`
- `position_topic_row_key`

If this RID is found, it may become the strongest source for stable billet identity, position graph relationships, authorization counts, and possibly section derivation through report-to grouping. Until then, it should be treated as **known but unlocated**, not as a current load source.

### 4.4 Treatment in the rest of this document
- `organizations.csv` → org-history data
- `organizations.json` → schema only, points at an unknown IPPS-A positions RID
- `position_data_positions.*` → hierarchy data, treated as a duplicate of `unit_hierarchy`
- "IPPS-A positions dataset" → referred to as a known-but-unlocated source

---

## 5. Inspection status and sample limits

The current conclusions are based on schema inspection plus small CSV samples. In the latest handoff, the inspected set was nine datasets, with most sample checks based on 20-row pulls. Those samples are enough to identify likely fields, obvious mismatches, and broken sample-level bridges, but they are **not** enough to prove full-population join rates.

Known sample-level observations:

- `unit_hierarchy`: 20 rows / 20 unique UICs.
- `position_data_positions`: 20 rows / 20 unique UICs, same 18-field schema as `unit_hierarchy`.
- `organizations.csv`: 20 rows / 1 unique UIC in sample, showing many temporal rows per UIC.
- `all_current_units_crew`: 20 rows / 2 unique UICs in sample, showing multi-row-per-UIC behavior.
- `smallunit_billets` and `person` hash samples did not overlap at small sample size; that is inconclusive, not a failed bridge.

The next investigation step should use larger targeted samples by shared UIC, especially for occupant and section-derivation tests. A first targeted test has now been completed for `WD83AA`, and it materially improves confidence in `mtoe_unit_personnel_view.partl` as a section/container source.

### 5.1 Verified targeted test: `WD83AA` / HHB DIVARTY

**Target:** `WD83AA`

**Known unit name from the pull:** `HHB, 10TH MOUNTAIN DIVISION ARTILLERY`

**Purpose of test:** prove whether Green Pages can move below the organization level and recover section-level billet structure for a real target UIC. The product path being tested is:

```text
10th Mountain Division
└── DIVARTY
    └── HHB
        └── S-3
            └── billet / role
                └── current occupant / person admin data
```

**Access method:** Foundry Python SDK using the SQL Queries API, not `readTable`.

Reason for moving beyond `readTable`:

- `readTable` is useful for raw export and random sampling.
- It does not provide a SQL-style `WHERE uic = ...` server-side filter.
- The targeted inspection needed to pull rows where `UPPER(TRIM(uic)) = 'WD83AA'`.

**Query pattern used:**

```sql
SELECT
    docno,
    parno_1,
    parno_3,
    fiscal_year,
    change_number,
    uic,
    lname,
    unit_effective_date,
    macom_text,
    unit_type,
    partl,
    suttl,
    sub_unit,
    perln,
    posco,
    posco_4,
    posco_w_text,
    posco_e_text,
    grade,
    grade_code,
    grade_text,
    psntl,
    brnch,
    austr,
    rqstr,
    ident
FROM <dataset_rid>
WHERE UPPER(TRIM(uic)) = 'WD83AA'
ORDER BY parno_1, parno_3, perln, posco
```

**Output file from successful run:** `WD83AA_mtoe_filtered.csv`

**Observed output:**

- 182 rows
- 26 columns
- `uic = WD83AA`
- `lname = HHB, 10TH MOUNTAIN DIVISION ARTILLERY`
- `unit_effective_date = 2025-10-16`
- `macom_text = US Army Forces Command`
- `unit_type = mtoe`

**Key result:** `partl` is highly useful as a section/container grouping field for this UIC.

`partl` counts from the 182-row pull:

```text
S3 SECTION                19
SUSTAINMENT SECTION       16
S1 SECTION                 9
NETWORK EXTENSION SECT     9
S2 SECTION                 8
TARGETING SECTION          8
FIRE CONTROL ELEMENT       8
ADAM/BAE SECTION           7
RANGE EXT SEC              7
SEN SECTION                7
FIRES LETHAL ELEMENT       6
TARGET PROCESSING SECT     6
LIAISON SECTION            6
CONTENT MANAGEMENT (CM     6
COMMAND SECTION            5
S4 SECTION                 5
TI&S SECTION               4
AIR SUPPORT                4
RADAR SECTION              4
ENTERPRISE MANAGEMENT      4
MEDICAL TREATMENT TEAM     4
PROPERTY BOOK OFFICE       4
NETWORK ASSURANCE (NA)     3
C4 OPS-SIGNAL OPS          3
SJA SECTION                3
BATTERY HQ                 3
SUPPLY SECTION             3
TARGET ACQ PLATOON HEA     2
S6 SECTION                 2
SIGNAL SUPPORT PLATOON     2
UNIT MINISTRY TEAM         2
AMBULANCE TEAM             2
COMBAT MEDIC SECTION       1
```

**Negative/low-value grouping fields from this test:**

- `sub_unit` was blank for all 182 rows.
- `suttl` was mostly blank; only `SENTINEL SECTION` appeared 7 times.

**Implication:** for `WD83AA`, `mtoe_unit_personnel_view.partl` is no longer just a possible section signal. It is a verified section/container source for the structural path:

```text
Organization -> Section/Container -> Billet
```

**What this test did not solve by itself:** person admin lookup. At the time of the MTOE-only pull, the final `current_unit.dod_id` → `person` lookup was still unverified. That final link has since been verified for the `WD83AA` sample in §5.3.

### 5.2 Verified targeted test: WD83AA occupant bridge (MTOE ↔ current_unit)

**Target:** same UIC as §5.1 (`WD83AA` / HHB DIVARTY).

**Purpose of test:** prove that MTOE billets can be joined to `current_unit` assignment rows on a composite paragraph/line key, and that the resulting matched pairs carry a usable `dod_id` for person lookup.

**Inputs:**
- `WD83AA_mtoe_filtered.csv` (182 MTOE billet rows; produced in §5.1)
- `WD83AA_current_unit_filtered.csv` (146 `current_unit` assignment rows; pulled by filtering the `current_unit` dataset on `uic = WD83AA`)

**Composite key formula (verified):**

```text
MTOE side:        (uic, parno_1 ‖ zfill(parno_3, 2), int(perln))
current_unit side: (uic, authorization_document_paragraph_number, int(authorization_document_line_number))
```

`parno_1 ‖ zfill(parno_3, 2)` means string-concatenate `parno_1` with `parno_3` zero-padded to 2 digits. Example: `parno_1 = 1`, `parno_3 = 05` → key paragraph component `"105"`. `current_unit.authorization_document_paragraph_number` already arrives in this combined form.

**Result for `WD83AA`:**

```text
MTOE billet keys:           182
current_unit assignment keys: 146
matched keys:                144
MTOE-only keys:               38   (first-pass vacancy candidates, pending product/data-owner confirmation)
current_unit-only keys:        2   (likely overstrength rows on paragraph 999E or unit attachments)
```

**Match rate: 144 / 146 = 98.6%** of current_unit rows aligned to a MTOE billet.

**Important distinction:** 98.6% is the `current_unit` assignment-key match rate, not the MTOE fill rate. The MTOE-side matched-key rate was `144 / 182 = 79.1%`, with the remaining 38 MTOE keys treated as first-pass vacancy candidates pending additional validation.

**Sample matches confirm the join is semantically correct, not just numerically lucky:**

```text
KEY (WD83AA, 101, 1)   MTOE psntl=COMMANDER             | current_unit duty=COMMANDER
KEY (WD83AA, 101, 3)   MTOE psntl=COMMAND SERGEANT MAJOR| current_unit duty=COMMAND SERGEANT MAJOR (CSM)
KEY (WD83AA, 102, 1)   MTOE psntl=S1                    | current_unit duty=PERSONNEL STAFF OFFICER/S1
KEY (WD83AA, 103, 1)   MTOE psntl=S2                    | current_unit duty=S2/INTELLIGENCE STAFF OFFICER
KEY (WD83AA, 105, 1)   MTOE psntl=S3                    | current_unit duty=S3/OPERATIONS STAFF OFFICER
KEY (WD83AA, 110, 1)                                    | current_unit duty=PLANS OFFICER, dod_id present
```

**Plans Officer fully resolved as a worked example:**

```text
UIC:           WD83AA
paragraph:     110
line:          1
position_fmid: 72060795911793100
position_number: 09723648
posco:         13A00
duty:          PLANS OFFICER
status:        ASSIGNED, current_assignment_indicator=True
dod_id:        present (used for next-step person lookup)
```

**Multiple `current_unit` rows per paragraph/line observed.** A small number of MTOE paragraph/line keys matched two `current_unit` rows (for example `(WD83AA, 101, 5)` VEHICLE DRIVER, `(WD83AA, 104, 3)`, and `(WD83AA, 104, 5)`). Earlier notes called these “doubly occupied billets.” After the §5.5 AOS inspection, the safer interpretation is: some duplicates may be true assignment overlap, but some may be multiple authorized IPPS-A positions under one MTOE authorization line. Until AOS/current_unit row-level equality is proven, the transform should preserve all matched occupants and choose only one primary per canonical billet/position using the §8.6 precedence rule.

**Cross-source POSCO consistency.** On every sampled match, MTOE `posco` equals `current_unit.positions_posco`. Useful as an integrity check during transform, not as a join key.

**Implication:**
- The product loop is now verified through the assignment bridge. The final `current_unit` DoD ID → `person` lookup is verified for the `WD83AA` sample in §5.3.
- Occupancy-status derivation can move from "prefer `unknown` over false `vacant`" to a confident match-based rule (see §9).
- 38 MTOE-only keys at this UIC give a realistic vacancy-candidate set to plan around.

### 5.3 Verified targeted test: `WD83AA` person admin-data bridge (sample)

**Target:** same UIC as §5.1/§5.2 (`WD83AA` / HHB DIVARTY).

**Purpose of test:** prove that the DoD IDs carried by `WD83AA` `current_unit` rows resolve cleanly into `person` and that the expected admin fields (names, rank, email, contact-field shape, specialty) are present. This was the last unverified step in the Organization → Section → Billet → Person product loop.

**Access method:** Foundry SQL filter against the `person` dataset (`ri.foundry.main.dataset.a9562d8e-92f0-4fba-8f97-d9abb3ffc522`) on `uic = 'WD83AA' OR uic_of_attachment = 'WD83AA'`. The script applied a column-exclusion list to drop sensitive personal, medical, financial, address, ASVAB, and AIM-comments fields before the data ever reached the working CSV. That exclusion list lives with the script, not in this notebook.

**Strict allowlist rule:** the script-level exclusion list is only a scratch-safety measure. The production Vantage transform should use a strict allowlist, not a broad export with a blacklist, and should emit only the fields required by `greenpages_people` and related identity/contact mappings.

**Sample size in this notebook:** 6 rows. The full `WD83AA` person pull is larger; only a 6-row sample was inspected here.

**Source-role summary:**

```text
mtoe_unit_personnel_view = billet authority and section grouping
current_unit             = primary occupancy bridge
person                   = identity, rank, contact, and person-side assignment enrichment
```

**Rows confirmed in sample (DoD IDs and names intentionally omitted from this notebook):**

```text
duty                              rank  branch / specialty
#2 FIRE SUPPORT SERGEANT          SPC   13F2O JOINT FIRE SUPPORT
STANDARD EXCESS                   1LT   25A SIGNAL  (overstrength, billet_specialty=9999 - Over Strength)
PLANS OFFICER                     CPT   13A FIELD ARTILLERY  (matches §5.2 Plans Officer)
#1 AMMUNITION SERGEANT            SGT   13B CANNON CREWMEMBER
#1 FIRE CONTROL SERGEANT          SGT   13J FIRE CONTROL
COMMUNICATION STAFF OFFICER       CPT   25A SIGNAL  (S6/StfOfcr)
```

**Verified populated on every sample row:**

- `department_of_defense_identification_number`
- `names_last_name` and `names_first_name`; `names_middle` exists and is populated where the source has a middle name or initial. Empty middle names are valid and should not be treated as data-quality failures
- `rank_true_abbreviation`, `grade`
- `dod_email` — universal in sample, well-formed `FIRSTNAME.M.LASTNAME.MIL@ARMY.MIL`
- `component` (top-level) = `Active` for all sample rows
- `military_personnel_class` = `Enlisted` or `Commissioned Officer`
- `basic_branch`, `primary_specialty_code`, `duty_specialty_code`
- `uic`, `uic_of_attachment`, `position_fmid`, `position_number`, `assignment_status`, `current_assignment_indicator`, `date_of_assignment_to_duty`, `designation_of_duties_performed`

**Plans Officer cross-check vs §5.2:**

```text
position_fmid:    72060795911793100   (matches §5.2)
position_number:  09723648            (matches §5.2)
duty:             PLANS OFFICER       (matches §5.2)
names_last_name:  present
names_first_name: present
names_middle:     present
rank:             CPT (O3)
branch:           FIELD ARTILLERY (13A)
dod_email:        present, well-formed
```

**Headline finding 1: phone fields are sparse in `phone` and `phone_duty`, but `phone_home` has high coverage.**

`phone`, `phone_duty`, and `phone_home` are source-typed arrays. The 6-row sample had empty `phone` and `phone_duty` arrays on every row, so a follow-on 4-column pull was run against the full `WD83AA` person set using only `department_of_defense_identification_number`, `phone`, `phone_duty`, and `phone_home`. Result:

```text
file: WD83AA_person_phone_rows.csv
rows: 200

phone
  filled: 23
  empty:  177

phone_duty
  filled: 6
  empty:  194

phone_home
  filled: 168
  empty:  32

any phone field
  rows with at least one: 187
  rows with none:         13
```

Product interpretation: many soldiers appear to use `phone_home` as their default/cell number because they do not have a landline. Green Pages will therefore allow `phone_home` as a fallback source for the general `Phone` value, but only under the rank-gated phone display policy in §8.5. It must not be displayed as a separate `Home phone` field.

**Headline finding 2: overstrength soldiers exist in `person`.**

The 1LT Signal row in the sample is at `WD83AA` with `current_assignment_indicator = True` and `assignment_status = ASSIGNED`, but the slot is not an MTOE billet:

- `billet_specialty = '9999 - Over Strength'`
- `designation_of_duties_performed = STANDARD EXCESS`

This row almost certainly corresponds to one of the 2 `current_unit`-only keys (paragraph `999E` / line `99`) excluded from MTOE occupancy by the §7.4 / §9 first-pass filter. The soldier is real personnel at the unit but has no MTOE billet to attach to. New product question — see §13 Q16.

**Headline finding 3: `person` is partially denormalized but does not replace `current_unit`.**

Each `person` row carries assignment fields (`uic`, `position_fmid`, `position_number`, `assignment_status`, `current_assignment_indicator`, `date_of_assignment_to_duty`, `last_position`, `last_uic`). On the 6-row sample these agree with the matched `current_unit` row. They are not, however, sufficient to replace `current_unit` as the occupancy source: `person` is one row per soldier and cannot represent all current assignment rows for a paragraph/line key, especially when AOS shows multiple IPPS-A positions can sit under one MTOE authorization line. This is the proof point for keeping `current_unit` authoritative for occupancy and using AOS mapping for position-cardinality validation.

**Treatment in the transform:** `current_unit` remains the authoritative occupancy bridge. `person` is the authoritative identity source. The denormalized assignment fields in `person` are useful as a sanity check (do they agree with the matched `current_unit` row?) but should not feed `billet_occupants`.

**Other sample observations:**

- `name_individual` formatting is inconsistent across the 6 rows. Case varies between mixed-case and uppercase, suffix handling varies, middle-name format alternates between initial and full word. Confirms the §6.9 / §8.5 rule to build display names from `names_*` parts and not from `name_individual`.
- `image_url` was populated on 1 of 6 sample rows (~17%). The URL points at a Foundry data proxy (`/foundry-data-proxy/api/web/dataproxy/datasets/...jpg`) on a different RID. Even at high coverage, a Green Pages photo feature would need backend plumbing to proxy through Vantage auth. Defer to post-MVP.
- `subcomponent` carries ACMS reporting buckets (e.g. `Active:ACMS-Force Structure Unit Pers-Avail Unknown`). Useless for directory display. Use top-level `component` only.
- `last_known_update_date` and `record_date` are not data-freshness fields. One sample row had `last_known_update_date = 2005-04-07` for a soldier who entered service in 2023. Use the dataset-level refresh time for `people.last_refreshed_at`, not a row field.

**What this sample test did not cover at the time:**

- The original 6-row sample did not cover the full `WD83AA` person population. That gap is now closed by the validated `greenpages_people_wd83aa_prototype` output in §5.8.
- Broader UIC retesting is still useful, but the immediate people bridge for WD83AA is good enough for the next prototype.

### 5.4 Verified targeted test: `WD83AA` `army_unit_auth_fms` (billet authority candidate)

**Target:** `WD83AA`, server-side filter on `uic = 'WD83AA'`.

**Source RID:** `ri.foundry.main.dataset.30228eb3-399f-48a6-b976-e3fddcb0c4b9`.

**Result counts (after correcting for embedded newlines in array-typed columns; raw `wc -l` was misleading):**

```text
rows:                          178
distinct fms_pers_auth_pk:     178   (per-row primary key)
distinct uic:                    1   (WD83AA)
distinct unit_type:              1   (mtoe)
distinct mpc_short:              3   (E, O, W)
distinct fiscal_year:            1   (26)
distinct change_number:          1   (1)
distinct unit_effective_date:    1   (2025-10-16)
```

**Headline finding 1: this dataset is a strict superset of `mtoe_unit_personnel_view` for billet authority.** Every field MTOE carried at `WD83AA` is here, plus three things we were planning to derive ourselves:

- `parno_concat` — pre-computed paragraph number; populated 178/178; sample values `101`, `102`, `103`, `104`, `105`, ... No need to apply the §5.2 zfill rule client-side.
- `grade_code` — clean form (`E3`, `E4`, `E5`, `E6`, `E7`, `E8`, `E9`, `O2`, `O3`, `O4`, `O5`, `O6`, `W2`, `W3`); populated 178/178. **Identical to `grade` on every row** (zero diffs in the 178-row pull).
- `derived_mos` — clean MOS code; populated 178/178; sample values `12Y`, `131`, `13A`, `13B`, `13F`, `13J`, `13M`, `13R`, `13Z`, `140`, `14A`, `14G`, `25A`, `25B`, `25D`, `25E`, etc.

`partl` is also populated 178/178 with the same staff-section / functional-container shape verified for MTOE in §5.1. WD83AA `partl` distribution from this pull (top values; matches §5.1 closely):

```text
S3 SECTION             19
SUSTAINMENT SECTION    16
NETWORK EXTENSION SECT  9
S1 SECTION              9
S2 SECTION              8
TARGETING SECTION       8
FIRE CONTROL ELEMENT    8
RANGE EXT SEC           7
SEN SECTION             7
ADAM/BAE SECTION        7
FIRES LETHAL ELEMENT    6
LIAISON SECTION         6
TARGET PROCESSING SECT  6
CONTENT MANAGEMENT (CM  6
S4 SECTION              5
COMMAND SECTION         5
```

**Plans Officer cross-check (parno_concat=110, perln='01'):** found, with `psntl='PLANS OFFICER'`, `grade='O3'`, `grade_code='O3'`, `mpc_short='O'`, `partl='FIRES LETHAL ELEMENT'`. Note: `partl` for the Plans Officer is *not* a clean `S?` staff section — it lives in `FIRES LETHAL ELEMENT`. This is a real product-relevant signal for §13 Q1: if the first-pass section policy is "staff sections only", the Plans Officer billet will not get a section in v1.

**Headline finding 2: `perln` is zero-padded in this dataset.** Distinct values include `01`, `02`, `03`, …, `10`, `11`, …. `mtoe_unit_personnel_view.perln` was already required to be cast to `int()` for the §7.6 bridge, so the §7.6 join rule generalizes unchanged: `(uic, parno_concat, int(perln))` ↔ `(uic, authorization_document_paragraph_number, int(authorization_document_line_number))`.

**Headline finding 3: WD83AA row-count gap to MTOE is now explained.** A follow-on reconciliation pulled `army_unit_auth_fms` and `mtoe_unit_personnel_view` for `WD83AA` and diffed billet keys at `(uic, paragraph, line)`.

```text
FMS rows:                         178
MTOE rows:                        182
FMS distinct billet keys:         178
MTOE distinct billet keys:        182
MTOE-only keys:                     4
FMS-only keys:                      0
Same-key row-count differences:     0
```

The 4 MTOE-only rows are all paragraph `107`, lines `1` through `4`, under `partl = AIR SUPPORT`:

```text
WD83AA|107|1  AIR SUPPORT  AIR FORCE STAFF OFFICE  O4  posco=01A00
WD83AA|107|2  AIR SUPPORT  AIR FORCE STAFF OFFICE  O3  posco=01A00
WD83AA|107|3  AIR SUPPORT  AIR FORCE STAFF NCO     E7  posco=00D4O
WD83AA|107|4  AIR SUPPORT  AIR FORCE STAFF NCO     E6  posco=00D3O
```

All 4 source rows carry `prmk1 = NON-ARMY POSITION (OTHER-PERS)`. This makes the 178-vs-182 gap explainable and non-blocking for the Army-focused Green Pages MVP. If Green Pages later chooses to include non-Army / other-service support billets, this exclusion must be revisited.

**Headline finding 4: TDA coverage is now verified in `army_unit_auth_fms`.** A unit-type count across `army_unit_auth_fms` returned:

```text
unit_type  row_count  uic_count
mtoe         441,689     8,146
tda          433,577     2,444
```

A targeted TDA candidate query selected `W8A5AA` and showed complete billet-authority field coverage:

```text
UIC: W8A5AA
unit_type: tda
row_count: 182
parno_concat: 182/182
perln:       182/182
grade_code:  182/182
partl:       182/182
derived_mos: 182/182
```

This verifies that `army_unit_auth_fms` is not MTOE-only and can surface TDA billet-authority rows with the same key fields needed by Green Pages. TDA occupancy matching is messier than WD83AA MTOE matching, but that affects occupant classification, not billet-authority adoption.

### 5.5 Verified targeted test: `WD83AA` `army_mtoe_aos_position_mapping` (IPPS-A position graph + MOS enrichment)

**Target:** `WD83AA`, server-side filter on `uic = 'WD83AA'`.

**Source RID:** `ri.foundry.main.dataset.af99eacf-b071-4e4d-a775-63e305b53a17`.

**Result counts (after correcting for embedded newlines):**

```text
rows total:                          224
rows current (effdt_to=2999-12-01):  216
rows historical:                       8
distinct position_id (current):      216
distinct ipps_position_number (curr):216
distinct (positions_parno, positions_perln) (current): 178
distinct unit_type:                    1   (mtoe)
distinct mpc_short:                    3   (E, O, W)
distinct fiscal_year:                  1   (25)
```

**Headline finding 1: this dataset is keyed at the IPPS-A position grain, not the MTOE billet grain.** 216 active IPPS-A positions sit on top of 178 distinct MTOE billet keys. Worked example:

```text
positions_parno=108, positions_perln='05'  (FS OPNS NCO, E7, 13F4)
  → ipps_position_number 09714008
  → ipps_position_number 09722895
```

Two IPPS-A positions, one MTOE line. This is the same multi-allocation pattern as the §5.2 multiple-row paragraph/line matches `(101,5)`, `(104,3)`, `(104,5)`, but seen from the IPPS-A side. Confirms that `(uic, paragraph, line)` is the MTOE-billet key, and `ipps_position_number` (8 digits, e.g. `09714008`) is the IPPS-A position key. The §7.6 bridge to `current_unit` keys at the MTOE-billet grain and is unaffected by this cardinality.

**Headline finding 2: temporal — needs current-row filter.** `positions_effdt_to` carries one of two values: `2999-12-01` (open / active, 216 rows) or `2025-10-16` (closed, 8 rows). `positions_effdt` ranges 2018-01-17 through 2025-10-16. Current-row filter rule: `positions_effdt_to = '2999-12-01'`. Same temporal-window pattern as `organizations.csv` but with a clean far-future sentinel instead of NULL.

**Headline finding 3: MOS_CODE and Code_Description are clean.** `MOS_CODE` populated 224/224 with composite values like `E13F4` (`E`/`O`/`W` prefix + 3-char MOS + skill level). `Code_Description` populated 224/224 with values like `13F-JOINT FIRE SUPPORT SPECIALIST`, `92Y-UNIT SUPPLY SPECIALIST`. This is the cleanest MOS source seen so far. For the `greenpages_billets` `mos_code` field (§8.4), this dataset gives a usable value without parsing `posco`.

**Headline finding 4: `partl` is NOT present in this dataset.** Confirmed by schema scan — no `partl` column. So `army_mtoe_aos_position_mapping` is **not** a complete billet-authority replacement on its own; section grouping still requires `mtoe_unit_personnel_view` or `army_unit_auth_fms`.

**Headline finding 5: org-level metadata is clean and stable per UIC.** For the `WD83AA` slice (current rows):

```text
aos_unit_size:               COY
aos_unit_type:               Headquarters and Headquarters Battery Division Artillery
aos_unit_id:                 72060794014819532
aos_unit_type_clean:         Headquarters and Headquarters Battery Division Artillery
positions_admin_parent_uic:  WD83AA
positions_dircon_parent_uic: WD83AA
positions_taabase_parent_uic:WD83AA
```

`aos_unit_id` looks like a stable org-level FMID anchor. Worth capturing as `source_org_fmid` on `greenpages_organizations` when the orgs transform is built. The three `positions_*_parent_uic` fields all point to WD83AA itself because WD83AA is the unit being inspected; for subordinate UICs they would diverge into separate parent-graph signals.

**Headline finding 6: `state_code` is empty in this dataset for `WD83AA`.** The column exists but has zero populated rows. Do not rely on it from this source; state coverage needs to come from `organizations.csv` enrichment.

**Cross-check vs `army_unit_auth_fms`:** both datasets see 178 distinct MTOE billet keys at `WD83AA`. Consistent at the billet grain. The 38-row difference (`216 IPPS-A − 178 MTOE`) is position-cardinality, not a coverage gap. More importantly, the current AOS row count by paragraph/line key exactly equals `army_unit_auth_fms.austr` across all 178 keys: `sum(austr)=216` and current AOS rows = 216. This makes `army_unit_auth_fms` the authorization-line truth and `army_mtoe_aos_position_mapping` the current IPPS-A/AOS position-cardinality truth for this WD83AA slice.

**Q18 position-number bridge verification:** a follow-on test compared current AOS rows (`positions_effdt_to = 2999-12-01`) to `current_unit` rows for `WD83AA` using `army_mtoe_aos_position_mapping.ipps_position_number` ↔ `current_unit.position_number`. A raw all-current-unit comparison returned 170 matched position numbers, 30 current_unit-only position numbers, and 46 AOS-only position numbers. The 30 current_unit-only rows were dominated by overstrength / `999*` / `9STU` / `positions_posco=NKN` rows and should not be counted as canonical billet misses.

A refined real-billet comparison excluded the obvious special/unmapped current_unit rows and produced:

```text
AOS current rows:                                  216
AOS distinct ipps_position_number:                 216
current_unit rows:                                 200
real-billet current_unit rows:                     172
excluded current_unit rows:                         28
real-billet current_unit distinct position_number: 172
matched distinct position numbers:                 170
real-billet current_unit-only distinct positions:    2
AOS-only distinct position numbers:                 46
real-billet current_unit position match rate:     98.8%
```

The 2 unmatched real-billet current_unit rows still had `authorization_document_paragraph_number = 999E`, `authorization_document_line_number = 99`, and `positions_posco = NKN`, so they look like non-canonical billet rows despite `overstrength_designation_code = NOT OVERSTRENGTH`. Decision: for the next `WD83AA` prototype, use AOS current rows as the position-level expansion of FMS authorization lines, use `ipps_position_number` as canonical `position_number`, treat AOS-only rows as likely vacant authorized positions, and exclude or separately track current_unit-only `999*`/`NKN` rows as unmapped/special personnel.

### 5.6 Verified targeted test: `WD83AA` `hrc_curated_org_hierarchy` (org parent-chain view)

**Target:** `WD83AA`, server-side filter on `zero_uic = 'WD83AA'`.

**Source RID:** `ri.foundry.main.dataset.4c466b15-7d60-462d-9524-f95b65936be1`.

**View-not-dataset note:** the Foundry catalog flags this object as a view that does not store data of its own; it represents the union of its backing datasets, similar to a database view. Treat queries against it as recomputed on demand — query stability and performance characteristics are not the same as a materialized dataset and are unverified at scale.

**Result counts (after correcting for embedded newlines in `Parent_Hierarchy_UIC` array):**

```text
rows:                                 140
distinct zero_uic:                      1   (WD83AA)
distinct first_uic:                     1   (WD83FF)
distinct second_uic:                    1   (WGKEFF)
distinct FMID:                        140
rows with first_uic populated:        140
rows with second_uic populated:       140
```

**Schema (7 columns):** `FMID`, `FMID_ippsa_dept_id`, `Parent_FMIDs`, `Parent_Hierarchy_UIC`, `zero_uic`, `first_uic`, `second_uic`.

**Headline finding 1: row grain is FMID, not UIC.** Each row is one FMID (position-level identifier in the IPPS-A position graph) anchored at the deepest-unit `zero_uic`. For the `WD83AA` slice, all 140 FMIDs roll up to `first_uic = WD83FF` and `second_uic = WGKEFF` — i.e. the parent and grandparent of WD83AA are constant across the slice.

**Headline finding 2: full parent chain is available.** `Parent_Hierarchy_UIC` carries the full ordered chain from the unit up to the top. Sample value:

```text
['WD83AA' 'WD83FF' 'WGKEFF' 'WAUKFF' 'W3YBFF' 'WARCFF' 'WDARFF']
```

That's a 7-level chain. The `zero_uic` / `first_uic` / `second_uic` columns surface only the bottom three levels; for full-tree walking, `Parent_Hierarchy_UIC` is the field to read. For the `parent_organization_id` field on `greenpages_organizations` (§8.1), `first_uic` is the immediate parent — a clean signal that doesn't require parsing arrays.

**Headline finding 3: row count does not match billet or position counts.** 140 FMIDs at `zero=WD83AA` vs 178 MTOE billets (§5.1, §5.4) vs 216 IPPS-A positions (§5.5). 38-row gap below billet count and 76-row gap below IPPS-A position count. This view is not 1:1 with billets. Hypothesis: it tracks only IPPS-A-mapped positions or only positions with a populated `FMID_ippsa_dept_id`; not yet verified. **Do not assume FMID count from this view equals billet count or position count.**

**Use-case fit:** strong for org-graph parent walking; weak as a position-cardinality source. For the future `greenpages_organizations` transform, this is the cleanest parent-UIC signal seen so far. For the `greenpages_billets` transform, do not use this view to count or enumerate billets.

### 5.7 Captured data lineage observation (for context, not verified at the data layer)

Lineage tree as observed in Vantage:

```text
mtoe_unit_personnel_view ─┐
                          ├─→ fms_unit_personnel_view ─→ army_unit_auth_fms ─→ army_mtoe_aos_position_mapping
tda_unit_personnel_view ──┘
```

That is:

- `mtoe_unit_personnel_view` and `tda_unit_personnel_view` both feed `fms_unit_personnel_view`.
- `fms_unit_personnel_view`, `mtoe_unit_personnel_view`, and `tda_unit_personnel_view` together feed `army_unit_auth_fms`.
- `army_unit_auth_fms` feeds `army_mtoe_aos_position_mapping`.

**Implication if the lineage holds at the data layer:**

- `army_unit_auth_fms` is intended to be the union of MTOE + TDA + FMS billet authorities. If true, this collapses §13 Q9 (cross-unit-type billet support) into "use this dataset and skip the union logic."
- `army_mtoe_aos_position_mapping` is intended to be `army_unit_auth_fms` enriched with the IPPS-A position graph and AOS organizational metadata.

**What's verified so far:** the §5.4 and §5.5 row counts and field shapes are consistent with the lineage description. The MTOE half of the union is present for `WD83AA`, and the TDA half is now proven at the dataset level: `army_unit_auth_fms` contains 433,577 TDA rows across 2,444 UICs. Test UIC `W8A5AA` returned 182 TDA rows with complete `parno_concat`, `perln`, `grade_code`, `partl`, and `derived_mos` coverage.

**Scope boundary now understood:** FMS does not carry a `joint` `unit_type`; its observed design is MTOE + TDA. Pure joint or other-service billet authority is outside this FMS source and outside the Army-focused MVP billet load. Army personnel assigned or attached to joint/non-Army contexts may still appear through `current_unit` and `person`, but pure other-service billets should not be expected from `army_unit_auth_fms`.


### 5.8 Built and validated: `greenpages_people_wd83aa_prototype`

**Output dataset path:** `/Army_NIPR/AI2C Analytics for Recruiting/Green Pages/datasets/greenpages_people_wd83aa_prototype`

**Output RID observed during validation:** `ri.foundry.main.dataset.77319125-d5f0-43ea-ad1d-146c27cb4dab`

**Transform status:** good for prototype use.

**Scope:** first Vantage PySpark transform only. Source is the `person` dataset (`ri.foundry.main.dataset.a9562d8e-92f0-4fba-8f97-d9abb3ffc522`) with the strict allowlist from §8.5 / §15.4 and the target filter:

```text
uic = 'WD83AA' OR uic_of_attachment = 'WD83AA'
```

**Important build/access note:** the first publish failed with `PERMISSION_DENIED (Jemma:AccessWithoutImportDenied)` because the external `person` dataset RID had not been referenced/imported into the Foundry transform project. After adding the input dataset reference at the project level, the transform published successfully. This is a Foundry project-reference/governance requirement, not a PySpark logic problem.

**Initial transform defect found during validation:** `person.grade` did not arrive as canonical values such as `E5`, `O3`, or `W2`. It arrived as long rank text such as `CAPTAIN`, `PRIVATEFIRSTCLASS`, `SPECIALIST`, and `CHIEFWARRANTOFFICER2CHIEFWARRANTOFFICERTWO`. The first phone-policy implementation expected an `E/O/W` prefix and therefore suppressed every phone field. The transform was patched to derive canonical grade codes from `rank_true_abbreviation` and fallback source grade text before applying phone policy.

**Validated canonical grade distribution:**

```text
E2: 10
E3: 36
E4: 46
E5: 22
E6: 22
E7: 16
E8: 2
E9: 2
O2: 6
O3: 16
O4: 7
O6: 1
W1: 3
W2: 11
Total: 200
```

**General quality validation:**

```text
row_count:                       200
distinct_person_ids:             200
distinct_dod_ids:                200
missing_display_name:              0
missing_normalized_display_name:   0
missing_rank:                      0
missing_grade:                     0
missing_work_email:                2
work_phone_vs_phone_mismatch:      0
```

**Rank-gated phone policy validation:**

```text
Total rows:               200
Rows with general phone:   92
Rows with duty_phone:       6
Rows with both:             5
Rows with neither:        107
```

Policy behavior by grade group:

```text
E2-E4: general phone suppressed; duty phone suppressed
E5-E8: general phone allowed; duty phone allowed when populated
E9:    general phone suppressed; duty phone allowed when populated
O2-O6: general phone allowed; duty phone allowed when populated
W1-W2: general phone allowed; duty phone allowed when populated
```

**Display-name convention update:** after validation, the transform was refined so `display_name` is user-friendly `First M. Last` rather than roster-style `Last, First M.`. The intended Green Pages user-facing label is composed at presentation time from separate fields: `rank` + `display_name` (for example `MAJ Nathan J. Hogan`). `normalized_display_name` is derived from `display_name` for search/indexing only and should not be displayed. `source_grade_normalized` is temporary inspection/debug output and is not a human display field.

**Output columns validated for prototype:**

```text
person_id
dod_id
display_name
normalized_display_name
rank
grade
source_grade_normalized
component
work_email
phone
duty_phone
work_phone
office_symbol
is_current
source_lineage
```

**Compatibility note:** `work_phone` is intentionally emitted as an alias of `phone` because the current Green Pages Postgres/API model still has `people.work_phone`. The future-shaped `phone` and `duty_phone` columns are also emitted so the transform output already reflects the later phone-model split.

**Privacy note:** validation was performed using aggregate counts only. Raw DoD IDs, names, emails, and phone numbers should not be pasted into durable notes or chat transcripts.

**Conclusion:** `greenpages_people_wd83aa_prototype` is the first successful Green Pages-shaped Vantage output. It proves the strict-allowlist person transform, canonical display-name construction, deterministic person ID generation, current-row deduping, grade normalization, and rank-gated phone shaping for the WD83AA slice.


### 5.9 Verified targeted test: `WD83AA` MTOE vs FMS row reconciliation (Q17a closeout)

**Target:** `WD83AA`, full pulls of both `mtoe_unit_personnel_view` and `army_unit_auth_fms`.

**Purpose of test:** explain the 178 (`army_unit_auth_fms`) vs 182 (`mtoe_unit_personnel_view`) row-count gap before adopting `army_unit_auth_fms` as billet authority.

**Method:** pulled both datasets for `WD83AA`. Built billet keys `(uic, paragraph, line)` on both sides — `parno_1 || zfill(parno_3, 2)` on the MTOE side and `parno_concat` on the FMS side, with `perln` normalized to an integer.

**Result:**

```text
FMS rows: 178
MTOE rows: 182

FMS distinct billet keys: 178
MTOE distinct billet keys: 182

MTOE-only keys: 4
FMS-only keys: 0
Keys with same key but different row count: 0
```

**The 4 MTOE-only rows are all paragraph 107 / `partl=AIR SUPPORT` Air Force liaison billets:**

```text
WD83AA|107|1  AIR SUPPORT  AIR FORCE STAFF OFFICE  O4  posco=01A00  prmk1=NON-ARMY POSITION (OTHER-PERS)
WD83AA|107|2  AIR SUPPORT  AIR FORCE STAFF OFFICE  O3  posco=01A00  prmk1=NON-ARMY POSITION (OTHER-PERS)
WD83AA|107|3  AIR SUPPORT  AIR FORCE STAFF NCO     E7  posco=00D4O  prmk1=NON-ARMY POSITION (OTHER-PERS)
WD83AA|107|4  AIR SUPPORT  AIR FORCE STAFF NCO     E6  posco=00D3O  prmk1=NON-ARMY POSITION (OTHER-PERS)
```

**Headline finding:** `army_unit_auth_fms` excludes these non-Army billets. The gap is definitional/scope-related, not a random missing-data issue.

**Implication for Green Pages:** for the Army-focused MVP, these 4 Air Force / other-service liaison billets should not block adoption of `army_unit_auth_fms`. If a future requirement says Green Pages must include other-service liaison billets embedded in Army MTOE structures, revisit a hybrid load: FMS primary plus MTOE-only `NON-ARMY POSITION (OTHER-PERS)` rows as billets-without-occupants.

**Decision:** Q17(a) closed. Adopt `army_unit_auth_fms` as the WD83AA billet-authority base for the next prototype.

### 5.10 Verified targeted test: `W8A5AA` TDA coverage and FMS↔current_unit bridge (Q17b closeout)

**Target:** `W8A5AA`, selected from `army_unit_auth_fms` as a strong TDA candidate with row count near WD83AA and full key-field population.

**Purpose of test:** verify that `army_unit_auth_fms` actually surfaces TDA rows and that the FMS↔current_unit composite-key bridge holds outside the WD83AA MTOE case.

**Full-population `unit_type` scan in `army_unit_auth_fms`:**

```text
unit_type  row_count  uic_count
mtoe       441,689    8,146
tda        433,577    2,444
```

No `joint` `unit_type` value appeared. The earlier “joint half” of Q17 is therefore N/A for this dataset, not an unresolved blocker.

**W8A5AA FMS field coverage:**

```text
FMS rows:     182
unit_type:    tda

parno_concat: 182/182
perln:        182/182
grade_code:   182/182
partl:        182/182
derived_mos:  182/182
```

**W8A5AA FMS↔current_unit bridge result:**

```text
FMS rows:                  182
current_unit rows:          85
FMS distinct keys:         182
current_unit distinct keys: 72

matched keys:               63
FMS-only keys:             119
current_unit-only keys:      9

current_unit row-level match rate: 63/85 = 74.1%
current_unit key-level match rate: 63/72 = 87.5%
```

**Interpretation:** the bridge logic is valid, but TDA occupancy is messier than active MTOE. The matched rows show semantic alignment between FMS `psntl` and current_unit `designation_of_duties_performed`, with POSCO agreement on sampled rows. The current_unit-only rows are mostly overstrength/attached/holding patterns (`999E`, `999F`, `999J`, `999Q`, `999T`, `999Z`, `999`, `9STU`) plus a small number of paragraph-variant/inter-UIC attachment rows. Treat these as unmapped/special personnel rather than canonical billet-authority failures.

**TDA vacancy/fill caution:** `W8A5AA` had 119 FMS-only keys out of 182 FMS billets. That is a high potential vacancy / unfilled-authorized-position rate, but plausible for a state ARNG HQ TDA. Do not treat low TDA fill as a source failure by itself.

**Decision:** Q17(b) closed for TDA. `army_unit_auth_fms` is adopted as primary billet-authority source for the next prototype. Keep conservative special-personnel classification for TDA current_unit-only rows.

### 5.11 Verified targeted test: `WD83AA` AOS ↔ current_unit position-number equality (Q18 closeout)

**Target:** `WD83AA`, current AOS rows from `army_mtoe_aos_position_mapping` and all `current_unit` rows.

**Purpose of test:** verify whether `army_mtoe_aos_position_mapping.ipps_position_number` equals `current_unit.position_number` row-for-row, so AOS can be used for position-level cardinality and MOS enrichment.

**Initial run without filtering current_unit:**

```text
AOS current rows: 216
AOS distinct ipps_position_number: 216

current_unit rows: 200
current_unit distinct position_number: 200

matched distinct position numbers: 170
current_unit-only distinct position numbers: 30
AOS-only distinct position numbers: 46

raw current_unit position-number match rate: 85.0%
```

The raw 85% result was misleading because the 30 current_unit-only rows were mostly `999E`/`99`, `9STU`/`99`, `positions_posco=NKN`, overstrength, student, standard-excess, or other special/unmapped personnel rows that AOS should not match by design.

**Real-billet filtered result:**

```text
AOS current rows:                                  216
AOS distinct ipps_position_number:                 216
current_unit rows:                                 200
real-billet current_unit rows:                     172
excluded current_unit rows:                         28
real-billet current_unit distinct position_number: 172

matched distinct position numbers:                 170
real-billet current_unit-only distinct positions:    2
AOS-only distinct position numbers:                 46

real-billet current_unit position_number match rate: 98.8%
```

**Data-quality finding:** the 2 unmatched “real-billet” current_unit rows still had `authorization_document_paragraph_number = 999E`, `authorization_document_line_number = 99`, and `positions_posco = NKN`, despite `overstrength_designation_code = NOT OVERSTRENGTH`. They look like upstream mislabeled overstrength/special-personnel rows, not true AOS misses. This is why the production transform should not rely on `overstrength_designation_code` alone; use the paragraph-pattern backstop in §9.

**Cardinality picture for WD83AA:**

```text
178  FMS authorized billet keys after non-Army filter
216  current AOS/IPPS-A positions
200  current_unit rows
170  current_unit rows on real billets matched to AOS positions
 30  current_unit rows on 999*/9STU/special paragraphs, excluded from canonical billets
 46  AOS positions with no current_unit occupant, likely vacant authorized positions
```

**2026-05-08 validated transform update:** the later `greenpages_billet_occupants_wd83aa_prototype` build observed current source drift in `current_unit`. The Q18 bridge remained clean, but current counts moved to:

```text
216  billet positions from greenpages_billets_wd83aa_prototype
198  current_unit rows after WD83AA filter
169  real-billet current_unit rows matched to billet positions
 29  current_unit rows excluded by the real-billet filter
 47  billet positions with no current_unit occupant, likely vacant authorized positions
```

Use the 2026-05-08 numbers in §18 for current WD83AA prototype contracts. Keep the earlier 200/30/170/46 figures as historical Q18 closeout context.

**Decision:** Q18 closed. Adopt `army_mtoe_aos_position_mapping` as:

1. the current IPPS-A position-cardinality source (`positions_effdt_to = '2999-12-01'`),
2. the per-position bridge to `current_unit` via `ipps_position_number == position_number`, and
3. the preferred MOS enrichment source via `MOS_CODE` / `Code_Description`.


### 5.12 Built and validated: `greenpages_billets_wd83aa_prototype`

**Output dataset path:** `/Army_NIPR/AI2C Analytics for Recruiting/Green Pages (DO NOT TOUCH!)/datasets/greenpages_billets_wd83aa_prototype`

**Observed output RID during SQL validation:** `ri.foundry.main.dataset.76fb67d0-9dc7-40a9-b805-198e91fc307a`

**Transform status:** validated for the WD83AA prototype slice.

**Grain:** position-grain, not FMS authorization-line grain.

The prototype contract is:

```text
army_unit_auth_fms = authorization-line authority
army_mtoe_aos_position_mapping = current IPPS-A/AOS position expansion and specialty enrichment
one output row = one current AOS/IPPS-A position under one FMS authorization line
```

This makes the expected WD83AA output count **216 rows**, not 178. FMS provides 178 authorization-line keys. AOS materializes the authorized strength into 216 current position rows.

**Inputs:**

```text
army_unit_auth_fms
ri.foundry.main.dataset.30228eb3-399f-48a6-b976-e3fddcb0c4b9

army_mtoe_aos_position_mapping
ri.foundry.main.dataset.af99eacf-b071-4e4d-a775-63e305b53a17
```

**Join key:** `(uic, parno_concat, perln)` on the FMS side to `(uic, positions_parno, positions_perln)` on the AOS side. Paragraph keys are normalized consistently on both sides by trimming, uppercasing, and casting purely numeric values through `int` to remove leading-zero differences. `perln` / `positions_perln` are cast to `int` for canonical comparison.

**Validated contract:**

| Stage | Expected count |
|---|---:|
| FMS auth-line keys after WD83AA filter | 178 |
| Current AOS rows after WD83AA filter | 216 |
| Output rows | 216 |
| Distinct `position_number` | 216 |
| Rows with `aos_join_status='aos_position_match'` | 216 |
| Rows with `aos_join_status='fms_without_current_aos_position'` | 0 |
| Orphan AOS positions with no FMS auth line | 0 |

**Specialty derivation source attribution from WD83AA validation:**

| Source | Rows |
|---|---:|
| AOS `Code_Description` prefix | 216 |
| FMS `derived_mos` fallback | 0 |
| AOS `MOS_CODE` substring fallback | 0 |

This means AOS `Code_Description` supplied 100% of specialty enrichment for WD83AA. The fallback paths are implemented, but were not exercised on this slice. Any future UIC onboarding should re-run the specialty-source-attribution diagnostic before trusting those fallback paths.

**Important implementation decisions:**

- `position_number` comes from `army_mtoe_aos_position_mapping.ipps_position_number`.
- `prototype_billet_key` is deterministic and derived from UIC, paragraph, line, and position number.
- The transform does **not** join `current_unit`; occupancy remains `unknown` at this stage.
- The transform does **not** emit final Green Pages database IDs like `billet_id`, `organization_id`, or `section_id`.
- FMS-side overstrength / `999*` / `9STU` filtering is **not** applied here; that rule belongs to `current_unit`, not FMS.
- `component='Active'` is currently gated by `ACTIVE_MTOE_PROTOTYPE_UICS = {'WD83AA'}`. This is a prototype guard, not a production derivation. Production should derive component from an authoritative source field rather than expanding this allowlist indefinitely.
- `section_display_name` now uses `section_name` directly. The earlier `section_code`-preferred rule produced short `S1`/`S2`/`S3` labels while other sections retained full labels. The source `section_name` already carries the canonical display form, for example `S3 SECTION`.
- `macom_text`, `prmk1`, `sub_unit`, and `suttl` are optional enrichment/debug fields, not required billet-contract fields.
- `positions_effdt_to` is filtered with `startswith('2999-12-01')` to tolerate either date-string or timestamp-string representations. This should be tightened to equality once the emitted dtype is confirmed.

**Strictness rules added:**

- Missing required source columns fail the build.
- Malformed paragraph/line keys fail the build.
- Duplicate FMS authorization-line keys fail the build.
- Duplicate current AOS `(auth_line_key, position_number)` rows fail the build.
- FMS authorization lines without current AOS positions fail the build.
- Current AOS positions without matching FMS authorization lines fail the build.
- Output row count must match the validated WD83AA expected count of 216.
- Non-deterministic row timestamps were removed from output; Foundry build metadata should carry build time.

### 5.13 Built and validated: `greenpages_billet_occupants_wd83aa_prototype`

**Output dataset path:** `/Army_NIPR/AI2C Analytics for Recruiting/Green Pages (DO NOT TOUCH!)/datasets/greenpages_billet_occupants_wd83aa_prototype`

**Output RID:** `ri.foundry.main.dataset.fd7f2a5e-e69d-43ab-a3e9-704bac1c8846`

**Transform status:** validated for the WD83AA prototype slice.

**Grain:** occupant-grain.

The prototype contract is:

```text
greenpages_billets_wd83aa_prototype = position-grain billet structure
current_unit = authoritative occupancy bridge
greenpages_people_wd83aa_prototype = identity/contact/person enrichment
one output row = one real current_unit occupant matched to one billet position and one person
```

**Inputs:**

```text
greenpages_billets_wd83aa_prototype
/Army_NIPR/AI2C Analytics for Recruiting/Green Pages (DO NOT TOUCH!)/datasets/greenpages_billets_wd83aa_prototype

current_unit
ri.foundry.main.dataset.d62e2749-db98-4675-b9f9-bed4e3739657

greenpages_people_wd83aa_prototype
/Army_NIPR/AI2C Analytics for Recruiting/Green Pages (DO NOT TOUCH!)/datasets/greenpages_people_wd83aa_prototype
```

**Join keys:** billets ↔ `current_unit` on `position_number` using the Q18-validated bridge. `current_unit` ↔ people on DoD ID. The transform also derives `current_unit_auth_line_key` from `current_unit.authorization_document_paragraph_number` and `current_unit.authorization_document_line_number`, then asserts it equals the billet `auth_line_key` after the position-number join. This validates that each matched `position_number` remains bound to the expected FMS/AOS authorization line.

**Real-billet filter (§9):** exclude rows when any of the following are true:

- `overstrength_designation_code = 'OVERSTRENGTH'`
- `authorization_document_paragraph_number` starts with `999`
- `authorization_document_paragraph_number = '9STU'`
- `positions_posco = 'NKN'`

For Vantage SQL console diagnostics, use `LIKE '999%'` for the paragraph-prefix check when `RLIKE` is unsupported.

**Current validated WD83AA source truth as of 2026-05-08:**

| Stage | Expected count |
|---|---:|
| Billet positions from billet prototype | 216 |
| `current_unit` rows after WD83AA filter | 198 |
| Excluded by real-billet filter | 29 |
| Real-billet `current_unit` rows | 169 |
| Vacant billet positions (billets minus occupants) | 47 |
| `greenpages_people_wd83aa_prototype` rows | 200 |
| Output occupant rows | 169 |
| Orphan `current_unit` positions with no billet | 0 |
| Auth-line-key disagreements after position join | 0 |
| Unresolved DoD IDs (`current_unit` row → no person) | 0 |
| Rows with parsed `effective_date` | 169 |
| `assignment_status` mappable to canonical `active` | 169 |

This supersedes the earlier handoff expectation of `200 total current_unit rows / 30 excluded / 170 real / 46 vacant`. The bridge remains clean; the current source counts drifted.

**Real-billet exclusion distribution from current_unit:**

| Classification | Rows |
|---|---:|
| real_billet | 169 |
| overstrength_designation_code | 27 |
| paragraph_999_pattern | 2 |
| paragraph_9STU | 0 |
| positions_posco_NKN | 0 |

No `9STU` or `positions_posco = NKN` exclusions appeared in the latest WD83AA count split, but those exclusion rules remain part of the broader real-billet filter contract because they were established during Q18 closeout.

**Validated output checks:**

```text
row_count:                         169
occupied_billet_count:             169
occupied_position_count:           169
distinct_people:                   169
distinct_dod_ids:                  169
missing_effective_date_rows:         0
assignment_status: active / ASSIGNED = 169
auth_line mismatches:                0
duplicate billet_occupant_source_key rows: 0
```

**Section occupancy distribution:**

```text
SUSTAINMENT SECTION          21
S3 SECTION                   20
NETWORK EXTENSION SECT       11
FIRE CONTROL ELEMENT         10
SEN SECTION                  10
TARGETING SECTION            10
S1 SECTION                    7
LIAISON SECTION               6
RANGE EXT SEC                 6
ADAM/BAE SECTION              5
COMMAND SECTION               5
RADAR SECTION                 5
S2 SECTION                    5
S4 SECTION                    5
TARGET PROCESSING SECT        5
FIRES LETHAL ELEMENT          4
MEDICAL TREATMENT TEAM        4
PROPERTY BOOK OFFICE          4
TI&S SECTION                  4
BATTERY HQ                    3
CONTENT MANAGEMENT (CM        3
SJA SECTION                   3
ENTERPRISE MANAGEMENT         2
S6 SECTION                    2
UNIT MINISTRY TEAM            2
AMBULANCE TEAM                1
C4 OPS-SIGNAL OPS             1
COMBAT MEDIC SECTION          1
NETWORK ASSURANCE (NA)        1
SIGNAL SUPPORT PLATOON        1
SUPPLY SECTION                1
TARGET ACQ PLATOON HEA        1
```

**Important implementation decisions:**

- `is_primary=True` is currently gated by `SINGLE_PRIMARY_OCCUPANT_PROTOTYPE_UICS = {'WD83AA'}` and backed by a uniqueness assertion on `position_number` in `current_unit_real`.
- Future UICs with dual-hatted positions, attached personnel overlap, or legitimate multi-occupant billets should not use the `is_primary=True` hardcode. They need explicit primary-selection logic.
- `current_unit.date_of_assignment_to_duty` is required for this slice and parsed into `effective_date`. WD83AA validated with 169/169 parsed dates.
- The date parser currently supports `yyyy-MM-dd`, ISO timestamp prefix, `MM/dd/yyyy`, and `yyyyMMdd`. Future UIC onboarding should inspect the dominant source format and tighten the parser if one format is confirmed.
- The transform uses a left join to people and then asserts no unresolved people rows. This is more diagnostic than an inner join because it fails with a clear person-resolution error instead of silently dropping rows.

## 6. Dataset inventory

### 6.1 `unit_hierarchy`
- **Shape:** 18 fields. **Row uniqueness: 1 row per UIC** (20/20 in sample).
- **Strong fields:** `uic`, `parent_uic`, `uic_hierarchy`, `uic_long_name`, `uic_short_name`, `uic_name_aliases`, `administrative_control_parent_uic`, `operational_control_parent_uic`, `uic_source`.
- **First-pass verdict:** Cleanest backbone for canonical `organizations` and `organization_aliases`. Hierarchy arrays can be passed near-directly. Names are sometimes raw/code-like and likely need enrichment from `organizations.csv`.

### 6.2 `position_data_positions`
- **Shape:** 18 fields, identical schema to `unit_hierarchy`. **Row uniqueness: 1 row per UIC** (20/20 in sample).
- **First-pass verdict:** Likely a substitute for `unit_hierarchy`. Pick one. Decision is probably arbitrary — choose by row count, alias coverage, and null rates on names. Do not load both.

### 6.3 `organizations.csv` (org-history)
- **Shape:** 110 columns. **Row uniqueness: MANY rows per UIC** (20 rows for 1 UIC in sample, all with `effdt_to` in the past — temporal history).
- **Requires a current-row filter.** Likely rule: `effdt_to IS NULL OR effdt_to >= TODAY()`, or `ROW_NUMBER() OVER (PARTITION BY uic ORDER BY effdt DESC) = 1`. Exact rule unconfirmed.
- **Strong fields:**
  - Core: `organization_id`, `ippsa_deptid`, `organization_data_history_uic`
  - Names: `organization_data_history_uic_short_description`, `organization_data_history_uic_long_description`, `organization_data_history_uic_gfm_short_description`, `organization_data_history_uic_gfm_long_description`
  - Parents: `organization_data_history_taabase_parent_uic`, `organization_data_history_admin_parent_uic`, `organization_data_history_dircon_parent_uic`
  - Component: `organization_data_history_gfm_component_code` (vocab: `NG_FED`, `ARMY`, ...)
  - Locations block: `locations_country`, `locations_city`, `locations_state`, `locations_postal`, `locations_address`
  - Leader pointer: `organization_data_history_leader_position_fmid`, `organization_data_history_leader_position_title`
- **First-pass verdict:** Strongest enrichment dataset for org display names, locations, leader pointer, and component. Not the hierarchy backbone — that role goes to `unit_hierarchy`.

### 6.4 `all_current_units_crew`
- **Shape:** 73 fields. **Row uniqueness: MULTI rows per UIC** (20 rows / 2 unique UICs in sample). Likely also needs a current-row filter despite the dataset name.
- **Strong fields:** `uic`, `mtoe_uic`, `name_txt`, `unit_type`, `gfm_alt_nm`, `gfm_dscr_lname`, `gfm_sname`, `uic_aname`, `uic_lname`, `parent_dircon_uic`, `parent_admin_uic`, `dircon_hierarchy`, `admin_hierarchy`, `gfm_component_cd` (vocab: `RESERV`, ...), `service_code`, `lduic`, `parno`, `docno`.
- **First-pass verdict:** Useful enrichment for org names/aliases. Not primary org backbone — likely has non-Army/JOINT records and rows missing UIC. Best use: alias enrichment, possibly billet→org bridging through `lduic`/`docno`.

### 6.5 `mtoe_unit_personnel_view`
- **Shape:** 53 fields.
- **Strong fields:** `uic`, `lname`, `docno`, `parno_1`, `parno_3`, `perln`, `posco`, `grade`, `grade_code`, `grade_text`, `psntl` (billet title), `brnch`, `unit_type`, `partl`, `suttl`, `sub_unit`, `uicdr`, `macom_text`, `austr` (authorized), `rqstr` (required).
- **Section/container signal — verified `WD83AA` values in `partl`:**
  - staff-section values: `S1 SECTION`, `S2 SECTION`, `S3 SECTION`, `S4 SECTION`, `S6 SECTION`, `SJA SECTION`
  - functional/grouping values: `SUSTAINMENT SECTION`, `TARGETING SECTION`, `FIRE CONTROL ELEMENT`, `ADAM/BAE SECTION`, `BATTERY HQ`, `SUPPLY SECTION`, `COMBAT MEDIC SECTION`
- **Earlier 20-row samples also showed other `partl` values** such as `HOWITZER SECTION`, `COMPANY HEADQUARTERS`, and `MILITARY POLICE SQUAD`. Those values should not be read as part of the verified `WD83AA` result.
- **`sub_unit` note:** earlier small samples showed code-like values such as `A0`, `B0`, `C0`, `D0`, and `T0`, but the targeted `WD83AA` pull had `sub_unit` blank for all 182 rows. Do not treat `sub_unit` as a reliable section source right now.
- **First-pass verdict:** Strongest first billet-authority source. Already close to canonical billet shape: UIC + paragraph + line + position code + title + grade + branch + auth counts. Also currently the strongest section-derivation source via `partl` — see §8.3.
- **Targeted verification:** A server-side filtered Foundry SQL pull for `WD83AA` returned 182 rows for `HHB, 10TH MOUNTAIN DIVISION ARTILLERY`; `partl` produced useful section/container groupings including `S3 SECTION` (19 rows), `SUSTAINMENT SECTION` (16), `S1 SECTION` (9), `S2 SECTION` (8), `FIRE CONTROL ELEMENT` (8), `S4 SECTION` (5), and `S6 SECTION` (2).

### 6.6 `fms_unit_personnel_view`
- **Shape:** 40 fields.
- **Strong fields:** `uic`, `lname`, `docno`, `unit_type`, `brnch`, `posco`, `grade`, `psntl`, `austr` (`total_austr`), `rqstr` (`total_rqstr`), `parno_1`, `parno_3`, `perln`, `derived_mos`, `person_type`, `special_qualification`.
- **First-pass verdict:** Same shape as MTOE but leaner; less section signal than MTOE. Useful for comparison/coverage gaps and possibly garrison/TDA-only units. Not the primary billet source.

### 6.7 `smallunit_billets`
- **Shape:** 67 fields.
- **Strong fields:**
  - Identity: `billet_id` (17-digit), `mtoe_uic`, `posco`, `grade`, `mos`, `branch_code`, `parno`, `perln`, `position_number`, `docno`
  - Display: `billet_name`, `short_name`, `description`, `rank_description`, `mos_description`
  - Container: `smallunit_id`, `smallunit_name`, `platoon_id`, `platoon_name`, `unit_description`
  - Occupancy: `assigned_soldier_ssn_hash`, `assigned_arrival_date`, `assigned_last_updated`, `is_temporary`
  - Vantage-side occupancy: `is_vantage_assigned`, `vantage_assigned_soldier_ssn_hash`
  - Hierarchy: `uic_hierarchy`, `full_hierarchy`, `admin_hierarchy`
- **Section signal — concrete sample values in `smallunit_name`:**
  - `S6 SECTION`, `G7`, `MORTAR SECTION`
  - `COMPANY HEADQUARTERS`, `MAINTENANCE SUPPORT ELEMENT`
  - `3RD RIFLE SQUAD`, `MORTAR PLATOON`, `A COMPANY`
- **First-pass verdict:** Promising supplemental source for tactical/lower-echelon decomposition. The two `assigned_*` column families need a product decision (see §8.6 and §13 Q13) before this is used for occupancy.

### 6.8 `current_unit`
- **Shape:** 47 fields.
- **Strong fields:** `member_id`, `department_of_defense_identification_number`, `social_security_number_hash`, `uic`, `position_fmid`, `position_number`, `assignment_id`, `assignment_status`, `current_assignment_indicator`, `authorization_document_paragraph_number`, `authorization_document_line_number`, `date_of_assignment_to_duty`, `designation_of_duties_performed`, `calculated_position`, `state_location_unit`, `last_position`, `last_uic`, `next_position`, `next_uic`, `positions_gfm_oe_long_name`, `positions_gmf_oe_short_name`, `positions_posco`, `positions_drcon_fmid_parent`, `positions_fmid_reportto_drcon`.
- **First-pass verdict:** Best occupant/assignment bridge. Carries DoD ID, UIC, paragraph, line, position number, `position_fmid`, source duty title, calculated position, and position graph clues.
- **Targeted verification (`WD83AA`):** server-side filter pulled 146 rows. 144 of those (98.6% of current-unit assignment keys) join cleanly to MTOE billets via the composite key `(uic, paragraph, line)`. Every matched row carried a populated DoD ID and a populated `position_fmid`. See §5.2 for the full result and §7.6 for the bridge entry.
- **Overstrength/attachment caution:** rows with `authorization_document_paragraph_number = '999E'` and `authorization_document_line_number = '99'` appeared in the pull and should not be treated as normal MTOE billet occupants during the first-pass structural join. Keep them visible in investigation output, but exclude them from the first-pass MTOE occupancy match unless product/data owners decide otherwise.

### 6.9 `person`
- **Shape:** 295 fields. Sample row format `name_individual` is space-separated (no comma) and inconsistent across rows: case varies between mixed-case and uppercase, suffix handling varies, middle name is sometimes a single initial and sometimes a full word. **Do not display `name_individual` directly** — build display name from `names_*` parts.
- **Strong fields:**
  - Identity: `department_of_defense_identification_number`, `edipi`, `member_id`
  - Names: `names_last_name`, `names_first_name`, `names_middle`, `names_name_suffix`, `name_individual`
  - Rank: `grade`, `rank_true_abbreviation`, `fms_rank_code`
  - Contact: `dod_email`, `phone` (ARRAY), `phone_duty` (ARRAY), `phone_home` (ARRAY; fallback only, never displayed as `Home phone`)
  - Component: top-level `component` is clean (`Active`, `Reserve`, ...). `subcomponent` carries ACMS reporting buckets and is **not** directory-relevant. `military_personnel_class` (`Enlisted` / `Commissioned Officer`) is useful for rank-group derivation.
  - Current assignment (denormalized; see "Partial denormalization" below): `uic`, `uic_of_attachment`, `position_fmid`, `position_number`, `assignment_status`, `current_assignment_indicator`, `date_of_assignment_to_duty`, `designation_of_duties_performed`, `billet_specialty`, `last_position`, `last_uic`
  - Specialty: `primary_specialty_code`, `primary_specialty_description`, `duty_specialty_code`, `basic_branch`
  - Image: `image_url` — when present, points at a Foundry data-proxy URL on a separate RID; only ~17% populated in the `WD83AA` 6-row sample. Defer to post-MVP.
- **Confirmed absent:** no `office_symbol` or `office_*` field of any kind. The §13 Q3 question is now closed on the source side; the product decision (drop / derive / seed) is what remains.
- **Phone field type caveat:** `phone`, `phone_duty`, and `phone_home` are ARRAY of strings, not scalar STRING. The transform must pick one element per allowed array (recommended: first non-empty), not write the whole array. In the full `WD83AA` 4-column phone pull, `phone` was populated on 23/200 rows, `phone_duty` on 6/200 rows, and `phone_home` on 168/200 rows; 187/200 rows had at least one phone field and 13/200 had none. `phone_home` is allowed only as a fallback source for the general `Phone` value under the rank-gated policy in §8.5.
- **Partial denormalization.** `person` carries assignment fields (`uic`, `position_fmid`, `position_number`, `assignment_status`, `current_assignment_indicator`, `date_of_assignment_to_duty`, `last_position`, `last_uic`) that overlap with `current_unit`. On the `WD83AA` sample these agree with `current_unit`, but `person` is one row per soldier and cannot represent multiple current assignment rows under one paragraph/line or AOS position-cardinality edge cases. **Treatment:** `current_unit` is the authoritative occupancy source; `person` is the authoritative identity source; the denormalized fields in `person` are a sanity-check signal only.
- **Overstrength rows are visible in `person`.** Soldiers attached to a UIC without an MTOE billet appear with `billet_specialty = '9999 - Over Strength'` and `designation_of_duties_performed = 'STANDARD EXCESS'`. They are real personnel records but should not flow into `billet_occupants`. See §13 Q16.
- **First-pass verdict:** Best person-identity source. See §5.3 for the verified sample bridge.


### 6.10 `army_unit_auth_fms`
- **RID:** `ri.foundry.main.dataset.30228eb3-399f-48a6-b976-e3fddcb0c4b9`.
- **Lineage (per §5.7):** receives from `mtoe_unit_personnel_view`, `tda_unit_personnel_view`, and `fms_unit_personnel_view`. It is the unified Army billet-authority source for MTOE and TDA.
- **Verified `unit_type` cardinality (2026-05-06):** `mtoe` = 441,689 rows / 8,146 UICs; `tda` = 433,577 rows / 2,444 UICs. No `joint` value exists in this dataset.
- **Shape:** 396 columns. Per-row primary key: `fms_pers_auth_pk` (verified unique on the `WD83AA` 178-row pull).
- **Strong fields (billet authority):** `fms_pers_auth_pk`, `uic`, `parno_1`, `parno_3`, `perln`, `parno_concat`, `partl`, `psntl`, `posco`, `grade`, `grade_code`, `mpc_short`, `unit_type`, `brnch`, `derived_mos`, `austr`, `rqstr`, `total_austr`, `total_rqstr`, `fiscal_year`, `change_number`, `unit_effective_date`, `lname`, `docno`.
- **Strong fields (org enrichment carried alongside):** `parent_uic`, `uic_name`, `uic_hierarchy`, `uic_name_aliases`, `component`, `unit_echelon`, `major_cmd_nm`, `major_cmd_uic`, `unit_branch`, `aos_unit_size`, `aos_unit_type`, `aos_unit_id`, `aos_unit_type_clean`, `gfm_alias`, `usafmsa_org_type`, `unit_geographic_locations`, `unit_home_geographic_location_name`, `corps`, `division`, `division_artillery`, `brigade`, `battalion`, `company`, `CompanyName`, `BattalionName`, `BrigadeName`, `DivisionName`.
- **First-pass verdict:** **Adopted as primary billet-authority source for the next `greenpages_billets` prototype.** Q17(a) and Q17(b) are closed: the WD83AA 178-vs-182 gap is explained by non-Army `AIR SUPPORT` rows, and TDA coverage is verified at both dataset level and W8A5AA sample level.
- **Bridge to `current_unit`:** `(uic, parno_concat, int(perln))` ↔ `(uic, authorization_document_paragraph_number, int(authorization_document_line_number))`. This supersedes the earlier MTOE-only bridge because FMS is now the adopted billet authority.
- **TDA coverage caveat:** during TDA candidate scanning, some TDA UICs had low or zero `grade_code` / `derived_mos` coverage even though `partl`, `parno_concat`, and `perln` were populated. Production transform should fall back to `posco` parsing where `grade_code` or `derived_mos` is empty.
- **Scope-by-design caveat:** non-Army liaison billets encoded in MTOE as `NON-ARMY POSITION (OTHER-PERS)` do not appear in FMS. For WD83AA this excludes 4 `AIR SUPPORT` rows. Treat this as an MVP scope decision, not a source-quality failure.

### 6.11 `army_mtoe_aos_position_mapping`
- **RID:** `ri.foundry.main.dataset.af99eacf-b071-4e4d-a775-63e305b53a17`.
- **Lineage (per §5.7):** downstream of `army_unit_auth_fms`. Intended as FMS authority enriched with IPPS-A/AOS position graph metadata.
- **Shape:** 435 columns. Per-row primary key: `position_id` (verified unique on the `WD83AA` 224-row pull). Row grain is **IPPS-A position**, not FMS/MTOE authorization line. Multiple positions per authorization line are normal and meaningful.
- **Temporal:** active/current rows have `positions_effdt_to = '2999-12-01'`. This is the verified current-row filter. On the WD83AA pull it retained 216 of 224 rows.
- **Strong fields (position graph):** `position_id`, `ipps_position_number`, `positions_admin_parent_uic`, `positions_admin_fmid_parent`, `positions_dircon_parent_uic`, `positions_drcon_fmid_parent`, `positions_taabase_fmid_parent`, `positions_taabase_parent_uic`, `positions_mil_comp_cd`, `positions_lduic`, `positions_mil_grade`, `positions_posco`, `positions_parno`, `positions_perln`, `positions_branch`, `positions_asi_1` through `positions_asi_4`.
- **Strong fields (MOS enrichment):** `MOS_CODE` (composite, e.g. `E13F4`) and `Code_Description` (e.g. `13F-JOINT FIRE SUPPORT SPECIALIST`). Both were populated on the WD83AA pull and are the cleanest MOS source seen so far.
- **Strong fields (org/AOS metadata):** `aos_unit_size`, `aos_unit_type`, `aos_unit_id`, `aos_unit_type_clean`, `organization_id`, and denormalized `organization_data_history_*` snapshot fields.
- **Confirmed absent / weak for WD83AA:** no `partl` column; `state_code` exists but was empty. Do not use this dataset as standalone billet authority or section source.
- **First-pass verdict:** **Adopted as IPPS-A position-cardinality and MOS enrichment source** for the next `greenpages_billets` prototype. Use AOS current rows to expand FMS authorization lines to position-level rows, use `ipps_position_number` as the position-grain key, and use `MOS_CODE` / `Code_Description` for MOS enrichment.
- **Q18 verification:** `ipps_position_number` ↔ `current_unit.position_number` is verified at 98.8% on WD83AA real-billet rows and effectively 100% after paragraph-pattern filtering removes two mislabeled `999E` rows. AOS-only positions are likely vacant authorized positions.

### 6.12 `hrc_curated_org_hierarchy`
- **RID:** `ri.foundry.main.dataset.4c466b15-7d60-462d-9524-f95b65936be1`.
- **Object type: VIEW, not a dataset.** Foundry catalog flags this as a view that represents the union of its backing datasets. Treat queries as recomputed on demand. Stability and performance at scale are unverified.
- **Shape:** 7 columns. Row grain: **FMID** (one row per FMID anchored at `zero_uic`).
- **Strong fields:** `FMID`, `FMID_ippsa_dept_id`, `Parent_FMIDs`, `Parent_Hierarchy_UIC` (full ordered parent chain, array form), `zero_uic`, `first_uic`, `second_uic`.
- **Verified counts (`WD83AA` slice):** 140 rows; all share `first_uic = WD83FF` and `second_uic = WGKEFF`; full chain `WD83AA → WD83FF → WGKEFF → WAUKFF → W3YBFF → WARCFF → WDARFF` (7 levels deep).
- **First-pass verdict:** Strong candidate for the org-graph parent-walking source on the future `greenpages_organizations` transform. `first_uic` is the immediate parent and is the cleanest single-column source for `parent_organization_id` (§8.1). For full-tree walking, read `Parent_Hierarchy_UIC`.
- **Adoption cautions:**
  - View-not-dataset; query stability/performance not verified at scale.
  - Row count (140 FMIDs at `zero=WD83AA`) does not match billet count (178) or IPPS-A position count (216). Do not use this view for billet enumeration or as a position-cardinality source.

---

## 7. Verified bridges and broken bridges

This section captures join keys that have been tested against real sample rows. Confirmed-broken bridges matter as much as confirmed-working ones.

### 7.1 ❌ BROKEN: `position_fmid` ↔ `smallunit_billets.billet_id`
Both are 17-digit identifiers, but in inspected sample data:
- 0 matches between `person.position_fmid` and `smallunit_billets.billet_id`
- 0 matches between `current_unit.position_fmid` and `smallunit_billets.billet_id`

**Conclusion:** They are different identifier spaces. `position_fmid` belongs to the enterprise IPPS-A/FMID position graph (`person`, `current_unit`, IPPS-A positions dataset). `billet_id` belongs to a separate smallunit object model. Same length, same digit count, **not the same key**.

### 7.2 ✅ Verified for admin fields (`WD83AA` sample): `person.dod_id` ↔ `current_unit.dod_id`
The DoD ID join from `current_unit` to `person` is verified for the `WD83AA` 6-row sample. Every sample row resolved cleanly and produced populated `names_*`, `rank_true_abbreviation`, `grade`, `dod_email`, `basic_branch`, and specialty fields. The Plans Officer row from §5.2 (DoD ID present, `position_fmid 72060795911793100`) cross-checks consistently against the `person` side. `edipi` is present in `person` and should be used as a validation cross-check against `department_of_defense_identification_number`, not as the primary join unless the primary field is absent or a data owner directs otherwise. Phone-field coverage has now been measured on the full `WD83AA` 4-column phone pull: `phone` 23/200, `phone_duty` 6/200, `phone_home` 168/200, at least one phone field 187/200, none 13/200. See §5.3 and §8.5 for the rank-gated display policy.

### 7.3 ⚠ Partially testable: `person.ssn_hash` ↔ `smallunit_billets.assigned_soldier_ssn_hash`
The 20 ssn_hashes from one sample did not overlap with the 10 from another sample. Expected for two independent 20-row pulls. Not proof the join fails — needs larger samples (1000+) to verify at scale.

### 7.4 ✅ Likely working: org joins
- `person.uic` ↔ `unit_hierarchy.uic` ↔ `smallunit_billets.mtoe_uic` ↔ `current_unit.uic`
- Child UIC `parent_uic` resolution from `unit_hierarchy` for org tree

### 7.5 ✅ Probable: MTOE ↔ smallunit composite-key bridge
- `smallunit_billets.(mtoe_uic, docno, parno, perln)` ↔ `mtoe_unit_personnel_view.(uic, docno, parno_1, perln)`

This is the **only credible bridge** between the smallunit world and the FMID world, since `position_fmid` ≠ `billet_id`. **Lower priority than §7.6** — with the verified MTOE ↔ current_unit bridge at 98.6% match rate, `smallunit_billets` is no longer needed as a primary occupancy source. Treat as supplemental for tactical decomposition only, if product wants it.

### 7.6 ✅ VERIFIED at scale (`WD83AA`): MTOE ↔ current_unit composite-key bridge

`mtoe_unit_personnel_view.(uic, parno_1 ‖ zfill(parno_3, 2), int(perln))` ↔ `current_unit.(uic, authorization_document_paragraph_number, int(authorization_document_line_number))`

**Match result for `WD83AA`:** 144 of 146 `current_unit` rows matched a MTOE billet (98.6%). 38 MTOE-only keys are interpreted as vacant billets (pending product confirmation). 2 `current_unit`-only rows likely correspond to overstrength entries (paragraph `999E`) or attachments not represented in MTOE.

**Sample matches confirm semantic alignment, not just numeric coincidence:**

```text
KEY (WD83AA, 101, 1)   MTOE psntl=COMMANDER             ↔ current_unit duty=COMMANDER
KEY (WD83AA, 102, 1)   MTOE psntl=S1                    ↔ current_unit duty=PERSONNEL STAFF OFFICER/S1
KEY (WD83AA, 103, 1)   MTOE psntl=S2                    ↔ current_unit duty=S2/INTELLIGENCE STAFF OFFICER
KEY (WD83AA, 105, 1)   MTOE psntl=S3                    ↔ current_unit duty=S3/OPERATIONS STAFF OFFICER
KEY (WD83AA, 110, 1)   MTOE row exists                  ↔ current_unit duty=PLANS OFFICER
```

**This bridge is now the canonical MTOE → current_unit join for the Vantage transform.** It also resolves the long-standing question of how to attach occupants to billets without a stable shared identifier: the composite key works, the `position_fmid` is supplemental within the FMID graph but not required for the join.

**Multiple rows per paragraph/line are real.** A small number of paragraph/line keys matched two `current_unit` rows (for example VEHICLE DRIVER at paragraph 101 / line 5). After the AOS inspection, treat these as multiple-assignment or multiple-position cardinality cases until row-level `current_unit` ↔ AOS equality is proven. The transform must preserve all matched occupants and select one primary; see §8.6 and §9 for the rule.

### 7.7 Implication for canonical billet identity
The composite natural key `(uic, paragraph, line, position_number)` is the only key shape that spans every billet-bearing source. The MTOE ↔ current_unit subset of this key, `(uic, paragraph, line)`, is **verified at 98.6% match rate** for `WD83AA` and is the recommended primary join inside the FMID graph.

`position_fmid` is reliable **within** the FMID graph (`person`, `current_unit`, IPPS-A positions dataset) and every matched `current_unit` row at `WD83AA` carried one. It does **not** reach `smallunit_billets`. Treat `position_fmid` as supplemental for the FMID graph, not the primary join.

---


### 7.8 ✅ VERIFIED for MTOE and TDA: `army_unit_auth_fms` ↔ `current_unit` composite-key bridge

`army_unit_auth_fms.(uic, parno_concat, int(perln))` ↔ `current_unit.(uic, authorization_document_paragraph_number, int(authorization_document_line_number))`.

This is the production bridge of record because `army_unit_auth_fms` is now the adopted billet-authority source. It has the same shape as the earlier MTOE-only bridge, but uses FMS's pre-computed `parno_concat` instead of rebuilding paragraph number from `parno_1` and `parno_3`.

Verified examples:

| UIC | Unit type | FMS billet keys | current_unit distinct keys | Matched keys | current_unit-only keys | Key-level match | Notes |
|---|---|---:|---:|---:|---:|---:|---|
| `WD83AA` | MTOE | 178 FMS keys | comparable to earlier 146 CU keys | 144 in MTOE baseline | 2 | 98.6% in MTOE baseline | 4 non-Army MTOE-only rows excluded by FMS by design |
| `W8A5AA` | TDA | 182 | 72 | 63 | 9 | 87.5% | current_unit-only rows are mostly overstrength/attached/holding patterns |

Sampled W8A5AA matched rows show semantic alignment between FMS `psntl` and current_unit duty values, and sampled POSCO values matched across sources. Use POSCO agreement as a validation signal, not as the primary join key.

### 7.9 ✅ VERIFIED at row level: `army_mtoe_aos_position_mapping` ↔ `current_unit` position-number bridge

`army_mtoe_aos_position_mapping.ipps_position_number` ↔ `current_unit.position_number`.

For WD83AA, equality is verified at 98.8% on real-billet rows (170/172) and effectively 100% once paragraph-pattern filtering excludes two upstream-mislabeled `999E` rows. This means AOS can be used for:

- per-position `current_unit` ↔ AOS joins,
- IPPS-A position-cardinality reasoning,
- vacancy detection through AOS-only positions,
- and MOS enrichment through `MOS_CODE` / `Code_Description`.

Apply the real-billet filter in §9 before using current_unit rows for canonical billet/occupant joins.


## 8. Detailed canonical mapping

### 8.1 organizations

| Target field | Primary source | Mapping type | Notes |
|---|---|---|---|
| `organization_name` | `organizations.csv.organization_data_history_uic_long_description` | transformed | Fallbacks: `unit_hierarchy.uic_long_name`, `all_current_units_crew.gfm_dscr_lname`, `name_txt`. |
| `normalized_name` | derived from chosen name | derived | Lowercase, trim, strip punctuation. |
| `short_name` | `organizations.csv.organization_data_history_uic_short_description` | transformed | Fallback to `unit_hierarchy.uic_short_name` or `gfm_sname`. |
| `parent_organization_id` | hierarchy join from `unit_hierarchy.parent_uic` | transformed | Resolve FK by UIC lookup after orgs load. |
| `component` | `organizations.csv.organization_data_history_gfm_component_code` | transformed | **Vocab translation required**: `NG_FED`, `RESERV`, `Reserve`, `ARMY`, etc. → canonical Active/Guard/Reserve. See §13 Q7. |
| `echelon` | unresolved | unresolved | No direct field. Possibly derivable from `ut_size_code`, `ut_gfm_size_code`, `aos_size_code`, or hierarchy depth. |
| `uic` | `unit_hierarchy.uic` | direct | Stable natural org key. |
| `location_name` | `organizations.csv.locations_city` | transformed | Combine with state/country if useful. |
| `state_code` | `organizations.csv.locations_state` | transformed | Normalize to USPS state code. |
| `is_current` | derived from current-row filter | derived | Set to `true` for the row passing the `effdt_to`/`ROW_NUMBER` filter. |

**Org load strategy:**
1. Pick one hierarchy backbone (`unit_hierarchy` or `position_data_positions`).
2. Load one org row per UIC.
3. Enrich names/component/locations from `organizations.csv` (current-row filter applied).
4. Resolve parents by UIC lookup.
5. Add aliases (§8.2).

### 8.2 organization_aliases

| Target field | Source | Mapping type | Notes |
|---|---|---|---|
| `organization_id` | resolved from canonical org | transformed | FK by UIC. |
| `alias_text` | `unit_hierarchy.uic_name_aliases` | transformed | Unnest array into one row per alias. |
| `alias_type` | literal/derived | derived | Examples: `source_alias`, `gfm_short`, `gfm_long`, `alt_name`, `uic_code`. |
| `normalized_alias_text` | derived | derived | Same normalization as org names. |

**Alias source candidates:** `unit_hierarchy.uic_name_aliases`, `position_data_positions.uic_name_aliases`, `all_current_units_crew.gfm_alt_nm` / `gfm_sname` / `uic_aname` / `uic_lname`, `organizations.csv` short/long description variants.

### 8.3 sections

**Status: `mtoe_unit_personnel_view.partl` is now verified as a useful section/container source for at least one real target UIC (`WD83AA`).**

The remaining uncertainty is not whether `partl` can create section-level structure. The remaining product decision is which `partl` values should become first-class Green Pages sections versus tactical containers, teams, or other lower-level groupings.

#### Strongest current source: `mtoe_unit_personnel_view.partl`
Sample values (`S2 SECTION`, `S3 SECTION`, `S4 SECTION`, `MAINTENANCE SECTION`, `COMPANY HEADQUARTERS`, etc.) are the cleanest staff-section-shaped strings observed across all 9 datasets. A targeted Foundry SQL pull for `WD83AA` returned 182 rows and showed `partl` counts that include `S3 SECTION` (19), `S1 SECTION` (9), `S2 SECTION` (8), `S4 SECTION` (5), and `S6 SECTION` (2).

**Derivation rule sketch:**
- Group `mtoe_unit_personnel_view` rows by `(uic, partl)`.
- A `partl` value qualifies as a Green Pages section when it matches a staff-section pattern (`G-?\d`, `S-?\d`, `J-?\d`, or product-approved literal list including `MAINTENANCE SECTION`, `COMPANY HEADQUARTERS`).
- `section_code` ← regex extract from `partl`.
- `section_name` ← `partl` (cleaned).
- Tactical containers (`HOWITZER SECTION`, `MILITARY POLICE SQUAD`, `MORTAR PLATOON`, `3RD RIFLE SQUAD`) — product call: include or exclude.

#### Secondary signal: `smallunit_billets.smallunit_name` / `platoon_name`
Sample values include `S6 SECTION`, `G7`, `MORTAR SECTION`, `MAINTENANCE SUPPORT ELEMENT`. Useful as a coverage cross-check and for tactical decomposition if product wants it.

#### Weak/unconfirmed signals
- `mtoe.suttl` — unit/subunit title, possibly too organizational.
- `mtoe.sub_unit` — `A0`/`B0`/`C0`/`D0` codes, not human-readable section names.
- IPPS-A positions `positions_drcon_reportto_title` — promising for graph-derived sections, blocked on locating the dataset.

#### Mapping table

| Target field | Mapping status | Notes |
|---|---|---|
| `organization_id` | transformed | FK by UIC after section row exists. |
| `section_code` | derived | Regex extract from `partl`, e.g. `S2 SECTION` → `S-2`. Needs a normalization rule. |
| `section_name` | transformed | Cleaned `partl` value. |
| `normalized_section_name` | derived | Standard normalization. |
| `display_name` | derived | E.g. `"<org short_name> <section_code>"`. |
| `parent_section_id` | unresolved | Probably null for first pass. |
| `is_current` | derived | True if source rows still present in current MTOE. |

#### Practical first-pass options
- **Option A (defer):** ship organizations + billets + people + occupants without sections.
- **Option B (narrow derive):** derive only sections matching the `G-?\d`/`S-?\d`/`J-?\d` pattern from `partl`.
- **Option C (full transform):** business rules in Vantage to convert all grouping signals into canonical sections.

**Recommended:** Option B is now the best near-term path. The `WD83AA` test proves `partl` can support section-level structure, but the first transform should stay narrow: derive obvious staff sections such as `S1 SECTION`, `S2 SECTION`, `S3 SECTION`, `S4 SECTION`, and `S6 SECTION` first; treat broader containers like `FIRE CONTROL ELEMENT`, `BATTERY HQ`, `AMBULANCE TEAM`, or `COMBAT MEDIC SECTION` as a separate product decision.

### 8.4 billets

| Target field | Primary source | Mapping type | Notes |
|---|---|---|---|
| `organization_id` | resolved from `mtoe_unit_personnel_view.uic` | transformed | FK by UIC. |
| `section_id` | resolved from `(uic, partl)` if §8.3 derivation runs | transformed | Null if sections deferred. |
| `position_number` | `mtoe_unit_personnel_view` paragraph/line tuple, or `smallunit_billets.position_number`, or `current_unit.position_number` | transformed | Multiple sources need reconciliation. Preserve as text. |
| `billet_title` | `mtoe_unit_personnel_view.psntl` | direct | Strongest source. Fallbacks: `smallunit_billets.billet_name`, `current_unit.designation_of_duties_performed`. |
| `normalized_billet_title` | derived | derived | For search. |
| `grade_code` | `mtoe_unit_personnel_view.grade_code` | direct | |
| `rank_group` | derived from `grade_code` | derived | O/W/E grouping logic. |
| `branch_code` | `mtoe_unit_personnel_view.brnch` | direct | |
| `mos_code` | `fms_unit_personnel_view.derived_mos`, or parsed `posco` | transformed | Need a consistent extraction rule. |
| `aoc_code` | parsed from `posco` for officers | derived | Depends on grade-based officer/enlisted classification. |
| `component` | inherited from org or derived from billet source | transformed | Same vocab translation as org component. |
| `uic` | `mtoe_unit_personnel_view.uic` | direct | |
| `paragraph_number` | combine `parno_1` + `parno_3` | transformed | **Verified rule** (`WD83AA`, §5.2): `paragraph_number ← parno_1 ‖ zfill(parno_3, 2)`. Example: `parno_1=1`, `parno_3=05` → `"105"`. This produces the same value as `current_unit.authorization_document_paragraph_number` and is the basis for the §7.6 bridge. |
| `line_number` | `perln` | direct | Convert to text. |
| `duty_location` | derived from org enrichment (`organizations.csv.locations_city`) | transformed | Likely an org-level field, not billet-native. |
| `state_code` | derived from org enrichment | transformed | |
| `occupancy_status` | derived from occupant join | derived | See §9. |

#### Billet natural key
**Recommended composite:** `(uic, paragraph_number, line_number, position_number)`. This is the only key shape that spans MTOE, FMS, smallunit, and current_unit.

#### `position_fmid` handling
- Reliable within IPPS-A graph (`person`, `current_unit`, IPPS-A positions dataset).
- **Does not bridge to `smallunit_billets`** (see §7.1).
- The Green Pages schema does not have a `position_fmid` column today. If/when needed, add as `source_position_fmid` rather than overloading `billet_id`. Recorded as a future need, not a blocker.

### 8.5 people

| Target field | Primary source | Mapping type | Notes |
|---|---|---|---|
| `dod_id` | `person.department_of_defense_identification_number` | direct | Cast to string to preserve leading zeros. Fallback: `edipi`. |
| `display_name` | derived from `names_first_name`, `names_middle`, `names_last_name`, `names_name_suffix` | transformed | Build user-friendly name format like `Nathan J. Hogan` or `Nathan J. Hogan Jr.`. Do **not** include rank in this field. **Do not use `name_individual`** — its case, suffix handling, and middle-name format are inconsistent across rows (see §6.9). |
| `normalized_display_name` | derived from `display_name` | derived | Search/index-only value made by lowercasing and stripping non-alphanumeric characters, e.g. `Nathan J. Hogan` → `nathanjhogan`. Never display this in the UI. |
| `rank` | `person.rank_true_abbreviation` | direct | Prefer `SGT`, `PFC`, `COL` form. Fallback: `grade`. |
| `work_email` | `person.dod_email` | direct | Universal in the `WD83AA` sample; well-formed `FIRSTNAME.M.LASTNAME.MIL@ARMY.MIL`. |
| `phone` | rank-gated derivation from `person.phone[0_non_empty]`, fallback `person.phone_home[0_non_empty]` | transformed | Future target field for general phone. For eligible grades only: use `phone` first; if empty, use `phone_home` as fallback. Display label: `Phone`. Never display source label `Home phone`. Suppressed for E1–E4 and senior-rank duty-phone-only groups. |
| `duty_phone` | rank-gated derivation from `person.phone_duty[0_non_empty]` | transformed | Future target field for duty phone. Display label: `Duty phone`. Allowed for E5–E8, O1–O7, WO1–CW4, E9, O8+, and CW5 when populated. Suppressed for E1–E4. |
| `office_symbol` | unresolved (no source field) | unresolved | Confirmed absent in `person` (§6.9). Source-side question is closed; product decision (drop from MVP / derive / seed) remains in §13 Q3. |
| `is_current` | derived | derived | Prefer rows with `current_assignment_indicator = true`. |

#### Phone display policy

**Scope:** uniformed military only; no civilians. Same policy applies across Active, Guard, and Reserve.

| Grade group | General `Phone` display | `Duty phone` display | Notes |
|---|---|---|---|
| E1–E4 | Do not display | Do not display | Suppress all phone fields for junior enlisted. |
| E5–E8 | Use `phone`; fallback to `phone_home` if `phone` is empty | Display `phone_duty` if populated | `phone_home` is fallback only and is labeled `Phone`, not `Home phone`. |
| E9 | Do not display | Display `phone_duty` if populated | Senior enlisted duty-phone-only rule. |
| O1–O7 | Use `phone`; fallback to `phone_home` if `phone` is empty | Display `phone_duty` if populated | Same as E5–E8. |
| O8 and above | Do not display | Display `phone_duty` if populated | General/admiral-equivalent senior officer duty-phone-only rule. |
| WO1–CW4 | Use `phone`; fallback to `phone_home` if `phone` is empty | Display `phone_duty` if populated | Same as E5–E8. |
| CW5 | Do not display | Display `phone_duty` if populated | Senior warrant duty-phone-only rule. |

The grade-gating rule should be derived from stable grade fields such as `grade`, `grade_rank_code`, or another normalized grade field in the Vantage transform, not from free-text display rank alone.

**App implementation delta:** Green Pages currently stores and returns one `work_phone` field. Supporting the product decision requires a later database migration, API response update, and frontend rendering update for separate `phone` and `duty_phone` fields. The future `phone` value is rank-gated and may be sourced from `person.phone` or fallback `person.phone_home`; the future `duty_phone` value is rank-gated from `person.phone_duty`. Recommended timing: make this change when real-data ingestion work starts, not as a standalone UI churn task unless the people detail/search UI is already being touched.

#### Person natural key
`department_of_defense_identification_number`. Fallbacks: `edipi`, `member_id`.

### 8.6 billet_occupants

| Target field | Primary source | Mapping type | Notes |
|---|---|---|---|
| `billet_id` | resolved by matching `current_unit` to canonical billet | transformed | **Verified bridge (§7.6):** match on `(uic, authorization_document_paragraph_number, int(authorization_document_line_number))`. 98.6% match rate at `WD83AA`. |
| `person_id` | resolved from canonical person by `dod_id` | transformed | `current_unit.department_of_defense_identification_number` → `person.department_of_defense_identification_number`. Verified populated on every matched `current_unit` row at `WD83AA`. |
| `is_primary` | derived | derived | When a billet has exactly one matched `current_unit` row → `True`. When multiple rows match (see "Multiple rows per paragraph/line" below) → exactly one row gets `True`, others `False`, by precedence: `assignment_status='ASSIGNED'` over `'ATTACHED'`, then most recent `date_of_assignment_to_duty`. |
| `assignment_status` | `current_unit.assignment_status` | transformed | Translate to canonical `active`/`inactive`. Observed source values at `WD83AA`: `ASSIGNED`, `ATTACHED`. Both → `active`. |
| `source_system` | literal | direct | E.g. `vantage_current_unit`. |
| `effective_date` | `current_unit.date_of_assignment_to_duty` | direct | |

#### Occupancy bridge strategy
**Primary (verified):** `current_unit` → canonical billets via the composite key in §7.6. Verified 98.6% match rate for `WD83AA`.

**Secondary (smallunit world):** `smallunit_billets.assigned_soldier_ssn_hash` (or `vantage_assigned_soldier_ssn_hash`) → person via `ssn_hash`. **Now lower priority** — with `current_unit` providing clean DoD-ID-keyed occupancy at scale, `smallunit_billets` is not needed for occupancy unless product specifically wants tactical/lower-echelon decomposition. The §13 Q13 question stays open but no longer blocks the first transform.

#### Multiple rows per paragraph/line
Observed in `WD83AA` data. A small number of MTOE paragraph/line keys matched two `current_unit` rows (for example `(WD83AA, 101, 5)` VEHICLE DRIVER, `(WD83AA, 104, 3)`, `(WD83AA, 104, 5)`). Possible causes include rotations, attachments, transition overlap, dual-slotting, or multiple IPPS-A positions under one MTOE authorization line. The exact reason should be confirmed with a data owner after `current_unit.position_number` is compared row-for-row to `army_mtoe_aos_position_mapping.ipps_position_number`.

The Green Pages canonical schema permits multiple occupants per billet but allows only one to be `is_primary = true`. If the transform later splits multi-quantity auth lines into separate AOS/IPPS-A positions, some of these cases may become one occupant per position instead of multiple occupants on one billet. Until that row-level position split is proven, the recommended Vantage transform behavior is:

1. Emit one `billet_occupants` row per matched `current_unit` row (do not drop the secondary rows).
2. Pick a single primary by precedence: `assignment_status = 'ASSIGNED'` beats `'ATTACHED'`; tie-break by most recent `date_of_assignment_to_duty`.
3. Set `is_primary = true` on that one row, `false` on the rest.

This keeps the schema's "one active primary occupant per billet" rule (§2.2) intact while preserving the secondary assignments for visibility.

#### `assigned_*` vs `vantage_assigned_*` in `smallunit_billets`
The dataset carries two parallel column families:
- `assigned_soldier_ssn_hash`, `assigned_last_updated`, `assigned_arrival_date`
- `vantage_assigned_soldier_ssn_hash`, `is_vantage_assigned`

The `is_vantage_assigned` flag implies one is a Vantage-side override of the upstream value. Which one is authoritative is a product/data-owner decision (§13 Q13). Now lower priority — `current_unit` covers occupancy without needing this resolution.

---


## 9. Occupancy status derivation

### Canonical states
`filled`, `vacant`, `unknown`.

### Real-billet filter rule for `current_unit`

`current_unit` contains rows that represent real people at or attached to a unit but do **not** correspond to normal authorized billets. These include overstrength rows, student/trainee rows, holding rows, standard-excess rows, and attachment rows parked on pseudo-paragraphs such as `999E`, `999F`, `999J`, `999Q`, `999T`, `999Z`, `999`, and `9STU`.

The transform must keep these people available for people search, but they should not create canonical billets or normal `billet_occupants` rows.

Use a keep-mask like this in the Vantage transform:

```python
real_billet_mask = (
    (cu["overstrength_designation_code"] != "OVERSTRENGTH")
    & (~cu["authorization_document_paragraph_number"].astype(str).str.startswith("999"))
    & (cu["authorization_document_paragraph_number"].astype(str) != "9STU")
)
```

Equivalent exclusion logic: exclude a current_unit row from canonical billet occupancy if **any** of these are true:

```text
overstrength_designation_code = OVERSTRENGTH
OR authorization_document_paragraph_number starts with 999
OR authorization_document_paragraph_number = 9STU
OR positions_posco = NKN
```

This rule is intentionally not FMS-side filtering. FMS remains the authorization-line authority. The special-personnel and overstrength filtering applies to `current_unit`, because `current_unit` contains assigned/attached/personnel rows that may not represent canonical authorized billet occupancy.

The paragraph-pattern backstop is required because WD83AA had rows with `paragraph_number=999E`, `positions_posco=NKN`, and overstrength-style duties that were not reliably identified by `overstrength_designation_code` alone.

Latest WD83AA validated category split as of 2026-05-08:

```text
current_unit total rows: 198
real_billet rows:       169
excluded rows:           29

excluded rows by reason:
overstrength_designation_code: 27
paragraph_999_pattern:          2
paragraph_9STU:                 0
positions_posco_NKN:            0
```

The `9STU` and `NKN` rules remain in the contract even though they did not fire for WD83AA in the latest run.

### First-pass rules

**`filled`** — FMS billet/position row exists and at least one matching real-billet `current_unit` row joins via either the FMS composite key (§7.8) or the AOS position-number bridge (§7.9), with `current_assignment_indicator = true` and `assignment_status IN ('ASSIGNED', 'ATTACHED')`.

**`vacant`** — FMS/AOS billet or position row exists, the key is well formed, the source row is current, and no matching real-billet `current_unit` row exists. For WD83AA, the latest validated output produced 47 AOS-only position numbers after matching 169 occupied real-billet positions; these are first-pass vacancy candidates.

**`unknown`** — source rows conflict, key fields are missing/malformed, current-row filtering is uncertain, or the unit type/source combination has not yet proven the bridge.

### Important metric distinction

The 98.6% WD83AA number from the original MTOE bridge is the **current_unit-to-MTOE assignment-key match rate**, not the MTOE fill rate:

```text
144 / 146 current_unit assignment keys matched MTOE
```

The billet-side fill view was lower:

```text
144 / 182 MTOE billet keys matched current_unit = 79.1%
```

For FMS/AOS prototype work, use the newer position-cardinality picture:

```text
178  FMS authorization-line keys after non-Army rows are excluded
216  AOS current IPPS-A positions
169  occupied real-billet current_unit rows matched to AOS
 47  AOS-only positions, likely vacant
```

### TDA caution

W8A5AA showed a much lower FMS-side fill rate than WD83AA. This is likely a staffing reality for a state ARNG HQ TDA, not a bridge failure. Keep special-personnel logging and do not silently discard current_unit-only rows; classify them as unmapped/special personnel.


## 10. Join hypotheses and candidate keys

### 10.1 Organization joins
- Natural key: `uic`.
- Parent join: child `uic` → `parent_uic`.
- Enrichment joins: `uic`, `mtoe_uic`, `lduic`, sometimes `docno`.

### 10.2 Billet joins
- **Primary canonical key (verified for MTOE ↔ current_unit):** composite `(uic, paragraph_number, line_number)` where `paragraph_number = parno_1 ‖ zfill(parno_3, 2)` on the MTOE side and equals `authorization_document_paragraph_number` on the current_unit side. 98.6% match rate at `WD83AA`. See §7.6.
- **Full canonical billet key (for cross-source identity):** composite `(uic, paragraph_number, line_number, position_number)`.
- **Supplemental:** `position_fmid` within the IPPS-A graph only (`person`, `current_unit`, IPPS-A positions dataset).
- **Not usable as primary:** `position_fmid` against `smallunit_billets.billet_id` (see §7.1).

### 10.3 Person joins
- Primary: `department_of_defense_identification_number`.
- Fallbacks: `edipi`, `member_id`.

### 10.4 Occupant joins
- `current_unit.dod_id` → `people.dod_id`.
- `current_unit.(uic, paragraph, line, position_number)` → canonical billet.

---

## 11. Source-by-target recommendation

### Phase 1 — Organizations
- Backbone: `unit_hierarchy` (or `position_data_positions` if that wins on coverage).
- Display enrichment: `organizations.csv` (current-row filter required).
- Alias enrichment: `all_current_units_crew` (current-row filter required).
- Parent-chain validation/candidate parent source: `hrc_curated_org_hierarchy.first_uic`, with the view-not-dataset caveat.

### Phase 2 — Billets
- **Primary billet authority:** `army_unit_auth_fms` (adopted after Q17 closeout).
- **Position-cardinality and MOS enrichment:** `army_mtoe_aos_position_mapping`, filtered to `positions_effdt_to = '2999-12-01'` (adopted after Q18 closeout).
- **Fallback / scope-expansion source:** `mtoe_unit_personnel_view` only if future product scope requires non-Army liaison billets that FMS intentionally excludes.
- Supplemental tactical decomposition only: `smallunit_billets`.

### Phase 3 — People
- Primary: `person`.

### Phase 4 — Billet occupants
- Primary: `current_unit`.
- Join to billet authority by `(uic, paragraph, line)` first; later validate whether `current_unit.position_number` equals `army_mtoe_aos_position_mapping.ipps_position_number` for row-level position matching.
- Supplemental tactical source only if product needs it: `smallunit_billets`.

### Phase 5 — Sections
- Narrow derivation from `partl` (currently available in both `mtoe_unit_personnel_view` and `army_unit_auth_fms`), pending product sign-off on which `partl` values qualify.

### Phase 6 — AOS/IPPS-A enrichment
- Use the located `army_mtoe_aos_position_mapping` dataset for current position-cardinality and MOS enrichment where verified.
- Continue the hunt for the broader IPPS-A positions master only if authorization-count fields like `req_qty` / `auth_qty` / `pmad_qty` are needed later.

## 12. What should happen in Vantage

### 12.1 Must happen in Vantage
- UIC-based org deduplication.
- Current-row filtering for `organizations.csv` and `all_current_units_crew`.
- Parent-child org resolution.
- Name selection and alias expansion.
- Component vocabulary normalization (`NG_FED`/`RESERV`/`Reserve`/`ARMY` → canonical).
- State/location normalization.
- Billet composite-key construction (`uic`, paragraph, line, position_number).
- Grade-to-rank-group derivation.
- MOS/AOC extraction from `posco`.
- Current-assignment matching to billets via the composite key.
- Occupancy-status derivation.
- Section derivation (§8.3) once product approves rules.
- Display name reformatting for people (`names_*` → `"First M. Last"`, e.g. `Nathan J. Hogan`). Keep `rank` separate so the UI can render `MAJ Nathan J. Hogan` without storing rank inside the name field.
- Strict allowlist shaping for people. Do not export the wide `person` record forward and then blacklist fields; emit only the approved `greenpages_people` fields.
- Phone array element selection and rank-gated phone-display shaping. `phone`, `phone_duty`, and `phone_home` are source ARRAY fields. The transform must pick the first non-empty allowed element, apply the §8.5 grade policy, emit future target columns `phone` and `duty_phone`, suppress all phone fields for E1–E4, and never emit/display `phone_home` as a separate `Home phone` field.

### 12.2 Should not happen in Go
- Raw-source hierarchy cleanup.
- Source-specific parent resolution.
- Source-specific billet key reconciliation.
- Source-specific person matching.
- Complex occupancy inference.
- Vocabulary translation.

---

## 13. Most important unresolved questions

Ranked by blocking impact on the first transform.

1. **Sections — first-class `partl` values.** `mtoe.partl` is now verified for `WD83AA`; decide which `partl` values become Green Pages sections. Recommended first pass: staff-section values only (`S1 SECTION`, `S2 SECTION`, `S3 SECTION`, `S4 SECTION`, `S6 SECTION`, etc.). Broader containers can remain in investigation output but should not automatically become first-class sections.
2. **Sections — unit-type-sensitive rules.** Decide whether section/container rules should vary by unit type. Example: `BATTERY HQ` makes sense in an HHB/artillery context, but a brigade/division staff may need a different interpretation. This should be a product/data-owner decision, not an automatic global rule.
3. **`office_symbol` — product decision needed.** Source-side question is **closed**: no `office_symbol` field exists in `person` (confirmed by full schema inspection, §6.9). Remaining product decision: drop from MVP, derive from `uic + billet_title`, or seed manually.
4. **Re-test the §7.6 occupant bridge against more UIC types.** 98.6% match rate is verified for `WD83AA` (an MTOE HHB). A TDA test on `W8A5AA` verified that `army_unit_auth_fms` surfaces usable TDA billet-authority rows, but also showed that current_unit occupancy matching is messier for TDA and needs conservative classification. FMS has no `joint` `unit_type`; joint/non-Army coverage is outside this billet-authority source and should be treated as a known scope boundary, not an unresolved FMS blocker.
5. **Multiple rows per paragraph/line — confirm precedence rule.** Recommended (§8.6) is `assignment_status='ASSIGNED'` over `'ATTACHED'`, then most recent `date_of_assignment_to_duty`. Confirm with a data owner before locking the transform.
6. **Current-row filter for `organizations.csv`.** Most likely `effdt_to IS NULL OR effdt_to >= TODAY()`, but verify against the data owner.
7. **Current-row filter for `all_current_units_crew`.** Keying column for "current per UIC" is unknown.
8. **`unit_hierarchy` vs `position_data_positions` as backbone.** Same shape; pick one based on coverage, null rates, alias completeness on a real pull. **Possibly superseded by `hrc_curated_org_hierarchy` (§6.12)** for parent-chain purposes; that view is a different shape (FMID-grain, not UIC-grain) so it doesn't replace the unit-level backbone, but it does provide a cleaner immediate-parent signal via `first_uic`.
9. **Component vocabulary translation table.** `NG_FED`, `RESERV`, `Reserve`, `ARMY` → canonical Green Pages set (Active / Guard / Reserve / ...). **Note:** `army_unit_auth_fms` (§6.10) carries a top-level `component` field whose vocabulary should be inspected on a multi-component pull before assuming it matches `person.component`.
10. **Echelon derivation rule.** From `ut_size_code` / `aos_size_code` / hierarchy depth?
11. **RID for the IPPS-A positions dataset** (the one whose schema came back as `organizations.json`). Locating it would unlock authorization counts and a stronger billet identity story. **Lower priority** now that the MTOE ↔ current_unit bridge is verified.
12. **MTOE/FMS scope:** is `smallunit_billets` a superset, or does it miss garrison/TDA units that FMS covers? **Lower priority** — `current_unit` covers occupancy without needing `smallunit_billets`.
13. **`smallunit_billets` `assigned_*` vs `vantage_assigned_*` authoritativeness.** **Now lower priority** — the verified `current_unit` bridge means we do not need `smallunit_billets` for occupancy. Question stays open for any future tactical-decomposition use.
14. **Stability of `smallunit_billets.billet_id` across refreshes.** **Now lower priority** for the same reason.
15. **`ssn_hash` join verification at scale.** **Now lower priority** — `current_unit.dod_id` is a cleaner person bridge than `ssn_hash`.
16. **Overstrength soldiers — directory inclusion rule.** Soldiers attached to a UIC with no MTOE billet appear in `current_unit` on paragraph `999E` / line `99` and in `person` with `billet_specialty = '9999 - Over Strength'` and `designation_of_duties_performed = 'STANDARD EXCESS'`. The §7.4 / §9 first-pass occupant filter already excludes them from `billet_occupants`. Open product question: should they still appear in Green Pages people search? Recommended **yes** — they are real people at the unit and the directory should find them — with no `billet_occupants` row attached. The schema already supports a person without an occupancy row.
17. **Adopt `army_unit_auth_fms` as billet authority?** **Resolved for the next prototype: yes.** The `WD83AA` 178-vs-182 gap is explained by 4 MTOE-only `AIR SUPPORT` / `NON-ARMY POSITION (OTHER-PERS)` rows. TDA coverage is verified at dataset level (`tda`: 433,577 rows / 2,444 UICs) and on test UIC `W8A5AA` with complete `parno_concat`, `perln`, `grade_code`, `partl`, and `derived_mos` coverage. Remaining caveat: pure joint/non-Army billet coverage is outside FMS because no `joint` `unit_type` exists; Army personnel at such units may still appear via `current_unit`/`person`, but pure other-service billets are out of MVP scope.
18. **Use `army_mtoe_aos_position_mapping` for IPPS-A position cardinality and MOS enrichment?** **Resolved for the next prototype: yes.** On `WD83AA`, current AOS rows produced 216 distinct `ipps_position_number` values. After excluding overstrength / `999*` / `NKN` current_unit rows, 170 of 172 real-billet current_unit position numbers matched AOS position numbers (98.8%). Use AOS-only positions as likely vacant authorized positions and current_unit matched rows as occupied positions.
19. **Stability of `hrc_curated_org_hierarchy` as a view.** Foundry flags it as a view rather than a materialized dataset. Before depending on it for production org-graph walking, characterize query latency, freshness, and refresh semantics with the data owner.

## 14. Recommended immediate next tests

The next concrete action is now the first billet/section/occupant prototype. Earlier items are kept here because this is a live notebook and those checks remain part of the broader mapping plan.

### 14.1 Org backbone comparison
Compare row count, distinct UIC count, name null rate, alias coverage, parent coverage between `unit_hierarchy`, `position_data_positions`, and current-row-filtered `organizations.csv`.

### 14.2 Position-to-org overlap
Test UIC overlap between org backbone, `mtoe_unit_personnel_view.uic`, `smallunit_billets.mtoe_uic`, `current_unit.uic`, `lduic`.

### 14.3 Occupant-to-billet bridge

**Status: completed for `WD83AA`.**

The `current_unit` pull and MTOE/current-unit compare proved the first-pass bridge:

```text
MTOE billet keys:              182
current_unit assignment keys:  146
matched keys:                  144
MTOE-only keys:                 38
current_unit-only keys:          2
```

The working bridge is:

- `uic`
- MTOE `parno_1` + zero-padded `parno_3` compared to `current_unit.authorization_document_paragraph_number`
- MTOE `perln` compared to `current_unit.authorization_document_line_number`
- `position_number` and `position_fmid` as supplemental evidence/tie-breakers

Next refinement: inspect the 38 MTOE-only keys and 2 current_unit-only keys to classify them as vacant, unknown, overstrength, attached, stale, or formatting edge cases.

### 14.4 Person-to-assignment bridge / people prototype output

**Status: admin bridge verified, phone counts measured, and first `greenpages_people` Vantage output built.** See §5.3 for the original 6-row admin bridge and §5.8 for the validated transform output. Names, rank abbreviation, email, branch, specialty, and the partially-denormalized assignment fields populated as expected in the sample; the Plans Officer cross-check against §5.2 was consistent.

**Phone quantitative task completed for `WD83AA`:** a full 4-column person phone pull measured 200 source rows. `phone` was populated on 23 rows and empty on 177. `phone_duty` was populated on 6 rows and empty on 194. `phone_home` was populated on 168 rows and empty on 32. At least one phone field was present on 187 rows; 13 rows had no phone fields. These counts justified treating `phone_home` as a fallback source for the general `Phone` value, but only under the rank-gated policy in §8.5.

**Rank-gated display effect now validated in the materialized prototype:** final `greenpages_people_wd83aa_prototype` output produced 200 rows, 92 rows with general `phone`, 6 rows with `duty_phone`, 5 rows with both, and 107 rows with neither. E2-E4 correctly exposed no phone fields. `work_phone` matched `phone` on all rows for compatibility with the current app schema.

**Keep this as the reusable checklist for future UICs:**

- Confirm `current_unit.department_of_defense_identification_number` resolves to `person.department_of_defense_identification_number`.
- Check `person.edipi` against `person.department_of_defense_identification_number` as a validation cross-check.
- Confirm `names_last_name` and `names_first_name` are populated; treat blank `names_middle` as acceptable.
- Confirm `rank_true_abbreviation`, `grade`, `dod_email`, `basic_branch`, and specialty fields are populated at useful rates.
- Count `phone` populated, `phone_duty` populated, `phone_home` populated, any phone field populated, and no phone fields populated.
- Apply the §8.5 rank-gated phone policy to calculate how many rows would actually expose `phone`, `duty_phone`, both, or neither in Green Pages.
- Sanity-check that `person.uic`, `person.position_fmid`, and `person.position_number` agree with the matched `current_unit` row.
- Specifically compare `current_unit.position_fmid` against `person.position_fmid`; disagreements should be investigated because both fields live in the FMID/IPPS-A graph.
- Identify overstrength/personnel-only rows such as `STANDARD EXCESS` / `9999 - Over Strength`; do not attach them to `billet_occupants` unless a matching MTOE billet exists.

**DoD-ID handling note:** use raw DoD IDs locally for joins and validation, but do not preserve raw DoD IDs in this notebook or other long-lived investigation documents. Durable notes should describe aggregate outcomes, match rates, and structural examples.

**Other open work that travels with this task:**

- Overstrength-soldier inclusion rule for people search (see §13 Q16).
- Sanity-check that `person`'s denormalized assignment fields agree with the matched `current_unit` row across the full pull. Disagreement would be the interesting finding.

### 14.5 Section derivation across units
Repeat the `WD83AA` targeted SQL flow against several more known UICs. For each UIC, list unique `partl` values, classify which match staff-section patterns, and compare consistency across units. The `WD83AA` result is strong, but the transform should not assume one unit proves the whole Army-wide rule.

### 14.6 Re-run the §7.6 bridge against more UIC types
**Status: partially completed.** The 98.6% match rate is verified for one MTOE HHB (`WD83AA`). A TDA test UIC (`W8A5AA`) verified that `army_unit_auth_fms` returns TDA billet-authority rows with complete key-field coverage, and matched FMS/current_unit rows were semantically clean. However, TDA current_unit matching is messier because many current_unit-only rows are overstrength, attached, `999*`, or other special personnel rows. Keep conservative unmapped/special-personnel handling for TDA. FMS has no `joint` `unit_type`; joint/non-Army coverage is outside this billet-authority source and should be treated as a known scope boundary, not an unresolved FMS blocker.

### 14.7 IPPS-A positions hunt
Search Vantage catalog for datasets with the `positions_*` prefix, anchored on `position_id`, including `positions_req_qty`/`positions_auth_qty`. Lower priority now that the MTOE ↔ current_unit bridge is verified. **Partially superseded** by `army_mtoe_aos_position_mapping` (§5.5 / §6.11), which provides IPPS-A `position_id` and `ipps_position_number` at known scale (216 positions for `WD83AA`). Authorization-count fields (`req_qty`, `auth_qty`, `pmad_qty`) were not seen in that dataset, so the hunt for the IPPS-A positions master dataset itself remains open.

### 14.8 SSN-hash bridge at scale (deprioritized)
Originally planned to pull 1000+ rows from `person` and `smallunit_billets` to verify `ssn_hash` overlap. **No longer needed for the first transform** — `current_unit.dod_id` is a cleaner person bridge than `ssn_hash` and is verified populated on every matched row.

### 14.9 Reconcile the 178-vs-182 row-count gap (§13 Q17 blocker)
**Status: completed for WD83AA.** `army_unit_auth_fms` returned 178 keys, `mtoe_unit_personnel_view` returned 182 keys, 178 keys matched, 0 FMS-only keys appeared, and the 4 MTOE-only rows were all `AIR SUPPORT` / `NON-ARMY POSITION (OTHER-PERS)` rows. This closes the WD83AA row-count blocker for the Army-focused MVP.

### 14.10 Verify `ipps_position_number` ↔ `current_unit.position_number` (§13 Q18)
**Status: completed for WD83AA.** The raw all-current-unit match rate was 85.0%, but that included overstrength / `999*` / `9STU` / `NKN` rows. After filtering to real-billet current_unit rows, 170 of 172 distinct current_unit position numbers matched AOS `ipps_position_number` values (98.8%). This closes Q18 for the next prototype.

### 14.11 Build the first billet/section/occupant prototype
**Status: completed for WD83AA as separate billet and occupant transforms.** The resolved source chain is:

```text
army_unit_auth_fms
→ army_mtoe_aos_position_mapping
→ current_unit
→ greenpages_people_wd83aa_prototype
```

First-pass rules:

- Use `army_unit_auth_fms` as authorization-line truth and section source via `partl`.
- Use AOS current rows (`positions_effdt_to = 2999-12-01`) as the position-level expansion.
- Use `ipps_position_number` as canonical `position_number`.
- Use `MOS_CODE` / `Code_Description` for MOS enrichment.
- Join `current_unit` by position number for occupied positions.
- Treat AOS-only positions as likely vacant authorized positions.
- Exclude or separately track current_unit-only `999*` / `9STU` / `NKN` rows as unmapped/special personnel.
- Join occupants to `greenpages_people_wd83aa_prototype` by DoD ID.

## 15. First-pass Vantage output dataset design

### 15.1 `greenpages_organizations`
One row per canonical organization. Fields: org name, normalized name, short name, parent UIC, component, location fields, source UIC, lineage, optional `source_org_fmid` (from `army_mtoe_aos_position_mapping.aos_unit_id`, §6.11). **Candidate parent-walking source:** `hrc_curated_org_hierarchy.first_uic` (§6.12), with the view-not-dataset stability caveat in §13 Q19.

### 15.2 `greenpages_organization_aliases`
One row per alias. Fields: org UIC, alias text, alias type, normalized alias text.

### 15.3 `greenpages_billets`
One row per canonical position-level billet for the validated WD83AA prototype. Fields: composite billet identity, canonical org UIC, billet title, normalized title, grade code, rank group, branch code, MOS code, AOC code, paragraph, line, position number, source lineage, optional `source_position_fmid`. **Preferred billet-authority source: `army_unit_auth_fms` (§6.10).** Q17 blockers are closed for prototype use: the WD83AA 178-vs-182 gap is explained and TDA coverage is verified. **MOS enrichment and position-cardinality source:** `army_mtoe_aos_position_mapping.MOS_CODE` / `Code_Description` (§6.11), using current rows where `positions_effdt_to = 2999-12-01` and `ipps_position_number` as canonical `position_number`. The WD83AA billet prototype is built and validated with 216 position-grain rows (§5.12, §18.2).

### 15.4 `greenpages_people`
One row per canonical person. Fields: deterministic hashed `person_id`, DoD ID, user-friendly `display_name` (`First M. Last`, e.g. `Nathan J. Hogan`), search-only `normalized_display_name`, rank abbreviation (`MAJ`, `CPT`, `SSG`, etc.), canonical `grade`, temporary inspection `source_grade_normalized`, component, email, future `phone`, future `duty_phone`, compatibility `work_phone`, `office_symbol`, `is_current`, and source lineage. `rank` is intentionally separate from `display_name`; Green Pages should render user-facing labels as `rank + display_name` when needed, e.g. `MAJ Nathan J. Hogan`. `phone` is a rank-gated general phone derived from `person.phone` with `person.phone_home` as fallback for eligible grades. `duty_phone` is a rank-gated duty phone derived from `person.phone_duty`. `phone_home` is never emitted as its own Green Pages field. `work_phone` currently mirrors `phone` because the app schema still has a single `work_phone` column. `office_symbol` remains null/deferred. `image_url` deferred to post-MVP (Foundry data-proxy URL; partial coverage). **Status:** WD83AA prototype output built and validated in Vantage (§5.8).

### 15.5 `greenpages_billet_occupants`
One row per current assignment linkage. Fields: canonical billet identity, canonical person identity, assignment status, effective date, source system, match-confidence flag.

### 15.6 `greenpages_sections` / section fields
For the WD83AA prototype, sections are materialized from `partl`/`section_name` in the billet output and loaded into the canonical `sections` table. The current section source key is `uic|normalized_section_name`; display name is presentation only and should not be part of identity.

---

## 16. Bottom-line conclusions

### Strongest current findings
- **Best org backbone:** `unit_hierarchy` (or `position_data_positions`).
- **Best org enrichment:** `organizations.csv` (with current-row filter).
- **Best org parent-walking source (candidate):** `hrc_curated_org_hierarchy` (§6.12), with the view-not-dataset caveat.
- **Best first billet source:** `army_unit_auth_fms` (§5.4, §5.9, §6.10). The earlier adoption blockers are closed for prototype use: the `WD83AA` 178-vs-182 gap is explained by 4 non-Army `AIR SUPPORT` rows, and TDA coverage is verified at dataset level and on `W8A5AA`.
- **Best billet MOS and position-cardinality source:** `army_mtoe_aos_position_mapping.MOS_CODE` / `Code_Description` plus `ipps_position_number` (§5.5, §5.11, §5.12, §6.11). Clean composite codes are populated, current-row rule is verified, and the WD83AA billet prototype materializes 216 distinct position-grain billet rows.
- **Best person source:** `person`. Admin bridge verified for the `WD83AA` sample — names, rank, email, branch, specialty all populated. Phone-field coverage was measured in the full `WD83AA` 4-column phone pull: `phone` 23/200, `phone_duty` 6/200, `phone_home` 168/200, at least one phone field 187/200, none 13/200. The first Vantage output `greenpages_people_wd83aa_prototype` is built and validated with 200 rows, 200 distinct person IDs, no missing names/ranks/grades, 2 missing work emails, 92 rows with rank-gated general phone, 6 rows with duty phone, and `work_phone = phone` on every row. See §5.3, §5.8, §7.2, and §8.5.
- **Best occupancy bridge:** `current_unit`. For authorization-line matching, join to FMS on `(uic, parno_concat, int(perln))` ↔ `(uic, authorization_document_paragraph_number, int(authorization_document_line_number))`. For the validated WD83AA position-grain prototype, join to billets by `current_unit.position_number` ↔ `greenpages_billets_wd83aa_prototype.position_number`, assert the derived auth-line keys agree, and join to people by DoD ID. The latest occupant output validates 169/169 real-billet rows matched with no orphan current_unit positions, no auth-line mismatches, and no unresolved people joins.
- **Best sections source (verified for WD83AA):** `mtoe_unit_personnel_view.partl`. Same `partl` column also appears in `army_unit_auth_fms` (§5.4) with matching values and counts.
- **Confirmed broken bridge:** `position_fmid` does not equal `smallunit_billets.billet_id`. Composite `(uic, paragraph, line, position_number)` is the only key spanning all billet sources.
- **Product loop verified end-to-end for `WD83AA` sample.** Real example: WD83AA → S3 SECTION (paragraph 105) → S3/Operations Staff Officer (paragraph 105 line 1) → matched current_unit row → person row with name, rank, email, branch. Plans Officer (paragraph 110 line 1) resolved with `position_fmid=72060795911793100` and a populated DoD ID → CPT, FIELD ARTILLERY, with email. Phone coverage has now been measured, and final display is governed by the rank-gated policy in §8.5.

### Biggest current gaps
- Two product decisions still matter: which `partl` values become first-class sections, and what to do with `office_symbol` (source-side closed; product call only). The §5.4 Plans Officer evidence (`partl=FIRES LETHAL ELEMENT`) is a concrete reason the staff-section-only first pass will leave some real billets without a section in v1.
- Phone coverage and rank-gated display effect are now validated for `WD83AA` in the materialized `greenpages_people_wd83aa_prototype` output. This should still be rechecked on future UICs, especially Guard/Reserve and senior-grade-heavy slices.
- TDA coverage in `army_unit_auth_fms` is verified, and W8A5AA proves TDA field coverage is usable, but TDA occupancy matching is messier and should keep conservative unmapped/special-personnel handling.
- FMS has no `joint` `unit_type`; joint/non-Army coverage is outside this billet-authority source and should be treated as a known scope boundary, not an unresolved FMS blocker.
- The two remaining product/data-owner decisions are section promotion rules for `partl` and how to handle unmapped/special personnel in directory search vs billet occupancy.
- Two current-row filter rules (`organizations.csv` and `all_current_units_crew`) still unconfirmed. `army_mtoe_aos_position_mapping`'s current-row rule (`positions_effdt_to = '2999-12-01'`) is now verified (§5.5).

### Best next move
The WD83AA Vantage vertical is validated, and the first Vantage-to-Postgres sync/load path is now proven in DEV Azure PostgreSQL Flexible Server. Q17/Q18 are closed for WD83AA, and the narrow vertical now flows through the deployed Green Pages application.

The next best moves, in priority order:

1. Keep the manual CSV loader as a DEV validation tool while the source shape is still being proven.
2. Onboard a second UIC, preferably a TDA UIC such as `W8A5AA`, because TDA coverage was structurally validated but has not yet been materialized end-to-end.
3. During second-UIC onboarding, extend the expected-count maps and explicit UIC allowlists only after validating that UIC's source shape. Do **not** fork transform bodies just to handle another UIC with the same shape.
4. After at least two UICs validate cleanly, generalize the transforms from `TARGET_UIC` to a controlled list of UICs and replace prototype allowlist gates with real derivations where possible.
5. Before scheduled refresh, decide whether the sync/load step should run as a GitLab scheduled pipeline job or as a small worker. Do not add a worker until refresh complexity proves it is needed.

---

## 17. Repeatable targeted Foundry inspection flow

Use this flow when validating another UIC against the MTOE-style dataset.

1. Activate the scratch environment.

```bash
cd ~/01_cdso/scratch/foundry-inspect
source .venv/bin/activate
```

2. Load the ECMA CA bundle environment if needed.

```bash
export SSL_CERT_FILE="/tmp/go-ca-bundle-with-ecma.pem"
export GIT_SSL_CAINFO="/tmp/go-ca-bundle-with-ecma.pem"
export REQUESTS_CA_BUNDLE="/tmp/go-ca-bundle-with-ecma.pem"
export CURL_CA_BUNDLE="/tmp/go-ca-bundle-with-ecma.pem"
```

3. Export Foundry/Vantage settings. `inspect_uic.py` is expected to read these environment variables, especially `TARGET_UIC` and `DATASET_RID`.

```bash
export FOUNDRY_HOSTNAME="vantage.army.mil"
export FOUNDRY_TOKEN="<fresh token>"
export TARGET_UIC="WD83AA"
export DATASET_RID="<mtoe dataset rid>"
```

4. Run the targeted inspection and analysis scripts.

```bash
python inspect_uic.py
python analyze_mtoe_csv.py
```

Minimum expected `inspect_uic.py` behavior:

```text
Read DATASET_RID from the environment.
Read TARGET_UIC from the environment.
Run a Foundry SQL query like:
SELECT ...
FROM `<DATASET_RID>`
WHERE UPPER(TRIM(`uic`)) = '<TARGET_UIC>'
```

Expected useful outputs for a successful MTOE-style pull:

- filtered CSV for the target UIC, such as `WD83AA_mtoe_filtered.csv`
- `query_status.json`
- row/column count
- `partl`, `suttl`, and `sub_unit` value counts

For `WD83AA`, the successful reference MTOE result was 182 rows / 26 columns, with `partl` providing section/container structure and `S3 SECTION` appearing 19 times.

5. Run the targeted `current_unit` pull for the same UIC and compare it to the MTOE CSV.

Expected useful outputs:

- `WD83AA_current_unit_filtered.csv`
- MTOE/current-unit compare summary
- sample matched keys showing MTOE `partl` / `psntl` beside current assignment duty and DoD ID presence

Reference `WD83AA` compare result:

```text
MTOE billet keys:              182
current_unit assignment keys:  146
matched keys:                  144
MTOE-only keys:                 38
current_unit-only keys:          2
```

This compare should run before the `person` pull, because it identifies the DoD IDs that should be used for the targeted person/admin-data join.


## 18. WD83AA validated prototype outputs

The WD83AA narrow vertical is the first end-to-end materialization of the source-mapping plan. Each transform's contract is encoded as build-time assertions; the contracts below are the canonical record of what the slice contains and what must be investigated if it drifts.

### 18.1 `greenpages_people_wd83aa_prototype`

Source: `person` filtered to WD83AA, with strict allowlist, rank-derived canonical grade codes, and rank-gated phone policy. See §5.8 and the v4/v5 update notes.

Row count: 200. Distinct `dod_id`: 200. Distinct `person_id`: 200. Missing `display_name`/`rank`/`grade`: 0. Missing `work_email`: 2.

### 18.2 `greenpages_billets_wd83aa_prototype`

Source: `army_unit_auth_fms` left-joined to current rows of `army_mtoe_aos_position_mapping` (`positions_effdt_to` startswith `2999-12-01`).

Join key: `(uic, parno_concat, perln)` with shared paragraph-key normalization applied identically on both sides. `perln` is cast to `int` for canonical join, neutralizing pad/format mismatch.

Output grain: position. Each FMS authorization line expands to its `austr` count of AOS `ipps_position_number` rows.

Contract:

| Stage | Expected count |
|---|---:|
| FMS auth-line keys after WD83AA filter | 178 |
| Current AOS rows after WD83AA filter | 216 |
| Output rows | 216 |
| Distinct `position_number` | 216 |
| Rows with `aos_join_status='aos_position_match'` | 216 |
| Rows with `aos_join_status='fms_without_current_aos_position'` | 0 |
| Orphan AOS positions with no FMS auth line | 0 |

Specialty derivation source attribution as of 2026-05-08:

| Source | Rows |
|---|---:|
| AOS `Code_Description` prefix | 216 |
| FMS `derived_mos` | 0 |
| AOS `MOS_CODE` substring | 0 |

Section display-name correction as of 2026-05-11: `section_display_name` now uses `section_name` directly. The original `section_code`-preferred derivation produced short staff-section labels (`S1`, `S2`, `S3`, `S4`, `S6`) while all other sections kept the canonical `... SECTION` suffix. Source `section_name` already has the correct canonical form for all 32 WD83AA sections.

### 18.3 `greenpages_billet_occupants_wd83aa_prototype`

RID: `ri.foundry.main.dataset.fd7f2a5e-e69d-43ab-a3e9-704bac1c8846`.

Source: `greenpages_billets_wd83aa_prototype` ⟕ `current_unit` (real-billet filtered) ⟕ `greenpages_people_wd83aa_prototype`.

Join keys: billets ↔ current_unit on `position_number` using the Q18-validated bridge. current_unit ↔ people on `dod_id`. The `auth_line_key` derived from `current_unit.authorization_document_*` is asserted to equal the billet's `auth_line_key` after the position-number join, validating that position numbers are stably bound to their authoritative auth line.

Real-billet filter (§9): exclude `overstrength_designation_code='OVERSTRENGTH'`, `authorization_document_paragraph_number` starting with `999`, `authorization_document_paragraph_number='9STU'`, or `positions_posco='NKN'`.

Contract as of 2026-05-08:

| Stage | Expected count |
|---|---:|
| `current_unit` rows after WD83AA filter | 198 |
| Excluded by real-billet filter | 29 |
| Real-billet `current_unit` rows | 169 |
| Vacant billet positions (billets minus occupants) | 47 |
| `greenpages_people_wd83aa_prototype` rows | 200 |
| Output occupant rows | 169 |
| Orphan `current_unit` positions with no billet | 0 |
| Auth-line-key disagreements after position join | 0 |
| Unresolved DoD IDs (`current_unit` row → no person) | 0 |
| `assignment_status` mappable to canonical `active` | 169 |
| Rows with parsed `effective_date` | 169 |

Excluded current_unit category breakdown as of 2026-05-08: `overstrength=27`, `paragraph_999=2`, `9STU=0`, `posco_NKN=0`.

Grade-alignment data-quality observation, not a contract: preliminary inspection suggested many occupants are at the exact authorized grade while the remainder are predominantly near-grade within the same rank class, consistent with normal Active-component fill patterns. Record this only as context unless the diagnostic is rerun and captured with exact counts.

## 19. Short working summary

If we had to pick a first-pass mapping today:

- `organizations` ← `unit_hierarchy` backbone + `organizations.csv` enrichment (current-row filter), with `hrc_curated_org_hierarchy.first_uic` as a strong parent-chain validation/candidate source.
- `organization_aliases` ← hierarchy alias arrays + GFM alternate names from `all_current_units_crew`.
- `sections` ← `partl`, using narrow staff-section derivation first. `partl` is verified in `mtoe_unit_personnel_view` and fully populated in `army_unit_auth_fms` for the WD83AA slice.
- `billets` ← **`army_unit_auth_fms`**. Q17 is closed: the WD83AA 178-vs-182 gap is explained by 4 non-Army `AIR SUPPORT` rows, TDA coverage is verified at dataset level and on W8A5AA, and `joint` is N/A because FMS has no `joint` `unit_type`.
- `billet` MOS / position-cardinality enrichment ← **`army_mtoe_aos_position_mapping`**, using current rows where `positions_effdt_to = '2999-12-01'`. Q18 is closed for WD83AA: `ipps_position_number` matches `current_unit.position_number` for real-billet rows.
- `people` ← `person`, with `names_*` reformatted to `First M. Last`, strict allowlist fields only, rank kept separate from the display name, and rank-gated `phone` / `duty_phone` shaping.
- `billet_occupants` ← `current_unit`, filtered by the §9 real-billet rule, joined to position-grain billet rows by `position_number`, asserted back to the FMS/AOS `auth_line_key`, and joined to people by DoD ID.

The WD83AA narrow vertical is built and validated. The three validated dataset outputs and contract-enforced row counts are recorded in §18. The implemented chain is:

```text
army_unit_auth_fms
→ army_mtoe_aos_position_mapping
→ current_unit
→ greenpages_people_wd83aa_prototype
```

The work was intentionally split into separate billet and occupant transforms instead of one combined `greenpages_billets_sections_occupants_wd83aa_prototype`. Billets and occupants have different grains, different validation contracts, and different failure modes. Keeping the stages separate exposed the 2026-05-08 `current_unit` drift from the earlier `200/30/170/46` handoff counts to the current validated `198/29/169/47` counts. Future UIC onboarding should preserve this two-stage shape unless a later architecture decision gives a stronger reason to combine them.


---

## 20. Vantage-to-Postgres load mechanism

The Vantage prototype outputs are loaded into Azure PostgreSQL Flexible Server using a simple bash + `psql` + SQL pattern. No ETL/source-shaping logic lives in Go.

### 20.1 Validated runtime path

```text
Raw Army source datasets in Vantage
→ Vantage PySpark transforms
→ Green Pages-shaped Vantage datasets
→ CSV/manual sync-load step
→ staging tables
→ validation checks
→ Azure PostgreSQL Flexible Server live tables
→ Go backend API
→ Frontend NGINX / React SPA
→ User browser
```

Vantage is the upstream data-processing layer. Azure PostgreSQL Flexible Server is the runtime read database. Normal page-load backend requests should read Postgres, not Vantage.

### 20.2 Loader files

- `backend/migrations/000008_source_keys_for_wd83aa_loader.sql` — adds the source-key columns described in §2.1.1.
- `backend/load_wd83aa_staging.sql` — creates the `staging` schema and three flat staging tables matching the Vantage CSV output columns.
- `backend/load_wd83aa_merge.sql` — validates staging, upserts into live tables, derives `occupancy_status`, soft-deletes stale rows, and validates post-merge counts inside a transaction.
- `backend/load_wd83aa_from_csv.sh` — orchestrates staging creation, CSV `\copy`, and merge execution.
- `backend/clear_dev_seed_data_before_wd83aa_load.sql` — one-time DEV cleanup used to remove fake seed/demo rows before loading the real WD83AA slice.

### 20.3 Input CSVs validated

```text
greenpages_people_wd83aa_prototype.csv              200 rows / 15 columns
greenpages_billets_wd83aa_prototype.csv             216 rows / 54 columns
greenpages_billet_occupants_wd83aa_prototype.csv    169 rows / 42 columns
```

### 20.4 Upsert conflict keys

| Live table | Conflict key |
|---|---|
| `organizations` | `uic` |
| `sections` | `source_section_key` |
| `people` | `dod_id` |
| `billets` | `source_billet_key` |
| `billet_occupants` | `source_billet_occupant_key` |

### 20.5 Soft-delete semantics

Rows present in the live table but absent from the current source-keyed load are retired rather than physically removed:

- `sections`: `is_current = FALSE`
- `billets`: `is_current = FALSE`
- `billet_occupants`: `assignment_status = 'inactive'`

`people` does not currently soft-delete from the WD83AA-only loader. A person leaving WD83AA between UIC-scoped loads remains `is_current = TRUE` until a broader people-refresh policy exists. Do not treat absence from one UIC-scoped load as proof a person is no longer current in the Army directory.

### 20.6 `occupancy_status` derivation

`occupancy_status` is derived inside the merge transaction from active `billet_occupants` after billets and occupants are loaded. The CSV-side `occupancy_status` column may be present but is not authoritative for the live read model.

### 20.7 Validated WD83AA post-merge counts

| Check | Validated result |
|---|---:|
| `organizations` | 1 |
| `sections` | 32 |
| `billets` | 216 |
| `people` | 200 |
| `billet_occupants` | 169 |
| `billets` filled / vacant | 169 / 47 |
| `billets_without_org` | 0 |
| `billets_without_section` | 0 |
| `occupants_without_billet_or_person` | 0 |
| duplicate `source_section_key` rows | 0 |
| duplicate `source_billet_key` rows | 0 |
| duplicate `source_billet_occupant_key` rows | 0 |

### 20.8 Idempotency validation

Rerunning the loader against the unchanged CSV set completed successfully without duplicating rows. Counts remained stable at 1 organization, 32 sections, 216 billets, 200 people, and 169 billet occupants. No stale rows were retired on the repeat run:

```text
retired_sections:    0
retired_billets:     0
inactive_occupants:  0
```

### 20.9 Legacy seed-data posture

Migrations `000003_seed_data.sql`, `000005_seed_billets.sql`, and `000007_seed_people.sql` predate the Vantage path and populate fake data. For the DEV WD83AA validation, those live seed/demo rows were cleared before loading real data so the deployed application served only the real WD83AA slice.

Disposition of legacy seed migrations is deferred. Options include deleting them, gating them behind an explicit dev seed flag, or replacing them with a smaller test fixture once the real-data path is stable.

### 20.10 Future sync/load work

- Keep the current manual CSV loader as a DEV validation tool.
- Do not generalize to all UICs until a second UIC is onboarded and validated.
- Next source-expansion candidate remains a TDA UIC such as `W8A5AA`.
- Before scheduled refresh, decide whether the sync/load step should run as a GitLab scheduled pipeline job or as a small worker.
- The known `people` phone model delta remains unresolved: current app schema has `work_phone`; source-shaped data contains `phone`, `duty_phone`, and compatibility `work_phone`.

