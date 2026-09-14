# Data Vortex — Phase 1 Final QA Audit

**Competition:** Data Vortex — Round 1  
**Audit Stage:** Final Quality Assurance Audit (Phase 1 Deliverables)  
**Target Datasets:**  
- Raw: `data/raw/Social_Engine_Users.csv`, `data/raw/Social_Engine_Posts_Corrupted.csv`  
- Cleaned: `data/cleaned/Social_Engine_Users_Cleaned.csv`, `data/cleaned/Social_Engine_Posts_Cleaned.csv`  
**Auditor:** Antigravity Automated QA Suite  
**Date:** 2026-09-14  
**Audit Status:** **READY (100% Verified)**  

---

## 1. Competition Requirement Checklist

Every Phase 1 competition deliverable was audited against strict compliance criteria:

| # | Requirement | Status | Evidence & Verification Reference |
| :---: | :--- | :---: | :--- |
| **1** | **Cleaned CSV Datasets** | **PASS** | `data/cleaned/Social_Engine_Users_Cleaned.csv` (1,500 rows, 5 cols) and `data/cleaned/Social_Engine_Posts_Cleaned.csv` (12,000 rows, 8 cols) exist, are UTF-8 compliant, and match verified schemas. |
| **2** | **EDA Report** | **PASS** | [`reports/EDA_Report.md`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/EDA_Report.md) complete with all 11 required sections, embedded figure links, sample sizes, and non-causal evidence-based findings. |
| **3** | **GitHub-Ready Notebooks** | **PASS** | All 6 notebooks in [`notebooks/`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/) (`01` through `06_final_eda.ipynb`) are structured, valid JSON, execute cleanly, and use relative paths. |
| **4** | **Data Cleaning Code** | **PASS** | [`src/clean_data.py`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/src/clean_data.py) provides an end-to-end reproducible, fully asserted Python pipeline from `data/raw/` to `data/cleaned/`. |
| **5** | **Documentation of Transformations** | **PASS** | [`reports/04_cleaning_validation.md`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/04_cleaning_validation.md) documents every applied transformation step-by-step with row counts before and after. |
| **6** | **Justification of Cleaning Decisions** | **PASS** | [`reports/04_cleaning_decision_log.md`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/04_cleaning_decision_log.md) provides full statistical and domain justification for every accepted or rejected transformation. |
| **7** | **Handling of Missing Values** | **PASS** | Zero imputation applied. Nulls in `platform` (1,784), `text_content` (1,711), and `likes` (1,814) preserved as missing. Documented in [`reports/EDA_Data_Dictionary.md`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/EDA_Data_Dictionary.md). |
| **8** | **Identification of Anomalies/Corruption** | **PASS** | [`reports/03_combined_forensic_analysis.md`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/03_combined_forensic_analysis.md) categorizes confirmed corruption vs. legitimate synthetic characteristics. |
| **9** | **EDA with Meaningful Visualizations** | **PASS** | Exactly 12 publication-quality visualizations generated with Matplotlib and saved to [`outputs/figures/`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/). |
| **10** | **Insights & Statistical Interpretation** | **PASS** | Top 10 validated findings in `EDA_Report.md` formatted with Title, Observation, Evidence, Interpretation, and Caveat; causal claims strictly avoided. |
| **11** | **Reproducible Workflow** | **PASS** | Clean linear pipeline: Raw Data $\rightarrow$ Forensic Analysis $\rightarrow$ Cleaning $\rightarrow$ Validation $\rightarrow$ EDA $\rightarrow$ Final Reports. Notebooks reproduce all numbers. |
| **12** | **Clear Assumptions & Limitations** | **PASS** | Section 10 of `EDA_Report.md` documents synthetic data bounds, timestamp resolution limits (date-only posts), missingness caveats, and absence of causal inference. |

---

## 2. Dataset Integrity

Independent programmatic audits verified the physical and logical integrity of both raw and cleaned datasets:

### Verification Summary:
1. **Raw Dataset Immutability:**
   - `data/raw/Social_Engine_Users.csv` (SHA-256: `d30efe470a4dd561...`, 76,897 bytes) remains byte-for-byte identical to original state.
   - `data/raw/Social_Engine_Posts_Corrupted.csv` (SHA-256: `49a460d6b6d8b7f5...`, 2,042,090 bytes) remains byte-for-byte identical to original state.
