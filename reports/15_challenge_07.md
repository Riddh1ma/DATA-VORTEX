# Challenge 7 — Audience Reach vs. Engagement

**Competition:** Data Vortex — Round 1 Phase 2  
**Challenge:** 07 — Audience Reach vs. Engagement  
**Database File:** `data/data_vortex.db`  
**Target Tables:** `users`, `posts`  
**Difficulty:** Medium  
**Date:** 2026-09-14  
**Status:** **COMPLETED & VALIDATED**  

---

## 1. Objective

The objective of Challenge 7 is to evaluate whether creators with larger follower counts demonstrate higher average post engagement (likes, shares, comments) or whether audience scale is decoupled from per-post interaction rates.

Specific requirements:
1. Aggregate post engagement metrics at the individual creator level (`user_id`, `location`, `follower_count`, `post_count`, `avg_likes`, `avg_shares`, `avg_comments`).
2. Categorize creators into three distinct audience-tier cohorts:
   - **Small Audience:** $< 10,000$ followers
   - **Medium Audience:** $10,000\text{–}29,999$ followers
   - **Large Audience:** $30,000+$ followers
3. Evaluate cohort-level creator distributions, audience size, post volumes, and average engagement per post.
4. Calculate the exact Pearson correlation coefficient ($r$) between `follower_count` and each interaction metric manually in standard SQLite aggregate SQL.
5. Provide non-causal interpretations regarding the relationship between audience reach and interaction performance.
6. Verify full creator population coverage ($N = 1,500$) and database immutability.

---

## 2. SQL Approach

### 1. Audience Segmentation
Creators are segmented based on `follower_count` using an ANSI SQL `CASE WHEN` expression. Two complementary aggregation levels are evaluated:
- **Post-Level Micro-Average:** Computes the true mean per post across all posts authored by creators within that cohort.
- **Creator-Level Macro-Average:** Computes the mean of creator-level averages.

### 2. Manual Pearson Correlation in SQLite
Because SQLite lacks a native `CORR()` function, Pearson's $r$ is computed manually using standard mathematical expansion:

$$r = \frac{N \sum XY - \sum X \sum Y}{\sqrt{\left[N \sum X^2 - (\sum X)^2\right] \left[N \sum Y^2 - (\sum Y)^2\right]}}$$

**Pairwise Complete Observation Handling:**
- Across all 1,500 creators, 2 creators (`user_lnbrfbja` and `user_mkqbrm43`) authored posts where all `likes` were NULL.
- Following standard statistical methodology, correlation with likes is evaluated over pairwise non-null records ($N = 1,498$), while correlation with shares and comments evaluates over the full population ($N = 1,500$).

All SQL statements are maintained in [`sql/challenge_07_audience_reach_vs_engagement.sql`](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/challenge_07_audience_reach_vs_engagement.sql).

---

## 3. Audience Group Result Table

| Audience Group | Follower Criteria | Creator Count | Share of Creators (%) | Avg Follower Count | Total Posts | Avg Likes / Post | Avg Shares / Post | Avg Comments / Post |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Small Audience** | $< 10,000$ | 287 | 19.13% | 5,208.78 | 2,293 | 2,455.22 | 1,027.14 | 498.18 |
| **Medium Audience** | $10,000\text{–}29,999$ | 619 | 41.27% | 19,859.19 | 4,960 | 2,490.97 | 1,004.31 | 510.50 |
| **Large Audience** | $30,000+$ | 594 | 39.60% | 39,828.74 | 4,747 | 2,510.75 | 1,000.51 | 500.89 |
| **Total / Overall** | — | **1,500** | **100.00%** | **24,963.91** | **12,000** | **2,491.78** | **1,007.17** | **504.35** |

*Note on Macro-Averages (Creator-Level Means):*
- **Small Audience:** 2,421.55 likes | 1,033.10 shares | 501.13 comments
- **Medium Audience:** 2,492.62 likes | 1,006.84 shares | 511.07 comments
- **Large Audience:** 2,490.07 likes | 1,001.88 shares | 501.23 comments

---

## 4. Pearson Correlation Results

| Metric Pair | Valid Pairs ($N$) | Pearson Correlation ($r$) | Direction & Strength |
| :--- | :---: | :---: | :--- |
| **Followers vs. Average Likes** | 1,498 | **+0.0168** | Negligible positive correlation ($|r| < 0.05$) |
| **Followers vs. Average Shares** | 1,500 | **-0.0428** | Negligible negative correlation ($|r| < 0.05$) |
| **Followers vs. Average Comments** | 1,500 | **-0.0005** | Virtually zero correlation ($|r| \approx 0$) |

---

## 5. Extremes & Key Observations

1. **Audience Extremes by Engagement:**
   - **Highest Average Likes:** **Large Audience** on a post-level basis (**2,510.75 likes/post**) and **Medium Audience** on a creator-average basis (**2,492.62 likes/creator**).
   - **Lowest Average Likes:** **Small Audience** (**2,455.22 likes/post** / **2,421.55 likes/creator**).
   - **Variation Spread:** The difference between the highest and lowest cohorts is only **55.53 likes per post** (a relative spread of just **2.26%**).

2. **Decoupling of Follower Count and Interaction Rates:**
   - The data shows that creators with tens of thousands of followers did not observe substantially higher per-post engagement than creators with fewer than 10,000 followers.
   - All computed Pearson correlation coefficients fall strictly within the $[-0.05, +0.05]$ interval, confirming that per-post interaction rates are essentially decoupled from audience size in this dataset.

3. **Subtle Inverse Patterns in Shares and Comments:**
   - While likes showed a minute positive association ($r = +0.0168$), shares showed a slight negative association ($r = -0.0428$), with Small Audience creators averaging **1,027.14 shares/post** compared to **1,000.51 shares/post** for Large Audience creators.
   - Comments were highest in the Medium Audience group (**510.50 comments/post**) and virtually identical between Small (**498.18**) and Large (**500.89**) tiers.

4. **Non-Causal Interpretation:**
   - These findings are descriptive of observed cross-sectional associations. The absence of strong correlation demonstrates that audience reach does not translate into higher per-post engagement rates in this platform benchmark.

---

## 6. Validation Results

| Verification Check | Target / Expected | Observed / Actual | Status |
| :--- | :---: | :---: | :---: |
| **Total Creators Represented** | Exactly 1,500 | 1,500 | **PASS** |
| **Audience Group Counts Sum** | Exactly 1,500 ($287 + 619 + 594$) | 1,500 | **PASS** |
| **Sum of Percentage Shares** | 100.00% ($\approx 100\%$) | 100.00% | **PASS** |
| **Lost / Unclassified Creators** | 0 | 0 | **PASS** |
| **Total Post Volume Sum** | Exactly 12,000 | 12,000 | **PASS** |
| **Database Immutability Audit** | Unchanged | Unchanged (`SELECT` only) | **PASS** |

*All analytical checks passed with 100% precision.*
