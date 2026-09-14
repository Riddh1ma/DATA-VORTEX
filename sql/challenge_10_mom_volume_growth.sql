-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Analytical SQL
-- Challenge 10: Month-over-Month Volume Growth & Cumulative Tracking
-- Database: SQLite 3 (data/data_vortex.db)
-- ====================================================================
-- Analytical Objective:
--   Analyze monthly post publishing volume over the 12-month period,
--   calculate month-over-month (MoM) volume changes and percentage growth
--   using the LAG() window function, and track cumulative publishing
--   volume using windowed SUM().
-- ====================================================================

-- --------------------------------------------------------------------
-- Query 1: Monthly Publishing Volume, MoM Growth & Cumulative Total
-- Returns:
--   - month (YYYY-MM)
--   - post_count (unrounded integer)
--   - previous_month_post_count (LAG post_count)
--   - mom_change (post_count - previous_month_post_count)
--   - mom_growth_pct (percentage growth rounded to 2 decimal places)
--   - cumulative_post_count (unrounded running total)
-- First Month Handling:
--   previous_month_post_count, mom_change, and mom_growth_pct evaluate
--   to NULL for the initial month (2024-05) due to no preceding period.
-- --------------------------------------------------------------------
WITH monthly_base AS (
    SELECT 
        strftime('%Y-%m', timestamp) AS month,
        COUNT(post_id) AS post_count
    FROM posts
    GROUP BY strftime('%Y-%m', timestamp)
),
monthly_lag AS (
    SELECT 
        month,
        post_count,
        LAG(post_count) OVER (ORDER BY month) AS previous_month_post_count,
        SUM(post_count) OVER (
            ORDER BY month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_post_count
    FROM monthly_base
)
SELECT 
    month,
    post_count,
    previous_month_post_count,
    (post_count - previous_month_post_count) AS mom_change,
    CASE
        WHEN previous_month_post_count IS NULL OR previous_month_post_count = 0
        THEN NULL
        ELSE ROUND(
            100.0 * (post_count - previous_month_post_count) 
            / previous_month_post_count, 
            2
        )
    END AS mom_growth_pct,
    cumulative_post_count
FROM monthly_lag
ORDER BY month ASC;

-- --------------------------------------------------------------------
-- Query 2: Monthly Publishing Summary Statistics
-- Aggregates:
--   - total_posts
--   - highest_volume_month and highest_volume_post_count
--   - lowest_volume_month and lowest_volume_post_count
--   - largest_positive_mom_month and largest_positive_mom_growth_pct
--   - largest_negative_mom_month and largest_negative_mom_growth_pct
-- --------------------------------------------------------------------
WITH monthly_base AS (
    SELECT 
        strftime('%Y-%m', timestamp) AS month,
        COUNT(post_id) AS post_count
    FROM posts
    GROUP BY strftime('%Y-%m', timestamp)
),
monthly_trends AS (
    SELECT 
        month,
        post_count,
        LAG(post_count) OVER (ORDER BY month) AS previous_month_post_count,
        CASE
            WHEN LAG(post_count) OVER (ORDER BY month) IS NULL 
                 OR LAG(post_count) OVER (ORDER BY month) = 0
            THEN NULL
            ELSE ROUND(
                100.0 * (post_count - LAG(post_count) OVER (ORDER BY month)) 
                / LAG(post_count) OVER (ORDER BY month), 
                2
            )
        END AS mom_growth_pct
    FROM monthly_base
)
SELECT 
    (SELECT SUM(post_count) FROM monthly_base) AS total_posts,
    (SELECT month FROM monthly_base ORDER BY post_count DESC LIMIT 1) AS highest_volume_month,
    (SELECT post_count FROM monthly_base ORDER BY post_count DESC LIMIT 1) AS highest_volume_post_count,
    (SELECT month FROM monthly_base ORDER BY post_count ASC LIMIT 1) AS lowest_volume_month,
    (SELECT post_count FROM monthly_base ORDER BY post_count ASC LIMIT 1) AS lowest_volume_post_count,
    (SELECT month FROM monthly_trends WHERE mom_growth_pct IS NOT NULL ORDER BY mom_growth_pct DESC LIMIT 1) AS largest_positive_mom_month,
    (SELECT mom_growth_pct FROM monthly_trends WHERE mom_growth_pct IS NOT NULL ORDER BY mom_growth_pct DESC LIMIT 1) AS largest_positive_mom_growth_pct,
    (SELECT month FROM monthly_trends WHERE mom_growth_pct IS NOT NULL ORDER BY mom_growth_pct ASC LIMIT 1) AS largest_negative_mom_month,
    (SELECT mom_growth_pct FROM monthly_trends WHERE mom_growth_pct IS NOT NULL ORDER BY mom_growth_pct ASC LIMIT 1) AS largest_negative_mom_growth_pct;
