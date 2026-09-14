# Challenge 8 — High-Impact Post Leaderboard

**Competition:** Data Vortex — Round 1 Phase 2  
**Challenge:** 08 — High-Impact Post Leaderboard  
**Database File:** `data/data_vortex.db`  
**Target Table:** `posts`  
**Difficulty:** Low–Medium  
**Date:** 2026-09-14  
**Status:** **COMPLETED & VALIDATED**  

---

## 1. Objective

The objective of Challenge 8 is to identify, rank, and summarize the top 20 individual posts across the entire platform based on total engagement volume.

Specific analytical goals:
1. Define and compute `total_engagement` as the linear sum of likes, shares, and comments using `COALESCE` to prevent missing values from invalidating totals.
2. Preserve original, unmodified raw values for `likes`, `shares`, and `comments` in all reported outputs.
3. Rank posts using strict ordering criteria:
   - `total_engagement DESC`
   - `likes DESC` (tie-breaker 1)
   - `shares DESC` (tie-breaker 2)
   - `comments DESC` (tie-breaker 3)
   - `post_id ASC` (tie-breaker 4)
4. Compile a platform distribution summary for the top 20 cohort, categorizing missing platform values as `'Unknown'`.
5. Identify empirical extremes and calculate cohort averages using descriptive, non-causal language.
6. Verify database integrity and complete analytical reproducibility.

---

## 2. Definition of Total Engagement & NULL Handling

Total interaction volume for each individual post is defined as:

$$\text{total\_engagement} = \text{COALESCE}(likes, 0) + \text{COALESCE}(shares, 0) + \text{COALESCE}(comments, 0)$$

### Operational & Analytical Rules:
- **Zero Imputation Exclusively for Total:** `COALESCE` is applied solely during arithmetic summation to prevent SQLite from returning `NULL` when an individual interaction component is absent.
- **Raw Data Preservation:** The reported columns `likes`, `shares`, and `comments` preserve their native values (including existing NULLs) without database modification.
- **Determinism:** `ROW_NUMBER() OVER (...)` guarantees unique, deterministic integer ranks from 1 to 20.

