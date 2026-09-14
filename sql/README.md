# Data Vortex — Phase 2 SQL Scripts & Database Documentation

This directory contains the Data Definition Language (DDL) schemas, database initialization scripts, and validation queries for **Data Vortex Round 1 Phase 2**.

---

## 1. Directory Structure & File Manifest

```
sql/
│
├── 01_schema.sql             # DDL script defining tables, keys, constraints, and indexes
├── 02_load_and_validation.sql # Comprehensive SQL query suite verifying database integrity
└── README.md                 # Technical documentation and workflow instructions (this file)
```

---

## 2. Database Location & Physical Specifications

- **Database Engine:** SQLite 3
- **File Location:** `data/data_vortex.db` (relative to project root)
- **File Size:** $\approx 2.5\text{ MB}$
- **Foreign Key Pragma:** `PRAGMA foreign_keys = ON;` (mandatory for all sessions)
- **Encoding:** UTF-8

---

## 3. Schema Architecture & Table Relationships

The database implements a normalized 1-to-Many relational structure:

```
users (1) ────< (N) posts
```

### Table Specifications:

#### 1. `users` Table (1,500 rows)
- **`user_id`** (`TEXT NOT NULL PRIMARY KEY`): Unique user identifier (`user_[a-z0-9]{8}`).
- **`location`** (`TEXT NOT NULL`): Metropolitan city and country of residence (33 international locations; UTF-8).
- **`language`** (`TEXT NOT NULL`): Two-letter ISO 639-1 language code (10 unique codes).
- **`account_created`** (`TEXT NOT NULL`): ISO 8601 registration date (`YYYY-MM-DD`).
- **`follower_count`** (`INTEGER NOT NULL`): Registered platform followers (range: 109 to 49,944).

#### 2. `posts` Table (12,000 rows)
- **`post_id`** (`TEXT NOT NULL PRIMARY KEY`): Unique post identifier (`^[a-z0-9]{12}$`).
- **`user_id`** (`TEXT NOT NULL`): Foreign key referencing `users(user_id)`.
- **`platform`** (`TEXT NULL`): Social media channel (1,784 `NULL` values preserved).
- **`text_content`** (`TEXT NULL`): Post body text (1,711 `NULL` values preserved).
- **`timestamp`** (`TEXT NOT NULL`): Standardized publication datetime (`YYYY-MM-DD HH:MM:SS`).
- **`likes`** (`INTEGER NULL`): Non-negative post likes (1,814 `NULL` values preserved).
- **`shares`** (`INTEGER NOT NULL`): Non-negative post shares (0 `NULL`s; range: 0 to 2,000).
- **`comments`** (`INTEGER NOT NULL`): Non-negative post comments (0 `NULL`s; range: 0 to 1,000).

### Optimized Indexes:
- `idx_posts_user_id`: B-tree index on foreign key `posts(user_id)` for high-performance `JOIN`s and aggregations.
- `idx_posts_timestamp`: B-tree index on `posts(timestamp)` for chronological range filtering.
- `idx_posts_platform`: B-tree index on `posts(platform)` for channel-level groupings.

---

## 4. How to Recreate the Database

To rebuild `data/data_vortex.db` deterministically from the cleaned CSV files:

### Method 1: Python Automated Loader (Recommended)
From the project root directory, run:
```bash
python src/load_sqlite.py
```
This script unlinks any existing database, applies `sql/01_schema.sql`, loads both cleaned CSVs, enforces foreign keys, and executes the validation assertions.

### Method 2: SQLite Command-Line Interface (CLI)
```bash
# 1. Apply Schema DDL
sqlite3 data/data_vortex.db < sql/01_schema.sql

# 2. Ingest Data via Python loader
python src/load_sqlite.py

# 3. Run Validation Queries
sqlite3 data/data_vortex.db < sql/02_load_and_validation.sql
```

---

## 5. SQL Validation Summary

Executing `sql/02_load_and_validation.sql` confirms:
1. **Zero Foreign Key Violations:** `PRAGMA foreign_key_check` returns 0 rows.
2. **Zero Orphan Posts:** All 12,000 posts link to valid users.
3. **Universal User Participation:** All 1,500 users have authored at least 1 post.
4. **Preserved NULL Counts:** `platform` (1,784), `text_content` (1,711), `likes` (1,814).
5. **Data Quality:** Zero negative likes, shares, or comments.
