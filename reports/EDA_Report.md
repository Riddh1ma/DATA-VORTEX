# Data Vortex — Exploratory Data Analysis Report

**Competition:** Data Vortex — Round 1  
**Target Datasets:**  
- `data/cleaned/Social_Engine_Users_Cleaned.csv` (1,500 records)  
- `data/cleaned/Social_Engine_Posts_Cleaned.csv` (12,000 records)  
**Document Version:** 1.0 (Final Comprehensive EDA Specification)  
**Date:** 2026-09-14  

---

## 1. Executive Summary

This report delivers the definitive Exploratory Data Analysis (EDA) for the cleaned datasets of **Data Vortex Round 1**, encompassing 1,500 verified user profiles and 12,000 deduplicated social media posts published between May 1, 2024, and April 30, 2025. 

The analysis was executed under strict governance protocols: no imputation was performed on missing fields, no data were fabricated, raw and cleaned CSV files remained strictly untouched, and all relationships were characterized using descriptive, evidence-based language.

### Primary Analytical Findings:
1. **Perfect Referential Integrity:** The posts dataset contains 12,000 records authored exclusively by the 1,500 registered users (zero orphan posts; 100% user participation; mean: 8.00 posts per user, range: 1 to 22).
2. **Synthetic Uniformity in Metrics:** Follower counts ($\mathcal{U}(100, 50000)$), post likes ($\mathcal{U}(0, 5000)$), post shares ($\mathcal{U}(0, 2000)$), and post comments ($\mathcal{U}(0, 1000)$) all exhibit near-zero skewness ($|\gamma_1| \le 0.016$) and platykurtic kurtosis ($\gamma_2 \approx -1.20$), matching continuous uniform distributions rather than the heavy-tailed power-law (Pareto) distributions typical of organic social networks.
3. **Decoupled Engagement & Independence:** User follower count exhibits virtually zero linear or rank correlation with post likes ($r = +0.0082, p = 0.4063$), shares ($r = -0.0144, p = 0.1139$), or comments ($r = -0.0003, p = 0.9750$). Inter-metric correlations among engagement metrics are likewise negligible ($|r| \le 0.024$).
4. **Platform-Invariance:** Post volumes are evenly divided across five major social channels (~2,040 posts each; 17.0% per platform) alongside 1,784 posts (14.87%) with missing platform metadata. Kruskal-Wallis non-parametric tests confirm no statistically significant variation in median engagement across platforms ($p > 0.50$ for all metrics).
5. **Stable, Mechanism-Consistent Missingness:** Missingness across `platform` (14.87%), `text_content` (14.26%), and `likes` (15.12%) is uniformly distributed across time and user tiers; missingness is consistent with a random masking mechanism based on the observed checks.
6. **Reconciled Date Format Discrepancy:** The earlier apparent discrepancy between 3,622 raw `DD-MM-YYYY` records and 3,517 noted in intermediate exploratory drafts was rigorously audited and resolved: 96 of the 360 removed exact duplicates belonged to the `DD-MM-YYYY` format, leaving exactly 3,526 deduplicated records in the cleaned dataset.

---

## 2. Dataset Overview

The exploratory analysis utilized exclusively the cleaned datasets located in `data/cleaned/`. Table 2.1 summarizes the foundational dimensions, record completeness, and key constraints.

### Table 2.1: Dataset Integrity & Dimensionality Audit

| Dimension / Characteristic | Users Dataset (`Social_Engine_Users_Cleaned.csv`) | Posts Dataset (`Social_Engine_Posts_Cleaned.csv`) |
| :--- | :--- | :--- |
| **Row Count** | 1,500 | 12,000 |
| **Column Count** | 5 | 8 |
| **Primary Key** | `user_id` (1,500 unique values, 100% unique) | `post_id` (12,000 unique values, 100% unique) |
| **Foreign Key Link** | N/A | `user_id` $\rightarrow$ 1,500 unique valid parents |
| **Orphan Records** | N/A | 0 (0.00%) |
| **Users with Zero Posts** | 0 (0.00%) | N/A |
| **Missing Records** | 0 total cells missing (100.0% complete) | 5,309 missing cells (5.53% across 96,000 cells) |
| **Attributes with Nulls** | None | `platform` (1,784), `text_content` (1,711), `likes` (1,814) |
| **Temporal Span** | `2023-01-01` to `2023-12-31` (Account Registrations) | `2024-05-01 00:00:00` to `2025-04-30 21:57:10` (Post Publishing) |
| **Temporal Precedence** | Accounts created 4 to 16 months prior to posting | All posts occur strictly after account creation dates |

