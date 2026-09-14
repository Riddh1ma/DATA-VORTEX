# Challenge 2 — Top Creator Audience Leaderboard

**Competition:** Data Vortex — Round 1 Phase 2  
**Challenge:** 02 — Top Creator Audience Leaderboard  
**Database File:** `data/data_vortex.db`  
**Target Tables:** `users`, `posts`  
**Difficulty:** Easy  
**Date:** 2026-09-14  
**Status:** **COMPLETED & VALIDATED**  

---

## 1. Objective

The objective of Challenge 2 is to construct a creator audience leaderboard ranking users by their registered follower count. For each qualifying creator who has authored at least one post, the query aggregates their publishing history to display:
1. **User Identifier** (`user_id`): Unique creator primary key.
2. **Geographic Location** (`location`): Metropolitan city and country of residence.
3. **Primary Language** (`language`): Two-letter ISO 639-1 language code.
4. **Follower Count** (`follower_count`): Total registered platform audience.
5. **Post Count** (`post_count`): Total number of social posts authored by the user.
6. **Average Likes** (`avg_likes`): Mean likes accumulated per post.
7. **Average Shares** (`avg_shares`): Mean shares accumulated per post.
8. **Average Comments** (`avg_comments`): Mean comments accumulated per post.

The leaderboard is sorted by `follower_count` in descending order, restricted to the top 20 creators.

---

## 2. SQL Query

The complete, verified SQL query is stored in [`sql/challenge_02_top_creator_audience.sql`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_02_top_creator_audience.sql):

```sql
SELECT 
    u.user_id,
    u.location,
    u.language,
    u.follower_count,
    COUNT(p.post_id) AS post_count,
    ROUND(AVG(p.likes), 2) AS avg_likes,
    ROUND(AVG(p.shares), 2) AS avg_shares,
    ROUND(AVG(p.comments), 2) AS avg_comments
FROM users u
INNER JOIN posts p ON u.user_id = p.user_id
GROUP BY 
    u.user_id, 
    u.location, 
    u.language, 
    u.follower_count
ORDER BY u.follower_count DESC
LIMIT 20;
```

---

## 3. Query Explanation

Below is an explanation of each clause and operational construct used in the query:

1. **`INNER JOIN posts p ON u.user_id = p.user_id`**:
   - Matches rows between the parent `users` table and the child `posts` table based on the relational foreign key `u.user_id = p.user_id`.
   - By using an `INNER JOIN`, users who have zero posts would be naturally excluded (though Phase 1 verified that all 1,500 users have authored posts).
   - Enables simultaneous retrieval of user-level demographics (`follower_count`, `location`, `language`) alongside post-level engagement metrics.

2. **`GROUP BY u.user_id, u.location, u.language, u.follower_count`**:
   - Collapses the multiple individual post records authored by each user into a single summary record per creator.
   - Including all selected non-aggregated columns in the `GROUP BY` clause adheres strictly to ANSI SQL standard grouping rules.

3. **`COUNT(p.post_id) AS post_count`**:
   - Counts the primary keys of the posts table associated with each user.
   - Accurately reports total authored post volume regardless of whether optional fields (like `likes` or `platform`) contain `NULL`s.

4. **`ROUND(AVG(p.likes), 2) AS avg_likes`**:
   - Computes the arithmetic mean of likes for each user's post portfolio.
   - Standard SQL `AVG()` ignores `NULL` likes automatically, calculating the average strictly over posts that have recorded like counts.
   - `ROUND(..., 2)` rounds the average to two decimal places.

5. **`ROUND(AVG(p.shares), 2)` & `ROUND(AVG(p.comments), 2)`**:
   - Calculate the mean shares and comments per post for each user. Because shares and comments contain zero missing values, the average covers all authored posts.

6. **`ORDER BY u.follower_count DESC`**:
   - Sorts the aggregated creator records from the largest audience size to the smallest.

7. **`LIMIT 20`**:
   - Truncates the output to the top 20 creators with the highest follower counts.

---

## 4. Results

