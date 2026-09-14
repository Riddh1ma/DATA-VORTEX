-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Analytical SQL
-- Challenge 5: Monthly Publishing Volume & Trends
-- Database: SQLite 3 (data/data_vortex.db)
-- ====================================================================
-- Analytical Objective:
--   Analyze post publishing volume over time by calendar month using
--   the timestamp column. Calculate month-over-month (MoM) volume changes,
--   percentage variations, and cumulative post counts using window functions.
--   Identify peak and trough publishing months as well as largest MoM shifts.
-- ====================================================================

-- --------------------------------------------------------------------
-- Query 1: Monthly Publishing Trends & Window Calculations
-- Returns:
--   - month (YYYY-MM)
--   - monthly_post_count
--   - month_over_month_change
--   - month_over_month_change_pct
--   - cumulative_post_count
-- First Month Handling:
--   The first month (2024-05) has no preceding record, so
--   month_over_month_change and month_over_month_change_pct evaluate to NULL.
-- --------------------------------------------------------------------
WITH monthly_aggregation AS (
    SELECT 
        strftime('%Y-%m', timestamp) AS month,
        COUNT(post_id) AS monthly_post_count
    FROM posts
    GROUP BY strftime('%Y-%m', timestamp)
)
SELECT 
    month,
    monthly_post_count,
    monthly_post_count - LAG(monthly_post_count) OVER (ORDER BY month) AS month_over_month_change,
    ROUND(
        100.0 * (monthly_post_count - LAG(monthly_post_count) OVER (ORDER BY month)) 
        / LAG(monthly_post_count) OVER (ORDER BY month), 
        2
    ) AS month_over_month_change_pct,
    SUM(monthly_post_count) OVER (
        ORDER BY month 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_post_count
FROM monthly_aggregation
ORDER BY month ASC;

-- --------------------------------------------------------------------
-- Query 2: Monthly Extremes & Largest MoM Trajectory Shifts
-- Identifies:
--   - Month with highest post volume
--   - Month with lowest post volume
--   - Largest positive MoM increase
--   - Largest negative MoM decrease
-- --------------------------------------------------------------------
WITH monthly_aggregation AS (
    SELECT 
        strftime('%Y-%m', timestamp) AS month,
        COUNT(post_id) AS monthly_post_count
    FROM posts
    GROUP BY strftime('%Y-%m', timestamp)
),
monthly_trends AS (
    SELECT 
        month,
        monthly_post_count,
        monthly_post_count - LAG(monthly_post_count) OVER (ORDER BY month) AS mom_change,
        ROUND(
            100.0 * (monthly_post_count - LAG(monthly_post_count) OVER (ORDER BY month)) 
            / LAG(monthly_post_count) OVER (ORDER BY month), 
            2
        ) AS mom_change_pct
    FROM monthly_aggregation
)
SELECT * FROM (
    SELECT 
        'Month with Highest Post Volume' AS metric, 
        month, 
        monthly_post_count AS metric_value, 
        NULL AS mom_change_pct
    FROM monthly_aggregation
    ORDER BY monthly_post_count DESC 
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT 
        'Month with Lowest Post Volume' AS metric, 
        month, 
        monthly_post_count AS metric_value, 
        NULL AS mom_change_pct
    FROM monthly_aggregation
    ORDER BY monthly_post_count ASC 
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT 
        'Largest Positive MoM Increase' AS metric, 
        month, 
        mom_change AS metric_value, 
        mom_change_pct
    FROM monthly_trends
    WHERE mom_change IS NOT NULL
    ORDER BY mom_change DESC 
    LIMIT 1
)
UNION ALL
SELECT * FROM (
    SELECT 
        'Largest Negative MoM Decrease' AS metric, 
        month, 
        mom_change AS metric_value, 
        mom_change_pct
    FROM monthly_trends
    WHERE mom_change IS NOT NULL
    ORDER BY mom_change ASC 
    LIMIT 1
);
