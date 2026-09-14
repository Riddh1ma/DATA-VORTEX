# Data Vortex — Round 1 Phase 2
## SQL Analytics Final Report

**Competition:** Data Vortex — Round 1 Phase 2  
**Deliverable:** Comprehensive SQL Analytics Final Report  
**Database File:** `data/data_vortex.db` (SQLite 3)  
**Date:** 2026-09-14  
**Status:** **COMPLETE & SUBMISSION-READY**  

---

### 1. Objective

The objective of Data Vortex Round 1 Phase 2 was to transition from data forensics and cleaning into production-grade relational database architecture and advanced analytical SQL. The validated, cleaned social-engine dataset (`Social_Engine_Users_Cleaned.csv` and `Social_Engine_Posts_Cleaned.csv`) was ingested into a normalized SQLite database (`data/data_vortex.db`) with strict schema typing, primary/foreign key constraints, and performance B-tree indexing.

Across 10 specialized SQL challenges, progressive analytical querying was applied to uncover actionable, descriptive patterns in platform interaction benchmarks, creator audience leadership, international geographic distribution, publishing cadence, audience reach versus engagement elasticity, and longitudinal growth trends.

---

### 2. Database Overview

The relational database implements a normalized 1-to-Many entity-relationship architecture (`users` 1 —< N `posts`) enforcing strict data integrity:

- **Database Engine:** SQLite 3 (version 3.49+)
- **Database Location:** `data/data_vortex.db` (~2.5 MB)
- **Users Table:** Exactly **1,500** unique user records
- **Posts Table:** Exactly **12,000** unique post records
- **Referential Integrity:** **100.0%** (0 foreign key violations; 0 orphan posts)
- **Cleaned CSV Fidelity:** **100.0%** exact bit-for-bit reconciliation with Phase 1 deliverables
- **Null Preservation:** All native NULL values preserved without artificial zero-imputation (`platform`: 1,784; `text_content`: 1,711; `likes`: 1,814)

---

### 3. SQL Challenges Completed

All 10 challenges were solved using pure analytical `SELECT` statements, documented in dedicated markdown reports, and verified through reproducible Jupyter notebooks:

| Challenge | Analysis | Main SQL Technique | SQL File | Report | Notebook |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **1** | Platform Interaction Benchmarks | `GROUP BY`, `AVG()`, `COALESCE` | [`challenge_01_platform_interaction_benchmarks.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_01_platform_interaction_benchmarks.sql) | [`09_challenge_01.md`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/09_challenge_01.md) | [`08_challenge_01.ipynb`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/08_challenge_01.ipynb) |
| **2** | Top Creator Audience Leaderboard | `INNER JOIN`, `GROUP BY`, `ORDER BY` | [`challenge_02_top_creator_audience.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_02_top_creator_audience.sql) | [`10_challenge_02.md`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/10_challenge_02.md) | [`09_challenge_02.ipynb`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/09_challenge_02.ipynb) |
| **3** | Geographic Representation | `CASE`, string parsing (`INSTR`, `SUBSTR`), `GROUP BY` | [`challenge_03_geographic_analysis.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_03_geographic_analysis.sql) | [`11_challenge_03.md`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/11_challenge_03.md) | [`10_challenge_03.ipynb`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/10_challenge_03.ipynb) |
| **4** | Creator Activity Segmentation | CTE, `CASE WHEN`, aggregation | [`challenge_04_creator_activity_segmentation.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_04_creator_activity_segmentation.sql) | [`12_challenge_04.md`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/12_challenge_04.md) | [`11_challenge_04.ipynb`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/11_challenge_04.ipynb) |
| **5** | Monthly Publishing Trends | `strftime()`, `LAG()`, `SUM() OVER()` | [`challenge_05_monthly_publishing_trends.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_05_monthly_publishing_trends.sql) | [`13_challenge_05.md`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/13_challenge_05.md) | [`12_challenge_05.ipynb`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/12_challenge_05.ipynb) |
| **6** | Day-of-Week Cadence | `strftime('%u')`, `CASE`, `GROUP BY` | [`challenge_06_day_of_week_cadence.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_06_day_of_week_cadence.sql) | [`14_challenge_06.md`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/14_challenge_06.md) | [`13_challenge_06.ipynb`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/13_challenge_06.ipynb) |
| **7** | Audience Reach vs Engagement | `JOIN`, aggregation, manual Pearson correlation formula | [`challenge_07_audience_reach_vs_engagement.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_07_audience_reach_vs_engagement.sql) | [`15_challenge_07.md`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/15_challenge_07.md) | [`14_challenge_07.ipynb`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/14_challenge_07.ipynb) |
| **8** | High-Impact Post Leaderboard | `COALESCE`, `ROW_NUMBER() OVER()` | [`challenge_08_high_impact_post_leaderboard.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_08_high_impact_post_leaderboard.sql) | [`16_challenge_08.md`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/16_challenge_08.md) | [`15_challenge_08.ipynb`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/15_challenge_08.ipynb) |
| **9** | Regional Creator Leadership | `DENSE_RANK()`, `PARTITION BY` | [`challenge_09_regional_creator_leadership.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_09_regional_creator_leadership.sql) | [`17_challenge_09.md`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/17_challenge_09.md) | [`16_challenge_09.ipynb`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/16_challenge_09.ipynb) |
| **10** | MoM Growth & Cumulative Tracking | `LAG()`, windowed `SUM() OVER()` | [`challenge_10_mom_volume_growth.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_10_mom_volume_growth.sql) | [`18_challenge_10.md`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/18_challenge_10.md) | [`17_challenge_10.ipynb`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/17_challenge_10.ipynb) |