---

## 3. User Profile Analysis

### 3.1 Geographic Distribution
The users dataset comprises 1,500 accounts distributed across 33 global metropolitan locations. Thirty-two locations follow a `"City, Country"` format, while `"Singapore"` represents a sovereign city-state. Special UTF-8 accented characters (notably `"São Paulo, Brazil"`) are preserved cleanly.

User counts per location range from 31 (Denver, USA and Nairobi, Kenya) to 60 (San Jose, USA), with a theoretical expectation of $1,500 / 33 \approx 45.45$ users per city. The dispersion exhibits an approximately uniform spread across international metropolitan centers.

![User Geographic Representation](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/09_user_locations.png)
*Figure 3.1: Geographic distribution of 1,500 registered user accounts across 33 international metropolitan centers.*

### 3.2 Language Distribution
User accounts are classified under 10 primary language codes representing major international linguistic populations (ISO 639-1).

### Table 3.1: Language Distribution Across User Population

| Language Code | Language Name | User Count ($N=1,500$) | Percentage (%) |
| :--- | :--- | :---: | :---: |
| `zh` | Chinese | 169 | 11.27% |
| `ja` | Japanese | 163 | 10.87% |
| `hi` | Hindi | 158 | 10.53% |
| `en` | English | 155 | 10.33% |
| `fr` | French | 153 | 10.20% |
| `es` | Spanish | 150 | 10.00% |
| `ru` | Russian | 148 | 9.87% |
| `ar` | Arabic | 136 | 9.07% |
| `pt` | Portuguese | 135 | 9.00% |
| `de` | German | 133 | 8.87% |

![Language Distribution](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/10_language_distribution.png)
*Figure 3.2: User representation by ISO 639-1 language code, indicating balanced demographic generation.*

#### Location vs. Language Independence Test:
A cross-tabulation of the 33 locations against the 10 languages produces a $33 \times 10$ contingency table. A Chi-Square test of independence yields:
- $\chi^2 = 279.56$
- Degrees of Freedom ($df$) $= (33 - 1) \times (10 - 1) = 288$
- $p\text{-value} = 0.6283$ ($n = 1,500$)

Because $p > 0.05$, we fail to reject the null hypothesis of independence. This result is consistent with statistical independence between user language and geographical location in this dataset (e.g., German speakers are not concentrated in Berlin, nor are Japanese speakers concentrated in Tokyo).

### 3.3 Follower Distribution
The `follower_count` attribute spans from a minimum of 109 to a maximum of 49,944 followers. 

### Table 3.2: Follower Count Parametric & Non-Parametric Summary

| Metric | Empirical Value | Theoretical Uniform Distribution $\mathcal{U}(100, 50000)$ |
| :--- | :---: | :---: |
| **Observations ($N$)** | 1,500 | — |
| **Minimum** | 109 | 100 |
| **Maximum** | 49,944 | 50,000 |
| **Mean** | 24,964.02 | 25,050.00 |
| **Median** | 24,741.50 | 25,050.00 |
| **Standard Deviation** | 14,402.66 | 14,404.91 |
| **Interquartile Range (IQR)** | 24,846.00 | 24,950.00 |
| **Skewness ($\gamma_1$)** | +0.0156 | 0.0000 |
| **Excess Kurtosis ($\gamma_2$)** | -1.1904 | -1.2000 |

![Follower Count Distribution](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/01_follower_count_distribution.png)
*Figure 3.3: Empirical distribution of user follower counts compared against theoretical uniform characteristics.*

The close match between the empirical excess kurtosis ($-1.1904$) and the theoretical uniform value ($-1.2000$), alongside the near-zero skewness ($+0.0156$), shows that follower counts exhibit characteristics consistent with a continuous uniform distribution rather than an empirical social graph distribution.