2. **Cleaned Users Dataset (`Social_Engine_Users_Cleaned.csv`):**
   - Exactly 1,500 rows and 5 columns (`user_id`, `location`, `language`, `account_created`, `follower_count`).
   - Exactly 1,500 unique primary keys matching `^user_[a-z0-9]{8}$`.
   - 0 missing cells across the entire table.
   - UTF-8 integrity confirmed: `"São Paulo, Brazil"` accented character `ã` is preserved; `"Singapore"` retained as sovereign city-state.
3. **Cleaned Posts Dataset (`Social_Engine_Posts_Cleaned.csv`):**
   - Exactly 12,000 rows and 8 columns (`post_id`, `user_id`, `platform`, `text_content`, `timestamp`, `likes`, `shares`, `comments`).
   - Exactly 12,000 unique primary keys matching `^[a-z0-9]{12}$`.
   - Exactly 0 orphan posts: all 12,000 `user_id` foreign keys exist in the Users table.
   - All 1,500 users authored between 1 and 22 posts ($Mean = 8.00$).
   - 0 negative likes remain (all 509 kept negative likes rectified via `abs()`).
   - Standardized timestamps: all 12,000 dates parse to valid `YYYY-MM-DD HH:MM:SS` within the interval `2024-05-01 00:00:00` to `2025-04-30 21:57:10`.
   - Text decoding: 0 raw `&amp;` entities remain (all 328 decoded to `&`); 0 whitespace-padded text strings remain.

---

## 3. Cleaning Integrity

The cleaning pipeline in [`src/clean_data.py`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/src/clean_data.py) was executed and audited against all documented cleaning decisions:

### Verified Transformations:
- **Users Dataset:**
  - Preserved 100% of rows (1,500 records) and original columns.
  - Preserved `user_id`, `location`, `language`, and `follower_count` without artificial alteration.
  - Standardized `account_created` to ISO 8601 `YYYY-MM-DD`.
- **Posts Dataset:**
  - Removed strictly exact duplicate tuples (360 duplicate rows removed; $12,360 \rightarrow 12,000$ rows).
  - Corrected inverted sign on likes via `abs()` (509 rows).
  - Standardized heterogeneous timestamps across 3 distinct raw representations:
    - 4,805 ISO 8601 strings ($4,950 - 145$ duplicates)
    - 3,669 Unix epoch seconds ($3,788 - 119$ duplicates)
    - 3,526 `DD-MM-YYYY` strings ($3,622 - 96$ duplicates, normalized to `00:00:00`)
  - Trimmed leading/trailing whitespace on `text_content` (329 rows).
  - Decoded HTML entity `&amp;` to `&` (328 rows).
  - Preserved missing values without imputation (`platform`: 1,784; `text_content`: 1,711; `likes`: 1,814).
  - Preserved `post_id`, `user_id`, `shares`, and `comments` completely unaltered.

---

## 4. Missing Data Handling

The audit confirmed that missing values are documented transparently and distinguished from corrupted data:

1. **Clear Categorization:**
   - **Missing Values:** True absence of data (`platform` nulls, `text_content` nulls, `likes` nulls).
   - **Corrupted Values:** Present data with formatting or sign errors (negative likes, timestamp format mixing, `&amp;` entity encoding, whitespace padding).
   - **Legitimate Values:** Unusual but valid values (uniform follower counts, uniform engagement metrics, low-volume cities).
2. **Missing Value Counts in Cleaned Posts:**
   - `platform`: 1,784 missing (14.87%) $\rightarrow$ preserved as explicit `'Missing'` category in aggregations.
   - `text_content`: 1,711 missing (14.26%) $\rightarrow$ 1,688 empty fields + 23 stripped literal `"NULL"` tokens; excluded pairwise from text analysis.
   - `likes`: 1,814 missing (15.12%) $\rightarrow$ excluded pairwise from numerical engagement analysis (sample size $n = 10,186$ reported).
   - `post_id`, `user_id`, `timestamp`, `shares`, `comments`: 0 missing (0.00%).
3. **Scientifically Cautious Evaluation:**
   - Statistical checks confirm missing rates are stable across all 12 months ($13.0\% - 16.4\%$), across platforms ($13.9\% - 15.8\%$), and across follower quartiles ($p > 0.45$).
   - In accordance with QA guidelines, reports avoid unverified claims of "proven MCAR" and instead state: *"Missingness is consistent with a random masking mechanism based on the observed checks."*

---

## 5. Corruption Handling

All anomalies detected during forensic analysis were cataloged and verified:

