-- ============================================================
-- Migration: 3-Level Taxonomy Upgrade
-- Adds super_category, denormalized fields, and overrides table
-- ============================================================

-- 1. Add super_category to receipt_items
ALTER TABLE receipt_items ADD COLUMN IF NOT EXISTS super_category TEXT;

-- 2. Add super_category to canonical_items
ALTER TABLE canonical_items ADD COLUMN IF NOT EXISTS super_category TEXT;

-- 3. Denormalize store_name + receipt_date into receipt_items
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'receipt_items' AND column_name = 'store_name'
  ) THEN
    ALTER TABLE receipt_items ADD COLUMN store_name TEXT;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'receipt_items' AND column_name = 'receipt_date'
  ) THEN
    ALTER TABLE receipt_items ADD COLUMN receipt_date DATE;
  END IF;
END $$;

-- 4. Backfill receipt_date and store_name from receipts
UPDATE receipt_items ri
SET receipt_date = r.receipt_date,
    store_name = COALESCE(r.store_name, '')
FROM receipts r
WHERE ri.receipt_id = r.id
  AND ri.receipt_date IS NULL;

-- 5. Create item_classification_overrides table
CREATE TABLE IF NOT EXISTS item_classification_overrides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  canonical_name TEXT NOT NULL,
  super_category TEXT NOT NULL,
  category TEXT NOT NULL,
  subcategory TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, canonical_name)
);

-- 6. Indexes for analytics performance (no user_id on receipt_items)
CREATE INDEX IF NOT EXISTS idx_ri_supercat_date
  ON receipt_items(super_category, receipt_date);
CREATE INDEX IF NOT EXISTS idx_ri_canonical_date
  ON receipt_items(canonical_item_id, receipt_date);
CREATE INDEX IF NOT EXISTS idx_ri_store_name
  ON receipt_items(store_name);
CREATE INDEX IF NOT EXISTS idx_overrides_user_name
  ON item_classification_overrides(user_id, canonical_name);

-- 7. Trigger: auto-update updated_at on overrides
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_overrides_updated') THEN
    CREATE TRIGGER trg_overrides_updated
      BEFORE UPDATE ON item_classification_overrides
      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
END $$;

-- 8. BACKFILL: Map existing category values to super_category
UPDATE receipt_items SET super_category = 'groceries'
WHERE super_category IS NULL AND category IN (
  'meat_seafood', 'dairy_eggs', 'produce', 'bakery', 'pantry', 'frozen',
  'beverages', 'snacks_sweets',
  'meat', 'dairy', 'snack', 'beverage', 'condiment', 'grains'
);

UPDATE receipt_items SET super_category = 'household'
WHERE super_category IS NULL AND category IN (
  'household', 'bills', 'cleaning', 'furniture', 'tools'
);

UPDATE receipt_items SET super_category = 'health'
WHERE super_category IS NULL AND category IN (
  'personal_care', 'pharmacy', 'fitness', 'baby_pet', 'health'
);

UPDATE receipt_items SET super_category = 'transport'
WHERE super_category IS NULL AND category IN (
  'fuel', 'insurance', 'maintenance', 'public_transport', 'transport'
);

UPDATE receipt_items SET super_category = 'electronics'
WHERE super_category IS NULL AND category IN (
  'devices', 'accessories', 'software', 'electronics'
);

UPDATE receipt_items SET super_category = 'dining'
WHERE super_category IS NULL AND category IN (
  'restaurant', 'cafe', 'delivery', 'dining'
);

-- Catch-all: anything still NULL gets 'groceries' (most common for receipt items)
UPDATE receipt_items SET super_category = 'groceries'
WHERE super_category IS NULL AND category IS NOT NULL;

-- Also backfill canonical_items
UPDATE canonical_items SET super_category = 'groceries'
WHERE super_category IS NULL AND category IN (
  'meat_seafood', 'dairy_eggs', 'produce', 'bakery', 'pantry', 'frozen',
  'beverages', 'snacks_sweets',
  'meat', 'dairy', 'snack', 'beverage', 'condiment', 'grains'
);

UPDATE canonical_items SET super_category = 'household'
WHERE super_category IS NULL AND category IN ('household', 'bills', 'cleaning', 'furniture', 'tools');

UPDATE canonical_items SET super_category = 'health'
WHERE super_category IS NULL AND category IN ('personal_care', 'pharmacy', 'fitness', 'baby_pet', 'health');

UPDATE canonical_items SET super_category = 'transport'
WHERE super_category IS NULL AND category IN ('fuel', 'insurance', 'maintenance', 'public_transport', 'transport');

UPDATE canonical_items SET super_category = 'electronics'
WHERE super_category IS NULL AND category IN ('devices', 'accessories', 'software', 'electronics');

UPDATE canonical_items SET super_category = 'dining'
WHERE super_category IS NULL AND category IN ('restaurant', 'cafe', 'delivery', 'dining');

UPDATE canonical_items SET super_category = 'groceries'
WHERE super_category IS NULL AND category IS NOT NULL;
