-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Analytical SQL
-- Challenge 7: Audience Reach vs. Engagement
-- Database: SQLite 3 (data/data_vortex.db)
-- ====================================================================
-- Analytical Objective:
--   Analyze whether creators with larger follower counts demonstrate
--   higher average post engagement (likes, shares, comments).
--   Groups creators into three audience tiers:
--     - Small Audience:   < 10,000 followers
--     - Medium Audience:  10,000–29,999 followers
--     - Large Audience:   30,000+ followers
--   Evaluates segment-level averages and calculates the exact
--   Pearson correlation coefficient (r) manually in SQLite.
-- ====================================================================

-- --------------------------------------------------------------------
-- Query 1: Creator-Level Audience & Engagement Classification
-- Calculates creator-level post volume and average interaction metrics,
-- categorizing each user into an audience group.
-- --------------------------------------------------------------------
WITH creator_stats AS (
    SELECT 
        u.user_id,
        u.location,
        u.follower_count,
        COUNT(p.post_id) AS post_count,
        ROUND(AVG(p.likes), 2) AS avg_likes,
        ROUND(AVG(p.shares), 2) AS avg_shares,
        ROUND(AVG(p.comments), 2) AS avg_comments,
        CASE
            WHEN u.follower_count < 10000 THEN 'Small Audience'
            WHEN u.follower_count BETWEEN 10000 AND 29999 THEN 'Medium Audience'
            WHEN u.follower_count >= 30000 THEN 'Large Audience'
        END AS audience_group
    FROM users u
    INNER JOIN posts p ON u.user_id = p.user_id
    GROUP BY u.user_id, u.location, u.follower_count
)
SELECT 
    user_id,
    location,
    follower_count,
    post_count,
    avg_likes,
    avg_shares,
    avg_comments,
    audience_group
FROM creator_stats
ORDER BY follower_count DESC;

-- --------------------------------------------------------------------
-- Query 2: Audience Group Summary & Interaction Metrics
-- Aggregates metrics by audience tier:
--   - creator count & percentage share
--   - average follower count
--   - total post volume
--   - average likes, shares, and comments per post
-- --------------------------------------------------------------------
WITH creator_groups AS (
    SELECT 
        user_id,
        follower_count,
        CASE
            WHEN follower_count < 10000 THEN 'Small Audience'
            WHEN follower_count BETWEEN 10000 AND 29999 THEN 'Medium Audience'
            WHEN follower_count >= 30000 THEN 'Large Audience'
        END AS audience_group
    FROM users
),
group_creators AS (
    SELECT 
        audience_group,
        COUNT(*) AS creator_count,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM users), 2) AS percentage_of_creators,
        ROUND(AVG(follower_count), 2) AS avg_follower_count
    FROM creator_groups
    GROUP BY audience_group
),
group_posts AS (
    SELECT 
        cg.audience_group,
        COUNT(p.post_id) AS total_posts,
        ROUND(AVG(p.likes), 2) AS avg_likes_per_post,
        ROUND(AVG(p.shares), 2) AS avg_shares_per_post,
        ROUND(AVG(p.comments), 2) AS avg_comments_per_post
    FROM posts p
    INNER JOIN creator_groups cg ON p.user_id = cg.user_id
    GROUP BY cg.audience_group
)
SELECT 
    gc.audience_group,
    gc.creator_count,
    gc.percentage_of_creators,
    gc.avg_follower_count,
    gp.total_posts,
    gp.avg_likes_per_post,
    gp.avg_shares_per_post,
    gp.avg_comments_per_post
FROM group_creators gc
INNER JOIN group_posts gp ON gc.audience_group = gp.audience_group
ORDER BY 
    CASE gc.audience_group
        WHEN 'Small Audience' THEN 1
        WHEN 'Medium Audience' THEN 2
        WHEN 'Large Audience' THEN 3
    END;

-- --------------------------------------------------------------------
-- Query 3: Manual Pearson Correlation Calculation
-- Computes the Pearson correlation coefficient r between follower_count
-- and each creator-level engagement metric:
--   r = (N * SUM(X*Y) - SUM(X)*SUM(Y)) / (SQRT(N*SUM(X^2) - (SUM(X))^2) * SQRT(N*SUM(Y^2) - (SUM(Y))^2))
-- Evaluates pairwise complete observations for likes (N=1498 due to 2 creators
-- with exclusively NULL likes) and full population for shares and comments (N=1500).
-- --------------------------------------------------------------------
WITH creator_stats AS (
    SELECT 
        u.user_id,
        CAST(u.follower_count AS REAL) AS followers,
        AVG(p.likes) AS avg_likes,
        AVG(p.shares) AS avg_shares,
        AVG(p.comments) AS avg_comments
    FROM users u
    INNER JOIN posts p ON u.user_id = p.user_id
    GROUP BY u.user_id, u.follower_count
),
corr_likes AS (
    SELECT 
        COUNT(*) AS n_likes,
        ROUND(
            (COUNT(*) * SUM(followers * avg_likes) - SUM(followers) * SUM(avg_likes)) /
            (SQRT(COUNT(*) * SUM(followers * followers) - SUM(followers) * SUM(followers)) *
             SQRT(COUNT(*) * SUM(avg_likes * avg_likes) - SUM(avg_likes) * SUM(avg_likes))),
            4
        ) AS pearson_r_likes
    FROM creator_stats
    WHERE avg_likes IS NOT NULL
),
corr_shares AS (
    SELECT 
        COUNT(*) AS n_shares,
        ROUND(
            (COUNT(*) * SUM(followers * avg_shares) - SUM(followers) * SUM(avg_shares)) /
            (SQRT(COUNT(*) * SUM(followers * followers) - SUM(followers) * SUM(followers)) *
             SQRT(COUNT(*) * SUM(avg_shares * avg_shares) - SUM(avg_shares) * SUM(avg_shares))),
            4
        ) AS pearson_r_shares
    FROM creator_stats
    WHERE avg_shares IS NOT NULL
),
corr_comments AS (
    SELECT 
        COUNT(*) AS n_comments,
        ROUND(
            (COUNT(*) * SUM(followers * avg_comments) - SUM(followers) * SUM(avg_comments)) /
            (SQRT(COUNT(*) * SUM(followers * followers) - SUM(followers) * SUM(followers)) *
             SQRT(COUNT(*) * SUM(avg_comments * avg_comments) - SUM(avg_comments) * SUM(avg_comments))),
            4
        ) AS pearson_r_comments
    FROM creator_stats
    WHERE avg_comments IS NOT NULL
)
SELECT 
    cl.n_likes,
    cl.pearson_r_likes,
    cs.n_shares,
    cs.pearson_r_shares,
    cc.n_comments,
    cc.pearson_r_comments
FROM corr_likes cl
CROSS JOIN corr_shares cs
CROSS JOIN corr_comments cc;