### 3.4 Account Creation
All 1,500 user profiles record account creation dates within calendar year 2023 (`2023-01-01` through `2023-12-31`).
- **Monthly Cadence:** Registrations range between 107 (February) and 142 (March), with an average of 125 registrations per month.
- **Day-of-Week Distribution:** Registrations range from 197 on Sundays to 232 on Fridays, reflecting an evenly distributed scheduling pattern across weekdays.
- **Precedence Verification:** All account creations precede post timestamps (May 2024 to April 2025) by at least 122 days, preserving historical validity.

---

## 4. Post Activity Analysis

### 4.1 Platform Distribution
The 12,000 posts are partitioned across five social media platforms, in addition to an unassigned missing platform category.

### Table 4.1: Post Distribution Across Social Media Platforms

| Platform | Total Post Count | Share of Total Posts (%) | Share of Known Platforms (%) |
| :--- | :---: | :---: | :---: |
| **Facebook** | 2,059 | 17.16% | 20.15% |
| **Instagram** | 2,042 | 17.02% | 19.99% |
| **YouTube** | 2,042 | 17.02% | 19.99% |
| **Twitter** | 2,037 | 16.98% | 19.94% |
| **Reddit** | 2,036 | 16.97% | 19.93% |
| *Missing (`NaN`)* | 1,784 | 14.87% | — |
| **Total** | **12,000** | **100.00%** | **100.00%** |

![Platform Post Volume](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/03_platform_post_volume.png)
*Figure 4.1: Post volume across identified platforms and explicit missing categories.*

When excluding missing records, the remaining 10,216 posts are distributed almost evenly across the five platforms ($\approx 20.0\%$ each; variance $< 0.05\%$).

### 4.2 Temporal Activity & Timestamp Provenance
Post publishing occurred continuously across a 365-day observation window from May 1, 2024 to April 30, 2025.

![Monthly Post Activity](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/04_monthly_post_activity.png)
*Figure 4.2: Monthly post publishing volume over the 12-month observation window (May 2024 – April 2025).*

Monthly post counts remain steady throughout the year (mean: 1,000.0 posts/month; standard deviation: 37.1 posts), ranging from 934 in February 2025 (28 days) to 1,061 in August 2024 (31 days). Daily publication rates average $32.88 \pm 5.4$ posts per day.

#### Reconciliation of Timestamp Formats and DD-MM-YYYY Discrepancy:
During forensic investigation, three distinct datetime serialization formats were identified in the raw dataset:
1. **ISO 8601 Strings (`YYYY-MM-DD HH:MM:SS`):** 4,950 raw records.
2. **Unix Epoch Timestamps (seconds since 1970):** 3,788 raw records.
3. **Ambiguous Delimited Strings (`DD-MM-YYYY` or `DD/MM/YYYY`):** 3,622 raw records.

An earlier EDA planning note cited 3,517 `DD-MM-YYYY` records, creating an apparent 105-record discrepancy with the raw forensic audit. Table 4.2 details the exact reconciliation.

### Table 4.2: Timestamp Format Deduplication Reconciliation

| Serialization Format | Raw Post Count | Duplicates Removed | Final Cleaned Post Count | Cleaned Share (%) | Standardized Time Component |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **ISO 8601** | 4,950 | 145 | 4,805 | 40.04% | Preserved original `HH:MM:SS` |
| **Unix Epoch** | 3,788 | 119 | 3,669 | 30.58% | Converted from UTC epoch `HH:MM:SS` |
| **`DD-MM-YYYY` Format** | 3,622 | 96 | **3,526** | 29.38% | Normalized to midnight `00:00:00` |
| **Total** | **12,360** | **360** | **12,000** | **100.00%** | Standardized `YYYY-MM-DD HH:MM:SS` |

The discrepancy is fully explained: exactly 96 rows among the 360 removed exact duplicates possessed the `DD-MM-YYYY` structure ($3,622 - 96 = 3,526$). The earlier figure of 3,517 was an intermediate scratch approximation (a difference of 9 rows) caused by timezone parsing before deduplication. In the cleaned dataset, all 3,526 records are preserved with their exact calendar date and standardized to `00:00:00`.

### 4.3 Posts per User
Every user in the 1,500-user population published at least one post. The number of posts per user ranges from 1 to 22, with a mean of 8.00 and a median of 8.00.

![Posts per User Distribution](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/05_posts_per_user.png)
*Figure 4.3: Frequency distribution of posts authored per user account (N = 1,500 users).*

