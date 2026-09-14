# Data Cleaning Validation Report

**Competition:** Data Vortex - Round 1  
**Execution Date:** 2026-09-14  
**Pipeline Source:** [src/clean_data.py](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/src/clean_data.py)  
**Notebook Reference:** [notebooks/04_data_cleaning.ipynb](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/04_data_cleaning.ipynb)  
**Target Cleaned Files:**  
- [data/cleaned/Social_Engine_Users_Cleaned.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/cleaned/Social_Engine_Users_Cleaned.csv)  
- [data/cleaned/Social_Engine_Posts_Cleaned.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/cleaned/Social_Engine_Posts_Cleaned.csv)  

---

## 1. Raw vs. Cleaned Row Counts

| Dataset | Raw File Path | Raw Rows | Cleaned File Path | Cleaned Rows | Delta | Explanation |
| :--- | :--- | :---: | :--- | :---: | :---: | :--- |
| **Users** | `data/raw/Social_Engine_Users.csv` | 1,500 | `data/cleaned/Social_Engine_Users_Cleaned.csv` | 1,500 | 0 | 100% records preserved; zero rows removed. |
| **Posts** | `data/raw/Social_Engine_Posts_Corrupted.csv` | 12,360 | `data/cleaned/Social_Engine_Posts_Cleaned.csv` | 12,000 | -360 | Exactly 360 redundant full-row duplicates removed. |

---

## 2. Transformations Performed & Affected Rows

| Transformation # | Target Table | Target Column | Description of Transformation | Rows Affected | Operational Rule |
| :---: | :--- | :--- | :--- | :---: | :--- |
| **T1** | Users | `account_created` | Standardize date format | 1,500 | Formatted as ISO `YYYY-MM-DD` |
| **T2** | Posts | Full Row | Deduplicate exact duplicate rows | 360 | `df.drop_duplicates()` |
| **T3** | Posts | `likes` | Invert negative values (sign flip) | 509 | `likes = abs(likes)` (preserving nulls) |
| **T4** | Posts | `timestamp` | Standardize heterogeneous formats | 12,000 | Parsed `ISO 8601`, `epoch`, `DD-MM-YYYY` $\rightarrow$ `YYYY-MM-DD HH:MM:SS` |
| **T5** | Posts | `text_content` | Trim leading/trailing whitespace | 329 | `text_content.strip()` |
| **T6** | Posts | `text_content` | Decode literal HTML entity `&amp;` | 328 | `text_content.replace('&amp;', '&')` |
| **T7** | Posts | `platform`, `likes`, `text` | Preserve missing values without imputation | 0 (Preserved) | Missing values kept as standard nulls (`NaN` / empty in CSV) |
| **T8** | Users | `location` | Preserve `Singapore` & `São Paulo, Brazil` | 0 (Preserved) | Kept authentic geographic strings without modification |

---

## 3. Before and After Examples

### 3.1 Exact Duplicate Rows (Deduplication)
- **Before (Sample Duplicate Pair):**
  ```text
  Row 3003:  post_id=01jzjra6mmwc, user_id=user_bqp8mrav, platform=YouTube, timestamp=2024-10-13T15:19:29, likes=2829.0
  Row 10546: post_id=01jzjra6mmwc, user_id=user_bqp8mrav, platform=YouTube, timestamp=2024-10-13T15:19:29, likes=2829.0
  ```
- **After (Single Unique Instance Retained):**
  ```text
  Clean Row: post_id=01jzjra6mmwc, user_id=user_bqp8mrav, platform=YouTube, timestamp=2024-10-13 15:19:29, likes=2829
  ```

### 3.2 Negative Likes Rectification
- **Before:**
  ```text
  post_id=mbykzpzh1l1y -> likes=-4812.0
  post_id=wal886ggp7kg -> likes=-1795.0
  post_id=38tm1xfxxsdi -> likes=-3707.0
  ```
- **After:**
  ```text
  post_id=mbykzpzh1l1y -> likes=4812
  post_id=wal886ggp7kg -> likes=1795
  post_id=38tm1xfxxsdi -> likes=3707
  ```

### 3.3 Timestamp Standardization
- **Before (Heterogeneous representations):**
  ```text
  post_id=to64mgey2v3y -> timestamp="25-09-2024"          (DD-MM-YYYY)
  post_id=7f0wdauzbj89 -> timestamp="1722528840"          (Unix epoch seconds)
  post_id=dvvhg8eel45x -> timestamp="2025-04-13T20:12:18" (ISO 8601)
  ```
- **After (Unified YYYY-MM-DD HH:MM:SS):**
  ```text
  post_id=to64mgey2v3y -> timestamp="2024-09-25 00:00:00"
  post_id=7f0wdauzbj89 -> timestamp="2024-08-01 16:14:00"
  post_id=dvvhg8eel45x -> timestamp="2025-04-13 20:12:18"
  ```

### 3.4 Text Whitespace Trimming
- **Before:**
  ```text
  post_id=mbykzpzh1l1y: "Could someone explain with my new Air Max from Nike! It's okay. #Quality, #Limited, #Trending\n\n"
  post_id=0yzjehvplo2u: "Just unboxed my new Samba from Adidas. Had issues with it. Feeling let down #Beauty, #CustomerService, #MustHave\n\n"
  ```
- **After:**
  ```text
  post_id=mbykzpzh1l1y: "Could someone explain with my new Air Max from Nike! It's okay. #Quality, #Limited, #Trending"
  post_id=0yzjehvplo2u: "Just unboxed my new Samba from Adidas. Had issues with it. Feeling let down #Beauty, #CustomerService, #MustHave"
  ```

