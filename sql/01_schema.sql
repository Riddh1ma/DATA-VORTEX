-- ====================================================================
-- Data Vortex — Round 1 Phase 2: Relational Database Schema
-- Database: SQLite 3
-- Target File: data/data_vortex.db
-- ====================================================================

-- Enforce Foreign Key Constraints
PRAGMA foreign_keys = ON;

-- ====================================================================
-- Table 1: users
-- Represents unique registered social engine user profiles.
-- Source: data/cleaned/Social_Engine_Users_Cleaned.csv (1,500 records)
-- ====================================================================
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id          TEXT PRIMARY KEY NOT NULL,
    location         TEXT NOT NULL,
    language         TEXT NOT NULL,
    account_created  TEXT NOT NULL,
    follower_count   INTEGER NOT NULL
);

-- ====================================================================
-- Table 2: posts
-- Represents published social engine post interactions.
-- Source: data/cleaned/Social_Engine_Posts_Cleaned.csv (12,000 records)
-- Referential link: posts.user_id references users.user_id (1-to-many)
-- ====================================================================
CREATE TABLE posts (
    post_id       TEXT PRIMARY KEY NOT NULL,
    user_id       TEXT NOT NULL,
    platform      TEXT,
    text_content  TEXT,
    timestamp     TEXT NOT NULL,
    likes         INTEGER,
    shares        INTEGER NOT NULL,
    comments      INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ====================================================================
-- Justified Indexes
-- Optimized for relational joins, temporal filtering, and platform analytics
-- ====================================================================

-- Foreign key lookup & JOIN optimization
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- Chronological range filtering & time-series analysis
CREATE INDEX idx_posts_timestamp ON posts(timestamp);

-- Platform aggregation and filtering
CREATE INDEX idx_posts_platform ON posts(platform);
