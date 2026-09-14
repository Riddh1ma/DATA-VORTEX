# Phase 2 Analytical SQL Challenge Plan

**Competition:** Data Vortex — Round 1 Phase 2  
**Database File:** `data/data_vortex.db`  
**Database Engine:** SQLite 3  
**Tables:** `users` (1,500 records), `posts` (12,000 records)  
**Document Version:** 1.0  
**Date:** 2026-09-14  
**Status:** **PLANNING ONLY (No Solutions Executed)**  

---

## 1. Competition Requirements

Phase 2 of the Data Vortex competition transitions from dataset inspection, cleaning, and exploratory analysis into structured relational database querying.

### Mandatory Rules & Constraints:
1. **Single Source of Truth:** All queries must execute exclusively against the verified SQLite database at `data/data_vortex.db`.
2. **Strict Immutability:** 
   - Zero modification to `data/raw/` or `data/cleaned/` CSV files.
   - Zero alteration to the relational tables, schemas, or existing data in `data/data_vortex.db`.
   - Analytical queries must be read-only (`SELECT`).
3. **Foreign Key Enforcement:** Foreign key constraints are active (`PRAGMA foreign_keys = ON;`), maintaining strict 1:N referential integrity (`posts.user_id -> users.user_id`).
4. **Transparent NULL Handling:** Missing values in `platform` (1,784), `text_content` (1,711), and `likes` (1,814) must be handled transparently using SQL `IS NULL`, `COALESCE`, or explicit conditional logic without artificial imputation.
5. **No Data Fabrication:** Queries must evaluate empirical records without inventing placeholder metrics or arbitrary classifications.
6. **Reproducibility & Evidence:** All final SQL queries must be stored in `sql/`, documented in `reports/`, executed in interactive notebooks under `notebooks/`, and verified with output captures in `outputs/screenshots/`.

---

## 2. Required Analytical Questions

Based on the forensic findings from Phase 1, the relational schema structure, and the analytical goals established in the project documentation, **10 core analytical SQL challenges** have been identified across four operational domains:

### Analytical Challenge Matrix

| # | Challenge Title | Domain | Difficulty | Main SQL Concepts | Priority |
| :---: | :--- | :--- | :---: | :--- | :---: |
| **1** | **Platform Interaction Benchmarks** | Platform Performance | **Easy** | `SELECT`, `GROUP BY`, `COUNT`, `AVG`, `ROUND`, `COALESCE`, `ORDER BY` | P1 |
| **2** | **Top Creator Audience Leaderboard** | User Demographics | **Easy** | `SELECT`, `ORDER BY`, `LIMIT`, `WHERE` | P1 |
| **3** | **Geographic Representation & Country Aggregation** | Geographic Distribution | **Medium** | `CASE`, `INSTR`, `SUBSTR`, `COUNT`, `SUM`, `AVG`, `GROUP BY`, `ORDER BY` | P2 |
| **4** | **Creator Activity Segmentation (Posting Tiers)** | User Activity | **Medium** | `CTE`, `COUNT`, `CASE WHEN`, `GROUP BY`, `ORDER BY` | P2 |
| **5** | **Monthly Publishing Volume & Engagement Trends** | Temporal Trends | **Medium** | `SUBSTR`, `COUNT`, `SUM`, `AVG`, `COALESCE`, `GROUP BY`, `ORDER BY` | P2 |
| **6** | **Day-of-Week Cadence & Engagement Distribution** | Temporal Patterns | **Medium** | `STRFTIME('%w')`, `CASE WHEN`, `COUNT`, `AVG`, `GROUP BY`, `ORDER BY` | P2 |
| **7** | **Audience Reach vs. Engagement Analysis** | Relational Coupling | **Medium** | `JOIN`, `NTILE` / `CASE`, `CTE`, `AVG`, `COUNT`, `GROUP BY`, `ORDER BY` | P3 |
| **8** | **High-Impact Post Leaderboard & Metric Ratios** | Content Performance | **Medium** | `JOIN`, `COALESCE`, Arithmetic expressions, `ORDER BY`, `LIMIT` | P3 |
| **9** | **Regional Creator Leadership via Window Functions** | Advanced Relational | **Hard** | `CTE`, `JOIN`, `DENSE_RANK() OVER (PARTITION BY ...)` | P4 |
| **10** | **Month-over-Month Volume Growth & Cumulative Tracking** | Time-Series Window | **Hard** | `CTE`, `STRFTIME`, `LAG() OVER ()`, `SUM() OVER ()`, `ROUND` | P4 |

---

## 3. Recommended Solving Order

To ensure a structured, pedagogical progression that builds from foundational aggregations to complex window functions, the challenges should be solved in the following sequence:

```
Stage 1: Foundational Aggregations & Baselines (Easy)
  ├── Challenge 1: Platform Interaction Benchmarks
  └── Challenge 2: Top Creator Audience Leaderboard
          │
          v
Stage 2: Categorical String Parsing & Temporal Groupings (Medium)
  ├── Challenge 3: Geographic Representation & Country Aggregation
  ├── Challenge 4: Creator Activity Segmentation (Posting Tiers)
  ├── Challenge 5: Monthly Publishing Volume & Engagement Trends
  └── Challenge 6: Day-of-Week Cadence & Engagement Distribution
          │
          v
Stage 3: Multi-Table Joins & Cohort Segmentations (Medium)
  ├── Challenge 7: Audience Reach vs. Engagement Analysis
  └── Challenge 8: High-Impact Post Leaderboard & Metric Ratios
          │
          v
Stage 4: Advanced Analytical Window Functions & Time-Series (Hard)
  ├── Challenge 9: Regional Creator Leadership via Window Functions
  └── Challenge 10: Month-over-Month Volume Growth & Cumulative Tracking
```

---

## 4. Expected Output for Each Challenge

### Challenge 1: Platform Interaction Benchmarks
- **Analytical Objective:** Quantify total post volume, share of total posts, and average likes, shares, and comments across each platform channel, including explicit preservation of missing platforms.
- **Target Tables:** `posts`
- **Expected Columns:** `platform_name`, `total_posts`, `pct_total_posts`, `avg_likes`, `avg_shares`, `avg_comments`
- **Expected Result Shape:** 6 rows (5 platforms + `[Missing]`), sorted by `total_posts DESC`.
- **Value:** Establishes the foundational channel distribution and verifies engagement invariance across platforms in SQL.

---

### Challenge 2: Top Creator Audience Leaderboard
- **Analytical Objective:** Identify the top 10 users with the largest audience followings, including location, primary language, and registration date.
- **Target Tables:** `users`
- **Expected Columns:** `user_id`, `follower_count`, `location`, `language`, `account_created`
- **Expected Result Shape:** 10 rows, sorted by `follower_count DESC`.
- **Value:** Validates demographic bounds at the upper tail of the uniform follower distribution.

---

### Challenge 3: Geographic Representation & Country Aggregation
- **Analytical Objective:** Parse user location strings into distinct country entities (correctly handling 32 `"City, Country"` entries and sovereign `"Singapore"`), aggregating total users, total audience reach, and average followers per country.
- **Target Tables:** `users`
- **Expected Columns:** `country`, `total_users`, `total_followers`, `avg_followers_per_user`
- **Expected Result Shape:** $\approx 19$ unique countries, sorted by `total_users DESC`.
- **Value:** Tests string manipulation in SQLite (`INSTR`, `SUBSTR`, `CASE`) and evaluates national representation.

---

### Challenge 4: Creator Activity Segmentation (Posting Tiers)
- **Analytical Objective:** Aggregate posts per user and categorize all 1,500 creators into distinct publishing cohorts (`Low Activity: 1-4 posts`, `Moderate Activity: 5-9 posts`, `High Activity: 10-14 posts`, `Super Creators: 15+ posts`), reporting user count, percentage of user base, and total posts generated.
- **Target Tables:** `posts` (aggregated by `user_id`)
- **Expected Columns:** `activity_tier`, `user_count`, `pct_users`, `total_posts_contributed`, `pct_total_posts`
- **Expected Result Shape:** 4 rows, sorted by activity tier hierarchy.
- **Value:** Evaluates creator concentration and demonstrates CTE aggregation patterns.

---

### Challenge 5: Monthly Publishing Volume & Engagement Trends
- **Analytical Objective:** Generate a 12-month timeline tracking post counts, total interaction volume (`likes + shares + comments`), and average likes per post across the observation window (May 2024 to April 2025).
- **Target Tables:** `posts`
- **Expected Columns:** `post_month`, `monthly_posts`, `total_interactions`, `avg_likes`, `avg_shares`, `avg_comments`
- **Expected Result Shape:** 12 rows (`2024-05` to `2025-04`), sorted chronologically.
- **Value:** Verifies temporal consistency and identifies month-to-month interaction volume in SQL.

---

### Challenge 6: Day-of-Week Cadence & Engagement Distribution
- **Analytical Objective:** Group posts by day of the week (Sunday through Saturday) to calculate publishing volume and average interaction metrics, assessing weekday vs. weekend patterns.
- **Target Tables:** `posts`
- **Expected Columns:** `day_number`, `day_name`, `total_posts`, `avg_likes`, `avg_shares`, `avg_comments`
- **Expected Result Shape:** 7 rows (Sunday to Saturday), ordered by `day_number`.
- **Value:** Demonstrates date formatting and weekday extraction functions in SQLite.

---

