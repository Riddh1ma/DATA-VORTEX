-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Analytical SQL
-- Challenge 6: Day-of-Week Posting Cadence
-- Database: SQLite 3 (data/data_vortex.db)
-- ====================================================================
-- Analytical Objective:
--   Analyze post publishing cadence across the 7 days of the week
--   using the timestamp column.
--   Returns:
--     - day_of_week (e.g., Monday, Tuesday, ...)
--     - day_number (Monday=1 through Sunday=7)
--     - post_count
--     - percentage_of_posts
--   Ordered strictly from Monday (1) through Sunday (7).
-- ====================================================================

-- --------------------------------------------------------------------
-- Query 1: Day-of-Week Publishing Distribution (Ordered Monday -> Sunday)
-- --------------------------------------------------------------------
WITH daily_posts AS (
    SELECT 
        post_id,
        CAST(strftime('%u', timestamp) AS INTEGER) AS day_number,
        CASE CAST(strftime('%u', timestamp) AS INTEGER)
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
            WHEN 7 THEN 'Sunday'
        END AS day_of_week
    FROM posts
)
SELECT 
    day_of_week,
    day_number,
    COUNT(post_id) AS post_count,
    ROUND(100.0 * COUNT(post_id) / (SELECT COUNT(*) FROM posts), 2) AS percentage_of_posts
FROM daily_posts
GROUP BY day_number, day_of_week
ORDER BY day_number ASC;

-- --------------------------------------------------------------------
-- Query 2: Cadence Extremes & Variance Analysis
-- Evaluates the highest-posting day, lowest-posting day,
-- absolute difference, and relative percentage difference.
-- --------------------------------------------------------------------
WITH daily_posts AS (
    SELECT 
        CAST(strftime('%u', timestamp) AS INTEGER) AS day_number,
        CASE CAST(strftime('%u', timestamp) AS INTEGER)
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
            WHEN 7 THEN 'Sunday'
        END AS day_of_week,
        COUNT(*) AS post_count
    FROM posts
    GROUP BY strftime('%u', timestamp)
),
extremes AS (
    SELECT 
        (SELECT day_of_week FROM daily_posts ORDER BY post_count DESC LIMIT 1) AS highest_day,
        (SELECT post_count FROM daily_posts ORDER BY post_count DESC LIMIT 1) AS highest_count,
        (SELECT day_of_week FROM daily_posts ORDER BY post_count ASC LIMIT 1) AS lowest_day,
        (SELECT post_count FROM daily_posts ORDER BY post_count ASC LIMIT 1) AS lowest_count
)
SELECT 
    highest_day,
    highest_count,
    lowest_day,
    lowest_count,
    highest_count - lowest_count AS absolute_difference,
    ROUND(100.0 * (highest_count - lowest_count) / lowest_count, 2) AS relative_difference_pct
FROM extremes;
