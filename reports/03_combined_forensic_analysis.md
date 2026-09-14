# Combined Forensic Analysis & Cross-Dataset Audit Report

**Competition:** Data Vortex - Round 1  
**Datasets Under Audit:**  
1. `data/raw/Social_Engine_Users.csv` (1,500 user profile records)  
2. `data/raw/Social_Engine_Posts_Corrupted.csv` (12,360 post interaction records)  
**Audit Date:** 2026-09-14  
**Audit Governance:** Both original CSV files remain completely untouched and unmodified.

---

## 1. Executive Summary

This forensic audit investigates the structural, syntactic, semantic, and relational integrity of both raw datasets and the foreign key relationship connecting them. 

### Key Findings:
1. **Perfect Cross-Dataset Referential Integrity:** Every single one of the 12,360 post records maps to a valid user in `Social_Engine_Users.csv`. There are **0 orphan posts** and **0 unrepresented users** (all 1,500 users have between 1 and 22 posts).
2. **Perfect Chronological Alignment:** 100% of post timestamps fall between **May 1, 2024 and April 30, 2025**, which strictly follows the 2023 calendar year user account creation window. Zero posts predate account registration.
3. **Confirmed Corruptions in Posts:**
   - **Negative Likes (525 rows, 4.25%):** Negative values ranging from -4,987 to -11 represent an exact sign-inversion anomaly (multiplying valid positive integers by -1).
   - **Exact Duplicate Rows (360 rows, 2.91%):** Exact duplicate records repeated across all 8 columns.
   - **Timestamp Format Heterogeneity (12,360 rows):** Three distinct date representations coexist (`ISO 8601`, `DD-MM-YYYY`, and `10-digit Unix epoch seconds`).
   - **Whitespace Padding in Text (337 rows):** Leading or trailing whitespace in `text_content`.
   - **HTML Entity Escaping in Text (341 rows):** Unescaped `&amp;` strings in `text_content`.
4. **Missing Values in Posts:**
   - `platform`: 1,846 missing (14.94%)
   - `text_content`: 1,746 missing (14.13%)
   - `likes`: 1,858 missing (15.03%)

---

## 2. PART A — USERS DATASET CONFIRMATION

The raw file [data/raw/Social_Engine_Users.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/raw/Social_Engine_Users.csv) was re-verified against all 13 core integrity checks:

| # | Audit Item | Verified Result | Forensic Finding |
| :---: | :--- | :--- | :--- |
| **1** | **Dimensions** | 1,500 rows × 5 columns | Complete and structurally intact |
| **2** | **Column Inventory** | `user_id`, `location`, `language`, `account_created`, `follower_count` | Exact order matches specification |
| **3** | **Data Types** | `object`, `object`, `object`, `object`, `int64` | Standard raw types |
| **4** | **Missing Values** | 0 cells (0.00%) | 100% fully populated |
| **5** | **Exact Duplicate Rows** | 0 rows (0.00%) | Every record is distinct |
| **6** | **Duplicate User IDs** | 0 duplicates | 100% primary key uniqueness |
| **7** | **User ID Syntax** | 1,500 / 1,500 match `^user_[a-z0-9]{8}$` | 13-character uniform lowercase alphanumeric schema |
| **8a** | **Location Frequencies** | 33 unique locations (Barcelona: 56 down to Sydney: 28) | 32 use `"City, Country"`; `Singapore` (49 rows) is a city-state |
| **8b** | **Language Frequencies** | 10 unique ISO 639-1 codes (`zh`: 168 down to `de`: 141) | Uniformly balanced (9.4% to 11.2% each) |
| **9** | **Follower Count Stats** | Min: 109, Max: 49,944, Mean: 24,964.02, Median: 24,741.50 | Uniform $\mathcal{U}(100, 50000)$; 0 negatives, 0 zeros, 0 outliers |
| **10** | **Account Created Dates** | Min: `2023-01-01`, Max: `2023-12-31`, 0 invalid | Spans 2023 calendar year across 359 distinct days (6 Poisson zero-days) |
| **11** | **Hidden Characters** | 0 control, 0 formatting, 0 zero-width characters | Verified via Python `unicodedata` inspection |
| **12** | **Whitespace Padding** | 0 leading/trailing whitespace instances | All strings are cleanly trimmed |
| **13** | **Unicode Integrity** | Valid UTF-8 `0xC3 0xA3` (`ã`) in `São Paulo, Brazil` | 44 rows; authentic Portuguese orthography |

