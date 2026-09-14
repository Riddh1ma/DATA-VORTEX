# Initial Dataset Inspection & Audit Report

**Competition:** Data Vortex - Round 1  
**Target File:** `data/raw/Social_Engine_Users.csv`  
**Date of Audit:** 2026-09-14  
**Audit Status:** Completed — Read-Only Inspection (No data modified)

---

## 1. Dataset Overview

An initial audit was performed on the raw competition dataset located at [data/raw/Social_Engine_Users.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/raw/Social_Engine_Users.csv). The file was inspected directly using Python 3 and pandas without altering, moving, or overwriting the original file.

| Parameter | Observed Value | Notes |
| :--- | :--- | :--- |
| **Filename** | `Social_Engine_Users.csv` | Original raw dataset file |
| **File Location** | `data/raw/` | Read-only competition storage |
| **File Size** | 76,897 bytes (75.1 KB) | Exact file size on disk |
| **Encoding** | UTF-8 | Valid UTF-8 byte stream; no BOM detected |
| **Delimiter** | `,` (Comma) | Standard CSV format verified by `csv.Sniffer` |
| **Line Terminator** | CRLF (`\r\n`) | Windows line endings |
| **Total Rows** | 1,500 data records | Excluding header row (1,501 total lines) |
| **Total Columns** | 5 columns | Complete table structure |

---

## 2. Sample Records

### First 10 Records (Head)

| # | user_id | location | language | account_created | follower_count |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | `user_guglt5jp` | Berlin, Germany | `ja` | `2023-10-23` | 38,963 |
| **1** | `user_b1p3wz81` | Munich, Germany | `zh` | `2023-05-06` | 24,644 |
| **2** | `user_jm2grmis` | Dubai, UAE | `en` | `2023-01-03` | 45,842 |
| **3** | `user_ykoqww5l` | Paris, France | `fr` | `2023-10-11` | 665 |
| **4** | `user_3zzvv8vp` | Los Angeles, USA | `ru` | `2023-05-23` | 42,908 |
| **5** | `user_s4nmuyvf` | Mumbai, India | `zh` | `2023-03-17` | 43,412 |
| **6** | `user_9vo7he3z` | Rio de Janeiro, Brazil | `en` | `2023-12-01` | 36,257 |
| **7** | `user_guruu55k` | Mexico City, Mexico | `en` | `2023-03-30` | 11,260 |
| **8** | `user_8nvzxsuj` | Vancouver, Canada | `es` | `2023-12-03` | 36,383 |
| **9** | `user_rgmvy3e1` | London, UK | `ja` | `2023-12-21` | 13,458 |

### Last 10 Records (Tail)

| # | user_id | location | language | account_created | follower_count |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1490** | `user_ewhj7uh3` | Houston, USA | `es` | `2023-12-23` | 14,378 |
| **1491** | `user_oypkjogs` | Dubai, UAE | `es` | `2023-10-31` | 47,001 |
| **1492** | `user_oki4xfhu` | São Paulo, Brazil | `es` | `2023-10-23` | 42,213 |
| **1493** | `user_1cz5m9ov` | Beijing, China | `hi` | `2023-01-19` | 18,267 |
| **1494** | `user_uby999hz` | Houston, USA | `de` | `2023-02-14` | 10,510 |
| **1495** | `user_5l9nw5ja` | Milan, Italy | `hi` | `2023-05-07` | 11,777 |
| **1496** | `user_5bifiovr` | Johannesburg, South Africa | `zh` | `2023-05-11` | 44,077 |
| **1497** | `user_m27g42ms` | Beijing, China | `hi` | `2023-01-28` | 27,325 |
| **1498** | `user_17homyqe` | Toronto, Canada | `en` | `2023-07-27` | 4,887 |
| **1499** | `user_057ka83m` | London, UK | `zh` | `2023-02-11` | 17,153 |

---

## 3. Column & Data-Type Summary

The dataset comprises 5 columns. All text and date columns are initially loaded as `object` (or `string` in modern pandas), while `follower_count` is recognized as an integer (`int64`).

| Column Index | Column Name | Raw / Pandas Dtype | Non-Null Count | Missing Count | Missing (%) |
| :---: | :--- | :--- | :---: | :---: | :---: |
| 1 | `user_id` | `object` (`string`) | 1,500 | 0 | 0.00% |
| 2 | `location` | `object` (`string`) | 1,500 | 0 | 0.00% |
| 3 | `language` | `object` (`string`) | 1,500 | 0 | 0.00% |
| 4 | `account_created` | `object` (`string`) | 1,500 | 0 | 0.00% |
| 5 | `follower_count` | `int64` | 1,500 | 0 | 0.00% |