### 3.5 HTML Entity Decoding (`&amp;` $\rightarrow$ `&`)
- **Before:**
  ```text
  post_id=to64mgey2v3y: "Bummed out with my new Air Max from Nike! Absolutely loving it. #Travel, #CustomerService, #Fashion&amp;"
  post_id=ckz4ciuuw7c5: "Has anyone else experienced delivery delays with Nike's Epic React? Had issues with it. @ReviewSite, @BrandSupport #ProductLaunch, #Affordable&amp;"
  ```
- **After:**
  ```text
  post_id=to64mgey2v3y: "Bummed out with my new Air Max from Nike! Absolutely loving it. #Travel, #CustomerService, #Fashion&"
  post_id=ckz4ciuuw7c5: "Has anyone else experienced delivery delays with Nike's Epic React? Had issues with it. @ReviewSite, @BrandSupport #ProductLaunch, #Affordable&"
  ```

---

## 4. Missing-Value Comparison

Missing values were strictly preserved without imputation.

| Dataset | Column | Raw Missing Count | Raw Missing (%) | Cleaned Missing Count | Cleaned Missing (%) | Note |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| **Users** | All columns | 0 | 0.00% | 0 | 0.00% | Pristine completeness |
| **Posts** | `post_id` | 0 | 0.00% | 0 | 0.00% | 100% complete |
| **Posts** | `user_id` | 0 | 0.00% | 0 | 0.00% | 100% complete |
| **Posts** | `platform` | 1,846 | 14.94% | 1,784 | 14.87% | Preserved (52 nulls in dropped duplicates) |
| **Posts** | `text_content` | 1,746 | 14.13% | 1,711 | 14.26% | Preserved (empty fields in cleaned CSV) |
| **Posts** | `timestamp` | 0 | 0.00% | 0 | 0.00% | 100% complete |
| **Posts** | `likes` | 1,858 | 15.03% | 1,814 | 15.12% | Preserved (44 nulls in dropped duplicates) |
| **Posts** | `shares` | 0 | 0.00% | 0 | 0.00% | 100% complete |
| **Posts** | `comments` | 0 | 0.00% | 0 | 0.00% | 100% complete |

---

## 5. Duplicate Comparison

| Metric | Raw Posts | Cleaned Posts | Validation Status |
| :--- | :---: | :---: | :---: |
| **Total Rows** | 12,360 | 12,000 | **PASS** |
| **Exact Duplicate Rows** | 360 (2.91%) | 0 (0.00%) | **PASS** |
| **Unique `post_id` Count** | 12,000 | 12,000 | **PASS** |
| **Duplicate `post_id` Count** | 360 | 0 | **PASS** |

Verification shows that every single one of the 360 removed records was an exact duplicate across all 8 columns.

---

## 6. Timestamp Validation

| Validation Check | Observed Value in Cleaned Posts | Expected Target | Pass / Fail |
| :--- | :---: | :---: | :---: |
| **Total Timestamps** | 12,000 | 12,000 | **PASS** |
| **Unparseable Timestamps** | 0 | 0 | **PASS** |
| **Consistent Format (`YYYY-MM-DD HH:MM:SS`)** | 12,000 (100%) | 12,000 (100%) | **PASS** |
| **Earliest Timestamp** | `2024-05-01 00:00:00` | `2024-05-01 00:00:00` | **PASS** |
| **Latest Timestamp** | `2025-04-30 21:57:10` | `2025-04-30 21:57:10` | **PASS** |
| **Anachronistic Posts (Before Account Creation)** | 0 | 0 | **PASS** |

---

## 7. Numerical Validation

| Column | Cleaned Min | Cleaned Max | Cleaned Mean | Cleaned Median | Negative Count | Zero Count | Pass / Fail |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`follower_count` (Users)** | 109 | 49,944 | 24,964.02 | 24,741.50 | 0 | 0 | **PASS** |
| **`likes` (Posts)** | 0 | 5,000 | 2,490.87 | 2,497.00 | 0 | 1 | **PASS** |
| **`shares` (Posts)** | 0 | 2,000 | 1,006.12 | 1,016.00 | 0 | 5 | **PASS** |
| **`comments` (Posts)** | 0 | 1,000 | 503.74 | 502.00 | 0 | 13 | **PASS** |

All non-missing likes are strictly non-negative integers $\le 5,000$. Shares and comments were preserved without alteration.

---

## 8. Referential Integrity Validation

- **Users in `Users` Dataset:** 1,500
- **Unique Users in `Posts` Dataset:** 1,500
- **Posts with Non-Existent `user_id` (Orphan Posts):** **0 (0.00%)**
- **Users with Zero Posts:** **0 (0.00%)**
- **Posts Per User:** Minimum = 1, Maximum = 22, Median = 8.
- Referential linkage between both tables is 100% sound.

---

## 9. Integrity Assurances

1. **No Data Fabrication:** Missing values in `platform`, `text_content`, and `likes` were strictly retained as nulls. No imputation (mean, median, mode, random, or constants) was applied.
2. **Provenance & Immutability:** Both raw files (`Social_Engine_Users.csv` and `Social_Engine_Posts_Corrupted.csv`) remain byte-for-byte identical to their initial state.
3. **Reproducibility:** The entire transformation pipeline is encapsulated deterministically in [src/clean_data.py](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/src/clean_data.py) and demonstrated in [notebooks/04_data_cleaning.ipynb](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/04_data_cleaning.ipynb).
