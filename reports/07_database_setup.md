# Data Vortex — Phase 2 Database Setup & Validation Report

**Competition:** Data Vortex — Round 1 Phase 2  
**Database Engine:** SQLite 3  
**Target Database File:** `data/data_vortex.db`  
**Source Datasets:**  
- `data/cleaned/Social_Engine_Users_Cleaned.csv` (1,500 records)  
- `data/cleaned/Social_Engine_Posts_Cleaned.csv` (12,000 records)  
**Date:** 2026-09-14  
**Setup Status:** **READY (100% Validated)**  

---

## 1. Database Technology

**SQLite 3** was selected as the relational database engine for Phase 2 based on several operational and analytical criteria:

1. **Embedded & Serverless:** Operates as a self-contained, zero-configuration local database file (`data/data_vortex.db`), eliminating external server dependencies, network latency, and service management overhead.
2. **Deterministic Reproducibility:** Entire database lifecycle (creation, schema execution, data ingestion, indexing) can be executed deterministically in seconds via Python and standard SQL DDL scripts.
3. **Full SQL & Foreign Key Support:** Supports standard ANSI SQL syntax, window functions, common table expressions (CTEs), and strict relational integrity via `PRAGMA foreign_keys = ON;`.
4. **Native Python & Multi-Tool Compatibility:** Built-in standard library support in Python (`sqlite3`), direct integration with `pandas.read_sql()`, and seamless compatibility with GUI SQL clients (e.g., DBeaver, DB Browser for SQLite, VS Code SQLite extensions).
5. **Portability & Archival Integrity:** The complete 2.5 MB database file can be version-controlled, shared, and evaluated directly within the competition repository without migration steps.

---

## 2. Schema Overview

The database implements a normalized two-table relational structure representing user profiles and their corresponding social post interactions.

### 2.1 Table: `users`
Represents verified registered social engine user accounts.
- **Physical Source:** `data/cleaned/Social_Engine_Users_Cleaned.csv`
- **Total Records:** 1,500 rows
- **Columns & Data Types:**
  - `user_id` (`TEXT NOT NULL PRIMARY KEY`): Unique 13-character account identifier (`user_[a-z0-9]{8}`).
  - `location` (`TEXT NOT NULL`): Metropolitan city and country of residence (33 international locations; UTF-8 encoded).
  - `language` (`TEXT NOT NULL`): Two-letter ISO 639-1 language code (10 unique codes).
  - `account_created` (`TEXT NOT NULL`): ISO 8601 registration date (`YYYY-MM-DD`).
  - `follower_count` (`INTEGER NOT NULL`): Registered follower count (range: 109 to 49,944).

### 2.2 Table: `posts`
Represents social media post publications and engagement interactions.
- **Physical Source:** `data/cleaned/Social_Engine_Posts_Cleaned.csv`
- **Total Records:** 12,000 rows
- **Columns & Data Types:**
  - `post_id` (`TEXT NOT NULL PRIMARY KEY`): Unique 12-character post identifier (`^[a-z0-9]{12}$`).
  - `user_id` (`TEXT NOT NULL REFERENCES users(user_id)`): Foreign key linking post author to `users.user_id`.
  - `platform` (`TEXT NULL`): Social media channel (`Facebook`, `Instagram`, `Reddit`, `Twitter`, `YouTube`, or `NULL`).
  - `text_content` (`TEXT NULL`): Post body text (5 to 172 characters, trimmed, HTML-decoded, or `NULL`).
  - `timestamp` (`TEXT NOT NULL`): Standardized publication datetime (`YYYY-MM-DD HH:MM:SS`).
  - `likes` (`INTEGER NULL`): Rectified non-negative post likes (range: 0 to 5,000, or `NULL`).
  - `shares` (`INTEGER NOT NULL`): Non-negative post shares (range: 0 to 2,000).
  - `comments` (`INTEGER NOT NULL`): Non-negative post comments (range: 0 to 1,000).

---

## 3. Primary Keys

Primary keys enforce entity uniqueness and physical integrity across both tables:

1. **`users.user_id`:**
   - Enforces unique identity for all 1,500 user accounts.
   - Guaranteed 100% unique: duplicate count = 0.
   - Serves as the foreign key target for post attribution.
2. **`posts.post_id`:**
   - Enforces unique identity for all 12,000 post publications.
   - Guaranteed 100% unique following Phase 1 exact deduplication: duplicate count = 0.
   - Indexed automatically as the B-tree primary key in SQLite.

---

## 4. Foreign Key Relationship

The relational link connects posts directly to their authors:

$$\text{posts.user\_id} \longrightarrow \text{users.user\_id}$$