| Anomaly Detected | Raw Affected Rows | Deduplication Impact | Cleaned Affected Rows | Rectification Applied | Validation Check |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **Exact Duplicate Tuples** | 360 | Removed entirely | 0 | `df.drop_duplicates()` | `df.duplicated().sum() == 0` |
| **Negative Likes** | 525 | 16 duplicates dropped | 509 | Sign inversion via `abs(x)` | `(df['likes'] < 0).sum() == 0` |
| **Mixed Timestamps** | 12,360 | 360 duplicates dropped | 12,000 | Regex parser standardizing to `YYYY-MM-DD HH:MM:SS` | `pd.to_datetime()` parses 100% |
| **HTML Entities (`&amp;`)**| 338 | 10 duplicates dropped | 328 | String replacement `.replace('&amp;', '&')` | `df['text_content'].str.contains('&amp;').sum() == 0` |
| **Whitespace Padding** | 339 | 10 duplicates dropped | 329 | String stripping `.strip()` | `(text != text.strip()).sum() == 0` |
| **Literal `"NULL\n\n"` Strings**| 24 | 1 duplicate dropped | 23 | Stripped and serialized to standard CSV null | Read by pandas as standard `NaN` |

---

## 6. EDA Completeness

The Exploratory Data Analysis covers all critical dimensions of the benchmark:

1. **User Profile Analysis:**
   - Geographic representation across 33 international metropolitan centers (31 to 60 users each).
   - Language distribution across 10 ISO 639-1 codes ($\approx 10\%$ each).
   - Follower count distribution: continuous uniform $\mathcal{U}(100, 50000)$, Mean: $24,964$, Median: $24,742$, Kurtosis: $-1.1904$.
   - Account creation timeline: calendar year 2023, steady cadence ($125 \pm 11$ users/month).
2. **Post Activity Analysis:**
   - Platform allocation: 5 platforms ($\approx 2,040$ posts / $17.0\%$ each) + Missing ($1,784$ posts / $14.87\%$).
   - Temporal activity: 12 months (May 2024 to April 2025), $1,000.0 \pm 37.1$ posts/month.
   - User posting frequency: 1 to 22 posts/user ($Mean = 8.00, Median = 8.00$), matching a Poisson process ($\lambda = 8.0$).
3. **Engagement Analysis:**
   - Univariate metrics: likes ($\mathcal{U}(0, 5000)$), shares ($\mathcal{U}(0, 2000)$), comments ($\mathcal{U}(0, 1000)$).
   - Cross-platform comparison: medians reported for robustness; Kruskal-Wallis tests confirm no platform engagement differences ($p > 0.50$).
4. **Relationship Analysis:**
   - Audience vs. engagement: followers vs. likes ($r = +0.0082, p = 0.4063$), followers vs. shares ($r = -0.0144, p = 0.1139$), followers vs. comments ($r = -0.0003, p = 0.9750$).
   - Inter-metric coupling: likes vs. shares ($r = -0.0012$), likes vs. comments ($r = +0.0100$), shares vs. comments ($r = +0.0244$).
5. **Text & Linguistic Analysis:**
   - Character length distribution: 5 to 172 characters ($Mean = 88.35 \pm 48.09$).
   - Hashtag analysis: 56 unique tags, 20,531 total tokens, top 15 tags plotted ($684 - 739$ occurrences each).
   - Handle mentions: 15 unique corporate/functional handles across 2,073 instances.
6. **Missingness Tracking:**
   - Monthly missingness rates tracked over time; multi-attribute overlap audited ($40$ rows with all 3 missing).

---

## 7. Visualization Checklist

All 12 publication-quality visualizations were verified in [`outputs/figures/`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/):