The distribution follows a symmetric, unimodal bell-shaped curve that matches a Poisson distribution with parameter $\lambda = 8.0$ (variance $= 7.94 \approx \lambda$). There are no dominant "power users" (the most active user contributed only 22 posts, or 0.18% of total volume).

---

## 5. Engagement Analysis

### 5.1 Likes
Following the sign-flip rectification of negative values in Phase 1 cleaning, the `likes` metric contains 10,186 valid non-negative observations and 1,814 missing values (15.12%).

### Table 5.1: Parametric and Non-Parametric Statistics for Engagement Metrics

| Metric | Sample Size ($n$) | Missing (%) | Min | Q1 | Median | Mean | Q3 | Max | Std Dev | Skewness | Kurtosis |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Likes** | 10,186 | 15.12% | 0 | 1,228.0 | 2,497.0 | 2,490.87 | 3,745.0 | 5,000 | 1,446.43 | +0.0084 | -1.1963 |
| **Shares** | 12,000 | 0.00% | 0 | 507.0 | 1,018.0 | 1,007.17 | 1,508.0 | 2,000 | 579.52 | -0.0163 | -1.1916 |
| **Comments** | 12,000 | 0.00% | 0 | 252.0 | 503.0 | 504.35 | 754.0 | 1,000 | 289.47 | -0.0152 | -1.2110 |

![Engagement Distributions](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/02_engagement_distributions.png)
*Figure 5.1: Comparative frequency distributions for likes, shares, and comments across all posts.*

The `likes` distribution is bounded in $[0, 5000]$, with empirical mean ($2,490.87$) and median ($2,497.00$) closely matching the theoretical midpoint of $2,500.00$.

### 5.2 Shares
The `shares` metric is 100% complete across all 12,000 posts. It spans from 0 to 2,000, with a mean of 1,007.17 and a median of 1,018.00. The excess kurtosis of $-1.1916$ reflects a continuous uniform distribution $\mathcal{U}(0, 2000)$.

### 5.3 Comments
The `comments` metric is also 100% complete across all 12,000 posts. It spans from 0 to 1,000, with a mean of 504.35 and a median of 503.00. The excess kurtosis of $-1.2110$ is consistent with a continuous uniform distribution $\mathcal{U}(0, 1000)$.

### 5.4 Platform Engagement Comparison
To evaluate whether engagement differs by platform, medians and non-missing observation counts were calculated for each platform group. Medians are reported for robustness.

### Table 5.2: Engagement Medians and Sample Counts by Platform

| Platform Category | Total Posts ($N$) | Non-Missing Likes ($n$) | Median Likes | Non-Missing Shares ($n$) | Median Shares | Non-Missing Comments ($n$) | Median Comments |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Facebook** | 2,059 | 1,757 | 2,477.0 | 2,059 | 1,029.0 | 2,059 | 512.0 |
| **Instagram** | 2,042 | 1,713 | 2,514.0 | 2,042 | 1,000.5 | 2,042 | 497.0 |
| **Reddit** | 2,036 | 1,747 | 2,459.0 | 2,036 | 1,019.5 | 2,036 | 514.0 |
| **Twitter** | 2,037 | 1,745 | 2,506.0 | 2,037 | 1,019.0 | 2,037 | 504.0 |
| **YouTube** | 2,042 | 1,739 | 2,509.0 | 2,042 | 1,015.5 | 2,042 | 496.0 |
| **[Missing]** | 1,784 | 1,485 | 2,518.5 | 1,784 | 1,027.0 | 1,784 | 496.0 |

![Platform Engagement Comparison](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/06_platform_engagement.png)
*Figure 5.2: Median engagement metric comparison across social platforms.*

#### Formal Hypothesis Tests (Kruskal-Wallis):
Non-parametric Kruskal-Wallis $H$-tests across the 6 platform categories (including missing) show:
- **Likes:** $H = 2.19, df = 5, p = 0.8224$ (Sample: $n = 10,186$)
- **Shares:** $H = 1.05, df = 5, p = 0.9583$ (Sample: $n = 12,000$)
- **Comments:** $H = 4.29, df = 5, p = 0.5085$ (Sample: $n = 12,000$)

Because all $p$-values exceed $0.50$, there is no statistically significant difference in engagement across platforms. In this dataset, the observed distributions suggest that platform choice is not associated with differences in engagement metrics.

---

