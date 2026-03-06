-- Backfill: update receipts category from store name inference
-- Maps known Finnish store name patterns to correct super categories

UPDATE receipts SET category = 'health'
WHERE store_name ILIKE '%apteekki%'
  AND (category IS NULL OR category = 'General' OR category = 'uncategorized');

UPDATE receipts SET category = 'groceries'
WHERE (
  store_name ILIKE '%market%'
  OR store_name ILIKE '%prisma%'
  OR store_name ILIKE '%lidl%'
  OR store_name ILIKE '%k-city%'
  OR store_name ILIKE '%s-market%'
  OR store_name ILIKE '%alepa%'
  OR store_name ILIKE '%sale%'
  OR store_name ILIKE '%tokman%'
  OR store_name ILIKE '%ruoka%'
)
AND (category IS NULL OR category = 'General' OR category = 'uncategorized');

UPDATE receipts SET category = 'dining'
WHERE (
  store_name ILIKE '%ravintola%'
  OR store_name ILIKE '%restaurant%'
  OR store_name ILIKE '%mcdonald%'
  OR store_name ILIKE '%burger%'
  OR store_name ILIKE '%pizza%'
  OR store_name ILIKE '%cafe%'
  OR store_name ILIKE '%kahvi%'
)
AND (category IS NULL OR category = 'General' OR category = 'uncategorized');

UPDATE receipts SET category = 'transport'
WHERE (
  store_name ILIKE '%neste%'
  OR store_name ILIKE '%abc%'
  OR store_name ILIKE '%st1%'
  OR store_name ILIKE '%shell%'
)
AND (category IS NULL OR category = 'General' OR category = 'uncategorized');

UPDATE receipts SET category = 'electronics'
WHERE (
  store_name ILIKE '%gigantti%'
  OR store_name ILIKE '%verkkokauppa%'
  OR store_name ILIKE '%power%'
)
AND (category IS NULL OR category = 'General' OR category = 'uncategorized');