Executing the query against [`data/data_vortex.db`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/data_vortex.db) generates 1,500 total creator rows before the `LIMIT` clause. The top 20 rows are presented in Table 4.1.

### Table 4.1: Top 20 Creator Audience Leaderboard

| Rank | User ID | Location | Language | Follower Count | Post Count | Average Likes | Average Shares | Average Comments |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | `user_3o7w66o2` | Berlin, Germany | `ja` | **49,944** | 8 | 3,394.00 | 724.50 | 683.38 |
| **2** | `user_u98jwp3f` | Chicago, USA | `zh` | **49,936** | 11 | 2,871.80 | 1,283.00 | 560.45 |
| **3** | `user_usts5yuo` | Shanghai, China | `ja` | **49,933** | 6 | 3,049.00 | 1,101.17 | 611.50 |
| **4** | `user_d4eat3v3` | Tokyo, Japan | `de` | **49,914** | 15 | 2,855.71 | 1,083.07 | 532.13 |
| **5** | `user_siuvpkza` | Chicago, USA | `en` | **49,905** | 9 | 2,063.83 | 1,167.22 | 410.00 |
| **6** | `user_ujllj1n7` | Chicago, USA | `es` | **49,855** | 16 | 3,056.08 | 1,014.06 | 508.00 |
| **7** | `user_kr0ydzhh` | Barcelona, Spain | `fr` | **49,836** | 10 | 1,677.89 | 1,143.20 | 515.00 |
| **8** | `user_9asov0m8` | Singapore | `hi` | **49,763** | 9 | 2,429.43 | 1,156.56 | 439.44 |
| **9** | `user_84k7x6zn` | Barcelona, Spain | `ja` | **49,736** | 13 | 3,139.40 | 927.69 | 490.77 |
| **10** | `user_t028mbub` | Osaka, Japan | `en` | **49,727** | 5 | 3,104.60 | 850.20 | 478.40 |
| **11** | `user_i8ncp2ai` | Delhi, India | `fr` | **49,722** | 6 | 2,251.00 | 696.00 | 472.00 |
| **12** | `user_sjm4thcl` | Dubai, UAE | `en` | **49,721** | 10 | 3,224.50 | 996.40 | 451.50 |
| **13** | `user_b8ysn8r5` | Shanghai, China | `hi` | **49,699** | 13 | 1,871.50 | 984.77 | 600.08 |
| **14** | `user_kf84zwv2` | Paris, France | `es` | **49,575** | 13 | 2,711.92 | 1,171.46 | 474.62 |
| **15** | `user_8i81i0p7` | Los Angeles, USA | `en` | **49,518** | 9 | 3,136.43 | 947.44 | 365.44 |
| **16** | `user_ixw57ddo` | Chicago, USA | `de` | **49,484** | 7 | 1,600.33 | 1,079.57 | 457.29 |
| **17** | `user_reqsqicb` | Toronto, Canada | `hi` | **49,432** | 13 | 1,921.50 | 1,034.23 | 350.31 |
| **18** | `user_5wmdl0y4` | Dubai, UAE | `hi` | **49,404** | 8 | 1,875.60 | 977.13 | 486.25 |
| **19** | `user_9ksxfq3r` | Manchester, UK | `zh` | **49,368** | 5 | 3,273.00 | 1,215.80 | 511.60 |
| **20** | `user_mtuzxdlb` | Melbourne, Australia | `fr` | **49,341** | 14 | 2,632.50 | 1,115.07 | 467.50 |

---

## 5. Key Findings

### 5.1 Identified Extreme Entities
1. **Highest Follower Count User:**
   - **`user_3o7w66o2`** ranks #1 overall with **49,944 followers** (Location: Berlin, Germany; Language: `ja`). Authored 8 posts averaging 3,394.00 likes, 724.50 shares, and 683.38 comments.
