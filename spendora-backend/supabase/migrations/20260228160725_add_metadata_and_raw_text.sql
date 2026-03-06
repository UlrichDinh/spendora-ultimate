-- Add metadata and raw_text columns to the public.receipts table
ALTER TABLE public.receipts 
ADD COLUMN metadata JSONB,
ADD COLUMN raw_text TEXT;
