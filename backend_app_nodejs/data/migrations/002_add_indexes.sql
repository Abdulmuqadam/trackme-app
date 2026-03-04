-- Migration 002: Add indexes to improve query performance
-- Run after 001_add_audio_url.sql

-- Queries table
ALTER TABLE queries ADD INDEX idx_queries_assignedTo (assignedTo);
ALTER TABLE queries ADD INDEX idx_queries_postedBy (postedBy);
ALTER TABLE queries ADD INDEX idx_queries_querytype_completed (querytype, completed);
ALTER TABLE queries ADD INDEX idx_queries_createdAt (createdAt);

-- Users table
ALTER TABLE users ADD UNIQUE INDEX idx_users_email (email);

-- Facilitators table
ALTER TABLE facilitators ADD UNIQUE INDEX idx_facilitators_email (email);
ALTER TABLE facilitators ADD INDEX idx_facilitators_role (role);
