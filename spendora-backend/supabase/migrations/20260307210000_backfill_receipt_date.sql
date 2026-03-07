-- Backfill receipt_date on receipt_items from parent receipts
-- This ensures that category drilldown queries using the item-level receipt_date correctly find the items

UPDATE receipt_items
SET receipt_date = receipts.receipt_date
FROM receipts
WHERE receipt_items.receipt_id = receipts.id
  AND receipt_items.receipt_date IS NULL;
