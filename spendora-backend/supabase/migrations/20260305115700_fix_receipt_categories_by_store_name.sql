-- Comprehensive fix: set receipts.category for ALL remaining uncategorized receipts
-- using store name pattern matching (covers cases where receipt_items lack super_category)

-- Grocery stores
UPDATE receipts SET category = 'groceries'
WHERE (
  store_name ILIKE '%lidl%'
  OR store_name ILIKE '%market%'
  OR store_name ILIKE '%prisma%'
  OR store_name ILIKE '%k-city%'
  OR store_name ILIKE '%s-market%'
  OR store_name ILIKE '%alepa%'
  OR store_name ILIKE '%sale%'
  OR store_name ILIKE '%tokman%'
  OR store_name ILIKE '%ruoka%'
  OR store_name ILIKE '%grocery%'
  OR store_name ILIKE '%supermarket%'
  OR store_name ILIKE '%aldi%'
  OR store_name ILIKE '%carrefour%'
  OR store_name ILIKE '%tesco%'
  OR store_name ILIKE '%walmart%'
  OR store_name ILIKE '%k-supermarket%'
  OR store_name ILIKE '%k market%'
)
AND (category IS NULL OR category = 'General' OR category = 'uncategorized' OR category = 'other');

-- Pharmacies / Health
UPDATE receipts SET category = 'health'
WHERE (
  store_name ILIKE '%apteekki%'
  OR store_name ILIKE '%pharmacy%'
  OR store_name ILIKE '%apotheke%'
  OR store_name ILIKE '%apotek%'
)
AND (category IS NULL OR category = 'General' OR category = 'uncategorized' OR category = 'other');

-- Dining
UPDATE receipts SET category = 'dining'
WHERE (
  store_name ILIKE '%ravintola%'
  OR store_name ILIKE '%restaurant%'
  OR store_name ILIKE '%mcdonald%'
  OR store_name ILIKE '%burger%'
  OR store_name ILIKE '%pizza%'
  OR store_name ILIKE '%cafe%'
  OR store_name ILIKE '%kahvi%'
  OR store_name ILIKE '%subway%'
  OR store_name ILIKE '%kebab%'
)
AND (category IS NULL OR category = 'General' OR category = 'uncategorized' OR category = 'other');

-- Transport / Fuel
UPDATE receipts SET category = 'transport'
WHERE (
  store_name ILIKE '%neste%'
  OR store_name ILIKE '%abc%'
  OR store_name ILIKE '%st1%'
  OR store_name ILIKE '%shell%'
  OR store_name ILIKE '%fuel%'
  OR store_name ILIKE '%gas station%'
)
AND (category IS NULL OR category = 'General' OR category = 'uncategorized' OR category = 'other');

-- Electronics
UPDATE receipts SET category = 'electronics'
WHERE (
  store_name ILIKE '%gigantti%'
  OR store_name ILIKE '%verkkokauppa%'
  OR store_name ILIKE '%power%'
  OR store_name ILIKE '%electronics%'
)
AND (category IS NULL OR category = 'General' OR category = 'uncategorized' OR category = 'other');
