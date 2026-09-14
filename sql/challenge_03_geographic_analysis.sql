-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Analytical SQL
-- Challenge 3: Geographic Representation & Country Aggregation
-- Database: SQLite 3 (data/data_vortex.db)
-- ====================================================================
-- Analytical Objective:
--   Derive national entities from "City, Country" location strings,
--   correctly handling the sovereign city-state "Singapore" (no comma).
--   Perform country-level user demographic and post interaction analyses,
--   and retrieve the top 10 countries by post volume.
-- ====================================================================

-- --------------------------------------------------------------------
-- Query 1: Country-Level User Demographic Analysis
-- For each country: user count, average/min/max followers
-- --------------------------------------------------------------------
WITH user_countries AS (
    SELECT 
        user_id,
        follower_count,
        CASE 
            WHEN INSTR(location, ',') > 0 THEN TRIM(SUBSTR(location, INSTR(location, ',') + 1))
            ELSE location 
        END AS country
    FROM users
)
SELECT 
    country,
    COUNT(*) AS user_count,
    ROUND(AVG(follower_count), 2) AS avg_followers,
    MIN(follower_count) AS min_followers,
    MAX(follower_count) AS max_followers
FROM user_countries
GROUP BY country
ORDER BY user_count DESC, country ASC;

-- --------------------------------------------------------------------
-- Query 2: Country-Level Post Publishing & Interaction Analysis
-- For each country: user count, post volume, posts per user,
-- and average likes, shares, comments
-- --------------------------------------------------------------------
WITH user_countries AS (
    SELECT 
        user_id,
        CASE 
            WHEN INSTR(location, ',') > 0 THEN TRIM(SUBSTR(location, INSTR(location, ',') + 1))
            ELSE location 
        END AS country
    FROM users
)
SELECT 
    uc.country,
    COUNT(DISTINCT uc.user_id) AS user_count,
    COUNT(p.post_id) AS post_count,
    ROUND(CAST(COUNT(p.post_id) AS REAL) / COUNT(DISTINCT uc.user_id), 2) AS avg_posts_per_user,
    ROUND(AVG(p.likes), 2) AS avg_likes,
    ROUND(AVG(p.shares), 2) AS avg_shares,
    ROUND(AVG(p.comments), 2) AS avg_comments
FROM user_countries uc
INNER JOIN posts p ON uc.user_id = p.user_id
GROUP BY uc.country
ORDER BY post_count DESC, uc.country ASC;

-- --------------------------------------------------------------------
-- Query 3: Top 10 Countries by Post Volume
-- --------------------------------------------------------------------
WITH user_countries AS (
    SELECT 
        user_id,
        CASE 
            WHEN INSTR(location, ',') > 0 THEN TRIM(SUBSTR(location, INSTR(location, ',') + 1))
            ELSE location 
        END AS country
    FROM users
)
SELECT 
    uc.country,
    COUNT(DISTINCT uc.user_id) AS user_count,
    COUNT(p.post_id) AS post_count,
    ROUND(CAST(COUNT(p.post_id) AS REAL) / COUNT(DISTINCT uc.user_id), 2) AS avg_posts_per_user,
    ROUND(AVG(p.likes), 2) AS avg_likes,
    ROUND(AVG(p.shares), 2) AS avg_shares,
    ROUND(AVG(p.comments), 2) AS avg_comments
FROM user_countries uc
INNER JOIN posts p ON uc.user_id = p.user_id
GROUP BY uc.country
ORDER BY post_count DESC, uc.country ASC
LIMIT 10;
