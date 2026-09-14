# Challenge 3 — Geographic Representation & Country Aggregation

**Competition:** Data Vortex — Round 1 Phase 2  
**Challenge:** 03 — Geographic Representation & Country Aggregation  
**Database File:** `data/data_vortex.db`  
**Target Tables:** `users`, `posts`  
**Difficulty:** Medium  
**Date:** 2026-09-14  
**Status:** **COMPLETED & VALIDATED**  

---

## 1. Objective

The objective of Challenge 3 is to evaluate geographic representation across the user population and examine post interaction activity aggregated by country.

In the `users` table, the `location` attribute stores strings formatted as `"City, Country"` for 32 international locations (e.g. `"Berlin, Germany"`, `"Chicago, USA"`, `"São Paulo, Brazil"`). The sovereign city-state `"Singapore"` is stored without a delimiter.

The challenge requires:
1. Deriving national country entities dynamically in SQL without modifying the underlying database.
2. Handling `"Singapore"` accurately as its own country.
3. Conducting country-level user demographic analysis (user volume, follower distribution).
4. Conducting country-level post activity analysis (post volume, publishing frequency, engagement metrics).
5. Extracting the top 10 countries by total post volume.

---

## 2. Country Extraction Logic

Country extraction is achieved dynamically using standard SQLite string functions:

```sql
CASE 
    WHEN INSTR(location, ',') > 0 THEN TRIM(SUBSTR(location, INSTR(location, ',') + 1))
    ELSE location 
END AS country
```

### Operational Mechanics:
1. **`INSTR(location, ',')`**: Searches for the 1-based character position of the comma delimiter.
   - For `"Berlin, Germany"`, `INSTR` returns `7`.
   - For `"Singapore"`, there is no comma, so `INSTR` returns `0`.
2. **`CASE WHEN INSTR(...) > 0`**: 
   - When a comma is present, `SUBSTR(location, INSTR(location, ',') + 1)` extracts all characters starting immediately after the comma (e.g. `" Germany"`).
   - `TRIM(...)` strips any leading whitespace, yielding the clean country string `"Germany"`.
3. **`ELSE location`**:
   - For records where no comma exists (specifically `"Singapore"`), the branch returns the location string directly (`"Singapore"`).
4. **Data Immutability:**
   - This derivation executes on-the-fly in a Common Table Expression (`WITH user_countries AS (...)`) without requiring an `ALTER TABLE` or `UPDATE` operation on the database.

---

## 3. SQL Queries

All queries are consolidated in [`sql/challenge_03_geographic_analysis.sql`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_03_geographic_analysis.sql).

### Query 1: Country-Level User Demographic Analysis
```sql
WITH user_countries AS (
    SELECT 
        user_id,
        follower_count,
        CASE 
            WHEN INSTR(location, ',') > 0 THEN TRIM(SUBSTR(location, INSTR(location, ',') + 1))
            ELSE location 
        END AS country
    FROM users
)
SELECT 
    country,
    COUNT(*) AS user_count,
    ROUND(AVG(follower_count), 2) AS avg_followers,
    MIN(follower_count) AS min_followers,
    MAX(follower_count) AS max_followers
FROM user_countries
GROUP BY country
ORDER BY user_count DESC, country ASC;
```

### Query 2: Country-Level Post Publishing & Interaction Analysis
```sql
WITH user_countries AS (
    SELECT 
        user_id,
        CASE 
            WHEN INSTR(location, ',') > 0 THEN TRIM(SUBSTR(location, INSTR(location, ',') + 1))
            ELSE location 
        END AS country
    FROM users
)
SELECT 
    uc.country,
    COUNT(DISTINCT uc.user_id) AS user_count,
    COUNT(p.post_id) AS post_count,
    ROUND(CAST(COUNT(p.post_id) AS REAL) / COUNT(DISTINCT uc.user_id), 2) AS avg_posts_per_user,
    ROUND(AVG(p.likes), 2) AS avg_likes,
    ROUND(AVG(p.shares), 2) AS avg_shares,
    ROUND(AVG(p.comments), 2) AS avg_comments
FROM user_countries uc
INNER JOIN posts p ON uc.user_id = p.user_id
GROUP BY uc.country
ORDER BY post_count DESC, uc.country ASC;
```

---

## 4. Country-Level User Results

Executing Query 1 against [`data/data_vortex.db`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/data_vortex.db) identifies **19 unique countries** across the 1,500 users:

### Table 4.1: Country Demographic Distribution ($N = 1,500$ Users)

