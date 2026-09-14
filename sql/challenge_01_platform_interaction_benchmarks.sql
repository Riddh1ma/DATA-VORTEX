-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Analytical SQL
-- Challenge 1: Platform Interaction Benchmarks
-- Database: SQLite 3 (data/data_vortex.db)
-- ====================================================================
-- Analytical Objective:
--   Analyze social interaction metrics across publishing platforms.
--   Calculates post volume, average likes, average shares, average comments,
--   and average total interactions per platform.
--
-- NULL Handling Policy:
--   1. Platform: Missing values are converted to 'Unknown' using COALESCE(platform, 'Unknown')
--      for display and grouping purposes without altering underlying table data.
--   2. Likes: Missing likes are handled using COALESCE(likes, 0) during addition so that
--      posts with missing likes still contribute their valid shares and comments to total interactions.
--   3. Component Averages: Standard SQL AVG() evaluates available non-null values.
-- ====================================================================

SELECT 
    COALESCE(platform, 'Unknown') AS platform,
    COUNT(*) AS post_count,
    ROUND(AVG(likes), 2) AS avg_likes,
    ROUND(AVG(shares), 2) AS avg_shares,
    ROUND(AVG(comments), 2) AS avg_comments,
    ROUND(AVG(COALESCE(likes, 0) + COALESCE(shares, 0) + COALESCE(comments, 0)), 2) AS avg_total_interactions
FROM posts
GROUP BY COALESCE(platform, 'Unknown')
ORDER BY avg_total_interactions DESC;
