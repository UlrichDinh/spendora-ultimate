-- Add unique constraint on item_aliases for upsert support
-- This ensures one canonical mapping per (raw_name, merchant, user) combination
ALTER TABLE item_aliases
  ADD CONSTRAINT item_aliases_raw_name_merchant_user_unique
  UNIQUE (raw_name, merchant_id, user_id);