---

## 3. PART B — POSTS DATASET FORENSIC AUDIT

Target File: [data/raw/Social_Engine_Posts_Corrupted.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/raw/Social_Engine_Posts_Corrupted.csv)

### 3.1 Dataset Structure
- **Physical Line Count:** 12,361 lines (1 header + 12,360 data rows).
- **Column Count:** Exactly 8 columns across 100% of rows.
- **Header Structure:** `['post_id', 'user_id', 'platform', 'text_content', 'timestamp', 'likes', 'shares', 'comments']`.
- **Delimiter:** `,` (ASCII Comma).
- **Encoding:** UTF-8 (No BOM).
- **Malformed Rows:** 0 (Zero mismatched column counts or unclosed quotes).

---

### 3.2 Missing Value Audit

| Column | Raw Data Type | Non-Null Count | Missing Count | Missing (%) | Empty Strings (`""`) | Whitespace-Only Strings |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| `post_id` | `object` (`string`) | 12,360 | 0 | 0.00% | 0 | 0 |
| `user_id` | `object` (`string`) | 12,360 | 0 | 0.00% | 0 | 0 |
| `platform` | `object` (`string`) | 10,514 | 1,846 | 14.94% | 0 | 0 |
| `text_content` | `object` (`string`) | 10,614 | 1,746 | 14.13% | 0 | 0 |
| `timestamp` | `object` (`string`) | 12,360 | 0 | 0.00% | 0 | 0 |
| `likes` | `float64` | 10,502 | 1,858 | 15.03% | 0 | 0 |
| `shares` | `int64` | 12,360 | 0 | 0.00% | 0 | 0 |
| `comments` | `int64` | 12,360 | 0 | 0.00% | 0 | 0 |

#### Missingness Overlap Analysis:
- **Rows with at least one missing attribute:** 4,713 rows (38.13%).
- **Rows missing all three nullable attributes (`platform`, `text_content`, `likes`):** 40 rows (0.32%).
- **Complete cases (all 8 columns populated):** 7,647 rows (61.87%).

---

### 3.3 Duplicate Records Analysis

| Duplicate Type | Count | Percentage | Description |
| :--- | :---: | :---: | :--- |
| **Exact Duplicate Rows** | 360 | 2.91% | All 8 fields match an earlier row |
| **Duplicate `post_id`** | 360 | 2.91% | 12,000 unique `post_id`s across 12,360 rows |
| **Duplicate `(post_id, user_id)`** | 360 | 2.91% | Matches exact duplicate row count |
| **Duplicate `user_id`** | 10,860 | 87.86% | Expected: users publish multiple posts |

Every duplicate `post_id` corresponds to an exact, identical row duplication. There are **0 conflicting duplicate IDs** (cases where the same `post_id` has conflicting timestamps or content).

---

### 3.4 Post ID Validation (`post_id`)
- **Format:** Every post ID consists of 12 lowercase alphanumeric characters matching `^[a-z0-9]{12}$`.
- **Length:** Exactly 12 characters across all 12,360 records.
- **Prefix:** Unlike `user_id`, `post_id` does not have a static prefix.
- **Validity:** 100% conform to valid synthetic token standards.

---

### 3.5 User ID Validation & Foreign Key Relationship
- **Cross-Reference:** Every `Posts.user_id` was compared against the `Users.user_id` primary key set.
- **Users in `Users` Table:** 1,500
- **Unique Users in `Posts` Table:** 1,500
- **Orphan Posts (Posts with non-existent `user_id`):** **0 (0.00%)**
- **Inactive Users (Users with 0 posts):** **0 (0.00%)**
- **Posts per User Distribution:**
  - Mean: 8.24 posts | Median: 8.0 posts | Std Dev: 2.95
  - Min: 1 post | Max: 22 posts
  - Interquartile Range: [6, 10] posts