---

## 4. Missing-Value Analysis

- **Total Missing Cells Across Dataset:** 0 / 7,500 (0.00%)
- **Whitespace / Empty String Inspection:** No leading or trailing spaces, tabs, newline characters, or empty strings (`""`) were detected in any of the columns.
- **Null Value Tokens:** No textual representations of nulls (such as `"NA"`, `"N/A"`, `"null"`, `"None"`, `"?"`, or `"-"`) are present.

---

## 5. Duplicate Analysis

- **Exact Duplicate Rows:** 0 (0.00%)
- **Duplicate Identifier Records:** 0 (0.00%)
- Every record is entirely distinct across all five attributes.

---

## 6. Numerical Analysis (`follower_count`)

`follower_count` is the sole numerical feature in the dataset.

| Metric | Computed Value | Description / Note |
| :--- | :--- | :--- |
| **Count** | 1,500 | 100% populated |
| **Mean** | 24,964.02 | Close to midpoint of range |
| **Median (50th percentile)** | 24,741.50 | Close to mean (symmetric) |
| **Standard Deviation** | 14,185.48 | Substantial spread |
| **Minimum** | 109 | Smallest recorded follower count |
| **25th Percentile (Q1)** | 12,771.75 | First quartile |
| **75th Percentile (Q3)** | 37,097.25 | Third quartile |
| **Maximum** | 49,944 | Highest recorded follower count |
| **Interquartile Range (IQR)** | 24,325.50 | Spread between Q3 and Q1 |
| **Skewness** | +0.0156 | Approximately 0 (symmetric) |
| **Kurtosis** | -1.1904 | Close to theoretical -1.2 for uniform distribution |
| **Negative Values** | 0 | No negative follower counts |
| **Zero Values** | 0 | Minimum value is 109 |
| **Tukey Outliers (1.5 × IQR)** | 0 | Lower threshold: -23,716.5; Upper threshold: 73,585.5 |

---

## 7. Categorical & Text Analysis

### Column: `language`
- **Unique Count:** 10
- **Format:** All values are standard 2-letter ISO 639-1 lowercase language codes.
- **Distribution:**
  - `zh` (Chinese): 168 (11.20%)
  - `ja` (Japanese): 156 (10.40%)
  - `hi` (Hindi): 156 (10.40%)
  - `en` (English): 153 (10.20%)
  - `fr` (French): 150 (10.00%)
  - `es` (Spanish): 146 (9.73%)
  - `ru` (Russian): 144 (9.60%)
  - `ar` (Arabic): 143 (9.53%)
  - `pt` (Portuguese): 143 (9.53%)
  - `de` (German): 141 (9.40%)
- **Observations:** Frequencies are uniformly balanced across all 10 language categories (~9.4% to 11.2% each).

### Column: `location`
- **Unique Count:** 33
- **Format Standard:** 32 out of 33 locations use the compound `"City, Country"` format (e.g. `"Berlin, Germany"`, `"Tokyo, Japan"`).
- **Format Exception:** `"Singapore"` (49 occurrences) is recorded without a comma or country specifier.
- **Special Characters:** `"São Paulo, Brazil"` contains the accented UTF-8 character `ã` (Unicode U+00E3, 44 occurrences).
- **Top 10 Locations by Count:**
  1. `Barcelona, Spain`: 56 (3.73%)
  2. `Shanghai, China`: 56 (3.73%)
  3. `Los Angeles, USA`: 55 (3.67%)
  4. `Munich, Germany`: 54 (3.60%)
  5. `Dubai, UAE`: 53 (3.53%)
  6. `Mumbai, India`: 53 (3.53%)
  7. `Milan, Italy`: 53 (3.53%)
  8. `Melbourne, Australia`: 52 (3.47%)
  9. `Beijing, China`: 51 (3.40%)
  10. `Houston, USA` / `Osaka, Japan` / `Chicago, USA`: 50 each (3.33%)
- **Lowest Count Location:** `Sydney, Australia`: 28 (1.87%).

---

## 8. Identifier Analysis (`user_id`)

- **Total Records:** 1,500
- **Unique IDs:** 1,500 (100% uniqueness)
- **Duplicate IDs:** 0
- **Missing IDs:** 0
- **Syntactic Structure:**
  - Every ID has length exactly 13 characters.
  - Matches regular expression `^user_[a-z0-9]{8}$`.
  - Prefix `user_` is constant across all 1,500 records.
  - Suffix consists of 8 lowercase alphanumeric characters.
