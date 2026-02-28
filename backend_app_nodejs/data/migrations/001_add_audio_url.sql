-- Migration 001: Replace base64 audio column with S3 URL column
-- Run this BEFORE deploying the S3-enabled backend.
-- Existing base64 data in `audio` is preserved in `audio_legacy` for manual migration.

-- 1. Rename old column so data isn't lost
ALTER TABLE queries
  CHANGE COLUMN audio audio_legacy LONGTEXT NULL;

-- 2. Add new URL column
ALTER TABLE queries
  ADD COLUMN audio_url VARCHAR(512) NULL AFTER audio_legacy;

-- Rollback:
-- ALTER TABLE queries DROP COLUMN audio_url;
-- ALTER TABLE queries CHANGE COLUMN audio_legacy audio LONGTEXT NULL;
