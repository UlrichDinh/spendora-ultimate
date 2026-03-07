-- Advanced Manual Cleanup: Link 'Other' items to Generic Canonical products to enable detail pages and clickability
-- This creates 'Master' records for common patterns so they become interactive in the UI

DO $$
DECLARE
    dairy_id UUID;
    snack_id UUID;
    bev_id UUID;
    bakery_id UUID;
    produce_id UUID;
    meat_id UUID;
BEGIN
    -- 1. Ensure Generic Canonical Items exist and capture their IDs
    
    -- Eggs & Dairy
    SELECT id INTO dairy_id FROM canonical_items WHERE name = 'General Eggs & Dairy' LIMIT 1;
    IF dairy_id IS NULL THEN
        INSERT INTO canonical_items (id, name, super_category, category)
        VALUES (gen_random_uuid(), 'General Eggs & Dairy', 'groceries', 'dairy')
        RETURNING id INTO dairy_id;
    END IF;

    -- Snacks & Sweets
    SELECT id INTO snack_id FROM canonical_items WHERE name = 'General Snacks & Sweets' LIMIT 1;
    IF snack_id IS NULL THEN
        INSERT INTO canonical_items (id, name, super_category, category)
        VALUES (gen_random_uuid(), 'General Snacks & Sweets', 'groceries', 'snack')
        RETURNING id INTO snack_id;
    END IF;

    -- Beverages
    SELECT id INTO bev_id FROM canonical_items WHERE name = 'General Beverages' LIMIT 1;
    IF bev_id IS NULL THEN
        INSERT INTO canonical_items (id, name, super_category, category)
        VALUES (gen_random_uuid(), 'General Beverages', 'groceries', 'beverage')
        RETURNING id INTO bev_id;
    END IF;

    -- Bakery
    SELECT id INTO bakery_id FROM canonical_items WHERE name = 'General Bakery' LIMIT 1;
    IF bakery_id IS NULL THEN
        INSERT INTO canonical_items (id, name, super_category, category)
        VALUES (gen_random_uuid(), 'General Bakery', 'groceries', 'bakery')
        RETURNING id INTO bakery_id;
    END IF;

    -- Fruits & Veg
    SELECT id INTO produce_id FROM canonical_items WHERE name = 'General Produce' LIMIT 1;
    IF produce_id IS NULL THEN
        INSERT INTO canonical_items (id, name, super_category, category)
        VALUES (gen_random_uuid(), 'General Produce', 'groceries', 'fruits_vegetables')
        RETURNING id INTO produce_id;
    END IF;

    -- Meat
    SELECT id INTO meat_id FROM canonical_items WHERE name = 'General Meat & Proteins' LIMIT 1;
    IF meat_id IS NULL THEN
        INSERT INTO canonical_items (id, name, super_category, category)
        VALUES (gen_random_uuid(), 'General Meat & Proteins', 'groceries', 'meat')
        RETURNING id INTO meat_id;
    END IF;

    -- 2. Link orphaned items to these new Master IDs
    
    -- Dairy (Kanamuna, Muna, Maito etc if classified as dairy)
    UPDATE receipt_items
    SET canonical_item_id = dairy_id
    WHERE (name_raw ILIKE '%kanamuna%' OR name_raw ILIKE '% muna %' OR name_raw ILIKE 'muna %' OR name_raw ILIKE '%maito%')
      AND canonical_item_id IS NULL;

    -- Snacks (Toblerone, Suklaa, Fazer)
    UPDATE receipt_items
    SET canonical_item_id = snack_id
    WHERE (name_raw ILIKE '%toblerone%' OR name_raw ILIKE '%suklaa%' OR name_raw ILIKE '%fazer%')
      AND canonical_item_id IS NULL;

    -- Beverages (Mehu, Kahvi, Water)
    UPDATE receipt_items
    SET canonical_item_id = bev_id
    WHERE (name_raw ILIKE '%mehu%' OR name_raw ILIKE '%kahvi%' OR name_raw ILIKE '%vesi%')
      AND canonical_item_id IS NULL;

    -- Bakery (Leipä, Pulla)
    UPDATE receipt_items
    SET canonical_item_id = bakery_id
    WHERE (name_raw ILIKE '%leipä%' OR name_raw ILIKE '%pulla%' OR name_raw ILIKE '%leipa%')
      AND canonical_item_id IS NULL;

    -- Produce
    UPDATE receipt_items
    SET canonical_item_id = produce_id
    WHERE (name_raw ILIKE '%omena%' OR name_raw ILIKE '%banaani%' OR name_raw ILIKE '%kurkku%' OR name_raw ILIKE '%tomaatti%' OR name_raw ILIKE '%peruna%')
      AND canonical_item_id IS NULL;

    -- Meat
    UPDATE receipt_items
    SET canonical_item_id = meat_id
    WHERE (name_raw ILIKE '%kana%' OR name_raw ILIKE '%jauheli%' OR name_raw ILIKE '%kalkkuna%')
      AND canonical_item_id IS NULL;

END $$;