- **Verdict:** Primary key integrity is verified.

---

## 9. Date & Time Analysis (`account_created`)

- **Format:** String conforming to ISO 8601 (`YYYY-MM-DD`).
- **Parseability:** 1,500 / 1,500 (100%) cleanly convert to datetime without parse errors.
- **Temporal Range:**
  - Earliest registration: `2023-01-01`
  - Latest registration: `2023-12-31`
  - Total span: Exactly the 2023 calendar year (365 calendar days).
- **Calendar Coverage:** 359 distinct dates contain account creations. Exactly 6 dates have zero registrations:
  - `2023-03-09`
  - `2023-07-05`
  - `2023-08-23`
  - `2023-10-05`
  - `2023-10-10`
  - `2023-12-28`
- **Monthly Distribution:**
  - Jan: 130 | Feb: 117 | Mar: 117 | Apr: 123 | May: 123 | Jun: 134
  - Jul: 104 | Aug: 133 | Sep: 128 | Oct: 135 | Nov: 112 | Dec: 144
- **Weekday vs Weekend Distribution:** Registrations are slightly higher on Saturdays (240) and Fridays (230) compared to Wednesdays (186).

---

## 10. Audit Categorization of Observations

### A. Confirmed Observations (Empirical Facts)
1. **Zero Data Loss / Zero Missing Values:** Every cell across all 1,500 rows and 5 columns contains populated, non-null data.
2. **Zero Duplicate Records:** No exact duplicate rows or duplicate user IDs exist.
3. **Primary Key Consistency:** `user_id` is 100% unique and strictly adheres to the 13-character schema `user_[a-z0-9]{8}`.
4. **Clean Dates:** `account_created` values all fall within calendar year 2023 and strictly use standard `YYYY-MM-DD`.
5. **Clean Numbers:** `follower_count` contains only positive non-zero integers ranging from 109 to 49,944.

### B. Potentially Suspicious Values & Structural Quirks
1. **Location Formatting Discrepancy (`Singapore`):** 32 locations adhere to `<City>, <Country>`, while `Singapore` is an isolated single-word entry without a country designation.
2. **Synthetic Uniformity in `follower_count`:**
   - Real-world social platform follower counts consistently exhibit long-tailed power-law (Pareto / Zipfian) distributions where a small fraction of accounts holds massive follower counts and the vast majority has very few.
   - In this dataset, `follower_count` has skewness $\approx 0.015$ and kurtosis $\approx -1.19$, which is characteristic of a synthetic continuous uniform distribution ($\mathcal{U}(100, 50000)$).
3. **Statistical Independence Between Location and Language:**
   - Cross-tabulation between `location` and `language` yields a Chi-Square statistic of $\chi^2 = 279.56$ with degrees of freedom $df = 288$ ($p \approx 0.63$).
   - This demonstrates that language is statistically independent of location (e.g., users located in Tokyo are just as likely to speak German, French, or Hindi as Japanese). This strongly indicates synthetic generation or anonymized randomization.

### C. Issues Requiring Investigation & Alignment Before Cleaning
1. **Location Normalization / Schema Strategy:**
   - Should `Singapore` be normalized to `"Singapore, Singapore"` to preserve uniform parsing in SQL?
   - Or should Phase 2 split `location` into two separate normalized columns: `city` and `country`?
2. **Date Type Casting:**
   - Confirm target SQL schema (`DATE`) and pandas schema (`datetime64[ns]`) for `account_created`.
3. **Special Character Safeguard:**
   - Ensure target database engines (PostgreSQL, MySQL, SQLite) and downstream pipelines explicitly enforce UTF-8 collation to preserve the `ã` in `"São Paulo, Brazil"`.
4. **Preservation of Raw Provenance:**
   - Confirm that `data/raw/Social_Engine_Users.csv` remains strictly untouched, and all subsequent transformations write exclusively to `data/cleaned/`.

---

## 11. Artifact Deliverables Summary

1. **Inspection Report:** [reports/initial_dataset_inspection.md](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/initial_dataset_inspection.md)
2. **Jupyter Inspection Notebook:** [notebooks/01_initial_dataset_inspection.ipynb](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/01_initial_dataset_inspection.ipynb)
3. **Machine-Readable Summary:** [outputs/initial_inspection_summary.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/initial_inspection_summary.csv)