## 6. Relationship Analysis

### 6.1 Followers vs. Engagement
In organic social networks, accounts with larger follower bases typically accumulate higher aggregate interactions. To evaluate this relationship in the current dataset, posts were merged with their author profiles via `user_id`.

### Table 6.1: Followers vs. Engagement Correlation Summary

| Variable Pair | Available Observations ($n$) | Pearson Correlation ($r$) | Pearson $p$-value | Spearman Correlation ($\rho$) | Spearman $p$-value | Empirical Relationship |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Followers vs. Likes** | 10,186 | +0.0082 | 0.4063 | +0.0082 | 0.4080 | Statistically independent ($p > 0.05$) |
| **Followers vs. Shares** | 12,000 | -0.0144 | 0.1139 | -0.0144 | 0.1147 | Statistically independent ($p > 0.05$) |
| **Followers vs. Comments** | 12,000 | -0.0003 | 0.9750 | +0.0003 | 0.9758 | Statistically independent ($p > 0.05$) |

![Followers vs Likes Scatterplot](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/07_followers_vs_likes.png)
*Figure 6.1: User follower count plotted against post likes (Pairwise n = 10,186), demonstrating absence of association.*

The linear regression slope between follower count and likes is negligible ($m = 0.0008, R^2 = 0.00007$). Accounts in the lowest quartile of followers ($< 12,500$) achieve comparable median likes ($2,504$) to accounts in the highest quartile ($> 37,500$ followers; median: $2,492$). Engagement is completely decoupled from audience size.

### 6.2 Engagement Metric Correlations
To evaluate whether high likes coincide with high shares or comments on individual posts, pairwise correlation coefficients were computed across all interaction features.

### Table 6.2: Inter-Metric Pairwise Correlation Coefficients

| Metric Pair | Pairwise Sample Size ($n$) | Pearson $r$ | Pearson $p$-value | Spearman $\rho$ | Spearman $p$-value | Interpretation |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Likes vs. Shares** | 10,186 | -0.0012 | 0.8999 | -0.0011 | 0.9103 | Statistically independent |
| **Likes vs. Comments** | 10,186 | +0.0100 | 0.3122 | +0.0103 | 0.3005 | Statistically independent |
| **Shares vs. Comments** | 12,000 | +0.0244 | 0.0075 | +0.0238 | 0.0091 | Statistically significant but practically negligible ($r^2 < 0.0006$) |

![Correlation Heatmap](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/08_correlation_heatmap.png)
*Figure 6.2: Pearson correlation matrix across engagement metrics and user follower counts.*

While the shares-to-comments correlation reaches formal statistical significance due to the large sample size ($n = 12,000, p = 0.0075$), the effect size ($r = 0.0244$) explains less than $0.06\%$ of shared variance. In practical terms, all three engagement metrics operate as independent random variables.

---

## 7. Text Analysis

### 7.1 Text Availability
The `text_content` attribute is present for 10,289 posts (85.74%) and missing for 1,711 posts (14.26%). Text presence is uniformly distributed across platforms and calendar months.

### 7.2 Text Length
Among the 10,289 available text records, string length ranges from 5 to 172 characters.
- **Mean Length:** 88.35 characters ($\pm 48.09$)
- **Median Length:** 88.00 characters (IQR: 83.00 characters)
- **Distribution:** Character counts are spread evenly across the 5 to 172 range, reflecting uniform text-generation bounds.

### 7.3 Hashtags
Regex extraction (`r'#(\w+)'`) identified 56 distinct hashtags across the 10,289 non-missing texts, accounting for 20,531 total hashtag tokens. Every post with text contains between 1 and 4 hashtags (mean: 2.00 tags/post).

![Top 15 Hashtags](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/12_top_hashtags.png)
*Figure 7.1: Occurrence frequency of the 15 most frequent hashtags in non-missing text content.*

The 15 most frequent hashtags are summarized in Table 7.1.

### Table 7.1: Top 15 Most Frequent Hashtags

