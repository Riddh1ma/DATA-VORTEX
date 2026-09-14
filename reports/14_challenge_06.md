# Challenge 6 — Day-of-Week Posting Cadence

**Competition:** Data Vortex — Round 1 Phase 2  
**Challenge:** 06 — Day-of-Week Posting Cadence  
**Database File:** `data/data_vortex.db`  
**Target Table:** `posts`  
**Difficulty:** Low–Medium  
**Date:** 2026-09-14  
**Status:** **COMPLETED & VALIDATED**  

---

## 1. Objective

The objective of Challenge 6 is to evaluate creator publishing distribution across the days of the week using the `timestamp` column in the `posts` table.

Specific goals:
1. Extract the day of week and map it to standard ISO day numbers (Monday = 1 through Sunday = 7).
2. Tally total posts and calculate percentage shares across all seven days.
3. Order the output chronologically from Monday through Sunday.
4. Identify the highest-posting and lowest-posting days and compute absolute and relative differences.
5. Provide concise, non-causal observations regarding weekday versus weekend publishing cadence.
6. Verify dataset integrity (7 days, 12,000 posts, ~100% distribution, immutable database).

---

## 2. SQL Approach

The query uses SQLite's date formatting function `strftime()` and a `CASE` expression:
- **`strftime('%u', timestamp)`**: Returns the ISO day of the week as an integer string (`1` for Monday through `7` for Sunday).
- **`CASE CAST(strftime('%u', timestamp) AS INTEGER) ... END`**: Maps the numeric code to its formal English day name (`Monday`, `Tuesday`, etc.).
- **`COUNT(post_id)`**: Counts total posts published on that day across the 12-month period.
- **`ROUND(100.0 * COUNT(post_id) / (SELECT COUNT(*) FROM posts), 2)`**: Evaluates each day's percentage share of the 12,000 total posts.
- **`ORDER BY day_number ASC`**: Ensures chronological presentation from Monday (1) to Sunday (7).

All SQL statements are located in [`sql/challenge_06_day_of_week_cadence.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_06_day_of_week_cadence.sql).

```sql
WITH daily_posts AS (
    SELECT 
        post_id,
        CAST(strftime('%u', timestamp) AS INTEGER) AS day_number,
        CASE CAST(strftime('%u', timestamp) AS INTEGER)
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
            WHEN 7 THEN 'Sunday'
        END AS day_of_week
    FROM posts
)
SELECT 
    day_of_week,
    day_number,
    COUNT(post_id) AS post_count,
    ROUND(100.0 * COUNT(post_id) / (SELECT COUNT(*) FROM posts), 2) AS percentage_of_posts
FROM daily_posts
GROUP BY day_number, day_of_week
ORDER BY day_number ASC;
```

---

## 3. Result Table

| Day of Week | Day Number | Post Count | Percentage of Posts (%) |
| :--- | :---: | :---: | :---: |
| **Monday** | 1 | 1,720 | 14.33% |
| **Tuesday** | 2 | 1,677 | 13.98% |
| **Wednesday** | 3 | 1,771 | 14.76% |
| **Thursday** | 4 | 1,718 | 14.32% |
| **Friday** | 5 | 1,723 | 14.36% |
| **Saturday** | 6 | 1,675 | 13.96% |
| **Sunday** | 7 | 1,716 | 14.30% |
| **Total** | — | **12,000** | **100.00%** |

---

## 4. Highest and Lowest Posting Days

| Metric | Day of Week | Day Number | Post Count | Share of Total (%) |
| :--- | :---: | :---: | :---: | :---: |
| **Highest-Posting Day** | **Wednesday** | 3 | 1,771 posts | 14.76% |
| **Lowest-Posting Day** | **Saturday** | 6 | 1,675 posts | 13.96% |

### Variance Analysis:
- **Absolute Difference:** $1,771 - 1,675 = \mathbf{96\text{ posts}}$.
- **Relative Percentage Difference:** $\frac{1,771 - 1,675}{1,675} \times 100 = \mathbf{5.73\%}$ higher on Wednesday compared to Saturday.
- **Percentage Share Spread:** $14.76\% - 13.96\% = \mathbf{0.80\text{ percentage points}}$.

---

## 5. Simple Analytical Observations

1. **Remarkable Uniformity Across the Week:**
   - Posting activity is distributed almost uniformly across all seven days.
   - If posts were perfectly distributed across days, each day would capture $\frac{100\%}{7} \approx 14.29\%$ (or ~1,714 posts).
   - Observed daily counts range between 1,675 and 1,771 posts, fluctuating by only $\pm 2.3\%$ around the theoretical average.

2. **Midweek Publishing Peak:**
   - **Wednesday** exhibited the highest observed posting volume at **1,771 posts** (14.76%), while Tuesday (1,677 posts) and Saturday (1,675 posts) saw the lowest volumes.

3. **Weekday vs. Weekend Proportions:**
   - **Weekdays (Monday–Friday, 5 days):** Totaled **8,609 posts** (71.74% of all posts; expected theoretical share is $\frac{5}{7} = 71.43\%$), averaging **1,721.8 posts/day**.
   - **Weekends (Saturday–Sunday, 2 days):** Totaled **3,391 posts** (28.26% of all posts; expected theoretical share is $\frac{2}{7} = 28.57\%$), averaging **1,695.5 posts/day**.
   - Creators published at essentially identical rates on weekends as on weekdays, with weekday volume exceeding weekend volume by only ~1.5% on a per-day basis.

---

## 6. Validation Results

| Verification Check | Target / Expected | Observed / Actual | Status |
| :--- | :---: | :---: | :---: |
| **Number of Days Represented** | Exactly 7 | 7 (Monday–Sunday) | **PASS** |
| **Total Post Volume Sum** | Exactly 12,000 | 12,000 | **PASS** |
| **Sum of Percentage Shares** | 100.00% ($\approx 100\%$) | 100.00% | **PASS** |
| **Chronological Ordering** | Monday (1) → Sunday (7) | Monday (1) → Sunday (7) | **PASS** |
| **Lost / Unclassified Posts** | 0 | 0 | **PASS** |
| **Database Immutability Audit** | Unchanged | Unchanged (`SELECT` only) | **PASS** |

*All analytical checks passed with 100% precision.*
