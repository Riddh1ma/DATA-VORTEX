-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Database Validation Suite
-- Database: SQLite 3
-- Target Database: data/data_vortex.db
-- Purpose: Verify schema integrity, record counts, foreign key constraints,
--          NULL counts, and statistical ranges post-loading.
-- ====================================================================

-- 1. Enable Foreign Key Enforcement
PRAGMA foreign_keys = ON;

-- ====================================================================
-- SECTION 1: Foreign Key Integrity Checks
-- ====================================================================

-- 1.1 PRAGMA Foreign Key Check (Expected: 0 rows returned)
PRAGMA foreign_key_check;

-- 1.2 Orphan Posts Audit (Expected: 0)
SELECT 
    COUNT(*) AS orphan_posts_count
FROM posts
WHERE user_id NOT IN (SELECT user_id FROM users);

-- 1.3 Universal User Participation Audit (Expected: 1,500)
SELECT 
    COUNT(DISTINCT user_id) AS participating_users_count
FROM posts;

-- ====================================================================
-- SECTION 2: Record Counts & Primary Key Uniqueness
-- ====================================================================

-- 2.1 Users Table Row Count & Unique Primary Keys (Expected: 1,500, 1,500, 0)
SELECT 
    COUNT(*) AS total_users_count,
    COUNT(DISTINCT user_id) AS unique_user_ids,
    COUNT(*) - COUNT(DISTINCT user_id) AS duplicate_user_ids
FROM users;

-- 2.2 Posts Table Row Count & Unique Primary Keys (Expected: 12,000, 12,000, 0)
SELECT 
    COUNT(*) AS total_posts_count,
    COUNT(DISTINCT post_id) AS unique_post_ids,
    COUNT(*) - COUNT(DISTINCT post_id) AS duplicate_post_ids
FROM posts;

-- ====================================================================
-- SECTION 3: Missing Value (NULL) Audit in Posts
-- ====================================================================

-- 3.1 Verify Exact Null Counts (Expected: platform=1784, text=1711, likes=1814)
SELECT 
    SUM(CASE WHEN platform IS NULL THEN 1 ELSE 0 END) AS null_platform_count,
    SUM(CASE WHEN text_content IS NULL THEN 1 ELSE 0 END) AS null_text_count,
    SUM(CASE WHEN likes IS NULL THEN 1 ELSE 0 END) AS null_likes_count,
    SUM(CASE WHEN shares IS NULL THEN 1 ELSE 0 END) AS null_shares_count,
    SUM(CASE WHEN comments IS NULL THEN 1 ELSE 0 END) AS null_comments_count
FROM posts;

-- 3.2 Verify Multi-Attribute Missingness Overlap
SELECT 
    SUM(CASE WHEN platform IS NULL AND text_content IS NULL AND likes IS NULL THEN 1 ELSE 0 END) AS all_three_null,
    SUM(CASE WHEN platform IS NOT NULL AND text_content IS NOT NULL AND likes IS NOT NULL THEN 1 ELSE 0 END) AS complete_records
FROM posts;

-- ====================================================================
-- SECTION 4: Data Quality & Constraint Range Audits
-- ====================================================================

-- 4.1 Non-Negative Engagement Metric Audit (Expected: 0 rows violating non-negativity)
SELECT 
    SUM(CASE WHEN likes < 0 THEN 1 ELSE 0 END) AS negative_likes_count,
    SUM(CASE WHEN shares < 0 THEN 1 ELSE 0 END) AS negative_shares_count,
    SUM(CASE WHEN comments < 0 THEN 1 ELSE 0 END) AS negative_comments_count
FROM posts;

-- 4.2 Numeric Metric Bounds Audit
-- Expected Ranges:
--   follower_count: [109, 49944]
--   likes: [0, 5000]
--   shares: [0, 2000]
--   comments: [0, 1000]
SELECT 
    MIN(follower_count) AS min_followers,
    MAX(follower_count) AS max_followers,
    ROUND(AVG(follower_count), 2) AS avg_followers
FROM users;

SELECT 
    MIN(likes) AS min_likes,
    MAX(likes) AS max_likes,
    ROUND(AVG(likes), 2) AS avg_likes,
    MIN(shares) AS min_shares,
    MAX(shares) AS max_shares,
    ROUND(AVG(shares), 2) AS avg_shares,
    MIN(comments) AS min_comments,
    MAX(comments) AS max_comments,
    ROUND(AVG(comments), 2) AS avg_comments
FROM posts;

-- 4.3 Temporal Span & Format Integrity
-- Expected:
--   users: 2023-01-01 to 2023-12-31
--   posts: 2024-05-01 00:00:00 to 2025-04-30 21:57:10
--   chronological integrity: posts strictly occur after account creation
SELECT 
    MIN(account_created) AS min_user_created,
    MAX(account_created) AS max_user_created
FROM users;

SELECT 
    MIN(timestamp) AS min_post_timestamp,
    MAX(timestamp) AS max_post_timestamp
FROM posts;

SELECT 
    COUNT(*) AS chronologically_invalid_posts
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE p.timestamp < u.account_created;

-- 4.4 UTF-8 & Location Validation
SELECT 
    location,
    COUNT(*) AS user_count
FROM users
WHERE location IN ('São Paulo, Brazil', 'Singapore')
GROUP BY location;
