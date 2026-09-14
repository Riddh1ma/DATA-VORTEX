# Data Cleaning Decision Log

**Competition:** Data Vortex - Round 1  
**Datasets:**  
- `data/raw/Social_Engine_Users.csv` $\rightarrow$ `data/cleaned/Social_Engine_Users_Cleaned.csv`  
- `data/raw/Social_Engine_Posts_Corrupted.csv` $\rightarrow$ `data/cleaned/Social_Engine_Posts_Cleaned.csv`  
**Date:** 2026-09-14  
**Pipeline Script:** [src/clean_data.py](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/src/clean_data.py)  

---

## 1. Cleaning Decisions Matrix

This log documents every action taken during data cleaning, as well as intentional decisions **NOT** to modify specific data attributes.

---

### Decision 1: Deduplication of Exact Duplicate Post Records
- **Issue:** Redundant records repeated across the entire 8-column schema.
- **Evidence:** 360 rows share identical `post_id`, `user_id`, `platform`, `text_content`, `timestamp`, `likes`, `shares`, and `comments`.
- **Decision:** **CLEAN** (Remove exact duplicate rows).
- **Transformation:** `df_posts.drop_duplicates()`
- **Reason:** Exact duplicate rows artificially inflate user activity metrics, engagement totals, and downstream statistical calculations.
- **Affected Rows:** 360 rows removed (reducing row count from 12,360 to 12,000).
- **Validation:** `df_posts_clean['post_id'].nunique() == 12000` and `df_posts_clean.duplicated().sum() == 0`.

---

### Decision 2: Negative Likes Sign-Inversion Correction
- **Issue:** Negative integer values in a metric that represents positive counts.
- **Evidence:** 525 rows in raw (509 in deduplicated posts) contain negative values from -4,987 to -11. The distribution of $|negative\_likes|$ ($Mean = 2,457.24, Median = 2,388, Std = 1,426.57$) identically mirrors positive likes ($Mean = 2,494.62, Median = 2,505, Std = 1,437.92$), confirming an accidental sign negation ($x \times -1$).
- **Decision:** **CLEAN** (Convert negative likes to positive integers via absolute value).
- **Transformation:** `likes = abs(likes) if pd.notnull(likes) else likes`
- **Reason:** Restores the true positive engagement count without altering the metric's magnitude.
- **Affected Rows:** 509 rows in deduplicated dataset.
- **Validation:** `(df_posts_clean['likes'] < 0).sum() == 0`; non-missing likes are non-negative integers $\le 5,000$.

---

### Decision 3: Timestamp Standardization
- **Issue:** Inconsistent date/time representations across 3 coexisting formats.
- **Evidence:** Posts timestamps contain ISO 8601 (`YYYY-MM-DDTHH:MM:SS`, 4,950 rows), Unix epoch seconds (10-digit integers, 3,788 rows), and DD-MM-YYYY (`DD-MM-YYYY`, 3,622 rows), preventing direct chronological querying.
- **Decision:** **CLEAN** (Standardize all timestamps to `YYYY-MM-DD HH:MM:SS`).
- **Transformation:** Parse epoch seconds, ISO 8601 strings, and DD-MM-YYYY dates into uniform datetime strings.
- **Reason:** Enables chronological sorting, SQL time-series querying, and cohort aggregation in Phase 2 without modifying the underlying point in time.
- **Affected Rows:** 12,000 rows standardized (4,809 ISO, 3,674 epoch, 3,517 DD-MM-YYYY post-deduplication).
- **Validation:** Zero unparseable timestamps; overall date range strictly preserved between `2024-05-01 00:00:00` and `2025-04-30 21:57:10`.

---

### Decision 4: Text Content Whitespace Trimming
- **Issue:** Leading and trailing whitespace padding in post text.
- **Evidence:** 329 rows in deduplicated posts contain untrimmed leading or trailing spaces (`s != s.strip()`).
- **Decision:** **CLEAN** (Trim boundary whitespace).
- **Transformation:** `text_content = text_content.strip()`
- **Reason:** Removes formatting noise while preserving meaningful internal words and whitespace.
- **Affected Rows:** 329 rows trimmed.
- **Validation:** `(df_posts_clean['text_content'].dropna().apply(lambda x: x != x.strip())).sum() == 0`.

---

