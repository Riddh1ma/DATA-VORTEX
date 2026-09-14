# Data Vortex — EDA Data Dictionary

**Competition:** Data Vortex - Round 1  
**Target Cleaned Datasets:**  
1. `data/cleaned/Social_Engine_Users_Cleaned.csv` (1,500 records)  
2. `data/cleaned/Social_Engine_Posts_Cleaned.csv` (12,000 records)  
**Document Version:** 1.0 (Post-Cleaning Final Specification)  
**Date:** 2026-09-14  

---

## 1. Overview

This data dictionary provides comprehensive metadata, semantic definitions, storage types, missingness characteristics, and analytical treatment guidelines for every feature present in the cleaned datasets analyzed during Phase 1 Exploratory Data Analysis (EDA).

---

## 2. Users Dataset: `Social_Engine_Users_Cleaned.csv`

| Variable Name | Source Dataset | Physical Data Type | Logical Domain | Missing Count (%) | Semantic Definition & Valid Range | Analytical Treatment in EDA |
| :--- | :--- | :--- | :--- | :---: | :--- | :--- |
| **`user_id`** | Users | `object` (`string`) | Identifier (PK) | 0 (0.00%) | Unique user account identifier matching format `user_[a-z0-9]{8}`. Length: 13 characters. 100% unique. | Primary key. Used as foreign key target to join user profile attributes to posts. |
| **`location`** | Users | `object` (`string`) | Categorical | 0 (0.00%) | Metropolitan city and country of user residence. 33 unique values. 32 use `"City, Country"`; `"Singapore"` is a sovereign city-state. Accented UTF-8 character `ã` in `"São Paulo, Brazil"`. | Aggregated to evaluate demographic volume and geographic posting activity. Kept un-split in cleaned baseline; mapped to city/country in SQL planning. |
| **`language`** | Users | `object` (`string`) | Categorical | 0 (0.00%) | Primary language code registered by user. 10 unique 2-letter ISO 639-1 lowercase codes: `ar`, `de`, `en`, `es`, `fr`, `hi`, `ja`, `pt`, `ru`, `zh`. | Grouped to test linguistic demographic balance and cross-demographic engagement invariance. |
| **`account_created`** | Users | `object` (`string`) | Temporal Date | 0 (0.00%) | Calendar date of account registration. Valid ISO 8601 string format `YYYY-MM-DD`. Range: `2023-01-01` to `2023-12-31`. | Analyzed across monthly and day-of-week intervals. Cross-referenced against post timestamps to verify temporal validity. |
| **`follower_count`** | Users | `int64` | Continuous Metric | 0 (0.00%) | Number of registered platform followers for the user. Non-negative integer. Range: $[109, 49944]$. Mean: 24,964.02, Median: 24,741.50. | Evaluated via histograms, correlation matrices, and quartile bucketing. Identified as a continuous uniform distribution $\mathcal{U}(100, 50000)$. |

---

## 3. Posts Dataset: `Social_Engine_Posts_Cleaned.csv`

| Variable Name | Source Dataset | Physical Data Type | Logical Domain | Missing Count (%) | Semantic Definition & Valid Range | Analytical Treatment in EDA |
| :--- | :--- | :--- | :--- | :---: | :--- | :--- |
| **`post_id`** | Posts | `object` (`string`) | Identifier (PK) | 0 (0.00%) | Unique social post identifier matching format `^[a-z0-9]{12}$`. Length: 12 characters. 12,000 unique records (deduplicated). | Primary key for posts. Used to quantify post counts per user and platform. |
| **`user_id`** | Posts | `object` (`string`) | Identifier (FK) | 0 (0.00%) | Foreign key reference to author's account in Users dataset. 1,500 unique values. Zero orphan records. | Used as join key to connect user demographic profile (followers, location, language) with engagement. |
| **`platform`** | Posts | `object` (`string`) | Categorical | 1,784 (14.87%) | Social media channel where post was published. 5 unique categories: `Facebook`, `Instagram`, `Reddit`, `Twitter`, `YouTube`. | Missing values explicitly categorized as `[Missing]` rather than dropped. Evaluated for platform-level engagement and posting shares. |
| **`text_content`** | Posts | `object` (`string`) | Textual | 1,711 (14.26%) | Cleaned text body of the social post. Length: 5 to 172 characters. Trimmed of boundary whitespace; `&amp;` decoded to `&`. | Missing values preserved as nulls. Evaluated for character length distribution, hashtag frequencies (`#tag`), and mention extraction (`@handle`). |
| **`timestamp`** | Posts | `object` (`string`) | Temporal Datetime | 0 (0.00%) | Standardized publication datetime matching `YYYY-MM-DD HH:MM:SS`. Range: `2024-05-01 00:00:00` to `2025-04-30 21:57:10`. | Parsed into native datetime for monthly trendlines, day-of-week volume, and hourly diurnal distribution (for timed records). |
| **`likes`** | Posts | `Int64` (Nullable) | Discrete Metric | 1,814 (15.12%) | Number of post likes. Non-negative integer following sign-flip rectification. Range: $[0, 5000]$. Mean: 2,490.87, Median: 2,497.00. | Missing values strictly excluded from sample calculations without imputation (pairwise $n = 10,186$). Analyzed across platforms and user follower tiers. |
| **`shares`** | Posts | `int64` | Discrete Metric | 0 (0.00%) | Number of post shares/reposts. Non-negative integer. Range: $[0, 2000]$. Mean: 1,007.17, Median: 1,018.00. Zero missing values. | Analyzed across full sample ($n = 12,000$). Evaluated for distribution bounds and inter-metric correlation. |
| **`comments`** | Posts | `int64` | Discrete Metric | 0 (0.00%) | Number of post comments. Non-negative integer. Range: $[0, 1000]$. Mean: 504.35, Median: 503.00. Zero missing values. | Analyzed across full sample ($n = 12,000$). Evaluated for distribution bounds and inter-metric correlation. |

---

## 4. Derived & Engineered Variables (Used in EDA Aggregations)

| Derived Variable | Base Field(s) | Computation / Logic | Range / Values | Analytical Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **`posts_per_user`** | `df_posts['user_id']` | Groupby count of `post_id` per `user_id` | $1 - 22$ posts (Mean: 8.00) | Assesses user engagement concentration and activity distribution. |
| **`post_month`** | `df_posts['timestamp']` | Datetime converted to monthly period (`dt.to_period('M')`) | 12 periods: `2024-05` to `2025-04` | Tracks temporal post cadence, missingness rates, and monthly engagement trends. |
| **`day_name`** | `df_posts['timestamp']` | Day of week extraction (`dt.day_name()`) | 7 days (Monday through Sunday) | Assesses publishing patterns across days of the week. |
| **`follower_quartile`** | `df_users['follower_count']`| 4 quantiles (`pd.qcut`): Q1 (Low), Q2 (Mid-Low), Q3 (Mid-High), Q4 (High) | 4 tiers ($\approx 375$ users each) | Evaluates whether high-follower accounts receive differential engagement. |
| **`hashtags`** | `df_posts['text_content']` | Regex extraction `r'#(\w+)'` | 56 unique tags (20,531 total tokens) | Quantifies topical marketing tags and discussion categories. |
| **`mentions`** | `df_posts['text_content']` | Regex extraction `r'@(\w+)'` | 15 unique handles (2,073 total tokens) | Measures institutional and brand handle targeting. |
