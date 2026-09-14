-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Analytical SQL
-- Challenge 9: Regional Creator Leadership via Window Functions
-- Database: SQLite 3 (data/data_vortex.db)
-- ====================================================================
-- Analytical Objective:
--   Identify leading content creators within each country based on audience reach.
--   Derives country dynamically from users.location, evaluates creator-level
--   post volume and average interaction benchmarks, ranks creators regionally
--   using DENSE_RANK(), and returns the top 3 creators per nation.
-- ====================================================================

-- --------------------------------------------------------------------
-- Query 1: Top 3 Regional Creators by Country (Window Function Ranking)
-- Extracts country dynamically handling Singapore, ranks creators
-- per country by follower_count DESC using DENSE_RANK(), and filters top 3.
-- --------------------------------------------------------------------
WITH user_countries AS (
    SELECT 
        u.user_id,
        u.location,
        CASE
            WHEN INSTR(u.location, ',') > 0
            THEN TRIM(SUBSTR(u.location, INSTR(u.location, ',') + 1))
            ELSE u.location
        END AS country,
        u.follower_count
    FROM users u
),
creator_stats AS (
    SELECT 
        uc.user_id,
        uc.location,
        uc.country,
        uc.follower_count,
        COUNT(p.post_id) AS post_count,
        ROUND(AVG(p.likes), 2) AS average_likes,
        ROUND(AVG(p.shares), 2) AS average_shares,
        ROUND(AVG(p.comments), 2) AS average_comments
    FROM user_countries uc
    INNER JOIN posts p ON uc.user_id = p.user_id
    GROUP BY uc.user_id, uc.location, uc.country, uc.follower_count
),
ranked_creators AS (
    SELECT 
        country,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY follower_count DESC
        ) AS regional_rank,
        user_id,
        location,
        follower_count,
        post_count,
        average_likes,
        average_shares,
        average_comments
    FROM creator_stats
)
SELECT 
    country,
    regional_rank,
    user_id,
    location,
    follower_count,
    post_count,
    average_likes,
    average_shares,
    average_comments
FROM ranked_creators
WHERE regional_rank <= 3
ORDER BY 
    country ASC,
    regional_rank ASC,
    follower_count DESC,
    user_id ASC;

-- --------------------------------------------------------------------
-- Query 2: Country Leadership Summary
-- Summarizes total creator volume and profiles the #1 ranked creator
-- (regional_rank = 1) for every country.
-- --------------------------------------------------------------------
WITH user_countries AS (
    SELECT 
        u.user_id,
        u.location,
        CASE
            WHEN INSTR(u.location, ',') > 0
            THEN TRIM(SUBSTR(u.location, INSTR(u.location, ',') + 1))
            ELSE u.location
        END AS country,
        u.follower_count
    FROM users u
),
creator_stats AS (
    SELECT 
        uc.user_id,
        uc.country,
        uc.follower_count,
        ROUND(AVG(p.likes), 2) AS average_likes
    FROM user_countries uc
    INNER JOIN posts p ON uc.user_id = p.user_id
    GROUP BY uc.user_id, uc.country, uc.follower_count
),
ranked_creators AS (
    SELECT 
        country,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY follower_count DESC
        ) AS regional_rank,
        user_id,
        follower_count,
        average_likes
    FROM creator_stats
),
country_counts AS (
    SELECT 
        country, 
        COUNT(*) AS number_of_creators
    FROM user_countries
    GROUP BY country
)
SELECT 
    cc.country,
    cc.number_of_creators,
    rc.user_id AS top_creator_user_id,
    rc.follower_count AS top_creator_followers,
    rc.average_likes AS top_creator_average_likes
FROM country_counts cc
INNER JOIN ranked_creators rc ON cc.country = rc.country AND rc.regional_rank = 1
ORDER BY 
    cc.number_of_creators DESC, 
    cc.country ASC;