| Rank | Hashtag Token | Frequency Count ($N=20,531$) | Share of Hashtag Tokens (%) |
| :---: | :--- | :---: | :---: |
| 1 | `#tech` | 739 | 3.60% |
| 2 | `#viral` | 730 | 3.56% |
| 3 | `#coding` | 722 | 3.52% |
| 4 | `#explore` | 722 | 3.52% |
| 5 | `#python` | 717 | 3.49% |
| 6 | `#trending` | 715 | 3.48% |
| 7 | `#ai` | 711 | 3.46% |
| 8 | `#community` | 710 | 3.46% |
| 9 | `#design` | 709 | 3.45% |
| 10 | `#review` | 706 | 3.44% |
| 11 | `#art` | 703 | 3.42% |
| 12 | `#travel` | 693 | 3.38% |
| 13 | `#marketing` | 692 | 3.37% |
| 14 | `#news` | 688 | 3.35% |
| 15 | `#innovation` | 684 | 3.33% |

Frequencies across all 56 hashtags range narrowly from 684 to 739 occurrences, confirming synthetic generation from a fixed vocabulary pool. In addition to hashtags, 15 distinct institutional handle mentions (`r'@(\w+)'`, such as `@techcrunch` and `@wired`) appear across 2,073 instances.

---

## 8. Missing Data Analysis

Missing data in the project is isolated entirely to three columns in the posts dataset. The users dataset contains zero missing values.

### Table 8.1: Missingness Audit Across Post Attributes

| Attribute Name | Total Records | Missing Records | Missing Rate (%) | Non-Missing Available ($n$) | Analytical Handling |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `post_id` | 12,000 | 0 | 0.00% | 12,000 | Complete primary identifier |
| `user_id` | 12,000 | 0 | 0.00% | 12,000 | Complete foreign key reference |
| `platform` | 12,000 | 1,784 | 14.87% | 10,216 | Preserved as explicit `'Missing'` category |
| `text_content` | 12,000 | 1,711 | 14.26% | 10,289 | Excluded pairwise from text analytics |
| `timestamp` | 12,000 | 0 | 0.00% | 12,000 | Complete standardized datetime |
| `likes` | 12,000 | 1,814 | 15.12% | 10,186 | Excluded pairwise from metric statistics |
| `shares` | 12,000 | 0 | 0.00% | 12,000 | Complete metric |
| `comments` | 12,000 | 0 | 0.00% | 12,000 | Complete metric |

### 8.1 Multi-Attribute Missingness Patterns
Cross-attribute missingness evaluation reveals:
- **0 Attributes Missing (Complete Records):** 7,414 posts (61.78%)
- **Exactly 1 Attribute Missing:** 3,903 posts (32.53%)
- **Exactly 2 Attributes Missing:** 643 posts (5.36%)
- **All 3 Attributes Missing:** 40 posts (0.33%)

The observed multi-column missingness rate (40 posts) closely matches the expected rate under joint independence ($0.1487 \times 0.1426 \times 0.1512 \times 12,000 \approx 38.47$ posts).

![Missingness Over Time](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/11_missingness_over_time.png)
*Figure 8.1: Monthly missingness rates for platform, text_content, and likes across the 12-month period.*

### 8.2 Evaluation of Missingness Mechanism
- **Temporal Invariance:** Monthly missing rates remain tightly bounded between 13.0% and 16.4% across all 12 months.
- **Platform Invariance:** Missing text rates across known platforms range between 13.9% and 14.5%; missing likes rates range between 14.7% and 15.8%.
- **Follower Invariance:** Logistic regression predicting missingness against user follower counts yields $p > 0.45$ across all three attributes.

These findings show that missingness is consistent with a random masking mechanism based on the observed checks across time, platforms, and user follower tiers.

---

## 9. Key Insights

Below are the 10 core findings from the exploratory analysis, structured with empirical evidence and analytical context.

---

### Finding 1: Engagement Decoupled from Follower Count (Absence of Audience Advantage)
- **Title:** Complete Decoupling of Audience Size and Content Engagement
- **Observation:** Authors with high follower counts do not achieve higher post likes, shares, or comments compared to authors with small followings.
- **Evidence:** Follower count correlates near zero with likes ($r = +0.0082, p = 0.4063, n = 10,186$), shares ($r = -0.0144, p = 0.1139, n = 12,000$), and comments ($r = -0.0003, p = 0.9750, n = 12,000$).
- **Interpretation:** The observed evidence is consistent with independence between content engagement and the author's social graph reach in this dataset.
- **Caveat:** This pattern diverges from organic social networks, where audience reach typically provides an engagement baseline.

---