---

### 3.6 Platform Analysis (`platform`)
- **Total Populated Entries:** 10,514
- **Missing Entries:** 1,846 (14.94%)
- **Distribution of Populated Platforms:**
  1. `YouTube`: 2,136 (20.32% of populated)
  2. `Facebook`: 2,135 (20.31% of populated)
  3. `Twitter`: 2,119 (20.15% of populated)
  4. `Reddit`: 2,086 (19.84% of populated)
  5. `Instagram`: 2,038 (19.38% of populated)
- **Formatting / Syntax Audit:**
  - Capitalization: 100% consistent Title Case.
  - Whitespace: 0 padded strings.
  - Unexpected or corrupted platform names: 0.

---

### 3.7 Text Content Analysis (`text_content`)
- **Total Populated Entries:** 10,614
- **Missing Entries:** 1,746 (14.13%)
- **Character Lengths:** Min = 6, Max = 172, Mean = 117.38 characters.
- **Formatting & Escaping Anomalies:**
  - **Whitespace Padding:** Exactly 337 rows have untrimmed leading or trailing whitespace.
  - **HTML Entity Artifacts:** Exactly 341 rows contain unescaped HTML entities (specifically `&amp;` instead of `&`).
  - **Hashtags:** 10,520 rows contain one or more `#hashtags`.
  - **User Mentions:** 1,415 rows contain `@mentions`.
  - **Duplicate Text Strings:** 689 rows share duplicate text (comprising the 360 duplicate rows plus common short phrases).

---

### 3.8 Timestamp Forensic Analysis (`timestamp`)
Timestamps are 100% populated (0 missing values), but are encoded across **three distinct representations**:

| Timestamp Format | Syntax Example | Row Count | Percentage | Temporal Span (Min to Max) | Time Component Present? |
| :--- | :--- | :---: | :---: | :--- | :---: |
| **ISO 8601** | `2025-04-13T20:12:18` | 4,950 | 40.05% | `2024-05-01 01:35:53` to `2025-04-30 21:57:10` | Yes (HH:MM:SS) |
| **Unix Epoch** | `1722528840` | 3,788 | 30.65% | `2024-05-01 04:39:36` to `2025-04-30 21:21:15` | Yes (Seconds precision) |
| **DD-MM-YYYY** | `25-09-2024` | 3,622 | 29.30% | `2024-05-01 00:00:00` to `2025-04-30 00:00:00` | No (Date only) |
| **Total** | — | **12,360** | **100.0%** | **2024-05-01 00:00:00 to 2025-04-30 21:57:10** | — |

#### Critical Forensic Discoveries:
1. **Epoch Resolution:** The Unix timestamps consist of exactly 10 digits, confirming they are in **seconds** (13 digits would indicate milliseconds).
2. **Unified Interval:** Across all three formats, the minimum date is May 1, 2024, and the maximum date is April 30, 2025. This shows that all three formats represent the exact same continuous 12-month post collection window.
3. **Cross-Dataset Temporal Coherence:** Every user account in `Social_Engine_Users.csv` was registered between `2023-01-01` and `2023-12-31`. Since all posts occur between `2024-05-01` and `2025-04-30`, **zero posts predate user creation dates**.

---

### 3.9 Engagement Metrics Analysis (`likes`, `shares`, `comments`)

