"""
Data Vortex - Round 1 Phase 2: SQLite Database Loader
=====================================================
This script creates and populates the SQLite database 'data/data_vortex.db'
using exclusively the cleaned datasets:
  - data/cleaned/Social_Engine_Users_Cleaned.csv
  - data/cleaned/Social_Engine_Posts_Cleaned.csv

Strict Governance:
  - Cleaned datasets are strictly read-only and are NEVER modified.
  - Foreign key constraints are enforced (PRAGMA foreign_keys = ON).
  - Missing values in platform, text_content, and likes are preserved as SQL NULL.
  - Unicode integrity (e.g. 'São Paulo, Brazil') is preserved in UTF-8.
"""

import os
import csv
import sqlite3
import pandas as pd


def get_paths():
    """Resolve absolute project directory paths."""
    src_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(src_dir, ".."))
    
    return {
        "db": os.path.join(project_root, "data", "data_vortex.db"),
        "schema": os.path.join(project_root, "sql", "01_schema.sql"),
        "users_csv": os.path.join(project_root, "data", "cleaned", "Social_Engine_Users_Cleaned.csv"),
        "posts_csv": os.path.join(project_root, "data", "cleaned", "Social_Engine_Posts_Cleaned.csv"),
    }


def init_database(db_path: str, schema_path: str) -> sqlite3.Connection:
    """Initialize or recreate the SQLite database and apply DDL schema."""
    if os.path.exists(db_path):
        os.remove(db_path)
        print(f"Removed existing database file: {db_path}")
        
    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA foreign_keys = ON;")
    
    with open(schema_path, "r", encoding="utf-8") as f:
        schema_sql = f.read()
        
    conn.executescript(schema_sql)
    print("Database initialized and schema applied successfully.")
    return conn