---

### 4. Key Analytical Findings

All findings represent empirical, cross-sectional observations derived strictly from the dataset without claiming causal relationships:

1. **Instagram Led in Interaction Benchmarks:**
   - In Challenge 1, **Instagram** observed the highest average total interactions per post (**4,040.02**), followed closely by YouTube (4,031.84), Facebook (4,015.99), and Reddit (4,003.94), while Twitter observed the lowest (3,951.91). Interaction benchmarks across all platforms remained within a tight $\approx 2.2\%$ spread.
2. **Follower Leadership Decoupled from Interaction Rates:**
   - Across Challenges 2, 7, and 9, creators with the highest follower counts did not achieve the highest average likes per post. In Challenge 7, the Pearson correlation between `follower_count` and average likes was negligible ($r = +0.0168$), shares showed a slight negative association ($r = -0.0428$), and comments were near zero ($r = -0.0005$).
3. **USA Formed the Largest Regional Creator Base:**
   - In Challenges 3 and 9, the **USA** represented the largest national creator population (**203 creators**, 13.53% of total) and the highest post volume (**1,645 posts**, 13.71%), followed by China (107 creators) and Germany (97 creators).
4. **Creator Cadence Concentrated in Medium Activity Tier:**
   - In Challenge 4, **61.53% of creators** (923 users) belonged to the Medium Activity segment (6–10 posts), accounting for 60.19% of total post output. Casual creators (1–5 posts, 19.00%) and prolific creators (11+ posts, 19.47%) formed symmetrical tails.
5. **Publishing Velocity Remained Uniform Across Months:**
   - In Challenges 5 and 10, monthly volume averaged 1,000.00 posts ($\sigma = 33.72$). The observed trough in **February 2025 (914 posts)** and subsequent rebound in **March 2025 (1,013 posts, +10.83%)** aligned directly with calendar length; daily publishing velocity was virtually constant at **32.88 posts per day** (ranging between 32.13 and 34.17 posts/day).
6. **Midweek Publishing Observed Highest Cadence:**
   - In Challenge 6, **Wednesday** captured the highest post volume (**1,771 posts**, 14.76%), while Saturday had the lowest (**1,675 posts**, 13.96%). Overall, weekly publishing was remarkably uniform, with weekday volume exceeding weekend volume by only ~1.5% on a per-day basis.