| # | Figure Filename | Status | File Size | Verification Notes |
| :---: | :--- | :---: | :---: | :--- |
| 1 | `01_follower_count_distribution.png` | **EXISTS** | 129,708 B | Correctly displays uniform histogram, mean line, median line, and kurtosis callout. |
| 2 | `02_engagement_distributions.png` | **EXISTS** | 172,355 B | 3-panel comparative histogram with sample sizes ($n=10,186$ likes, $n=12,000$ shares/comments). |
| 3 | `03_platform_post_volume.png` | **EXISTS** | 116,143 B | Explicitly shows 5 platforms + `[Missing]` bar with counts and percentages. |
| 4 | `04_monthly_post_activity.png` | **EXISTS** | 215,504 B | 12-month timeline (May 2024 – Apr 2025) with monthly data points and mean reference line. |
| 5 | `05_posts_per_user.png` | **EXISTS** | 105,784 B | Discrete integer histogram (range 1–22) with mean ($8.00$) and median ($8.00$) lines. |
| 6 | `06_platform_engagement.png` | **EXISTS** | 132,517 B | Grouped bar chart of medians with platform sample sizes and non-causal explanatory footnote. |
| 7 | `07_followers_vs_likes.png` | **EXISTS** | 805,479 B | Scatterplot with OLS fit line ($n=10,186$); Pearson $r$ and Spearman $\rho$ values annotated. |
| 8 | `08_correlation_heatmap.png` | **EXISTS** | 116,812 B | $4 \times 4$ Pearson correlation matrix with exact coefficients displayed in cells. |
| 9 | `09_user_locations.png` | **EXISTS** | 305,625 B | Clean horizontal bar chart of all 33 cities sorted ascending by user count. |
| 10 | `10_language_distribution.png` | **EXISTS** | 177,498 B | Categorical bar chart showing user counts and percentages across 10 ISO language codes. |
| 11 | `11_missingness_over_time.png` | **EXISTS** | 277,104 B | 3-line trend chart tracking % missing per month for platform, text, and likes. |
| 12 | `12_top_hashtags.png` | **EXISTS** | 168,905 B | Horizontal bar chart of top 15 extracted hashtags ($N=20,531$ hashtag tokens). |

---

## 8. Statistical & Interpretation Review

During the audit, all markdown reports were scanned and edited to ensure adherence to scientific, non-causal language standards:

1. **Elimination of Overly Strong / Unsubstantiated Phrasing:**
   - Replaced terms like `"proves"`, `"confirms"`, and `"guarantees"` with `"shows"`, `"indicates"`, `"is consistent with"`, and `"ensures"`.
   - Replaced inferred generative claims (e.g. *"were generated using"*, *"represents a Poisson arrival process"*, *"simulated"*, *"platform metadata functions as"*) with cautious evidence-based phrasing:
     - *"the empirical metrics exhibit properties consistent with bounded uniform distributions"*
     - *"the observed post distribution per user is compatible with a Poisson process"*
     - *"the observed temporal pattern is consistent with an active, steady-state platform lifecycle"*
     - *"the data suggests that platform metadata behaves as a balanced categorical factor without observed channel-specific engagement bias"*
2. **Missingness Phrasing Compliance:**
   - Replaced definitive statements (e.g. *"Missing Completely at Random (MCAR)"*, *"administrative random-masking process"*) with:
     - *"missingness is consistent with a random masking mechanism based on the observed checks across time, platforms, and user follower tiers."*
3. **Sample Size Reporting:**
   - Every platform engagement metric and correlation explicitly notes the pairwise non-missing observation count ($n = 10,186$ for likes, $n = 12,000$ for shares and comments).

---

## 9. Timestamp Discrepancy Resolution

The audit verified the mathematical and procedural resolution of the `DD-MM-YYYY` record count:

### Forensic Verification:
1. **Raw Dataset Total:** Exactly **3,622 records** possess the `DD-MM-YYYY` (or `DD/MM/YYYY`) format.
2. **Exact Duplicate Rows:** Exactly **96 records** among the 360 removed exact duplicates belong to this format.
3. **Cleaned Dataset Total:** Exactly **3,526 records** originate from this format:
   $$3,622 - 96 = \mathbf{3,526}$$
4. **Standardization Rule:** Because original `DD-MM-YYYY` strings contained only calendar dates without time-of-day information, all 3,526 records were standardized to midnight (`00:00:00`).
5. **Discrepancy Source:** The earlier note citing 3,517 records was an intermediate draft calculation produced by an exploratory script before final regex categorization. The verified, exact count in the cleaned dataset is **3,526**.
6. **Diurnal Analysis Guidance:** Hourly diurnal analyses must exclude these 3,526 records to prevent an artificial midnight spike, utilizing only the 8,474 posts originating from ISO 8601 (4,805) and Unix epoch (3,669) timestamps.

---

## 10. Remaining Issues

**No blocking Phase 1 issues identified.**

All datasets, cleaning code, notebooks, documentation reports, metadata dictionaries, and figures are verified, consistent, and reproducible.

---

## 11. Final Submission Readiness

### Verdict: **READY**

The Phase 1 deliverables meet 100% of the competition requirements. The repository is fully prepared for Phase 2 (Database Schema Design & SQL Implementation).
