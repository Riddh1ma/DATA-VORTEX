# Data Vortex — Round 1: End-to-End Analytics & SQL Relational Modeling

[![Project Status: Complete](https://img.shields.io/badge/Project%20Status-Complete%20%26%20Validated-brightgreen.svg)](#)
[![Python Version](https://img.shields.io/badge/Python-3.11%20%7C%203.13-blue.svg)](#)
[![Database](https://img.shields.io/badge/Database-SQLite%203-navy.svg)](#)
[![Submission Document](https://img.shields.io/badge/Submission-29--Page%20Verified%20PDF-red.svg)](reports/DATA_VORTEX_PHASE2_SUBMISSION.pdf)

Official competition repository for **Data Vortex Round 1**, encompassing both **Phase 1** (Forensic Corruption Audit, Programmatic Data Cleaning, and Exploratory Data Analysis) and **Phase 2** (Relational Database Architecture, SQLite Schema Implementation, and 10 Advanced Analytical SQL Challenges).

The official final deliverable is the 29-page verified submission report:  
📄 **[DATA_VORTEX_PHASE2_SUBMISSION.pdf](reports/DATA_VORTEX_PHASE2_SUBMISSION.pdf)**

---

## Executive Summary

The Data Vortex project analyzes creator behavior, content engagement, publishing cadence, and platform performance across a multi-platform social media ecosystem. The raw input data suffered from systematic corruption, heterogeneous formatting, duplicate records, and sign inversion errors. 

Across two competition phases, this project:
1. **Audited & Cleaned Raw Data (Phase 1):** Uncovered root-cause corruptions, eliminated 360 duplicate records, inverted 1,228 negative engagement values, standardized multi-format timestamps, cleaned text artifacts, and preserved missing values without synthetic fabrication.
2. **Explored Behavioral Dynamics (Phase 1 EDA):** Conducted rigorous exploratory data analysis producing 12 publication-ready visualizations uncovering creator skewness, platform volume patterns, and follower-to-engagement dynamics.
3. **Engineered Relational Architecture (Phase 2):** Built an optimized SQLite relational database (`data_vortex.db`) enforcing referential integrity, check constraints, and composite indexes.
4. **Executed 10 SQL Challenges (Phase 2):** Answered complex business and behavioral questions using Common Table Expressions (CTEs), window functions (`LAG`, `SUM() OVER`, `DENSE_RANK() OVER`), and statistical aggregations across 12,000 posts and 1,500 creators.

---

## Core Project Metrics

| Metric | Raw Dataset | Final Cleaned / Database | Validation Status |
| :--- | :--- | :--- | :--- |
| **Users / Creators** | 1,500 rows | 1,500 rows | 100% unique primary keys, 0 missing values |
| **Posts Volume** | 12,360 rows | 12,000 rows | 360 duplicates removed, 0 data loss |
| **Engagement Validity** | 1,228 negative likes | 0 negative likes | Rectified via absolute value inversion |
| **Timestamp Fidelity** | 3 conflicting formats | 100% ISO (`YYYY-MM-DD HH:MM:SS`) | Verified period: 2024-05-01 to 2025-04-30 |
| **Referential Integrity** | Unchecked | 100% valid (`posts.user_id` $\rightarrow$ `users.user_id`) | 0 orphan posts, enforced via Foreign Keys |
| **Missing Values** | Uncontrolled | platform: 588, text: 615, likes: 622 | Preserved as true `NULL`s per governance rules |
| **Database File** | N/A | `data/data_vortex.db` (3.36 MB) | Indexed SQLite 3 schema |
| **SQL Deliverables** | N/A | 10 Challenge Scripts + 10 Reports + 10 Notebooks | 100% tested and cross-reconciled |

---

## Repository Architecture

```text
DATA-VORTEX/
│
├── README.md                                 # Comprehensive project documentation
├── .gitignore                                # Git ignore configuration preserving deliverables
│
├── data/
│   ├── raw/                                  # Read-only original datasets (immutable)
│   │   ├── Social_Engine_Users.csv           # 1,500 user profile records
│   │   └── Social_Engine_Posts_Corrupted.csv # 12,360 raw post records with corruptions
│   │
│   ├── cleaned/                              # Production cleaned datasets
│   │   ├── Social_Engine_Users_Cleaned.csv   # 1,500 validated user records
│   │   └── Social_Engine_Posts_Cleaned.csv   # 12,000 standardized post records
│   │
│   └── data_vortex.db                        # Relational SQLite database (3.36 MB)
│
├── src/                                      # Reproducible Python automation pipelines
│   ├── clean_data.py                         # End-to-end data cleaning & validation pipeline
│   └── load_sqlite.py                        # SQLite schema initialization & database loader
│
├── notebooks/                                # Interactive Jupyter Notebooks
│   ├── 01_initial_dataset_inspection.ipynb   # Initial exploratory inspection
│   ├── 02_corruption_forensics.ipynb         # Forensic investigation of corrupted posts
│   ├── 03_combined_forensics.ipynb           # Cross-table join & integrity verification
│   ├── 04_data_cleaning.ipynb                # Interactive cleaning validation
│   ├── 05_eda.ipynb                          # Exploratory data analysis & distributions
│   ├── 06_final_eda.ipynb                    # Final visualization & statistical checks
│   ├── 07_sql_database_setup.ipynb           # SQLite database loading & validation checks
│   ├── 08_challenge_01.ipynb                 # SQL Challenge 1 interactive notebook
│   ├── 09_challenge_02.ipynb                 # SQL Challenge 2 interactive notebook
│   ├── 10_challenge_03.ipynb                 # SQL Challenge 3 interactive notebook
│   ├── 11_challenge_04.ipynb                 # SQL Challenge 4 interactive notebook
│   ├── 12_challenge_05.ipynb                 # SQL Challenge 5 interactive notebook
│   ├── 13_challenge_06.ipynb                 # SQL Challenge 6 interactive notebook
│   ├── 14_challenge_07.ipynb                 # SQL Challenge 7 interactive notebook
│   ├── 15_challenge_08.ipynb                 # SQL Challenge 8 interactive notebook
│   ├── 16_challenge_09.ipynb                 # SQL Challenge 9 interactive notebook
│   └── 17_challenge_10.ipynb                 # SQL Challenge 10 interactive notebook
│
├── sql/                                      # Production SQL Scripts
│   ├── README.md                             # SQL directory documentation & query guide
│   ├── 01_schema.sql                         # DDL table definitions, keys, and indexes
│   ├── 02_load_and_validation.sql            # Verification & constraint validation queries
│   ├── challenge_01_platform_interaction_benchmarks.sql
│   ├── challenge_02_top_creator_audience.sql
│   ├── challenge_03_geographic_analysis.sql
│   ├── challenge_04_creator_activity_segmentation.sql
│   ├── challenge_05_monthly_publishing_trends.sql
│   ├── challenge_06_day_of_week_cadence.sql
│   ├── challenge_07_audience_reach_vs_engagement.sql
│   ├── challenge_08_high_impact_post_leaderboard.sql
│   ├── challenge_09_regional_creator_leadership.sql
│   └── challenge_10_mom_volume_growth.sql
│
├── reports/                                  # Audited Technical Reports & Official Submissions
│   ├── DATA_VORTEX_PHASE2_SUBMISSION.pdf     # 29-Page Final Competition Submission Document
│   ├── PHASE2_FINAL_REPORT.md                # Comprehensive Phase 2 markdown report
│   ├── PHASE2_SUBMISSION_CHECKLIST.md        # 100% verified Phase 2 compliance checklist
│   ├── FINAL_PHASE1_QA.md                    # Phase 1 QA, audit, and sign-off report
│   ├── EDA_Report.md                         # Detailed exploratory data analysis report
│   ├── EDA_Data_Dictionary.md                # Field-level metadata and variable definitions
│   ├── 04_cleaning_validation.md             # Data cleaning validation evidence
│   ├── 04_cleaning_decision_log.md           # Governance rationale for cleaning actions
│   ├── 05_final_reconciliation.md            # Post-cleaning dataset reconciliation
│   ├── 06_eda_analysis.md                    # In-depth statistical analysis
│   ├── 07_database_setup.md                  # Database architecture & schema documentation
│   ├── 08_sql_challenge_plan.md              # Phase 2 implementation strategy
│   └── 09_challenge_01.md through 18_challenge_10.md # Individual challenge analytical reports
│
└── outputs/
    ├── figures/                              # 12 Publication-quality EDA charts (PNG)
    │   ├── 01_follower_count_distribution.png
    │   ├── 02_engagement_distributions.png
    │   ├── 03_platform_post_volume.png
    │   ├── 04_monthly_post_activity.png
    │   ├── 05_posts_per_user.png
    │   ├── 06_platform_engagement.png
    │   ├── 07_followers_vs_likes.png
    │   ├── 08_correlation_heatmap.png
    │   ├── 09_user_locations.png
    │   ├── 10_language_distribution.png
    │   ├── 11_missingness_over_time.png
    │   └── 12_top_hashtags.png
    ├── screenshots/                          # Query execution evidence placeholder
    │   └── .gitkeep
    ├── initial_inspection_summary.csv        # Phase 1 raw data profile
    └── posts_forensic_summary.csv            # Phase 1 corruption inventory
```

---

## Phase 1 Highlights: Forensic Cleaning & EDA

### 1. Data Cleaning Transformations
- **Deduplication:** Identified 360 redundant rows in `Social_Engine_Posts_Corrupted.csv` resulting from byte-level logging duplicates. Deduplication reduced the row count from 12,360 to exactly 12,000 unique posts.
- **Negative Engagement Sign Correction:** 1,228 records contained negative `likes` values due to sensor sign-bit inversion. Corrected via `abs(likes)` with 0 data loss.
- **Timestamp Standardization:** Standardized three concurrent formats into ISO `YYYY-MM-DD HH:MM:SS`:
  - 10-digit Unix epoch timestamps (e.g., `1722528840` $\rightarrow$ `2024-08-01 16:14:00`)
  - ISO 8601 strings (e.g., `2025-04-13T20:12:18` $\rightarrow$ `2025-04-13 20:12:18`)
  - European date format (e.g., `25-09-2024` $\rightarrow$ `2024-09-25 00:00:00`)
- **Text Standardization:** Stripped leading/trailing whitespace and decoded escaped HTML entities (`&amp;` $\rightarrow$ `&`).
- **Missing Value Governance:** Explicitly preserved genuine missing values (588 missing `platform`, 615 missing `text_content`, 622 missing `likes`) without synthetic imputation to preserve statistical integrity.

### 2. Exploratory Insights
- **Follower Distribution:** Power-law distribution with mean follower count of 25,650 and high right-skewness (max: 49,997).
- **Platform Breakdown:** Instagram leads total post volume (3,844 posts; 32.03%), followed by TikTok (3,803 posts; 31.69%) and YouTube (3,765 posts; 31.38%), with 4.90% unclassified (`NULL`).
- **Engagement Independence:** Follower count demonstrates near-zero Pearson correlation with per-post likes ($r = -0.003$) and shares ($r = 0.001$), revealing that content virality is driven by algorithmic discovery rather than static audience size.

---

## Phase 2 Highlights: Relational Schema & 10 SQL Challenges

The SQLite database (`data/data_vortex.db`) models two core entities:
- `users`: `user_id` (PK), `location`, `language`, `account_created`, `follower_count`
- `posts`: `post_id` (PK), `user_id` (FK referencing `users`), `platform`, `text_content`, `timestamp`, `likes`, `shares`, `comments`

### SQL Challenges Summary

| # | Challenge Name | Primary SQL Techniques | Key Finding / Business Insight |
| :-: | :--- | :--- | :--- |
| **01** | **Platform Interaction Benchmarks** | `AVG()`, `ROUND()`, `GROUP BY`, `COALESCE` | Instagram leads in average likes (1,300.9) and total engagement; YouTube leads in average comments (149.9). |
| **02** | **Top Creator Audience Reach** | `ORDER BY follower_count DESC LIMIT 10` | Top 10 creators hold 493,529 combined followers (avg 49,353), led by `user_09d290fa` (49,997 followers). |
| **03** | **Geographic Analysis** | String parsing, `SUBSTR()`, `INSTR()`, `GROUP BY` | 15 distinct countries; United States (306 creators; 20.4%) and Brazil (202 creators; 13.5%) represent the largest creator hubs. |
| **04** | **Creator Activity Segmentation** | `CASE WHEN`, CTEs, aggregated subqueries | High activity creators ($\ge 11$ posts) author 21.6% of content despite representing only 18.0% of creators. |
| **05** | **Monthly Publishing Trends** | `strftime()`, `LAG() OVER()`, `SUM() OVER()` | Publishing volume remained stable across 12 months (avg 1,000 posts/mo), peaking in October 2024 (1,048 posts). |
| **06** | **Day-of-Week Posting Cadence** | `strftime('%w')`, modulo indexing, `GROUP BY` | Publishing activity is uniformly distributed across all 7 days (13.7%–14.8% per day); Friday is peak (1,779 posts). |
| **07** | **Audience Reach vs. Engagement** | Audience tiering, multi-level CTEs, `JOIN` | Large audience creators ($\ge 30\text{k}$) achieve nearly identical engagement to small creators ($<10\text{k}$), confirming algorithmic leveling. |
| **08** | **High-Impact Post Leaderboard** | Multi-column tie-breaker ranking, `LIMIT 20` | Post `post_26b86cf3` holds #1 rank (4,675 total engagement: 3,998 likes, 497 shares, 180 comments on YouTube). |
| **09** | **Regional Creator Leadership** | `DENSE_RANK() OVER (PARTITION BY ...)` | Successfully extracted top 3 ranked creators by audience within each of the 15 countries using analytical windowing. |
| **10** | **MoM Volume Growth & Tracking** | Windowed `LAG()`, cumulative `SUM() OVER()` | Quantified month-over-month growth swings (ranging from -6.74% to +7.37%) reaching exactly 12,000 cumulative posts. |

---

## Reproduction & Pipeline Execution

To reproduce the entire pipeline from scratch on any machine with Python 3.10+:

### 1. Environment Setup
```bash
# Clone the repository
git clone <repository_url>
cd DATA-VORTEX

# Create and activate virtual environment (optional)
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install pandas numpy matplotlib
```

### 2. Run Data Cleaning Pipeline
Executes all deduplication, negative likes correction, timestamp standardization, and outputs cleaned CSVs to `data/cleaned/`:
```bash
python src/clean_data.py
```

### 3. Build & Validate SQLite Database
Creates `data/data_vortex.db`, builds tables with schema constraints, loads cleaned datasets, and validates referential integrity:
```bash
python src/load_sqlite.py
```

### 4. Execute SQL Queries
Directly execute any challenge SQL script against the database:
```bash
# Example: Run Challenge 1 using SQLite CLI
sqlite3 data/data_vortex.db < sql/challenge_01_platform_interaction_benchmarks.sql

# Or query using Python
python -c "import sqlite3; conn=sqlite3.connect('data/data_vortex.db'); print(conn.execute('SELECT COUNT(*) FROM posts;').fetchone())"
```

---

## Official Deliverables & Submission Links

- 📑 **[DATA_VORTEX_PHASE2_SUBMISSION.pdf](reports/DATA_VORTEX_PHASE2_SUBMISSION.pdf)**: Official 29-page final competition submission PDF.
- 📋 **[PHASE2_FINAL_REPORT.md](reports/PHASE2_FINAL_REPORT.md)**: Full markdown submission report with complete SQL queries and result tables.
- ✅ **[PHASE2_SUBMISSION_CHECKLIST.md](reports/PHASE2_SUBMISSION_CHECKLIST.md)**: Official verification checklist verifying 100% compliance.
- 🔬 **[FINAL_PHASE1_QA.md](reports/FINAL_PHASE1_QA.md)**: Final Phase 1 audit and data quality sign-off.
- 📊 **[EDA_Report.md](reports/EDA_Report.md)**: Exploratory data analysis report with statistical distributions.
- 🗄️ **[sql/README.md](sql/README.md)**: Detailed schema breakdown, indexing rationale, and challenge query directory.

---

## Governance & Compliance Statement

- **Zero Synthetic Fabrication:** No values were artificially manufactured or imputed. Missing values in optional columns (`platform`, `text_content`, `likes`) are preserved as genuine `NULL` values.
- **Read-Only Raw Provenance:** The raw datasets (`data/raw/`) have been maintained in an immutable, read-only state throughout all phases.
- **Strict Determinism:** All data transformations in `src/clean_data.py` and `src/load_sqlite.py` are strictly deterministic, idempotent, and fully reproducible.
