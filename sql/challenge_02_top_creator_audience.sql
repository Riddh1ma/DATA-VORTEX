-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Analytical SQL
-- Challenge 2: Top Creator Audience Leaderboard
-- Database: SQLite 3 (data/data_vortex.db)
-- ====================================================================
-- Analytical Objective:
--   Rank social engine creators by follower count.
--   For each creator, retrieve user demographics (location, language, audience size)
--   and calculate total posts authored, average likes, average shares, and average comments.
--
-- Relational Mechanics:
--   - INNER JOIN connects users and posts on user_id (only users with >= 1 post included).
--   - GROUP BY aggregates multiple post records per user profile.
--   - COUNT(p.post_id) counts authored posts.
--   - AVG() naturally ignores NULL values in likes without artificial imputation.
--   - ORDER BY sorts the leaderboard by follower_count descending.
--   - LIMIT restricts the output to the top 20 creators.
-- ====================================================================

SELECT 
    u.user_id,
    u.location,
    u.language,
    u.follower_count,
    COUNT(p.post_id) AS post_count,
    ROUND(AVG(p.likes), 2) AS avg_likes,
    ROUND(AVG(p.shares), 2) AS avg_shares,
    ROUND(AVG(p.comments), 2) AS avg_comments
FROM users u
INNER JOIN posts p ON u.user_id = p.user_id
GROUP BY 
    u.user_id, 
    u.location, 
    u.language, 
    u.follower_count
ORDER BY u.follower_count DESC
LIMIT 20;
