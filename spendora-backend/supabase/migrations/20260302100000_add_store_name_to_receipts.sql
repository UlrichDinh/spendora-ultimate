-- Add store_name as a denormalized cache column on receipts.
-- This avoids a complex JOIN through stores → merchants for display purposes.
-- The store_id FK relationship remains intact for when the full merchant DB is populated.
ALTER TABLE public.receipts
ADD COLUMN store_name TEXT;