- **Relationship Cardinality:** One-to-Many (1:N). One user can author multiple posts; each post is authored by exactly one registered user.
- **Referential Enforcement:** Enabled via `PRAGMA foreign_keys = ON;`.
- **Constraint Actions:** `ON UPDATE CASCADE ON DELETE RESTRICT`. Prevents accidental deletion of users who have active post records.
- **Foreign Key Index:** `CREATE INDEX idx_posts_user_id ON posts(user_id);` was explicitly created to optimize relational `JOIN` operations and prevent full table scans.
- **Audit Results:**
  - `PRAGMA foreign_key_check;` returned **0 violations**.
  - Orphan posts query (`WHERE user_id NOT IN (SELECT user_id FROM users)`) returned **0 rows**.
  - User participation: all **1,500 users** have authored at least 1 post (range: 1 to 22 posts).

---

## 5. NULL Handling

Missing data in the cleaned CSV files are explicitly preserved as true SQL `NULL` values rather than placeholder strings or imputed values:

1. **`platform`:** Exactly 1,784 records lack platform metadata (14.87%). Stored as SQL `NULL`. In SQL queries, filtered via `WHERE platform IS NULL` or handled via `COALESCE(platform, 'Missing')`.
2. **`text_content`:** Exactly 1,711 records lack text body (14.26%). Both empty strings and stripped literal `"NULL"` tokens are ingested as SQL `NULL`. Filtered via `WHERE text_content IS NULL`.
3. **`likes`:** Exactly 1,814 records lack like counts (15.12%). Stored as SQL `NULL` (`INTEGER NULL`). Standard SQL aggregate functions (`AVG(likes)`, `MIN(likes)`, `MAX(likes)`) automatically ignore `NULL`s, ensuring mathematically accurate non-missing sample calculations ($n = 10,186$).
4. **Non-Nullable Attributes:** `user_id`, `location`, `language`, `account_created`, `follower_count`, `post_id`, `timestamp`, `shares`, and `comments` are defined with `NOT NULL` constraints to prevent incomplete records.

---

## 6. Data Loading Pipeline

Data ingestion is orchestrated by [`src/load_sqlite.py`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/src/load_sqlite.py):

```
data/cleaned/Social_Engine_Users_Cleaned.csv  --> users table (1,500 rows)
data/cleaned/Social_Engine_Posts_Cleaned.csv  --> posts table (12,000 rows)
                                                      |
                                                      v
                                            data/data_vortex.db
```

### Ingestion Steps:
1. **Database Reset:** If `data/data_vortex.db` exists, it is unlinked and recreated cleanly.
2. **DDL Application:** [`sql/01_schema.sql`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/01_schema.sql) is executed with `PRAGMA foreign_keys = ON;`.
3. **Users Ingestion:** Loaded first via parameterized `executemany()` to establish parent keys. UTF-8 encoding preserves accented characters.
4. **Posts Ingestion:** Loaded second. Empty strings and literal `"NULL"` tokens are cast to Python `None` to produce true SQL `NULL`s.
5. **Index Creation:** Indexes on `posts(user_id)`, `posts(timestamp)`, and `posts(platform)` are created post-ingestion for optimal performance.
6. **Integrity Assertions:** Post-load validation queries execute automatically; any assertion failure rolls back and halts execution.

---

## 7. Validation Results

The database was tested against the full validation query suite in [`sql/02_load_and_validation.sql`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/sql/02_load_and_validation.sql):

