-- ============================================================
-- Migration: Fix remaining Security Advisor warnings
-- 1. Enable RLS on receipt_images (missed in previous migration)
-- 2. Set search_path on mutable functions (handle_new_user, set_updated_at)
-- ============================================================

-- ──────────────────────────────────────────────────────────────
-- 1. RECEIPT_IMAGES — indirect via receipts.user_id
-- ──────────────────────────────────────────────────────────────
ALTER TABLE receipt_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "receipt_images_select_own" ON receipt_images
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM receipts WHERE receipts.id = receipt_images.receipt_id AND receipts.user_id = auth.uid())
  );

CREATE POLICY "receipt_images_insert_own" ON receipt_images
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM receipts WHERE receipts.id = receipt_images.receipt_id AND receipts.user_id = auth.uid())
  );

CREATE POLICY "receipt_images_update_own" ON receipt_images
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM receipts WHERE receipts.id = receipt_images.receipt_id AND receipts.user_id = auth.uid())
  );

CREATE POLICY "receipt_images_delete_own" ON receipt_images
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM receipts WHERE receipts.id = receipt_images.receipt_id AND receipts.user_id = auth.uid())
  );

-- ──────────────────────────────────────────────────────────────
-- 2. Fix "Function Search Path Mutable" warnings
--    Setting search_path prevents privilege escalation attacks
-- ──────────────────────────────────────────────────────────────
ALTER FUNCTION public.set_updated_at() SET search_path = '';

ALTER FUNCTION public.handle_new_user() SET search_path = '';
