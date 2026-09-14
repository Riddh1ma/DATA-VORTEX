# Final Reconciliation Audit Report: Raw vs. Cleaned Datasets

**Competition:** Data Vortex - Round 1  
**Audit Target:** Reconcile all metric discrepancies between raw and cleaned posts datasets  
- **Raw File:** [data/raw/Social_Engine_Posts_Corrupted.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/raw/Social_Engine_Posts_Corrupted.csv) (12,360 rows)  
- **Cleaned File:** [data/cleaned/Social_Engine_Posts_Cleaned.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/cleaned/Social_Engine_Posts_Cleaned.csv) (12,000 rows)  
- **Users Baseline:** [data/cleaned/Social_Engine_Users_Cleaned.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/cleaned/Social_Engine_Users_Cleaned.csv) (1,500 rows)  
**Execution Date:** 2026-09-14  
**Audit Status:** Completed — 100% Reconciled and Mathematically Verified  

---

## 1. Executive Reconciliation Summary

This reconciliation audit explains and mathematically accounts for every variance observed between the initial raw forensic report and the final cleaned datasets.

### Core Reconciliation Proof:
1. **The Negative Likes Discrepancy (525 raw vs. 509 cleaned):**
   - The raw file contained **525 negative likes**.
   - Exactly **16 negative-like records** were present within the **360 exact duplicate rows** that were pruned during deduplication.
   - Exactly **509 negative-like records** remained in the deduplicated dataset.
   - 100% of these 509 values were converted via `abs(likes)` to valid positive integers.
   - **0 negative likes** remain in the cleaned dataset.
2. **The Exact Duplicate Proof (360 rows):**
   - Every single one of the 360 removed rows was verified to be a byte-for-byte exact replica of an earlier retained row across all 8 columns.
   - Zero non-identical records were removed.
3. **Missing Value Invariance (No Imputation):**
   - `platform`: 1,846 raw missing $-$ 62 in duplicate rows $=$ **1,784 cleaned missing** (100% preserved).
   - `likes`: 1,858 raw missing $-$ 44 in duplicate rows $=$ **1,814 cleaned missing** (100% preserved).
   - `text_content`: 1,746 raw missing $-$ 58 in duplicate rows $+$ 23 stripped literal `"NULL\n\n"` tokens $=$ **1,711 cleaned missing** (100% preserved).
   - Zero missing values were artificially filled.
4. **Column Invariance:**
   - `post_id`, `user_id`, `shares`, `comments`, and `platform` are **100% bit-level identical** between the kept raw rows and cleaned rows.

---

## 2. Comprehensive Master Reconciliation Table

| Metric / Attribute | Raw Posts (`Social_Engine_Posts_Corrupted.csv`) | Removed by Exact Deduplication | Cleaned Posts (`Social_Engine_Posts_Cleaned.csv`) | Mathematical Proof & Detailed Explanation |
| :--- | :---: | :---: | :---: | :--- |
| **Total Row Count** | 12,360 | 360 | **12,000** | $12,360 - 360 = 12,000$. Exactly 360 redundant duplicate rows dropped. |
| **Unique `post_id` Count** | 12,000 | 0 unique IDs lost | **12,000** | Every duplicate post shared an identical `post_id` with an earlier row. |
| **Exact Duplicate Rows** | 360 | 360 | **0** | All redundant duplicate tuples were eliminated. |
| **Negative Likes Count** | 525 | 16 | **0** | $525 - 16 = 509$ unique negative likes; all 509 converted via `abs()`. |
| **Positive / Zero Likes** | 9,977 | 300 | **10,186** | $(9,977 - 300) + 509\text{ (corrected)} = 10,186$ valid non-negative likes. |
| **Missing Likes (`NaN`)** | 1,858 | 44 | **1,814** | $1,858 - 44 = 1,814$. Retained without imputation. |
| **Missing Platform (`NaN`)** | 1,846 | 62 | **1,784** | $1,846 - 62 = 1,784$. Retained without imputation. |
| **Missing Text Content (`NaN`)** | 1,746 | 58 | **1,711** | $(1,746 - 58) + 23\text{ (stripped 'NULL\n\n')} = 1,711$. Retained without imputation. |
| **Shares Missing Count** | 0 | 0 | **0** | 100% populated; values are 100% identical. |
| **Comments Missing Count** | 0 | 0 | **0** | 100% populated; values are 100% identical. |
| **Orphan User IDs** | 0 | 0 | **0** | 100% of rows map to valid users in `Social_Engine_Users_Cleaned.csv`. |
| **Unparseable Timestamps** | 0 | 0 | **0** | All 12,000 rows standardized to `YYYY-MM-DD HH:MM:SS`. |
| **Padded Text Content** | 337 | 8 | **0** | $337 - 8 = 329$ padded rows; all 329 cleanly trimmed. |
| **HTML Entity `&amp;` Count** | 341 | 13 | **0** | $341 - 13 = 328$ rows with `&amp;`; all 328 decoded to `&`. |

---

## 3. Deep Dive into Reconciled Discrepancies

### 3.1 Negative Likes: Reconciling 525 vs. 509
In the initial forensic report (Report 03), **525 negative likes** were identified across the 12,360 raw rows. In the cleaning log (Report 04), **509 rows** were transformed.