#### 1. Likes Analysis:
- **Total Populated:** 10,502 | **Missing:** 1,858 (15.03%)
- **Data Type:** `float64` (stored as floats due to NaN representations; all non-null values are `.0` integers).
- **Negative Likes Corruption:**
  - **Count:** Exactly 525 rows (4.25% of all rows; 5.00% of populated likes).
  - **Negative Range:** -4,987 to -11 ($Mean = -2,457.24, Std = 1,426.57$).
  - **Positive Range:** 0 to 5,000 ($Mean = 2,494.62, Std = 1,437.92$).
  - **Evidence of Sign Inversion:** The statistical distribution of $|negative\_likes|$ ($Mean = 2,457.24, Median = 2,388, Std = 1,426.57$) identically mirrors the positive likes distribution ($Mean = 2,494.62, Median = 2,505, Std = 1,437.92$). This indicates that negative likes are valid integer engagement metrics corrupted by an accidental sign negation ($x \times -1$).
- **Zero Likes:** 1 row.

#### 2. Shares Analysis:
- **Total Populated:** 12,360 (0 missing) | **Data Type:** `int64`
- **Range:** 0 to 2,000 ($Mean = 1,005.87, Median = 1,016.00, Std = 574.73$).
- **Negatives:** 0 | **Zeros:** 5.

#### 3. Comments Analysis:
- **Total Populated:** 12,360 (0 missing) | **Data Type:** `int64`
- **Range:** 0 to 1,000 ($Mean = 504.08, Median = 503.00, Std = 288.80$).
- **Negatives:** 0 | **Zeros:** 13.

#### 4. Inter-Metric Correlation:
Engagement metrics are mutually independent ($r_{likes, shares} = 0.012$, $r_{likes, comments} = 0.010$, $r_{shares, comments} = 0.026$), consistent with synthetic benchmark generation.

---

## 4. Corruption Classification Matrix

| Issue | Dataset | Column | Exact Value(s) | Row Number(s) | Frequency | Evidence | Severity | Recommended Action | Confidence |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- | :---: | :---: | :---: |
| **Negative Likes (Sign Inversion)** | Posts | `likes` | Integers in range $[-4987, -11]$ | 525 rows (e.g., 20, 27, 43, 62, 85...) | 525 | Distribution of $|likes|$ matches positive likes $\mathcal{U}(0, 5000)$ | High | **CLEAN** | **HIGH** |
| **Exact Duplicate Rows** | Posts | Full Row | Identical across all 8 columns | 360 rows (e.g., 3003, 5671, 9153...) | 360 | Redundant duplicated records sharing identical `post_id` | High | **CLEAN** | **HIGH** |
| **Heterogeneous Timestamps** | Posts | `timestamp` | `YYYY-MM-DDTHH:MM:SS`, `10-digit epoch`, `DD-MM-YYYY` | All 12,360 rows | 12,360 | 3 distinct formats spanning 2024-05-01 to 2025-04-30 | Medium | **CLEAN** | **HIGH** |
| **Whitespace Padding** | Posts | `text_content` | Strings with leading/trailing spaces | 337 rows | 337 | Untrimmed whitespace (`s != s.strip()`) | Low | **CLEAN** | **HIGH** |
| **HTML Entity Escaping** | Posts | `text_content` | Strings containing `&amp;` | 341 rows | 341 | Raw HTML entity token for ampersand | Low | **CLEAN** | **HIGH** |
| **Missing Platform** | Posts | `platform` | `NaN` | 1,846 rows | 1,846 | Missing platform metadata (14.94%) | Medium | **INVESTIGATE** | **HIGH** |
| **Missing Text Content** | Posts | `text_content` | `NaN` | 1,746 rows | 1,746 | Missing post text (14.13%) | Medium | **INVESTIGATE** | **HIGH** |
| **Missing Likes** | Posts | `likes` | `NaN` | 1,858 rows | 1,858 | Missing engagement count (15.03%) | Medium | **INVESTIGATE** | **HIGH** |
| **City-State Location Naming** | Users | `location` | `'Singapore'` | 49 rows in Users | 49 | Sovereign city-state validly lacking country suffix | Low / Info | **INVESTIGATE** | **HIGH** |
| **Accented UTF-8 Character** | Users | `location` | `'São Paulo, Brazil'` | 44 rows in Users | 44 | Authentic Portuguese spelling `ã` (`U+00E3`) | Low / Info | **KEEP** | **HIGH** |

---

## 5. Categorized Findings Summary