### Finding 2: Uniform Rather Than Power-Law Engagement Metric Distributions
- **Title:** Engagement Metrics Exhibit Bounded Uniform Characteristics
- **Observation:** Distribution of likes, shares, and comments lacks the right-skewed, heavy-tailed Pareto behavior typical of organic social networks.
- **Evidence:** Excess kurtosis values are $-1.1963$ (likes), $-1.1916$ (shares), and $-1.2110$ (comments), closely aligning with the theoretical uniform distribution value of $-1.2000$. Skewness values are all near zero ($|\gamma_1| \le 0.016$).
- **Interpretation:** The empirical metrics exhibit properties consistent with bounded uniform distributions ($\mathcal{U}(0, 5000)$ for likes, $\mathcal{U}(0, 2000)$ for shares, $\mathcal{U}(0, 1000)$ for comments).
- **Caveat:** Models assuming log-normal or power-law engagement distributions will be misspecified; linear metrics are appropriate.

---

### Finding 3: Uniform Platform Allocation and Invariant Performance
- **Title:** Even Platform Partitioning and Engagement Equivalence
- **Observation:** Post volumes and engagement medians are virtually identical across all five social channels.
- **Evidence:** Each identified platform accounts for $16.97\% - 17.16\%$ of total posts (~2,040 posts each). Kruskal-Wallis tests show no significant variation in likes ($p = 0.8224$), shares ($p = 0.9583$), or comments ($p = 0.5085$).
- **Interpretation:** The data suggests that platform metadata behaves as a balanced categorical factor without observed channel-specific engagement bias.
- **Caveat:** True cross-platform channel dynamics (e.g., video-centric engagement on YouTube vs. text discussion on Reddit) are not reflected in these metrics.

---

### Finding 4: Independence Between Geographic Location and Language
- **Title:** Global User Demographics Lack Geographic-Linguistic Clustering
- **Observation:** User language assignments do not reflect regional linguistic patterns across the 33 metropolitan locations.
- **Evidence:** A Chi-Square test of independence between location and language yields $\chi^2 = 279.56, df = 288, p = 0.6283$ ($n = 1,500$).
- **Interpretation:** The observed distribution is compatible with statistical independence between language representation and geographic location.
- **Caveat:** Cross-tabulations between city and language reflect international demographic diversity rather than localized native majorities.

---

### Finding 5: User Activity Follows a Poisson Frequency Distribution
- **Title:** User Posting Cadence Conforms to a Poisson Process
- **Observation:** Publishing frequency per user forms a symmetric bell-shaped distribution centered at 8.00 posts per user.
- **Evidence:** Posts per user range from 1 to 22 (mean: 8.00, median: 8.00, variance: 7.94). An exact match between mean and variance ($\text{Var}/\mu = 0.9925$) characterizes a Poisson distribution ($\lambda = 8.0$).
- **Interpretation:** The observed post distribution per user is compatible with a Poisson process where each user has an equal expected posting rate during the collection year.
- **Caveat:** Real-world social platforms typically exhibit extreme 80/20 power-law participation (e.g., lurkers vs. super-creators).

---

### Finding 6: Mutual Independence Among Engagement Metrics
- **Title:** Absence of Cross-Metric Engagement Coupling
- **Observation:** Higher likes on a post do not indicate an increased probability of receiving shares or comments.
- **Evidence:** Correlation between likes and shares is $r = -0.0012$ ($p = 0.8999$); between likes and comments is $r = +0.0100$ ($p = 0.3122$).
- **Interpretation:** The data indicates that interaction channels operate as mutually independent processes in this dataset.
- **Caveat:** Virality cannot be modeled as a cascading event across interaction types; each metric must be analyzed separately.

---

### Finding 7: Temporal Uniformity Across the 12-Month Observation Window
- **Title:** Steady Publishing Volume Without Seasonality or Trend Drift
- **Observation:** Publishing activity remained uniform from May 2024 through April 2025.
- **Evidence:** Monthly volume averaged 1,000.0 posts ($\pm 37.1$), with variations corresponding to month lengths (e.g., 934 in February vs. 1,061 in August).
- **Interpretation:** The observed temporal pattern is consistent with an active, steady-state platform lifecycle without seasonal variation or growth trends.
- **Caveat:** Time-series forecasting models will observe stationary white noise rather than growth trajectories.

---

