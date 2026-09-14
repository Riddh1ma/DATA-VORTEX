-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Analytical SQL
-- Challenge 8: High-Impact Post Leaderboard
-- Database: SQLite 3 (data/data_vortex.db)
-- ====================================================================
-- Analytical Objective:
--   Identify and rank the highest-impact individual posts across the
--   platform based on total interaction volume.
--   Total engagement is defined as:
--     total_engagement = likes + shares + comments
--   Using COALESCE to ensure NULL engagement values do not yield NULL totals.
--   Preserves original raw column values for likes, shares, and comments.
-- ====================================================================

-- --------------------------------------------------------------------
-- Query 1: Top 20 High-Impact Posts Leaderboard
-- Ranked strictly by:
--   1. total_engagement DESC
--   2. likes DESC (tie-breaker 1)
--   3. shares DESC (tie-breaker 2)
--   4. comments DESC (tie-breaker 3)
--   5. post_id ASC (tie-breaker 4)
-- --------------------------------------------------------------------
WITH post_engagement AS (
    SELECT 
        post_id,
        user_id,
        platform,
        timestamp,
        likes,
        shares,
        comments,
        (COALESCE(likes, 0) + COALESCE(shares, 0) + COALESCE(comments, 0)) AS total_engagement,
        ROW_NUMBER() OVER (
            ORDER BY 
                (COALESCE(likes, 0) + COALESCE(shares, 0) + COALESCE(comments, 0)) DESC,
                likes DESC,
                shares DESC,
                comments DESC,
                post_id ASC
        ) AS rank
    FROM posts
)
SELECT 
    rank,
    post_id,
    user_id,
    platform,
    timestamp,
    likes,
    shares,
    comments,
    total_engagement
FROM post_engagement
WHERE rank <= 20
ORDER BY rank ASC;

-- --------------------------------------------------------------------
-- Query 2: Platform Summary for Top 20 Posts
-- Summarizes post distribution across platforms for the top 20 cohort.
-- NULL platforms are treated as 'Unknown'.
-- --------------------------------------------------------------------
WITH post_engagement AS (
    SELECT 
        post_id,
        platform,
        (COALESCE(likes, 0) + COALESCE(shares, 0) + COALESCE(comments, 0)) AS total_engagement,
        ROW_NUMBER() OVER (
            ORDER BY 
                (COALESCE(likes, 0) + COALESCE(shares, 0) + COALESCE(comments, 0)) DESC,
                likes DESC,
                shares DESC,
                comments DESC,
                post_id ASC
        ) AS rank
    FROM posts
),
top20 AS (
    SELECT * 
    FROM post_engagement 
    WHERE rank <= 20
)
SELECT 
    COALESCE(platform, 'Unknown') AS platform,
    COUNT(*) AS number_of_top_posts,
    ROUND(AVG(total_engagement), 2) AS average_total_engagement
FROM top20
GROUP BY COALESCE(platform, 'Unknown')
ORDER BY number_of_top_posts DESC, average_total_engagement DESC;

-- --------------------------------------------------------------------
-- Query 3: Top 20 Benchmark Extremes & Cohort Averages
-- Evaluates the maximum, minimum, and cohort-wide mean engagement.
-- --------------------------------------------------------------------
WITH post_engagement AS (
    SELECT 
        post_id,
        likes,
        shares,
        comments,
        (COALESCE(likes, 0) + COALESCE(shares, 0) + COALESCE(comments, 0)) AS total_engagement,
        ROW_NUMBER() OVER (
            ORDER BY 
                (COALESCE(likes, 0) + COALESCE(shares, 0) + COALESCE(comments, 0)) DESC,
                likes DESC,
                shares DESC,
                comments DESC,
                post_id ASC
        ) AS rank
    FROM posts
),
top20 AS (
    SELECT * 
    FROM post_engagement 
    WHERE rank <= 20
)
SELECT 
    MAX(total_engagement) AS highest_total_engagement,
    MIN(total_engagement) AS lowest_total_engagement,
    ROUND(AVG(total_engagement), 2) AS average_total_engagement,
    SUM(CASE WHEN likes IS NULL OR shares IS NULL OR comments IS NULL THEN 1 ELSE 0 END) AS null_interaction_posts
FROM top20;
