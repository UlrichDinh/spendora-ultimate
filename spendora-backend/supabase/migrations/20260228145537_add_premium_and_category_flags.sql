-- Add is_premium flag to the public.users table (defaulting to false for existing and new users)
ALTER TABLE public.users 
ADD COLUMN is_premium BOOLEAN NOT NULL DEFAULT false;

-- Add category to the public.receipts table
ALTER TABLE public.receipts 
ADD COLUMN category TEXT;