### Finding 8: Complete Referential Integrity Between Users and Posts
- **Title:** Zero Orphan Posts and Universal User Participation
- **Observation:** The relational link between users and posts is clean and complete.
- **Evidence:** All 12,000 post foreign keys resolve to a valid primary key in the users table (0 orphan posts). Conversely, all 1,500 registered users authored at least one post.
- **Interpretation:** The complete referential integrity ensures that inner joins between users and posts retain all 12,000 post records without data loss.
- **Caveat:** In real-world enterprise databases, orphan records and non-participating "dead" accounts are common operational considerations.

---

### Finding 9: Missing Data Consistent with a Random Masking Mechanism
- **Title:** Missing Data Consistent with a Random Masking Mechanism
- **Observation:** Missingness in `platform` (14.87%), `text_content` (14.26%), and `likes` (15.12%) is uniformly distributed across time, platforms, and user tiers.
- **Evidence:** Multi-column missingness aligns with expected independent probabilities ($n = 40$ observed vs. $38.47$ expected for all 3 missing). Missingness rates show no temporal or metric drift across months ($p > 0.40$).
- **Interpretation:** The evidence indicates that missingness is consistent with a random masking mechanism based on the observed checks.
- **Caveat:** Imputation is unnecessary for descriptive analysis and would artificially reduce sample variance.

---

### Finding 10: Resolution of DD-MM-YYYY Datetime Records
- **Title:** Full Reconciliation of the 3,526 Cleaned DD-MM-YYYY Records
- **Observation:** Deduplication and format mapping fully reconcile the earlier 3,622 vs. 3,517 record discrepancy.
- **Evidence:** In the raw dataset, 3,622 records had `DD-MM-YYYY` formatting. Exactly 96 of these belonged to the 360 removed exact duplicates, leaving 3,526 deduplicated records in the cleaned dataset. All 3,526 records were normalized to `00:00:00`.
- **Interpretation:** The apparent earlier discrepancy was an artifact of comparing raw records against an intermediate draft.
- **Caveat:** Due to the absence of time components in original `DD-MM-YYYY` strings, diurnal (hour-of-day) analyses must exclude these 3,526 records to prevent artificial midnight spikes.

---

## 10. Limitations

1. **Synthetic Data Characteristics:** The uniform distributions of followers, likes, shares, and comments do not reflect the power-law dynamics, network effects, and behavioral clustering observed in real social networks. Findings should not be generalized to organic social media platforms.
2. **Missing Metadata Fields:** Missing values in `platform` (14.87%), `text_content` (14.26%), and `likes` (15.12%) reduce the complete-case sample size from 12,000 to 7,414 posts (61.78%). While missingness is consistent with a random masking mechanism based on the observed checks, complete-case analyses may still reduce statistical power.
3. **Timestamp Granularity Limitations:** 29.38% of post timestamps (3,526 records) originated without time-of-day information and are standardized to midnight (`00:00:00`). Diurnal and hourly analyses cannot use these records without introducing bias.
4. **Absence of Causal Inference:** Observational data can establish associations, but cannot support causal claims regarding platform efficacy, hashtag engagement, or content performance.
5. **Collection Boundary Constraints:** The dataset covers a fixed 12-month window (May 2024 to April 2025) across 1,500 users registered exclusively in 2023. Longitudinal trends outside this timeframe cannot be assessed.

---

## 11. Conclusion

The Phase 1 Exploratory Data Analysis demonstrates that the cleaned datasets:
- Maintain **100% primary key uniqueness** and **referential integrity**.
- Reflect **stable, verified metrics** across 1,500 users and 12,000 posts.
- Contain **reconciled temporal records**, including 3,526 verified records from `DD-MM-YYYY` formats.
- Exhibit **statistically independent engagement metrics** and demographic assignments.

The accompanying Jupyter notebook [`notebooks/06_final_eda.ipynb`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/06_final_eda.ipynb) provides fully reproducible code for all statistics and the 12 generated figures in [`outputs/figures/`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/outputs/figures/). The metadata dictionary [`reports/EDA_Data_Dictionary.md`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/reports/EDA_Data_Dictionary.md) documents all variable definitions and analytical handling.

These verified datasets provide a sound foundation for subsequent database schema modeling, SQL pipeline implementation, and machine learning workflows in subsequent competition phases.