7. **Top High-Impact Posts Spanned All Platforms:**
   - In Challenge 8, the top 20 individual posts (ranging from 7,468 to 7,893 interactions; mean: 7,622.30) were distributed across all channels: YouTube (5 posts), Instagram (4), Reddit (4), Facebook (3), Unknown (3), and Twitter (1).
8. **Germany Contained the Global Follower Leader:**
   - In Challenge 9, `user_3o7w66o2` from Berlin, Germany, held the platform's highest registered audience size with **49,944 followers**, followed closely by `user_u98jwp3f` in the USA (49,936 followers) and `user_usts5yuo` in China (49,933 followers).

---

### 5. Advanced SQL Techniques Demonstrated

Phase 2 demonstrated mastery of modern, production-grade SQL concepts:

- **Common Table Expressions (CTEs):** Used sequentially to decouple pre-aggregation, business categorization, and final reporting for clean, readable queries.
- **`CASE WHEN` Conditional Logic:** Implemented dynamic country extraction (handling city-states like Singapore without commas) and multi-tiered classifications.
- **`COALESCE` Arithmetic:** Applied to ensure accurate linear summation of interactions without propagating NULL values or altering raw underlying data.
- **`GROUP BY` & Two-Tier Aggregation:** Distinguished between micro-averages (post-weighted) and macro-averages (creator-weighted) to prevent ecological fallacies.
- **`ROW_NUMBER() OVER (...)`:** Used for deterministic pagination, leaderboard ranking, and multi-column tie-breaking.
- **`DENSE_RANK() OVER (PARTITION BY ...)`:** Partitioned regional creator leadership by nation, ensuring consecutive integer ranks even when follower counts tie.
- **`LAG() OVER (ORDER BY ...)`:** Implemented inter-row temporal comparisons for month-over-month volume shifts while preserving NULL for baseline periods.
- **Windowed `SUM() OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`:** Constructed running cumulative volume totals terminating precisely at the population total.
- **Manual Pearson Correlation in SQL:** Expanded mathematical covariance and standard deviation formulas into standard SQLite aggregate expressions to calculate exact bivariate correlation coefficients without external libraries.

---

### 6. Data Quality & Validation

All 10 challenges underwent rigorous automated cross-validation:

- **Universal User Participation:** All 1,500 registered users authored at least one post; zero orphan users exist.
- **Referential Integrity:** All 12,000 posts link to a valid primary key in `users`; zero orphan posts exist.
- **Identifier Uniqueness:** Both `users.user_id` and `posts.post_id` are 100% unique.
- **NULL Integrity:** Native missing values (`platform`: 1,784; `text_content`: 1,711; `likes`: 1,814) were preserved naturally via ANSI standard aggregate functions (`AVG()` skips NULLs) rather than distorted via premature imputation.
- **Zero Database Mutation:** All analytical operations executed as read-only `SELECT` statements; `data/data_vortex.db` and the cleaned CSV files remain completely unmodified.

---

### 7. Limitations

- **Synthetic Benchmark Characteristics:** The dataset exhibits uniform demographic and interaction spreads (e.g. follower counts uniformly distributed from ~100 to 50,000; post interactions tightly centered around platform means), which is characteristic of benchmark environments.
- **Descriptive Observations:** All reported findings describe observed patterns within this 12-month historical window and do not establish causal relationships.
- **Missing Value Scope:** Likes data is missing for 15.12% of posts, which was accounted for via pairwise complete analyses.

---

### 8. Conclusion

Data Vortex Round 1 Phase 2 successfully converted cleaned flat CSV records into an enterprise-grade, relational SQLite analytical database. Across 10 systematically engineered SQL challenges, the project demonstrated advanced relational modeling, window function partitioning, longitudinal tracking, and rigorous non-causal interpretation. 

Every challenge deliverable—comprising pure SQL files, thorough markdown documentation, and automated validation notebooks—is fully verified, deterministic, and competition-ready.
