-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Analytical SQL
-- Challenge 4: Creator Activity Segmentation
-- Database: SQLite 3 (data/data_vortex.db)
-- ====================================================================
-- Analytical Objective:
--   Segment creators according to their posting activity volume:
--     - Low Activity:    1–5 posts
--     - Medium Activity: 6–10 posts
--     - High Activity:   11+ posts
--   Calculate creator-level metrics, evaluate segment distribution,
--   summarize cross-segment performance (followers & engagement),
--   and rank top creators within each activity tier using window functions.
-- ====================================================================

-- --------------------------------------------------------------------
-- Query 1: Creator-Level Activity & Segmentation (Tasks 1 & 2)
-- Calculates user_id, location, follower_count, post_count,
-- and classifies each creator into an activity segment.
-- --------------------------------------------------------------------
WITH creator_activity AS (
    SELECT 
        u.user_id,
        u.location,
        u.follower_count,
        COUNT(p.post_id) AS post_count
    FROM users u
    INNER JOIN posts p ON u.user_id = p.user_id
    GROUP BY u.user_id, u.location, u.follower_count
)
SELECT 
    user_id,
    location,
    follower_count,
    post_count,
    CASE
        WHEN post_count BETWEEN 1 AND 5 THEN 'Low Activity'
        WHEN post_count BETWEEN 6 AND 10 THEN 'Medium Activity'
        WHEN post_count >= 11 THEN 'High Activity'
    END AS activity_segment
FROM creator_activity
ORDER BY post_count DESC, user_id ASC;

-- --------------------------------------------------------------------
-- Query 2: Segment Summary & Creator Distribution (Tasks 3 & 4)
-- Aggregates metrics by activity segment:
--   - creator count & percentage of creator base
--   - total post volume
--   - average posts per creator
--   - average follower count per creator
--   - average likes, shares, and comments per post
-- NULL Handling Note:
--   AVG() naturally skips NULL likes (1,814 occurrences), evaluating
--   strictly over observed non-NULL values without distorting the denominator.
-- --------------------------------------------------------------------
WITH creator_activity AS (
    SELECT 
        u.user_id,
        u.follower_count,
        COUNT(p.post_id) AS post_count
    FROM users u
    INNER JOIN posts p ON u.user_id = p.user_id
    GROUP BY u.user_id, u.follower_count
),
creator_segments AS (
    SELECT 
        user_id,
        follower_count,
        post_count,
        CASE
            WHEN post_count BETWEEN 1 AND 5 THEN 'Low Activity'
            WHEN post_count BETWEEN 6 AND 10 THEN 'Medium Activity'
            WHEN post_count >= 11 THEN 'High Activity'
        END AS activity_segment
    FROM creator_activity
),
segment_creators AS (
    SELECT 
        activity_segment,
        COUNT(*) AS creator_count,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM users), 2) AS creator_percentage,
        ROUND(AVG(post_count), 2) AS avg_posts_per_creator,
        ROUND(AVG(follower_count), 2) AS avg_follower_count
    FROM creator_segments
    GROUP BY activity_segment
),
segment_posts AS (
    SELECT 
        cs.activity_segment,
        COUNT(p.post_id) AS total_posts,
        ROUND(AVG(p.likes), 2) AS avg_likes_per_post,
        ROUND(AVG(p.shares), 2) AS avg_shares_per_post,
        ROUND(AVG(p.comments), 2) AS avg_comments_per_post
    FROM posts p
    INNER JOIN creator_segments cs ON p.user_id = cs.user_id
    GROUP BY cs.activity_segment
)
SELECT 
    sc.activity_segment,
    sc.creator_count,
    sc.creator_percentage,
    sp.total_posts,
    sc.avg_posts_per_creator,
    sc.avg_follower_count,
    sp.avg_likes_per_post,
    sp.avg_shares_per_post,
    sp.avg_comments_per_post
FROM segment_creators sc
INNER JOIN segment_posts sp ON sc.activity_segment = sp.activity_segment
ORDER BY 
    CASE sc.activity_segment
        WHEN 'Low Activity' THEN 1
        WHEN 'Medium Activity' THEN 2
        WHEN 'High Activity' THEN 3
    END;

