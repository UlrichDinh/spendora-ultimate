-- Backfill: set receipts.category from the dominant super_category of their items.
-- This fixes receipts that were saved without a category (NULL or 'General').

UPDATE receipts r
SET category = dominant.super_category
FROM (
  SELECT
    ri.receipt_id,
    ri.super_category,
    ROW_NUMBER() OVER (
      PARTITION BY ri.receipt_id
      ORDER BY COUNT(*) DESC
    ) AS rn
  FROM receipt_items ri
  WHERE ri.super_category IS NOT NULL
  GROUP BY ri.receipt_id, ri.super_category
) dominant
WHERE dominant.receipt_id = r.id
  AND dominant.rn = 1
  AND (r.category IS NULL OR r.category = 'General' OR r.category = 'uncategorized');