| Validation Check | SQL Query / Metric | Expected Value | Actual Value | Status |
| :--- | :--- | :---: | :---: | :---: |
| **Users Row Count** | `SELECT COUNT(*) FROM users;` | 1,500 | 1,500 | **PASS** |
| **Users Unique Keys** | `SELECT COUNT(DISTINCT user_id) FROM users;` | 1,500 | 1,500 | **PASS** |
| **Users Duplicate PKs**| `COUNT(*) - COUNT(DISTINCT user_id)` | 0 | 0 | **PASS** |
| **Posts Row Count** | `SELECT COUNT(*) FROM posts;` | 12,000 | 12,000 | **PASS** |
| **Posts Unique Keys** | `SELECT COUNT(DISTINCT post_id) FROM posts;` | 12,000 | 12,000 | **PASS** |
| **Posts Duplicate PKs**| `COUNT(*) - COUNT(DISTINCT post_id)` | 0 | 0 | **PASS** |
| **Foreign Key Violations** | `PRAGMA foreign_key_check;` | 0 rows | 0 rows | **PASS** |
| **Orphan Posts** | `WHERE user_id NOT IN (SELECT user_id FROM users)` | 0 | 0 | **PASS** |
| **User Participation** | `SELECT COUNT(DISTINCT user_id) FROM posts;` | 1,500 | 1,500 | **PASS** |
| **Platform NULLs** | `SUM(CASE WHEN platform IS NULL THEN 1 ELSE 0 END)` | 1,784 | 1,784 | **PASS** |
| **Text Content NULLs** | `SUM(CASE WHEN text_content IS NULL THEN 1 ELSE 0 END)` | 1,711 | 1,711 | **PASS** |
| **Likes NULLs** | `SUM(CASE WHEN likes IS NULL THEN 1 ELSE 0 END)` | 1,814 | 1,814 | **PASS** |
| **Shares NULLs** | `SUM(CASE WHEN shares IS NULL THEN 1 ELSE 0 END)` | 0 | 0 | **PASS** |
| **Comments NULLs** | `SUM(CASE WHEN comments IS NULL THEN 1 ELSE 0 END)` | 0 | 0 | **PASS** |
| **Negative Likes** | `SUM(CASE WHEN likes < 0 THEN 1 ELSE 0 END)` | 0 | 0 | **PASS** |
| **Negative Shares** | `SUM(CASE WHEN shares < 0 THEN 1 ELSE 0 END)` | 0 | 0 | **PASS** |
| **Negative Comments** | `SUM(CASE WHEN comments < 0 THEN 1 ELSE 0 END)` | 0 | 0 | **PASS** |
| **Chronological Integrity** | `WHERE p.timestamp < u.account_created` | 0 | 0 | **PASS** |
| **UTF-8 Unicode Integrity** | `SELECT COUNT(*) FROM users WHERE location = 'São Paulo, Brazil';` | > 0 (44) | 44 | **PASS** |
| **Sovereign City-State** | `SELECT COUNT(*) FROM users WHERE location = 'Singapore';` | > 0 (49) | 49 | **PASS** |
| **Data Fidelity Check** | Bit-for-bit CSV vs. SQLite comparison across all fields | 100% Match | 100% Match | **PASS** |

---

## 8. Schema Diagram

```
+-------------------------------------------------------------+
|                            users                            |
+-------------------------------------------------------------+
| PK  user_id          TEXT NOT NULL                          |
|     location         TEXT NOT NULL                          |
|     language         TEXT NOT NULL                          |
|     account_created  TEXT NOT NULL                          |
|     follower_count   INTEGER NOT NULL                       |
+-------------------------------------------------------------+
                              |
                              |  1-to-many (1:N)
                              |  FK: posts.user_id -> users.user_id
                              v
+-------------------------------------------------------------+
|                            posts                            |
+-------------------------------------------------------------+
| PK  post_id          TEXT NOT NULL                          |
| FK  user_id          TEXT NOT NULL                          |
|     platform         TEXT NULL                              |
|     text_content     TEXT NULL                              |
|     timestamp        TEXT NOT NULL                          |
|     likes            INTEGER NULL                           |
|     shares           INTEGER NOT NULL                       |
|     comments         INTEGER NOT NULL                       |
+-------------------------------------------------------------+
| Indexes:                                                    |
|  - idx_posts_user_id   ON posts(user_id)                    |
|  - idx_posts_timestamp ON posts(timestamp)                  |
|  - idx_posts_platform  ON posts(platform)                   |
+-------------------------------------------------------------+
```

---

## 9. Reproducibility

To recreate and re-verify the database from scratch at any time, execute either of the following commands from the project root:

### Option A: Python Automated Pipeline (Recommended)
```bash
python src/load_sqlite.py
```

### Option B: SQLite Command-Line Interface
```bash
sqlite3 data/data_vortex.db < sql/01_schema.sql
# Ingest CSVs via sqlite3 import mode or load_sqlite.py
sqlite3 data/data_vortex.db < sql/02_load_and_validation.sql
```

### Option C: Jupyter Notebook
Run all cells in [`notebooks/07_sql_database_setup.ipynb`](file:///C:/Users/singh/OneDrive/Documents/DATA-VORTEX/notebooks/07_sql_database_setup.ipynb).

---

## 10. Phase 2 Readiness

### Verdict: **READY FOR ANALYTICAL SQL**

The relational SQLite database `data/data_vortex.db`:
- Is fully populated with 1,500 users and 12,000 posts.
- Enforces strict foreign key integrity with 0 violations and 0 orphan posts.
- Preserves missing values cleanly as SQL `NULL`.
- Contains optimized indexes on `user_id`, `timestamp`, and `platform`.
- Achieves 100% data fidelity against the cleaned CSV baseline.