-- --------------------------------------------------------------------
-- Query 2B (Complementary Macro-Average): Creator-Level Macro Summary
-- Evaluates the unweighted average across creator averages:
-- gives equal weight to each creator regardless of posting frequency.
-- --------------------------------------------------------------------
WITH creator_stats AS (
    SELECT 
        u.user_id,
        u.follower_count,
        COUNT(p.post_id) AS post_count,
        AVG(p.likes) AS user_avg_likes,
        AVG(p.shares) AS user_avg_shares,
        AVG(p.comments) AS user_avg_comments,
        CASE
            WHEN COUNT(p.post_id) BETWEEN 1 AND 5 THEN 'Low Activity'
            WHEN COUNT(p.post_id) BETWEEN 6 AND 10 THEN 'Medium Activity'
            WHEN COUNT(p.post_id) >= 11 THEN 'High Activity'
        END AS activity_segment
    FROM users u
    INNER JOIN posts p ON u.user_id = p.user_id
    GROUP BY u.user_id, u.follower_count
)
SELECT 
    activity_segment,
    COUNT(*) AS creator_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM users), 2) AS creator_percentage,
    ROUND(AVG(post_count), 2) AS avg_posts_per_creator,
    ROUND(AVG(follower_count), 2) AS avg_follower_count,
    ROUND(AVG(user_avg_likes), 2) AS avg_likes_per_creator,
    ROUND(AVG(user_avg_shares), 2) AS avg_shares_per_creator,
    ROUND(AVG(user_avg_comments), 2) AS avg_comments_per_creator
FROM creator_stats
GROUP BY activity_segment
ORDER BY 
    CASE activity_segment
        WHEN 'Low Activity' THEN 1
        WHEN 'Medium Activity' THEN 2
        WHEN 'High Activity' THEN 3
    END;

-- --------------------------------------------------------------------
-- Query 3: Segment Extremes Identification (Task 5)
-- Computes the minimum, maximum, and extreme indicators for each segment.
-- --------------------------------------------------------------------
WITH creator_activity AS (
    SELECT 
        u.user_id,
        u.follower_count,
        COUNT(p.post_id) AS post_count
    FROM users u
    INNER JOIN posts p ON u.user_id = p.user_id
    GROUP BY u.user_id, u.follower_count
),
creator_segments AS (
    SELECT 
        user_id,
        follower_count,
        post_count,
        CASE
            WHEN post_count BETWEEN 1 AND 5 THEN 'Low Activity'
            WHEN post_count BETWEEN 6 AND 10 THEN 'Medium Activity'
            WHEN post_count >= 11 THEN 'High Activity'
        END AS activity_segment
    FROM creator_activity
),
segment_metrics AS (
    SELECT 
        cs.activity_segment,
        COUNT(DISTINCT cs.user_id) AS creator_count,
        ROUND(AVG(cs.post_count), 2) AS avg_posts_per_creator,
        ROUND(AVG(cs.follower_count), 2) AS avg_follower_count,
        ROUND(AVG(p.likes), 2) AS avg_likes_per_post
    FROM creator_segments cs
    INNER JOIN posts p ON cs.user_id = p.user_id
    GROUP BY cs.activity_segment
)
SELECT 
    activity_segment,
    creator_count,
    avg_posts_per_creator,
    avg_follower_count,
    avg_likes_per_post
FROM segment_metrics
ORDER BY creator_count DESC;

-- --------------------------------------------------------------------
-- Query 4: Top 5 Creators within Each Activity Segment (Task 6)
-- Ranks creators within each segment by:
--   1. avg_likes DESC
--   2. follower_count DESC (tie-breaker)
-- Uses ROW_NUMBER() OVER (PARTITION BY activity_segment ORDER BY ...)
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
            WHEN COUNT(p.post_id) BETWEEN 1 AND 5 THEN 'Low Activity'
            WHEN COUNT(p.post_id) BETWEEN 6 AND 10 THEN 'Medium Activity'
            WHEN COUNT(p.post_id) >= 11 THEN 'High Activity'
        END AS activity_segment
    FROM users u
    INNER JOIN posts p ON u.user_id = p.user_id
    GROUP BY u.user_id, u.location, u.follower_count
),
ranked_creators AS (
    SELECT 
        activity_segment,
        user_id,
        location,
        follower_count,
        post_count,
        avg_likes,
        avg_shares,
        avg_comments,
        ROW_NUMBER() OVER (
            PARTITION BY activity_segment 
            ORDER BY avg_likes DESC, follower_count DESC
        ) AS rank_in_segment
    FROM creator_stats
)
SELECT 
    activity_segment,
    rank_in_segment,
    user_id,
    location,
    follower_count,
    post_count,
    avg_likes,
    avg_shares,
    avg_comments
FROM ranked_creators
WHERE rank_in_segment <= 5
ORDER BY 
    CASE activity_segment
        WHEN 'Low Activity' THEN 1
        WHEN 'Medium Activity' THEN 2
        WHEN 'High Activity' THEN 3
    END,
    rank_in_segment ASC;
