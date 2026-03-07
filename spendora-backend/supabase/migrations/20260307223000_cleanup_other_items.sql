-- Manual Cleanup: Reclassify common grocery items stuck in 'other' due to language or brand naming
-- Focuses on Finnish and generic English items that often miss the AI classification

-- 1. Eggs (Kanamuna, Muna)
UPDATE receipt_items
SET super_category = 'groceries',
    category = 'dairy'
WHERE (name_raw ILIKE '%kanamuna%' OR name_raw ILIKE '% muna %' OR name_raw ILIKE 'muna %')
  AND (super_category IS NULL OR super_category = 'other' OR super_category = 'uncategorized');

-- 2. Chocolate & Sweets (Toblerone, Suklaa, Fazer)
UPDATE receipt_items
SET super_category = 'groceries',
    category = 'snack'
WHERE (name_raw ILIKE '%toblerone%' OR name_raw ILIKE '%suklaa%' OR name_raw ILIKE '%fazer%')
  AND (super_category IS NULL OR super_category = 'other' OR super_category = 'uncategorized');

-- 3. Common Beverages (Maito, Mehu, Kahvi, Water, Coke)
UPDATE receipt_items
SET super_category = 'groceries',
    category = 'beverage'
WHERE (name_raw ILIKE '%maito%' OR name_raw ILIKE '%mehu%' OR name_raw ILIKE '%kahvi%' OR name_raw ILIKE '%vesi%' OR name_raw ILIKE '%col %' OR name_raw ILIKE 'cola%')
  AND (super_category IS NULL OR super_category = 'other' OR super_category = 'uncategorized');

-- 4. Bread & Bakery (Leipä, Pulla, Croissant)
UPDATE receipt_items
SET super_category = 'groceries',
    category = 'bakery'
WHERE (name_raw ILIKE '%leipä%' OR name_raw ILIKE '%pulla%' OR name_raw ILIKE '%leipa%')
  AND (super_category IS NULL OR super_category = 'other' OR super_category = 'uncategorized');

-- 5. Fruits & Vegetables (Produce)
UPDATE receipt_items
SET super_category = 'groceries',
    category = 'fruits_vegetables'
WHERE (name_raw ILIKE '%omena%' OR name_raw ILIKE '%banaani%' OR name_raw ILIKE '%kurkku%' OR name_raw ILIKE '%tomaatti%' OR name_raw ILIKE '%peruna%')
  AND (super_category IS NULL OR super_category = 'other' OR super_category = 'uncategorized');

-- 6. Meat & Proteins (Kana, Jauheliha, Kalkkuna)
UPDATE receipt_items
SET super_category = 'groceries',
    category = 'meat'
WHERE (name_raw ILIKE '%kana%' OR name_raw ILIKE '%jauheli%' OR name_raw ILIKE '%kalkkuna%')
  AND (super_category IS NULL OR super_category = 'other' OR super_category = 'uncategorized');