All queries are maintained in [`sql/challenge_08_high_impact_post_leaderboard.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_08_high_impact_post_leaderboard.sql).

---

## 3. Top-20 High-Impact Posts Leaderboard

| Rank | post_id | user_id | Platform | Timestamp | Likes | Shares | Comments | Total Engagement |
| :---: | :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **1** | `ycjj5zzt7mvx` | `user_d9971ba6` | Instagram | 2025-02-19 05:57:35 | 4,983 | 1,919 | 991 | **7,893** |
| **2** | `wo7py9aljg3t` | `user_o8le7hqf` | Reddit | 2025-04-28 00:00:00 | 4,864 | 1,981 | 948 | **7,793** |
| **3** | `gmoeib832zbs` | `user_pe5yckyb` | Facebook | 2025-01-24 10:39:09 | 4,902 | 1,880 | 982 | **7,764** |
| **4** | `5kvuyvf38nqx` | `user_z0feut2e` | YouTube | 2024-06-09 00:00:00 | 4,923 | 1,971 | 861 | **7,755** |
| **5** | `pvfl3d8hj7jd` | `user_csluibwk` | Instagram | 2024-05-15 00:00:00 | 4,989 | 1,840 | 909 | **7,738** |
| **6** | `tdgjjylpua20` | `user_8nvzxsuj` | *NULL* | 2024-06-02 00:00:00 | 4,979 | 1,932 | 812 | **7,723** |
| **7** | `tne7s3o4l4wd` | `user_lr3fagdl` | Instagram | 2024-10-30 11:45:55 | 4,931 | 1,903 | 878 | **7,712** |
| **8** | `a1kiwl618kzy` | `user_aaiari8o` | Facebook | 2025-04-09 00:00:00 | 4,811 | 1,952 | 920 | **7,683** |
| **9** | `fp89q1ickn9w` | `user_h4lueh1i` | Twitter | 2025-03-15 18:19:33 | 4,740 | 1,933 | 955 | **7,628** |
| **10** | `5n161ir5hhhr` | `user_u98jwp3f` | YouTube | 2025-01-26 00:44:23 | 4,751 | 1,981 | 878 | **7,610** |
| **11** | `g7d0tgdwipoy` | `user_yhe9m0z0` | Reddit | 2024-05-13 16:11:16 | 4,804 | 1,842 | 937 | **7,583** |
| **12** | `rh7jt9kj7tw8` | `user_01mu2x1s` | YouTube | 2025-01-08 01:23:46 | 4,881 | 1,787 | 913 | **7,581** |
| **13** | `za6nw486cyn2` | `user_rj984hbd` | YouTube | 2025-03-04 11:24:45 | 4,915 | 1,748 | 877 | **7,540** |
| **14** | `ji1k7vpa7acq` | `user_r3r59q7h` | *NULL* | 2025-04-15 09:33:12 | 4,797 | 1,980 | 759 | **7,536** |
| **15** | `vkn6dfmfb1mk` | `user_68enpikx` | *NULL* | 2024-10-21 08:44:53 | 4,674 | 1,943 | 894 | **7,511** |
| **16** | `d7a3bjdzzi5w` | `user_24wzfb8b` | Reddit | 2024-09-13 08:18:34 | 4,880 | 1,716 | 904 | **7,500** |
| **17** | `xzt681si3ibm` | `user_w4p8zi5g` | Reddit | 2024-09-30 00:14:29 | 4,672 | 1,822 | 985 | **7,479** |
| **18** | `k5qkhdj5zpnw` | `user_v85ub55d` | Facebook | 2025-03-03 00:00:00 | 4,554 | 1,985 | 938 | **7,477** |
| **19** | `2ubp2yyrtncq` | `user_q2y6x6ct` | YouTube | 2025-01-08 02:45:12 | 4,900 | 1,602 | 970 | **7,472** |
| **20** | `mb370uy6ajb1` | `user_u7cey8cm` | Instagram | 2024-06-07 20:38:21 | 4,686 | 1,970 | 812 | **7,468** |

---

## 4. Platform Summary for Top 20 Posts

| Platform | Number of Top Posts | Share of Top 20 (%) | Average Total Engagement |
| :--- | :---: | :---: | :---: |
| **YouTube** | 5 | 25.0% | 7,591.60 |
| **Instagram** | 4 | 20.0% | **7,702.75** |
| **Reddit** | 4 | 20.0% | 7,588.75 |
| **Facebook** | 3 | 15.0% | 7,641.33 |
| **Unknown** | 3 | 15.0% | 7,590.00 |
| **Twitter** | 1 | 5.0% | 7,628.00 |
| **Total** | **20** | **100.0%** | **7,622.30** |

---

## 5. Extremes & Key Analytical Observations

1. **Top-20 Cohort Extremes:**
   - **Highest Total Engagement Post:** `ycjj5zzt7mvx` (Rank 1, Instagram) authored by `user_d9971ba6` with **7,893 total interactions** (4,983 likes, 1,919 shares, 991 comments).
   - **Lowest Total Engagement Post in Top 20:** `mb370uy6ajb1` (Rank 20, Instagram) authored by `user_u7cey8cm` with **7,468 total interactions** (4,686 likes, 1,970 shares, 812 comments).
   - **Cohort Mean:** The top 20 posts averaged **7,622.30 total interactions**, spanning a tight threshold range of just **425 interactions** between Rank 1 and Rank 20.

2. **Broad Multi-Platform Representation:**
   - High-impact posts were observed across all five major social platforms as well as unlabelled (`Unknown`) posts.
   - **YouTube** captured the highest count (5 posts), followed by **Instagram** (4 posts), **Reddit** (4 posts), **Facebook** (3 posts), **Unknown** (3 posts), and **Twitter** (1 post).
   - Average engagement across platforms within the top 20 varied by only **1.5%** (from 7,588.75 on Reddit to 7,702.75 on Instagram), showing that top-performing posts attained comparable engagement volumes regardless of hosting platform.

3. **Complete Engagement Reporting in Top Cohort:**
   - Exactly **0.0%** of the top 20 posts contained NULL likes, NULL shares, or NULL comments.
   - Because likes account for over 60% of total engagement, posts with missing likes naturally could not surpass the ~7,468 interaction threshold required to enter the top 20.
   - Three posts (15.0%) had NULL platform values, preserved cleanly and aggregated as `'Unknown'`.

4. **Non-Causal Interpretation:**
   - These findings strictly describe the highest-engagement posts observed in the dataset. They do not demonstrate or explain *why* these specific posts performed well, nor do they establish that publishing on any given platform causes higher total engagement.

---

## 6. Validation Results

| Verification Check | Target / Expected | Observed / Actual | Status |
| :--- | :---: | :---: | :---: |
| **Total Database Posts** | Exactly 12,000 | 12,000 | **PASS** |
| **Leaderboard Post Count** | Exactly 20 | 20 | **PASS** |
| **Post ID Uniqueness** | 20 unique post IDs | 20 unique post IDs | **PASS** |
| **Total Engagement Formula Accuracy** | $\text{likes} + \text{shares} + \text{comments}$ | Exact 100% Match | **PASS** |
| **Platform Cohort Sum** | Exactly 20 posts | 20 posts | **PASS** |
| **Raw Column Value Preservation** | NULLs preserved, no DB mutation | Preserved, no mutation | **PASS** |
| **Database Immutability Audit** | Unchanged | Unchanged (`SELECT` only) | **PASS** |

*All analytical checks passed with 100% precision.*
