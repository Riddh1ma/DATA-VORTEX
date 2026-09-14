# Phase 1: Exploratory Data Analysis (EDA) Report

**Competition:** Data Vortex - Round 1  
**Execution Date:** 2026-09-14  
**Source Cleaned Datasets:**  
- [data/cleaned/Social_Engine_Users_Cleaned.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/cleaned/Social_Engine_Users_Cleaned.csv) (1,500 rows)  
- [data/cleaned/Social_Engine_Posts_Cleaned.csv](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/data/cleaned/Social_Engine_Posts_Cleaned.csv) (12,000 rows)  
**Notebook Reference:** [notebooks/05_eda_analysis.ipynb](file:///c:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/05_eda_analysis.ipynb)  

---

## 1. Dataset Overview

| Attribute | Users Dataset (`Social_Engine_Users_Cleaned.csv`) | Posts Dataset (`Social_Engine_Posts_Cleaned.csv`) | Relational Linkage |
| :--- | :--- | :--- | :--- |
| **Row Count** | 1,500 records | 12,000 records | 1:N relationship (Mean = 8.24 posts/user) |
| **Column Count** | 5 columns | 8 columns | Linked via primary/foreign key `user_id` |
| **Unique Entities** | 1,500 unique users | 12,000 unique posts | 0 orphan posts; 0 unrepresented users |
| **Primary Keys** | `user_id` (`user_[a-z0-9]{8}`) | `post_id` (`[a-z0-9]{12}`) | 100% unique primary keys in both tables |
| **Missing Values** | 0 missing values (0.00%) | `platform`: 1,784 (14.87%)<br>`text_content`: 1,711 (14.26%)<br>`likes`: 1,814 (15.12%) | Preserved as standard nulls without imputation |
| **Observation Window** | `2023-01-01` to `2023-12-31` | `2024-05-01 00:00:00` to `2025-04-30 21:57:10` | Posts occur strictly after account creation |

---

## 2. User Demographic & Profile Analysis

### 2.1 Geographic Distribution (`location`)
- **Total Locations:** 33 unique global metropolitan hubs.
- **Top Locations by Population:**
  1. `Barcelona, Spain`: 56 users (3.73%)
  2. `Shanghai, China`: 56 users (3.73%)
  3. `Los Angeles, USA`: 55 users (3.67%)
  4. `Munich, Germany`: 54 users (3.60%)
  5. `Dubai, UAE`: 53 users (3.53%)
  6. `Mumbai, India`: 53 users (3.53%)
  7. `Milan, Italy`: 53 users (3.53%)
  8. `Melbourne, Australia`: 52 users (3.47%)
  9. `Beijing, China`: 51 users (3.40%)
  10. `Houston, USA` / `Chicago, USA` / `Osaka, Japan`: 50 users each (3.33%)
- **Bottom Locations:** `Sydney, Australia` (28 users, 1.87%), `Lagos, Nigeria` (30 users, 2.00%), `Madrid, Spain` (36 users, 2.40%), `Seoul, South Korea` (36 users, 2.40%).
- **Key Observation:** Geographic representation is broadly uniform, with each city contributing between 1.9% and 3.7% of the total user base.

### 2.2 Language Distribution (`language`)
- **Total Languages:** 10 unique ISO 639-1 language codes.
- **Breakdown:**
  - `zh` (Chinese): 168 users (11.20%)
  - `ja` (Japanese): 156 users (10.40%)
  - `hi` (Hindi): 156 users (10.40%)
  - `en` (English): 153 users (10.20%)
  - `fr` (French): 150 users (10.00%)
  - `es` (Spanish): 146 users (9.73%)
  - `ru` (Russian): 144 users (9.60%)
  - `ar` (Arabic): 143 users (9.53%)
  - `pt` (Portuguese): 143 users (9.53%)
  - `de` (German): 141 users (9.40%)
- **Key Observation:** The 10 language categories are uniformly distributed across the user population (~10% each), characteristic of synthetic benchmark data.

### 2.3 Follower Count Distribution (`follower_count`)
- **Summary Metrics:**
  - **Count:** 1,500 users
  - **Mean:** 24,964.02 | **Median:** 24,741.50 | **Std Dev:** 14,185.48
  - **Min:** 109 | **Max:** 49,944
  - **Percentiles:** 10th = 5,647.60 | 25th (Q1) = 12,771.75 | 50th = 24,741.50 | 75th (Q3) = 37,097.25 | 90th = 44,377.60
- **Distribution Characterization:**
  - **Skewness:** $+0.0156$ (near perfectly symmetric)
  - **Kurtosis:** $-1.1904$ (theoretical continuous uniform distribution kurtosis is exactly $-1.2000$)
  - **Finding:** The follower count distribution is continuous uniform $\mathcal{U}(100, 50000)$. There are zero power-law dynamics, zero negative values, and zero statistical outliers.

### 2.4 Account Creation Trends (`account_created`)
- **Temporal Window:** Spans the entire 2023 calendar year (365 calendar days).
- **Monthly Volume:** Constant pace ranging between 104 registrations (July) and 144 registrations (December), averaging $\approx 125$ registrations/month.
- **Day of Week Distribution:** Slight weekend elevation: Saturday (240), Friday (230), Sunday (220), Tuesday (216), Thursday (210), Monday (198), Wednesday (186).
- **Zero Registration Days:** Exactly 6 dates have zero registrations (`2023-03-09`, `2023-07-05`, `2023-08-23`, `2023-10-05`, `2023-10-10`, `2023-12-28`), perfectly consistent with a Poisson random arrival process ($E = 365 \times e^{-4.11} \approx 6.0$ days).

---

## 3. Post Activity Analysis

### 3.1 Post Volume by Platform (`platform`)

| Platform Category | Post Count | Share of Total (%) | Notes |
| :--- | :---: | :---: | :--- |
| **Facebook** | 2,074 | 17.28% | Balanced across social channels |
| **YouTube** | 2,073 | 17.28% | Balanced across social channels |
| **Twitter** | 2,049 | 17.08% | Balanced across social channels |
| **Reddit** | 2,031 | 16.92% | Balanced across social channels |
| **Instagram** | 1,989 | 16.58% | Balanced across social channels |
| **[Missing Platform]** | 1,784 | 14.87% | Retained as nulls (not imputed) |
| **Total** | **12,000** | **100.00%** | Equal allocation among 5 named networks |

### 3.2 Posts Over Time (May 1, 2024 to April 30, 2025)
- **Monthly Cadence:**
  - May 2024: 1,023 | Jun 2024: 986 | Jul 2024: 1,037 | Aug 2024: 996
  - Sep 2024: 1,004 | Oct 2024: 1,015 | Nov 2024: 976 | Dec 2024: 1,028
  - Jan 2025: 1,020 | Feb 2025: 890 (shorter 28-day month) | Mar 2025: 1,013 | Apr 2025: 1,012
  - **Finding:** Activity is remarkably constant at approximately $1,000 \pm 35$ posts per month.
- **Day of Week Distribution:**
  - Friday: 1,768 (14.73%) | Saturday: 1,749 (14.58%) | Wednesday: 1,743 (14.53%)
  - Sunday: 1,725 (14.38%) | Thursday: 1,707 (14.22%) | Tuesday: 1,673 (13.94%) | Monday: 1,635 (13.62%)
- **Hourly Distribution:**
  - 8,483 posts originate from timestamps containing explicit hour data (ISO 8601 and Unix epoch). The hourly distribution across all 24 hours is completely uniform ($\approx 320 - 380$ posts/hour), showing no diurnal sleep/wake cycles.

### 3.3 User Activity Concentration (Posts per User)
- **Mean:** 8.00 posts/user | **Median:** 8.0 posts/user | **Std Dev:** 2.87
- **Min:** 1 post | **Max:** 22 posts
- **Distribution:** Symmetrically bell-shaped around 7–9 posts per user:
  - $\le 3$ posts: 63 users (4.2%)
  - 4–6 posts: 381 users (25.4%)
  - 7–9 posts: 578 users (38.5%)
  - 10–12 posts: 364 users (24.3%)
  - $\ge 13$ posts: 114 users (7.6%)
- **Top Poster:** `user_bqp8mrav` (22 posts, Shanghai, China).

---

## 4. Engagement Analysis (`likes`, `shares`, `comments`)

### 4.1 Statistical Distribution Comparison

| Metric | Sample Size ($n$) | Missing Count (%) | Mean | Median | Std Dev | Min | 25th (Q1) | 75th (Q3) | Max | Skewness | Kurtosis |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`likes`** | 10,186 | 1,814 (15.12%) | 2,490.87 | 2,497.00 | 1,438.45 | 0 | 1,237.25 | 3,721.75 | 5,000 | +0.0087 | -1.1963 |
| **`shares`** | 12,000 | 0 (0.00%) | 1,007.17 | 1,018.00 | 575.07 | 0 | 510.00 | 1,501.00 | 2,000 | -0.0136 | -1.1916 |
| **`comments`** | 12,000 | 0 (0.00%) | 504.35 | 503.00 | 288.68 | 0 | 253.00 | 755.00 | 1,000 | -0.0154 | -1.2110 |

### 4.2 Distribution Insights:
1. **Perfect Bounded Uniformity:**
   - `likes` $\sim \mathcal{U}(0, 5000)$
   - `shares` $\sim \mathcal{U}(0, 2000)$
   - `comments` $\sim \mathcal{U}(0, 1000)$
2. **Kurtosis Benchmark:** All three engagement metrics exhibit kurtosis values of approximately $-1.20$, precisely matching the theoretical excess kurtosis of a continuous uniform distribution.
3. **Absence of Viral Outliers:** Unlike real social networks where top posts accumulate orders of magnitude more likes than median posts, engagement here is bounded and uniformly scattered.

---

## 5. Platform Engagement Comparison

| Platform | Total Posts | Likes Observations ($n$) | Mean Likes | Median Likes | Shares Obs ($n$) | Mean Shares | Median Shares | Comments Obs ($n$) | Mean Comments | Median Comments |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Facebook** | 2,074 | 1,755 | 2,499.78 | 2,525.0 | 2,074 | 1,003.55 | 1,027.0 | 2,074 | 506.94 | 504.0 |
| **YouTube** | 2,073 | 1,747 | 2,488.94 | 2,506.0 | 2,073 | 1,003.04 | 1,007.0 | 2,073 | 504.38 | 498.0 |
| **Twitter** | 2,049 | 1,725 | 2,488.66 | 2,487.0 | 2,049 | 1,010.45 | 1,020.0 | 2,049 | 506.13 | 504.0 |
| **Reddit** | 2,031 | 1,742 | 2,476.99 | 2,473.0 | 2,031 | 1,019.20 | 1,029.0 | 2,031 | 511.18 | 513.0 |
| **Instagram** | 1,989 | 1,693 | 2,492.20 | 2,499.0 | 1,989 | 1,001.07 | 1,008.0 | 1,989 | 499.80 | 498.0 |
| **[Missing]** | 1,784 | 1,524 | 2,499.30 | 2,490.5 | 1,784 | 1,000.18 | 1,009.0 | 1,784 | 496.54 | 498.5 |

### Non-Causal Analytical Conclusion:
There are **zero statistically meaningful differences** in engagement across platforms. Mean likes across all platforms fall within the narrow interval $[2,477, 2,500]$; mean shares within $[1,000, 1,019]$; and mean comments within $[497, 511]$. One cannot claim any platform "causes" or drives higher engagement.

---

## 6. User Followers vs. Post Engagement

### 6.1 Correlation Matrix

| Metric Pair | Pearson Correlation ($r$) | Spearman Rank ($r_s$) | Statistical Interpretation |
| :--- | :---: | :---: | :--- |
| **`follower_count` vs. `likes`** | $+0.0082$ | $+0.0082$ | Zero linear or monotonic relationship ($p > 0.05$) |
| **`follower_count` vs. `shares`** | $-0.0144$ | $-0.0144$ | Zero linear or monotonic relationship ($p > 0.05$) |
| **`follower_count` vs. `comments`** | $-0.0003$ | $-0.0004$ | Zero linear or monotonic relationship ($p > 0.05$) |
| **`likes` vs. `shares`** | $-0.0012$ | $-0.0012$ | Engagement metrics are mutually independent |
| **`likes` vs. `comments`** | $+0.0100$ | $+0.0102$ | Engagement metrics are mutually independent |
| **`shares` vs. `comments`** | $+0.0244$ | $+0.0244$ | Engagement metrics are mutually independent |

### 6.2 Follower Quartile Tier Breakdown

| Follower Quartile | Follower Range | Active Users | Total Posts | Mean Likes | Median Likes | Mean Shares | Median Shares | Mean Comments | Median Comments |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Q1 (Low)** | $109 - 12,771$ | 375 | 3,028 | 2,456.62 | 2,452.0 | 1,023.39 | 1,040.0 | 504.78 | 500.0 |
| **Q2 (Mid-Low)** | $12,772 - 24,741$ | 375 | 3,006 | 2,511.62 | 2,553.0 | 1,002.34 | 1,002.0 | 505.51 | 506.0 |
| **Q3 (Mid-High)** | $24,742 - 37,097$ | 375 | 3,010 | 2,493.94 | 2,526.5 | 999.57 | 1,004.0 | 499.41 | 491.0 |
| **Q4 (High)** | $37,098 - 49,944$ | 375 | 2,956 | 2,505.68 | 2,472.5 | 1,003.37 | 1,018.5 | 507.68 | 513.0 |

### Critical Finding:
Users with 40,000+ followers receive the exact same average engagement as users with under 2,000 followers. In this benchmark dataset, follower count has no empirical influence on engagement.

---

## 7. Geographic & Linguistic Patterns

### 7.1 Location vs. Engagement
- **Top Post Volume Locations:** Los Angeles (459 posts, 55 users), Munich (452 posts, 54 users), Shanghai (451 posts, 56 users), Barcelona (439 posts, 56 users), Houston (422 posts, 50 users).
- **Lowest Post Volume Locations:** Sydney (208 posts, 28 users), Lagos (223 posts, 30 users), Seoul (276 posts, 36 users), Madrid (290 posts, 36 users), Lyon (293 posts, 37 users).
- **Engagement Invariance:** Across all 33 cities, mean likes remain within $[2,380, 2,620]$, mean shares within $[950, 1,065]$, and mean comments within $[472, 532]$.
- **Caveat:** Minor differences in total post counts are driven strictly by the number of users assigned to that city (e.g., 28 users in Sydney vs 56 in Shanghai), not higher posting frequency per user.

### 7.2 Language vs. Engagement
- Posts per language range from 1,119 posts (`ru`) to 1,369 posts (`zh`).
- Mean likes by language range from 2,442 (`de`) to 2,551 (`ar`).
- Mean shares by language range from 980 (`fr`) to 1,037 (`pt`).
- Mean comments by language range from 488 (`es`) to 520 (`fr`).
- **Statistical Invariance:** Differences between languages are within random sampling error.

---

## 8. Missing Data Forensic Analysis

### 8.1 Missingness Breakdown
- `platform`: 1,784 missing (14.87%)
- `text_content`: 1,711 missing (14.26%)
- `likes`: 1,814 missing (15.12%)

### 8.2 Random Masking Mechanism Verification:
1. **Across Months:** Monthly missing rates remain tightly constrained between 12.5% and 16.6% across all 12 months for all three attributes.
2. **Across Platforms:** When examining posts with known platforms, missingness in `likes` is $\approx 14.2\% - 15.8\%$ and missingness in `text_content` is $\approx 14.1\% - 15.2\%$.
3. **Across Languages and Locations:** Missingness is uniformly distributed ($14\% - 16\%$) across all demographic subsets.
4. **Conclusion:** Missingness is consistent with a random masking mechanism based on the observed checks ($p \approx 0.15$).

---

## 9. Text Content Linguistic Analysis

- **Sample Size:** 10,289 non-missing text records.
- **Length Metrics:** Min = 5 chars, Max = 172 chars, Mean = 117.44 chars, Median = 118.00 chars, Std Dev = 18.29 chars.
- **Syntactic Structure:** The text follows templated e-commerce/consumer product review formulas:
  - Form: `[Emotion/Action phrase] + [Product/Service] + from + [Brand]! + [Opinion phrase] + #[Hashtag] + @[Mention]`
- **Top Brands Observed:** Nike, Adidas, Apple, Samsung, Microsoft, Toyota, Amazon, Pepsi, Coca-Cola.
- **Hashtag Analysis:**
  - Total extracted hashtags: 20,531 instances across 56 unique tags.
  - Distribution: Uniform across all 56 tags ($\approx 700 - 750$ occurrences each).
  - Top Tags: `#Reviews` (750), `#Fitness` (749), `#BestValue` (732), `#Eco` (723), `#SpecialOffer` (723), `#Sustainable` (721), `#Trending` (720), `#Beauty` (716).
- **Mention Analysis:**
  - Total extracted mentions: 2,073 instances across 15 unique corporate/functional handles.
  - Top Handles: `@RetailSupport` (156), `@MarketingTeam` (155), `@ReviewSite` (153), `@BrandCEO` (153), `@BrandSupport` (149), `@IndustryExpert` (143).

---

## 10. Top 10 Important Analytical Findings

1. **Synthetic Uniformity Across All Numerical Metrics:** Follower counts, likes, shares, and comments exhibit near-zero skewness and kurtosis $\approx -1.20$, consistent with engagement metrics being drawn from bounded uniform distributions.
2. **Zero Follower-Engagement Coupling ($r \approx 0.00$):** In contrast to organic social networks where audience size drives reach, high-follower accounts receive the exact same average likes, shares, and comments as micro-accounts.
3. **Mutual Independence of Engagement Metrics:** Likes, shares, and comments share zero correlation with each other ($|r| < 0.025$). A post with 5,000 likes is no more likely to receive comments than a post with 50 likes.
4. **Equal Platform Performance:** Post volume ($\approx 2,000$ posts/channel) and mean engagement metrics are virtually identical across Facebook, Instagram, Reddit, Twitter, and YouTube.
5. **Random Masking Missingness Pattern:** Missing values in `platform`, `text_content`, and `likes` occur at a steady $\approx 15\%$ rate across all months, platforms, locations, and languages.
6. **Strict Chronological Sequence:** All user registrations occurred in calendar year 2023, while all post interactions occurred between May 1, 2024 and April 30, 2025. Zero posts predate account creation.
7. **Perfect Referential Integrity:** All 12,000 posts belong to the 1,500 registered users. Every user created between 1 and 22 posts ($Mean = 8.0$).
8. **Templated Text Generation:** Post text content is generated from a synthetic combinatorial grammar referencing 9 major consumer brands, 56 uniform hashtags, and 15 uniform corporate mentions.
9. **Balanced Global Demographics:** The 1,500 users are distributed across 33 global cities and 10 languages without demographic clustering (languages are statistically independent of geography).
10. **Constant Annual Activity Pace:** Posts are generated at an even rate of $\approx 1,000 \pm 35$ posts per month across the 12-month post collection window.

---

## 11. Recommended Visualizations Plan (12 Strong Charts)

The following visualizations are recommended for the Phase 1 EDA report to communicate these findings with maximum visual impact:

| # | Chart Name | Analytical Question | Dataset / Scope | Variables Plotted | Chart Type | Expected Analytical Insight |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | **Follower Count Distribution** | How is audience size distributed across users? | Users | `follower_count` | Histogram with KDE overlay | Shows continuous uniform distribution $\mathcal{U}(100, 50000)$ with kurtosis $\approx -1.2$. |
| **2** | **Engagement Distributions (Trio)** | What are the distributional shapes of likes, shares, and comments? | Posts | `likes`, `shares`, `comments` | 3-Panel Boxplots / Violin plots | Visually establishes uniform bounds $[0, 5000]$, $[0, 2000]$, $[0, 1000]$. |
| **3** | **Platform Post Volume Share** | How are posts divided across social platforms? | Posts | `platform` (including `[Missing]`) | Donut Chart / Bar Chart | Shows equal 5-way split ($\approx 17\%$ each) and 14.9% missingness. |
| **4** | **Monthly Post Timeline** | Does posting activity exhibit seasonality over the 1-year window? | Posts | `timestamp` (Monthly) | Time-Series Line Chart | Highlights steady rate ($\approx 1,000$ posts/month) from May 2024 to Apr 2025. |
| **5** | **Posts per User Distribution** | How is posting frequency distributed among active users? | Posts aggregated by User | `posts_per_user` count | Histogram with discrete bins | Demonstrates normal-like bell curve centered at 8 posts/user (range 1–22). |
| **6** | **Engagement by Platform Comparison** | Does platform choice influence likes, shares, or comments? | Posts | `platform`, `likes`, `shares`, `comments` | Grouped Bar Chart (Mean & Median) | Shows engagement invariance across all 5 platforms. |
| **7** | **Followers vs. Likes Scatterplot** | Does audience size drive post likes? | Merged | `follower_count` (X) vs `likes` (Y) | Scatterplot with Trendline | Visually illustrates $r = +0.0082$ flat regression slope (zero correlation). |
| **8** | **Engagement Metric Correlation Heatmap** | Are likes, shares, comments, and followers correlated? | Merged | `follower_count`, `likes`, `shares`, `comments` | Correlation Heatmap Matrix | Shows mutual independence across all four metrics ($|r| < 0.025$). |
| **9** | **Geographic User Concentration** | Which metropolitan hubs have the highest user representation? | Users | `location` | Horizontal Bar Chart (Top 15 vs Bottom 15) | Shows balanced representation between 28 and 56 users per city. |
| **10** | **Language Share Breakdown** | What is the linguistic diversity of the user base? | Users | `language` | Categorical Bar Chart | Shows uniform $\approx 10\%$ split across all 10 language codes. |
| **11** | **Missingness Rate by Month** | Does missing data cluster in specific collection periods? | Posts | Month (X) vs % Missing (Y) | Multi-Line Trend Chart | Demonstrates stability ($\approx 15\%$) across all 12 months. |
| **12** | **Top Hashtags Frequency** | What are the dominant discussion themes in text content? | Posts | Extracted `#hashtags` | Horizontal Bar Chart (Top 15) | Shows uniform hashtag usage ($\approx 700 - 750$ occurrences per tag). |

---

## 12. Important Limitations & Negative Guidance (What NOT to Include)

### Analytical Limitations to Acknowledge:
1. **Absence of Organic Social Dynamics:** Because this dataset was generated synthetically for a competition benchmark, real-world social media assumptions (e.g. viral power laws, network effects, diurnal sleep cycles, demographic language alignment) do not apply.
2. **Missing Data Cannot Be Imputed Reliably:** Missing values in `platform`, `text_content`, and `likes` are consistent with a random masking mechanism. Imputing them with mean/median or synthetic models would corrupt the ground truth.
3. **No Temporal Hour Data for Date-Only Posts:** The 3,622 posts originally formatted as `DD-MM-YYYY` contain no time-of-day information (`00:00:00`), so diurnal hourly analyses must be restricted to the 8,483 timed records.

### Negative Guidance (Analyses That MUST NOT Be Performed):
1. **DO NOT Claim Platform Superiority:** Do not assert that "Platform X is best for engagement" — differences in mean engagement are less than 0.5% and statistically insignificant.
2. **DO NOT Run Causal Regressions:** Do not model `likes ~ follower_count + platform + location` expecting predictive power ($R^2 \approx 0.00$).
3. **DO NOT Perform Complex NLP Sentiment Scoring:** Post text is synthetic combinatorial marketing copy with contradictory sentiment fragments; sentiment modeling is uninformative.
4. **DO NOT Label Low-Volume Cities as "Underperforming":** Differences in post counts by city reflect initial user assignment, not lower engagement or user disinterest.