| Rank | Country | User Count | Average Followers | Min Followers | Max Followers |
| :---: | :--- | :---: | :---: | :---: | :---: |
| **1** | **USA** | **203** | 24,579.05 | 251 | 49,936 |
| **2** | **China** | **107** | 25,418.79 | 844 | 49,933 |
| **3** | **Germany** | **97** | 24,916.19 | 445 | 49,944 |
| **4** | **Italy** | **96** | 21,657.57 | 358 | 48,020 |
| **5** | **Japan** | **94** | 27,025.06 | 247 | 49,914 |
| **6** | **Brazil** | **93** | 24,702.70 | 1,245 | 48,702 |
| **7** | **India** | **92** | 26,528.95 | 825 | 49,722 |
| **8** | **Spain** | **92** | 24,305.21 | 448 | 49,836 |
| **9** | **UK** | **86** | 23,394.94 | 606 | 49,368 |
| **10** | **Canada** | **83** | 24,430.69 | 327 | 49,432 |
| **11** | **France** | **82** | 24,359.90 | 125 | 49,575 |
| **12** | **Australia** | **80** | 27,109.96 | 640 | 49,341 |
| **13** | **UAE** | **53** | 25,724.26 | 2,531 | 49,721 |
| **14** | **Singapore** | **49** | 24,612.20 | 3,061 | 49,763 |
| **15** | **South Africa** | **48** | 24,823.94 | 789 | 48,811 |
| **16** | **Mexico** | **40** | 26,326.15 | 4,956 | 46,857 |
| **17** | **Egypt** | **39** | 21,908.77 | 2,374 | 47,309 |
| **18** | **South Korea** | **36** | 26,390.94 | 109 | 48,317 |
| **19** | **Nigeria** | **30** | **30,056.93** | 4,352 | 47,637 |
| **Total** | **19 Countries** | **1,500** | **24,964.02** | **109** | **49,944** |

---

## 5. Country-Level Post Results

Executing Query 2 connects post publications with author countries:

### Table 5.1: Country Post Volume and Engagement Metrics ($N = 12,000$ Posts)

| Country | User Count | Post Count | Avg Posts / User | Avg Likes | Avg Shares | Avg Comments |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **USA** | 203 | **1,645** | 8.10 | 2,539.00 | 980.89 | 497.14 |
| **China** | 107 | **824** | 7.70 | 2,487.04 | 1,022.05 | 509.17 |
| **Germany** | 97 | **807** | 8.32 | 2,527.46 | 988.27 | 503.34 |
| **Brazil** | 93 | **790** | 8.49 | 2,414.23 | 1,004.84 | 504.08 |
| **Japan** | 94 | **752** | 8.00 | 2,518.60 | 1,052.48 | 519.89 |
| **Italy** | 96 | **741** | 7.72 | 2,444.64 | 989.25 | 498.35 |
| **Spain** | 92 | **729** | 7.92 | 2,549.42 | 995.49 | 507.53 |
| **UK** | 86 | **717** | 8.34 | 2,521.76 | 1,000.80 | 491.96 |
| **India** | 92 | **710** | 7.72 | 2,441.47 | 1,007.16 | 509.75 |
| **Canada** | 83 | **681** | 8.20 | 2,470.79 | 983.85 | 507.57 |
| **France** | 82 | **672** | 8.20 | 2,440.88 | 999.68 | 505.76 |
| **Australia** | 80 | **629** | 7.86 | 2,525.19 | 1,047.49 | 514.46 |
| **UAE** | 53 | **421** | 7.94 | 2,564.81 | 994.54 | 506.09 |
| **South Africa**| 48 | **383** | 7.98 | 2,422.66 | 995.89 | 500.61 |
| **Singapore** | 49 | **358** | 7.31 | 2,506.94 | 1,035.55 | 512.19 |
| **Egypt** | 39 | **322** | 8.26 | **2,628.87** | 972.79 | 493.25 |
| **Mexico** | 40 | **320** | 8.00 | 2,449.55 | 1,084.52 | 508.37 |
| **South Korea**| 36 | **276** | 7.67 | 2,355.72 | 1,043.14 | 512.33 |
| **Nigeria** | 30 | **223** | 7.43 | 2,388.87 | 1,059.85 | 472.19 |
| **Total / Overall** | **1,500** | **12,000** | **8.00** | **2,491.86** | **1,007.17** | **504.35** |

---

## 6. Top 10 Countries by Post Volume

The top 10 countries account for **8,396 posts** (69.97% of total volume) and **1,033 users** (68.87% of total users):

### Table 6.1: Top 10 Countries Ranked by Post Volume