### Decision 5: Decoding Literal HTML Entity `&amp;`
- **Issue:** Raw HTML escape sequences embedded in text strings.
- **Evidence:** 328 rows in deduplicated posts contain the raw literal string `&amp;` instead of the standard character `&`.
- **Decision:** **CLEAN** (Decode `&amp;` to `&`).
- **Transformation:** `text_content = text_content.replace('&amp;', '&')`
- **Reason:** Corrects HTML entity escaping introduced during web data scraping/extraction without rewriting sentences or altering phrasing.
- **Affected Rows:** 328 rows updated.
- **Validation:** `df_posts_clean['text_content'].dropna().str.contains('&amp;').sum() == 0`.

---

### Decision 6: Non-Imputation of Missing Values in Posts (Intentional NO-CHANGE)
- **Issue:** High missingness across `platform` (1,784 nulls, 14.95%), `text_content` (1,688 nulls, 14.07%), and `likes` (1,814 nulls, 15.12%).
- **Evidence:** No verifiable external lookup source exists to infer deleted text, unrecorded platforms, or dropped likes.
- **Decision:** **KEEP (DO NOT IMPUTE)**.
- **Transformation:** Retain as missing (`NaN` / empty field in CSV).
- **Reason:** Fabricating values (e.g., using mean/median for likes, or imputing an arbitrary platform) introduces artificial bias and violates competition rules against data fabrication.
- **Affected Rows:** 0 rows modified (all missing values strictly preserved).
- **Validation:** Missingness percentages match expected counts; zero fabricated values introduced.

---

### Decision 7: Preservation of `Singapore` Location Name (Intentional NO-CHANGE)
- **Issue:** `Singapore` does not contain a comma or country specifier, unlike the 32 other locations formatted as `"City, Country"`.
- **Evidence:** Singapore is a sovereign island city-state with no distinct municipal vs national administrative division.
- **Decision:** **KEEP (DO NOT MODIFY)**.
- **Transformation:** Preserve `"Singapore"` exactly as-is in `Social_Engine_Users_Cleaned.csv`.
- **Reason:** The entry is geographically valid and factually correct. Arbitrarily appending `", Singapore"` would alter authentic raw geography without justification.
- **Affected Rows:** 0 rows modified (all 49 occurrences preserved).
- **Validation:** `(df_users_clean['location'] == 'Singapore').sum() == 49`.

---

### Decision 8: Preservation of Authentic Unicode Orthography in `São Paulo, Brazil` (Intentional NO-CHANGE)
- **Issue:** Multibyte UTF-8 accented character `ã` (`U+00E3`) in location string.
- **Evidence:** `São Paulo` is the authentic, correct Portuguese spelling.
- **Decision:** **KEEP (DO NOT STRIP ACCENT)**.
- **Transformation:** Preserve UTF-8 byte stream `0xC3 0xA3` without ASCII-folding.
- **Reason:** Stripping accents (`"Sao Paulo"`) degrades data fidelity and internationalization standards.
- **Affected Rows:** 0 rows modified (all 44 occurrences preserved).
- **Validation:** Verified UTF-8 encoding in output CSV; `(df_users_clean['location'] == 'São Paulo, Brazil').sum() == 44`.

---

### Decision 9: Preservation of Synthetic Metric Distributions (Intentional NO-CHANGE)
- **Issue:** Follower counts, positive likes, shares, and comments exhibit continuous uniform distributions rather than power-law Pareto curves.
- **Evidence:** Follower count has skewness $\approx 0.015$ and kurtosis $\approx -1.19$. Tukey outlier tests identify zero statistical outliers.
- **Decision:** **KEEP (DO NOT TRANSFORM OR FILTER)**.
- **Transformation:** Leave all metric values completely untouched.
- **Reason:** The uniformity is an intrinsic design characteristic of the synthetic competition benchmark dataset, not an error. Trimming or transforming would corrupt legitimate data.
- **Affected Rows:** 0 rows modified.
- **Validation:** Summary percentiles and distributions remain identical to raw data.

---

### Decision 10: Preservation of Foreign Key and Primary Key Identifiers (Intentional NO-CHANGE)
- **Issue:** Synthetic identifiers `user_[a-z0-9]{8}` and `[a-z0-9]{12}`.
- **Evidence:** 100% of post records link to valid user records; zero orphan posts exist.
- **Decision:** **KEEP (DO NOT ALTER)**.
- **Transformation:** Preserve all `user_id` and `post_id` strings exactly.
- **Reason:** Ensures absolute relational integrity for Phase 2 SQL joins.
- **Affected Rows:** 0 rows modified.
- **Validation:** `orphan_posts == 0`.