def load_users(conn: sqlite3.Connection, users_csv_path: str) -> int:
    """Load cleaned users into the users table."""
    print(f"Loading users from: {users_csv_path}")
    cursor = conn.cursor()
    
    users_data = []
    with open(users_csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            users_data.append((
                row["user_id"].strip(),
                row["location"].strip(),
                row["language"].strip(),
                row["account_created"].strip(),
                int(row["follower_count"].strip())
            ))
            
    cursor.executemany(
        """
        INSERT INTO users (user_id, location, language, account_created, follower_count)
        VALUES (?, ?, ?, ?, ?);
        """,
        users_data
    )
    conn.commit()
    print(f"Successfully loaded {len(users_data):,} rows into 'users' table.")
    return len(users_data)


def load_posts(conn: sqlite3.Connection, posts_csv_path: str) -> int:
    """
    Load cleaned posts into the posts table.
    Ensures missing values in platform, text_content, and likes are inserted as SQL NULL.
    """
    print(f"Loading posts from: {posts_csv_path}")
    cursor = conn.cursor()
    
    posts_data = []
    with open(posts_csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            post_id = row["post_id"].strip()
            user_id = row["user_id"].strip()
            
            # Platform: empty string or whitespace -> SQL NULL
            raw_plat = row["platform"].strip() if row["platform"] else ""
            platform = raw_plat if raw_plat != "" else None
            
            # Text content: empty string, whitespace, or literal "NULL" token -> SQL NULL
            raw_text = row["text_content"].strip() if row["text_content"] else ""
            text_content = raw_text if (raw_text != "" and raw_text != "NULL") else None
            
            # Timestamp: standard format
            timestamp = row["timestamp"].strip()
            
            # Likes: empty string or whitespace -> SQL NULL; otherwise integer
            raw_likes = row["likes"].strip() if row["likes"] else ""
            likes = int(raw_likes) if raw_likes != "" else None
            
            shares = int(row["shares"].strip())
            comments = int(row["comments"].strip())
            
            posts_data.append((
                post_id,
                user_id,
                platform,
                text_content,
                timestamp,
                likes,
                shares,
                comments
            ))
            
    cursor.executemany(
        """
        INSERT INTO posts (post_id, user_id, platform, text_content, timestamp, likes, shares, comments)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """,
        posts_data
    )
    conn.commit()
    print(f"Successfully loaded {len(posts_data):,} rows into 'posts' table.")
    return len(posts_data)


def validate_database(conn: sqlite3.Connection):
    """Execute rigorous integrity and data fidelity validations."""
    print("=" * 60)
    print("EXECUTING DATABASE VALIDATION SUITE")
    print("=" * 60)
    cursor = conn.cursor()
    
    # 1. Row counts
    cursor.execute("SELECT COUNT(*) FROM users;")
    users_count = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(DISTINCT user_id) FROM users;")
    unique_users = cursor.fetchone()[0]
    
    cursor.execute("SELECT COUNT(*) FROM posts;")
    posts_count = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(DISTINCT post_id) FROM posts;")
    unique_posts = cursor.fetchone()[0]
    
    print(f"Users Count:        {users_count:,} (Expected: 1,500) | Unique: {unique_users:,}")
    print(f"Posts Count:        {posts_count:,} (Expected: 12,000) | Unique: {unique_posts:,}")
    assert users_count == 1500 and unique_users == 1500, "Users table count/uniqueness violation"
    assert posts_count == 12000 and unique_posts == 12000, "Posts table count/uniqueness violation"
    
    # 2. Foreign key check
    cursor.execute("PRAGMA foreign_key_check;")
    fk_violations = cursor.fetchall()
    print(f"Foreign Key Violations: {len(fk_violations)} (Expected: 0)")
    assert len(fk_violations) == 0, f"Foreign key check failed: {fk_violations}"
    
    # 3. Orphan posts
    cursor.execute("SELECT COUNT(*) FROM posts WHERE user_id NOT IN (SELECT user_id FROM users);")
    orphan_posts = cursor.fetchone()[0]
    print(f"Orphan Posts:       {orphan_posts} (Expected: 0)")
    assert orphan_posts == 0, "Found orphan posts referencing non-existent users"
    
    # 4. Universal user participation
    cursor.execute("SELECT COUNT(DISTINCT user_id) FROM posts;")
    participating_users = cursor.fetchone()[0]
    print(f"Participating Users:{participating_users:,} (Expected: 1,500)")
    assert participating_users == 1500, "Not all users have authored posts"
    
    # 5. NULL counts in posts
    cursor.execute("SELECT COUNT(*) FROM posts WHERE platform IS NULL;")
    null_plat = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM posts WHERE text_content IS NULL;")
    null_text = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM posts WHERE likes IS NULL;")
    null_likes = cursor.fetchone()[0]
    
    print(f"Platform NULLs:     {null_plat:,} (Expected: 1,784)")
    print(f"Text Content NULLs: {null_text:,} (Expected: 1,711)")
    print(f"Likes NULLs:        {null_likes:,} (Expected: 1,814)")
    assert null_plat == 1784, f"Platform NULL count mismatch: got {null_plat}"
    assert null_text == 1711, f"Text Content NULL count mismatch: got {null_text}"
    assert null_likes == 1814, f"Likes NULL count mismatch: got {null_likes}"
    
    # 6. Non-negative engagement metrics
    cursor.execute("SELECT COUNT(*) FROM posts WHERE likes < 0;")
    neg_likes = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM posts WHERE shares < 0;")
    neg_shares = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM posts WHERE comments < 0;")
    neg_comments = cursor.fetchone()[0]
    print(f"Negative Metrics:   Likes={neg_likes}, Shares={neg_shares}, Comments={neg_comments} (All Expected: 0)")
    assert neg_likes == 0 and neg_shares == 0 and neg_comments == 0, "Negative metrics detected"
    
    # 7. Unicode preservation
    cursor.execute("SELECT COUNT(*) FROM users WHERE location = 'São Paulo, Brazil';")
    sao_paulo_count = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM users WHERE location = 'Singapore';")
    singapore_count = cursor.fetchone()[0]
    print(f"Unicode Check:      São Paulo users={sao_paulo_count}, Singapore users={singapore_count}")
    assert sao_paulo_count > 0, "Unicode character 'ã' lost or corrupted"
    assert singapore_count > 0, "'Singapore' location altered"
    
    print("=" * 60)
    print("ALL DATABASE INTEGRITY CHECKS PASSED PERFECTLY!")
    print("=" * 60)


def main():
    """Execute complete database pipeline."""
    paths = get_paths()
    print("STARTING DATA VORTEX PHASE 2 SQLITE DATABASE SETUP")
    print(f"Target Database: {paths['db']}")
    
    conn = init_database(paths["db"], paths["schema"])
    try:
        load_users(conn, paths["users_csv"])
        load_posts(conn, paths["posts_csv"])
        validate_database(conn)
    finally:
        conn.close()
        print("Database connection closed cleanly.")


if __name__ == "__main__":
    main()