2. **Highest Number of Posts User:**
   - **Within Top 20:** **`user_ujllj1n7`** (Rank #6) with **16 posts** (49,855 followers; Location: Chicago, USA).
   - **Across Overall Database:** **`user_zqv2vrf5`** with **22 posts** (Location: San Jose, USA; Language: `ja`; follower count: 13,531; avg likes: 2,533.79).
3. **Highest Average Likes User:**
   - **Within Top 20:** **`user_3o7w66o2`** with **3,394.00 average likes**.
   - **Across Overall Database:** **`user_uw0vd87k`** with **4,821.33 average likes** (Follower count: 11,640; Location: Milan, Italy; Language: `hi`; 6 posts).

---

### 5.2 Do Highest Followers Correspond to Highest Engagement?
**The data shows that highest follower counts do NOT systematically correspond to highest post engagement.**

#### Concrete Evidence from the Results:
1. **Wide Variance at the Top:** Within the top 20 creators (all possessing between 49,341 and 49,944 followers), average likes per post vary by more than **2.1x**, ranging from **1,600.33** (`user_ixw57ddo`, 49,484 followers) to **3,394.00** (`user_3o7w66o2`, 49,944 followers).
2. **Underperforming Mega-Followers:** Multiple creators in the top 20 average substantially lower engagement than the overall database mean of 2,491.86 likes:
   - `user_ixw57ddo` (49,484 followers) averages only **1,600.33 likes** (-35.8% below database mean).
   - `user_kr0ydzhh` (49,836 followers) averages only **1,677.89 likes** (-32.7% below database mean).
   - `user_b8ysn8r5` (49,699 followers) averages only **1,871.50 likes** (-24.9% below database mean).
3. **Global Engagement Leader Has Low Audience Reach:** Across all 1,500 users, the single highest average likes performance (**4,821.33 likes**) belongs to `user_uw0vd87k`, who possesses only **11,640 followers** (placing them in the lowest follower quartile Q1).
4. **Conclusion:** High audience reach does not translate to higher engagement in this dataset. The empirical observations are consistent with the Phase 1 finding of complete decoupling between follower counts and interaction metrics ($r = +0.0082, p = 0.4063$).

---

## 6. NULL Handling

1. **Natural Ignorance of NULLs in `AVG()`:**
   - In SQL, `AVG(p.likes)` computes $\frac{\sum \text{non-null likes}}{\text{count of non-null likes}}$.
   - For example, if a user authored 8 posts and 1 post had missing likes, the average is divided by 7.
   - This ensures the reported metric reflects the true observed average likes per populated post without artificial downward deflation.
2. **Accurate Post Volume Counting:**
   - `COUNT(p.post_id)` counts the primary keys of the joined posts table.
   - Because `post_id` is defined as `NOT NULL PRIMARY KEY`, every post authored by the user is counted, regardless of whether `platform`, `text_content`, or `likes` contain `NULL`s.
3. **Zero Value Substitution Avoided:**
   - Missing likes were NOT replaced with zeros for this leaderboard. Replacing missing likes with zero would artificially penalize users who published posts with missing like metadata.

---

## 7. Interpretation & Limitations

1. **Non-Causal Relationship:**
   - The observed data confirms that having high follower numbers does not cause higher post interactions.
2. **Demographic Synthesis:**
   - Top creators exhibit international diversity across 13 distinct metropolitan locations and 8 languages, consistent with synthetic random allocation rather than regional concentration.
3. **Post Volume Uniformity:**
   - Authored post counts for top creators range between 5 and 16 posts, matching the expected Poisson distribution ($\lambda = 8.0$) observed during EDA.

---

## 8. Reproducibility

To execute and verify Challenge 2:

### Via SQLite CLI:
```bash
sqlite3 data/data_vortex.db < sql/challenge_02_top_creator_audience.sql
```

### Via Python:
```python
import sqlite3
import pandas as pd

conn = sqlite3.connect("data/data_vortex.db")
query = open("sql/challenge_02_top_creator_audience.sql").read()
df = pd.read_sql(query, conn)
print(df)
conn.close()
```

### Via Jupyter Notebook:
Open and execute all cells in [`notebooks/09_challenge_02.ipynb`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/09_challenge_02.ipynb).
