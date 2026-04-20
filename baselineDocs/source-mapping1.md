# Vantage Source Mapping: GreenPages Detailed Data Dictionary

**Objective:** Map exact column names from raw Vantage datasets to construct the GreenPages unified tables (`gp_users`, `gp_units`, `gp_roster`) via Vantage transforms (PySpark/SQL).

## Target 1: `gp_users` (Core Personnel Data)
**Primary Source:** `person.csv` / `person.json`
**Purpose:** The definitive list of Soldier demographics, readiness, and contact info.

| Raw Vantage Column | GreenPages Column | Type | Transform / Notes |
| :--- | :--- | :--- | :--- |
| `department_of_defense_identification_number` (or `edipi`) | `dod_id` | String | **Primary Key.** Must cast to string to avoid dropping leading zeros. Check which column is populated more reliably. |
| `names_last_name` | `last_name` | String | |
| `names_first_name` | `first_name` | String | |
| `names_middle` | `middle_name` | String | Handle nulls. |
| `names_name_suffix` | `suffix` | String | Handle nulls (e.g., Jr., II). |
| `dod_email` | `email` | String | Coalesce nulls to empty string. |
| `phone_duty` (or `phone`, `phone_home`) | `phone` | String | Prioritize `phone_duty` > `phone` > `phone_home`. |
| `grade` (or `rank_true_abbreviation`) | `rank` | String | Use `rank_true_abbreviation` if available for standard display (e.g., "SGT", "CPT"). |
| `primary_specialty_code` | `mos` | String | The Soldier's actual MOS. |
| `component` | `component` | String | e.g., Active, Reserve, National Guard. |
| `uic` | `assigned_uic` | String | The unit they are currently attached/assigned to (Foreign Key to `gp_units`). |
| `assignment_status` | `status` | String | e.g., "Assigned", "Attached". |
| `medical_overdue_flag` | `is_medical_overdue` | Boolean | If your frontend needs a quick readiness indicator. |

---

## Target 2: `gp_units` (Unit Hierarchy and Data)
**Primary Sources:** `unit_hierarchy.csv`, `organizations.csv` (or `all_current_units_crew.csv`)
**Purpose:** Defines the organizational tree and human-readable unit information.

| Raw Vantage Column | GreenPages Column | Type | Source File | Transform / Notes |
| :--- | :--- | :--- | :--- | :--- |
| `uic` | `uic` | String | `unit_hierarchy` | **Primary Key.** |
| `parent_uic` (or `administrative_control_parent_uic`) | `parent_uic` | String | `unit_hierarchy` | Foreign Key back to `uic`. |
| `uic_hierarchy` | `hierarchy_path` | JSON Array | `unit_hierarchy` | Pass this raw array directly to the frontend for instant tree rendering. |
| `uic_long_name` | `name` | String | `unit_hierarchy` | Use this for the display name. |
| `uic_short_name` | `short_name` | String | `unit_hierarchy` | |

*(Note: If `unit_hierarchy` lacks geographic data, you must LEFT JOIN `organizations` on `uic = organization_data_history_uic` to pull `locations_city` and `locations_state`.)*

---

## Target 3: `gp_roster` (Billets and MTOE/TDA Authorizations)
**Primary Sources:** `smallunit_billets.csv`, `mtoe_unit_personnel_view.csv`, `fms_unit_personnel_view.csv`
**Purpose:** The intersection of Units, Positions (Billets), and the People sitting in them.

**CRITICAL STEP:** Vantage handles two different force structures. MTOE is for deployable units; FMS (TDA) is for garrison/institutional units. We must handle both.

### Step 3a: The Billet Definition
From `smallunit_billets.csv`:

| Raw Vantage Column | GreenPages Column | Type | Transform / Notes |
| :--- | :--- | :--- | :--- |
| `billet_id` | `billet_id` | String | **Primary Key.** |
| `mtoe_uic` (or `lduic`) | `uic` | String | Foreign Key to `gp_units`. |
| `billet_name` | `billet_title` | String | e.g., "Rifleman", "Commander". |
| `posco` | `position_code` | String | The official position code. |
| `grade` | `required_grade` | String | Required rank for the billet. |
| `mos` | `required_mos` | String | Required MOS for the billet. |
| `assigned_soldier_ssn_hash` | *Do not use* | | This is hashed. We need the actual DODID to join to the `person` table. |

### Step 3b: The Authorizations & Assignments (The Complex Join)
The raw MTOE/FMS views (`mtoe_unit_personnel_view.csv` and `fms_unit_personnel_view.csv`) define the authorized strength (`austr`) and required strength (`rqstr`), but they link to personnel using `docno`, `parno`, and `perln` (Paragraph and Line numbers).

To find out **who** is in a specific billet, your Vantage Transform will need to:
1.  Map the `smallunit_billets.billet_id` to the `person.position_number` or `person.position_fmid`.
2.  Alternatively, look at `person.uic` and `person.duty_specialty` to match them to a slot if direct billet mapping fails.

**The Target `gp_roster` Table Structure:**
After joining in Vantage, output this exact table:

| Transformed Column | Type | Description |
| :--- | :--- | :--- |
| `roster_id` | UUID | Generated in Vantage during transform. |
| `uic` | String | FK to `gp_units.uic`. |
| `billet_id` | String | FK to `smallunit_billets.billet_id`. |
| `billet_title` | String | From `billet_name`. |
| `assigned_dod_id` | String | FK to `gp_users.dod_id`. (Null if the seat is empty/unassigned). |
| `is_mtoe` | Boolean | True if sourced from MTOE, False if FMS. |