| Rank | Country | User Count | Post Count | Pct of Total Posts | Avg Posts / User | Avg Likes | Avg Shares | Avg Comments |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | **USA** | 203 | **1,645** | 13.71% | 8.10 | 2,539.00 | 980.89 | 497.14 |
| **2** | **China** | 107 | **824** | 6.87% | 7.70 | 2,487.04 | 1,022.05 | 509.17 |
| **3** | **Germany** | 97 | **807** | 6.73% | 8.32 | 2,527.46 | 988.27 | 503.34 |
| **4** | **Brazil** | 93 | **790** | 6.58% | 8.49 | 2,414.23 | 1,004.84 | 504.08 |
| **5** | **Japan** | 94 | **752** | 6.27% | 8.00 | 2,518.60 | 1,052.48 | 519.89 |
| **6** | **Italy** | 96 | **741** | 6.18% | 7.72 | 2,444.64 | 989.25 | 498.35 |
| **7** | **Spain** | 92 | **729** | 6.08% | 7.92 | 2,549.42 | 995.49 | 507.53 |
| **8** | **UK** | 86 | **717** | 5.98% | 8.34 | 2,521.76 | 1,000.80 | 491.96 |
| **9** | **India** | 92 | **710** | 5.92% | 7.72 | 2,441.47 | 1,007.16 | 509.75 |
| **10** | **Canada** | 83 | **681** | 5.68% | 8.20 | 2,470.79 | 983.85 | 507.57 |

---

## 7. Key Findings

### 7.1 Extremes Observed in the Data
1. **Country with the Most Users:**
   - **USA** was observed to have the highest user representation with **203 users** (13.53% of all users), driven by inclusion of four distinct metropolitan hubs (Chicago, Houston, Los Angeles, New York).
2. **Country with the Most Posts:**
   - **USA** accounted for the largest post volume with **1,645 posts** (13.71% of all posts).
3. **Country with the Highest Average Follower Count:**
   - **Nigeria** had the highest average follower count at **30,056.93 followers** across its 30 users.
4. **Country with the Highest Average Likes:**
   - **Egypt** was observed to have the highest average likes at **2,628.87 likes** per post (across 322 posts, 273 non-null likes).
5. **Country with the Lowest Activity Metrics:**
   - **Nigeria** represented the lowest post volume with **223 posts** (from 30 users).
   - **South Korea** had the lowest observed average likes at **2,355.72 likes** per post.

### 7.2 Geographic Engagement Invariance
- While post volumes differ across countries due to the number of constituent cities assigned during dataset generation (e.g., USA has 4 cities; Nigeria has 1 city), the **average posting frequency per user remains stable** between **7.31** (Singapore) and **8.49** (Brazil) posts per user.
- Average likes across all 19 countries remain within a narrow band of $[2,355, 2,629]$, average shares within $[972, 1,085]$, and average comments within $[472, 520]$.
- These findings show that geographic location was not associated with differential creator productivity or audience interaction rates.

---

## 8. NULL Handling

1. **`AVG(p.likes)` Automatically Ignores NULLs:**
   - In SQLite, the `AVG()` aggregate function sums only non-NULL values and divides by the count of non-NULL values.
   - For example, in Egypt, 49 of the 322 posts had missing likes; `AVG(p.likes)` divided the total likes by 273 populated posts, avoiding downward deflation.
2. **`COUNT(p.post_id)` Counts All Authored Posts:**
   - Because `post_id` is a non-null primary key, `COUNT(p.post_id)` accurately captures every post authored in that country regardless of whether `likes` or `platform` are `NULL`.
3. **`COUNT(DISTINCT uc.user_id)` Guarantees Accurate Creator Counts:**
   - In an `INNER JOIN` between users and posts, each user record is replicated for every post they published.
   - Using `COUNT(DISTINCT uc.user_id)` counts each user exactly once per country, ensuring the user count matches the demographic baseline (e.g. 203 for USA).
4. **Singapore String Handling:**
   - By evaluating `INSTR(location, ',') > 0`, the query branches to `ELSE location` for `"Singapore"`, avoiding empty string extraction.
5. **No Underlying Data Modified:**
   - Country derivation occurs strictly within the query scope; no table columns were added or altered.

---

## 9. Interpretation & Limitations

1. **Descriptive Non-Causal Language:**
   - The observed variations in user counts reflect the demographic distribution established during benchmark creation (e.g. 4 US cities vs. 1 Egyptian city). They do not indicate that creators in the US are inherently more prolific.
2. **Synthetic Geographic Uniformity:**
   - As established in Phase 1 ($\chi^2 = 279.56, p = 0.6283$), user language and follower allocations were assigned independently of geography. Country groupings reflect international diversity rather than localized cultural concentrations.

---

## 10. Reproducibility

To execute and verify Challenge 3:

### Via SQLite CLI:
```bash
sqlite3 data/data_vortex.db < sql/challenge_03_geographic_analysis.sql
```

### Via Python:
```python
import sqlite3
import pandas as pd

conn = sqlite3.connect("data/data_vortex.db")
query = open("sql/challenge_03_geographic_analysis.sql").read()
# Execute Query 2
df = pd.read_sql(query.split(";")[1], conn)
print(df)
conn.close()
```

### Via Jupyter Notebook:
Execute all cells in [`notebooks/10_challenge_03.ipynb`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/10_challenge_03.ipynb).
