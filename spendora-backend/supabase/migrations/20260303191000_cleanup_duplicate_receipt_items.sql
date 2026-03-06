-- ============================================================
-- Migration: Remove duplicate receipt_items within same receipt
-- Keeps only one copy per (receipt_id, name_raw, line_total)
-- ============================================================

DELETE FROM receipt_items
WHERE id NOT IN (
  SELECT DISTINCT ON (receipt_id, name_raw, line_total) id
  FROM receipt_items
  ORDER BY receipt_id, name_raw, line_total, created_at ASC
);
