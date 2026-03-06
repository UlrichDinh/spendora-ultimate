-- ============================================================
-- Migration: Remap legacy category keys to new taxonomy
-- Updates receipt_items and canonical_items with new category keys
-- ============================================================

-- 1. receipt_items: remap legacy category values
UPDATE receipt_items SET category = 'meat'
WHERE category = 'meat_seafood';

UPDATE receipt_items SET category = 'dairy'
WHERE category = 'dairy_eggs';

UPDATE receipt_items SET category = 'fruits_vegetables'
WHERE category = 'produce';

UPDATE receipt_items SET category = 'beverage'
WHERE category = 'beverages';

UPDATE receipt_items SET category = 'snack'
WHERE category = 'snacks_sweets';

UPDATE receipt_items SET category = 'grains'
WHERE category = 'pantry';

UPDATE receipt_items SET category = 'personal_care'
WHERE category = 'baby_pet';

-- 2. canonical_items: remap legacy category values
UPDATE canonical_items SET category = 'meat'
WHERE category = 'meat_seafood';

UPDATE canonical_items SET category = 'dairy'
WHERE category = 'dairy_eggs';

UPDATE canonical_items SET category = 'fruits_vegetables'
WHERE category = 'produce';

UPDATE canonical_items SET category = 'beverage'
WHERE category = 'beverages';

UPDATE canonical_items SET category = 'snack'
WHERE category = 'snacks_sweets';

UPDATE canonical_items SET category = 'grains'
WHERE category = 'pantry';

UPDATE canonical_items SET category = 'personal_care'
WHERE category = 'baby_pet';

-- 3. item_classification_overrides: remap legacy category values
UPDATE item_classification_overrides SET category = 'meat'
WHERE category = 'meat_seafood';

UPDATE item_classification_overrides SET category = 'dairy'
WHERE category = 'dairy_eggs';

UPDATE item_classification_overrides SET category = 'fruits_vegetables'
WHERE category = 'produce';

UPDATE item_classification_overrides SET category = 'beverage'
WHERE category = 'beverages';

UPDATE item_classification_overrides SET category = 'snack'
WHERE category = 'snacks_sweets';

UPDATE item_classification_overrides SET category = 'grains'
WHERE category = 'pantry';

UPDATE item_classification_overrides SET category = 'personal_care'
WHERE category = 'baby_pet';
