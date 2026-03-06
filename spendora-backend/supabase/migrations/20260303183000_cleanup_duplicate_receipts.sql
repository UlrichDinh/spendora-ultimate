-- ============================================================
-- Migration: Clean up duplicate receipts
-- Keeps only the newest receipt per (user_id, store_name, receipt_date, grand_total)
-- and deletes older duplicates (cascade deletes receipt_items and price_history)
-- ============================================================

DELETE FROM receipts
WHERE id NOT IN (
  SELECT DISTINCT ON (user_id, store_name, receipt_date, grand_total) id
  FROM receipts
  ORDER BY user_id, store_name, receipt_date, grand_total, created_at DESC
);