### Challenge 7: Audience Reach vs. Engagement Analysis
- **Analytical Objective:** Perform an inner join between `users` and `posts` to segment creators into 4 follower quartiles (`Q1: Low` to `Q4: High`) and calculate mean likes, shares, and comments for each tier.
- **Target Tables:** `users` $\bowtie$ `posts` on `user_id`
- **Expected Columns:** `follower_quartile`, `follower_range`, `total_posts`, `avg_likes`, `avg_shares`, `avg_comments`
- **Expected Result Shape:** 4 rows, ordered from Q1 to Q4.
- **Value:** Statistically demonstrates in SQL the absence of correlation between audience size and post engagement.

---

### Challenge 8: High-Impact Post Leaderboard & Metric Ratios
- **Analytical Objective:** Rank the top 10 individual posts with the highest combined interactions (`likes + shares + comments`), joining author metadata to display user location and platform, alongside calculated interaction ratios (`shares_to_likes` and `comments_to_likes`).
- **Target Tables:** `posts` $\bowtie$ `users` on `user_id`
- **Expected Columns:** `post_id`, `user_id`, `location`, `platform`, `likes`, `shares`, `comments`, `total_interactions`, `shares_per_100_likes`
- **Expected Result Shape:** 10 rows, sorted by `total_interactions DESC`.
- **Value:** Tests multi-column arithmetic, NULL-coalescing, and cross-table attribution.

---

### Challenge 9: Regional Creator Leadership via Window Functions
- **Analytical Objective:** Using the `DENSE_RANK() OVER (PARTITION BY ...)` window function, identify the top 3 most active post creators within each country.
- **Target Tables:** `users` $\bowtie$ `posts` on `user_id`
- **Expected Columns:** `country`, `user_id`, `total_posts`, `avg_likes`, `country_rank`
- **Expected Result Shape:** Filtered to `country_rank <= 3`, ordered by `country ASC, country_rank ASC`.
- **Value:** Exercises advanced analytical SQL ranking and partition window functions.

---

### Challenge 10: Month-over-Month Volume Growth & Cumulative Tracking
- **Analytical Objective:** Calculate monthly post counts alongside the previous month's count (`LAG()`), month-over-month percentage growth, and cumulative running total of posts over the 12-month period using window functions.
- **Target Tables:** `posts`
- **Expected Columns:** `post_month`, `monthly_posts`, `prev_month_posts`, `mom_growth_pct`, `running_cumulative_posts`
- **Expected Result Shape:** 12 chronological rows.
- **Value:** Demonstrates time-series lead/lag operations, cumulative window sums, and growth calculations.

---

## 5. SQL Concepts We Need to Learn & Apply

| Category | Specific SQL Construct / Function | Purpose in Phase 2 Challenges |
| :--- | :--- | :--- |
| **Filtering & Nulls** | `IS NULL`, `IS NOT NULL`, `COALESCE(col, default)` | Safeguard calculations against missing platform/likes metadata |
| **Conditional Logic**| `CASE WHEN ... THEN ... ELSE ... END` | Categorize activity tiers, map day numbers to day names, extract countries |
| **String Operations**| `SUBSTR()`, `INSTR()`, `TRIM()`, `LENGTH()` | Parse `"City, Country"` location strings into discrete geographic entities |
| **Temporal Parsing** | `STRFTIME('%Y-%m', col)`, `STRFTIME('%w', col)` | Group records by calendar month and day of week |
| **Subqueries & CTEs**| `WITH cte_name AS (SELECT ...) SELECT ...` | Modularize complex multi-step aggregations cleanly |
| **Relational Joins** | `INNER JOIN`, `LEFT JOIN` on `user_id` | Combine user demographic attributes with post engagement events |
| **Ranking Windows**  | `DENSE_RANK() OVER (PARTITION BY ... ORDER BY ...)` | Rank creators within local geographic cohorts without gaps |
| **Lead/Lag Windows** | `LAG(col, 1) OVER (ORDER BY ...)` | Compare current month volume against prior period for growth metrics |
| **Running Windows**  | `SUM(col) OVER (ORDER BY ... ROWS UNBOUNDED PRECEDING)` | Compute running cumulative totals across time series |

---

## 6. Phase 2 Submission Requirements

To successfully deliver Phase 2 of Data Vortex Round 1, the following deliverable artifacts will be generated upon completion of all challenge solutions:

1. **SQL Solution Scripts:**
   - Dedicated, well-commented SQL files under `sql/` (e.g., `sql/03_analytical_queries.sql`).
2. **Interactive Jupyter Notebook:**
   - [`notebooks/08_analytical_sql.ipynb`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/08_analytical_sql.ipynb) executing each query against `data/data_vortex.db` with rendered Pandas dataframes.
3. **Comprehensive Analytical Report:**
   - `reports/08_sql_analytics_report.md` detailing the business question, query syntax, tabular output, and analytical interpretation for all 10 challenges.
4. **Execution Evidence & Screenshots:**
   - Console query verification outputs saved under `outputs/screenshots/`.
5. **Zero Modification Guarantee:**
   - Final audit confirming raw datasets, cleaned datasets, and the SQLite database remain uncorrupted.