#### Reconciliation Proof:
- **Raw Negative Likes Count:** 525
- **Negative Likes in the 360 Dropped Duplicates:** Exactly 16 records.
- **Negative Likes Remaining in Kept Unique Rows:** $525 - 16 = 509$ records.
- **Applied Transformation:** Every single one of the 509 records had its negative sign inverted via `abs(original_likes)`.
- **Invariance Test on Positive Likes:** All 9,677 non-negative likes in the deduplicated subset remained strictly identical (`clean == raw`).
- **Invariance Test on Missing Likes:** All 1,814 null likes remained strictly null.
- **Result:** **0 negative likes exist in the cleaned file**.

```text
  Raw Negative Likes:       525
- Duplicate Row Removals:  - 16
--------------------------------
  Transformed via abs():    509
  Remaining Negatives:        0  (PASS)
```

---

### 3.2 Missing Values: Reconciling Raw vs. Cleaned Null Counts
Because 360 duplicate rows were removed, the absolute count of missing values decreased proportionally:

#### 1. Platform Missingness:
- Raw Missing: 1,846 rows (14.94%)
- Missing in 360 Duplicate Rows: 62 rows
- Cleaned Missing: $1,846 - 62 = \mathbf{1,784}$ rows (14.87%)
- **Verification:** 100% of the 1,784 missing platforms were preserved. Zero rows were imputed with `'Unknown'` or other constants.

#### 2. Likes Missingness:
- Raw Missing: 1,858 rows (15.03%)
- Missing in 360 Duplicate Rows: 44 rows
- Cleaned Missing: $1,858 - 44 = \mathbf{1,814}$ rows (15.12%)
- **Verification:** 100% of the 1,814 missing likes were preserved as nulls. Zero rows were imputed with mean, median, or zero.

#### 3. Text Content Missingness:
- Raw Missing (via default pandas NA parsing): 1,746 rows
- Missing in 360 Duplicate Rows: 58 rows
- Baseline Kept Missing: $1,746 - 58 = 1,688$ rows
- **The Literal `"NULL\n\n"` Resolution:** In the raw dataset, exactly 23 kept rows contained the malformed text literal `"NULL\n\n"`. During text sanitization, `str.strip()` trimmed the trailing newlines to `"NULL"`. When serialized to standard CSV, these are properly output as empty null fields (`,,`).
- Cleaned Missing: $1,688 + 23 = \mathbf{1,711}$ rows (14.26%).
- **Verification:** Zero missing text content fields were filled or fabricated.

---

### 3.3 Duplicate Pruning: Exact Duplicate Verification
To confirm that deduplication was strictly conservative:
1. Every one of the 360 removed records was cross-checked against the 12,000 retained records across all 8 columns (`post_id`, `user_id`, `platform`, `text_content`, `timestamp`, `likes`, `shares`, `comments`).
2. An inner join between the 360 removed records and the 12,000 kept records matched **exactly 360 records**.
3. Zero records with distinct metrics, different timestamps, or differing content were pruned.
4. **Conclusion:** Deduplication only eliminated redundant multi-extracted identical records.

---

### 3.4 Invariance Audit: Proof That Legitimate Columns Were Untouched
A row-by-row equality assertion was executed between the 12,000 deduplicated raw records and the 12,000 cleaned records:

| Column | Equality Assertion (`Cleaned == Kept_Raw`) | Validation Result |
| :--- | :---: | :---: |
| `post_id` | `(df_clean['post_id'] == df_kept_raw['post_id']).all()` | **TRUE (100% Identical)** |
| `user_id` | `(df_clean['user_id'] == df_kept_raw['user_id']).all()` | **TRUE (100% Identical)** |
| `shares` | `(df_clean['shares'] == df_kept_raw['shares']).all()` | **TRUE (100% Identical)** |
| `comments` | `(df_clean['comments'] == df_kept_raw['comments']).all()` | **TRUE (100% Identical)** |
| `platform` | `((df_clean['platform'] == df_kept_raw['platform']) \| (both null)).all()` | **TRUE (100% Identical)** |

---

## 4. Final Verification Checklist

- [x] **Row Count:** Exactly 12,000 rows in `Social_Engine_Posts_Cleaned.csv`.
- [x] **Unique Keys:** Exactly 12,000 unique `post_id` values.
- [x] **Zero Duplicates:** 0 exact duplicate rows.
- [x] **Zero Negative Likes:** 0 negative non-null likes.
- [x] **Zero Orphan Posts:** 0 posts with invalid `user_id`s.
- [x] **Standardized Timestamps:** 100% conform to `YYYY-MM-DD HH:MM:SS` within `[2024-05-01, 2025-04-30]`.
- [x] **Clean Text:** 0 padded text rows; 0 raw `&amp;` entities.
- [x] **No Imputation:** All missing values in `platform`, `text_content`, and `likes` remain null.
- [x] **Raw Immutability:** `Social_Engine_Users.csv` and `Social_Engine_Posts_Corrupted.csv` remain completely untouched.

---

*Reconciliation audit concluded successfully. Datasets are verified and ready for Exploratory Data Analysis (EDA).*