### A. Confirmed Corruption
1. **Negative Likes (525 rows):** Likes cannot be logically negative. The statistical symmetry indicates an inverted sign error.
2. **Exact Duplicate Rows (360 rows):** Complete duplicate tuples that distort statistical calculations and aggregation.
3. **Timestamp Formatting Chaos (12,360 rows):** Inconsistent formats preventing direct SQL and chronological querying.
4. **Text Whitespace Padding (337 rows):** Formatting noise.
5. **Text HTML Entity Escaping (341 rows):** Unescaped `&amp;` entities.

### B. Potential Corruption / Missing Data
1. **Missing Data in Posts (38.13% of rows have $\ge 1$ null):** Missing `platform`, `text_content`, and `likes` values require a disciplined imputation or flagging strategy.

### C. Legitimate / Synthetic Characteristics (Do NOT Change)
1. **Referential Integrity:** 100% matching user IDs between Posts and Users.
2. **Temporal Alignment:** All posts occur 5 to 16 months after account creation.
3. **Uniform Metric Distributions:** Uniformity in follower count, shares, comments, and positive likes is an intentional synthetic property.
4. **Location-Language Independence:** Random assignment across demographic categories is synthetic benchmark design.
5. **`Singapore` and `São Paulo`:** Geographically and orthographically authentic representations.

### D. No Issue Found
- `post_id` format and uniqueness (post-deduplication).
- `user_id` format and referential linkage.
- `shares` and `comments` distributions and boundaries.

---

## 6. Proposed Cleaning Plan (Roadmap for Phase 2)

*Note: In accordance with competition governance, no cleaning steps are executed yet.*

| Step | Target Column(s) | Proposed Transformation | Rationale & Evidence | Transformation Rule | Reversibility | Validation Method |
| :---: | :--- | :--- | :--- | :--- | :---: | :--- |
| **1** | Full Table | Deduplicate exact duplicate rows | 360 rows are identical across all 8 columns | `df.drop_duplicates()` | Reversible via raw backup | Assert `df['post_id'].nunique() == len(df)` (12,000 unique rows) |
| **2** | `likes` | Invert negative values | 525 negative values mirror positive likes distribution | `likes = abs(likes)` | Reversible | Assert `(likes < 0).sum() == 0` and max likes $\le 5000$ |
| **3** | `timestamp` | Standardize to ISO 8601 string / datetime | 3 competing formats (`ISO`, `DD-MM-YYYY`, `epoch`) | Parse all 3 formats to `YYYY-MM-DD HH:MM:SS` | Reversible | Assert all parsed without `NaT`; verify bounds $[2024-05-01, 2025-04-30]$ |
| **4** | `text_content` | Trim padding & decode `&amp;` | 337 padded rows; 341 rows with `&amp;` | `s.str.strip().replace('&amp;', '&')` | Reversible | Assert 0 untrimmed strings and 0 `&amp;` tokens |
| **5** | `platform` | Handle missing values | 1,846 null values (14.94%) | Impute with `'Unknown'` or preserve as `NULL` depending on SQL spec | Reversible | Assert no unintended platform values created |
| **6** | `likes` (nulls) | Handle missing values | 1,858 null values (15.03%) | Retain as SQL `NULL` or impute median (2,494) with indicator | Reversible | Track imputed row indices |
| **7** | `location` (Users) | Split into City / Country | Phase 2 SQL analytical queries require country aggregation | `city, country = loc.split(', ')` (Singapore $\rightarrow$ Singapore, Singapore) | Reversible | Assert 33 unique cities and 19 unique countries |

---

## 7. Deliverable Verification

1. **Combined Forensic Report:** [reports/03_combined_forensic_analysis.md](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/03_combined_forensic_analysis.md)
2. **Combined Forensic Notebook:** [notebooks/03_combined_forensic_analysis.ipynb](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/03_combined_forensic_analysis.ipynb)
3. **Posts Forensic Summary CSV:** [outputs/posts_forensic_summary.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/posts_forensic_summary.csv)
