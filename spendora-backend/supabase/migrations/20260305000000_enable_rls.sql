-- ============================================================
-- Migration: Enable Row Level Security on ALL public tables
-- Fixes Supabase Security Advisor warning: "RLS Disabled in Public"
-- ============================================================

-- ──────────────────────────────────────────────────────────────
-- 1. USERS — own row only
-- ──────────────────────────────────────────────────────────────
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_select_own" ON users
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "users_update_own" ON users
  FOR UPDATE USING (id = auth.uid());

-- ──────────────────────────────────────────────────────────────
-- 2. RECEIPTS — direct user_id ownership
-- ──────────────────────────────────────────────────────────────
ALTER TABLE receipts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "receipts_select_own" ON receipts
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "receipts_insert_own" ON receipts
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "receipts_update_own" ON receipts
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "receipts_delete_own" ON receipts
  FOR DELETE USING (user_id = auth.uid());

-- ──────────────────────────────────────────────────────────────
-- 3. RECEIPT_ITEMS — indirect via receipts.user_id
-- ──────────────────────────────────────────────────────────────
ALTER TABLE receipt_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "receipt_items_select_own" ON receipt_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM receipts WHERE receipts.id = receipt_items.receipt_id AND receipts.user_id = auth.uid())
  );

CREATE POLICY "receipt_items_insert_own" ON receipt_items
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM receipts WHERE receipts.id = receipt_items.receipt_id AND receipts.user_id = auth.uid())
  );

CREATE POLICY "receipt_items_update_own" ON receipt_items
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM receipts WHERE receipts.id = receipt_items.receipt_id AND receipts.user_id = auth.uid())
  );

CREATE POLICY "receipt_items_delete_own" ON receipt_items
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM receipts WHERE receipts.id = receipt_items.receipt_id AND receipts.user_id = auth.uid())
  );

-- ──────────────────────────────────────────────────────────────
-- 4. ITEM_ALIASES — direct user_id ownership
-- ──────────────────────────────────────────────────────────────
ALTER TABLE item_aliases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "item_aliases_select_own" ON item_aliases
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "item_aliases_insert_own" ON item_aliases
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "item_aliases_update_own" ON item_aliases
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "item_aliases_delete_own" ON item_aliases
  FOR DELETE USING (user_id = auth.uid());

-- ──────────────────────────────────────────────────────────────
-- 5. BUDGETS — direct user_id ownership
-- ──────────────────────────────────────────────────────────────
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "budgets_select_own" ON budgets
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "budgets_insert_own" ON budgets
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "budgets_update_own" ON budgets
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "budgets_delete_own" ON budgets
  FOR DELETE USING (user_id = auth.uid());

-- ──────────────────────────────────────────────────────────────
-- 6. BUDGET_ALLOCATIONS — indirect via budgets.user_id
-- ──────────────────────────────────────────────────────────────
ALTER TABLE budget_allocations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "budget_allocations_select_own" ON budget_allocations
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM budgets WHERE budgets.id = budget_allocations.budget_id AND budgets.user_id = auth.uid())
  );

CREATE POLICY "budget_allocations_insert_own" ON budget_allocations
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM budgets WHERE budgets.id = budget_allocations.budget_id AND budgets.user_id = auth.uid())
  );

CREATE POLICY "budget_allocations_update_own" ON budget_allocations
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM budgets WHERE budgets.id = budget_allocations.budget_id AND budgets.user_id = auth.uid())
  );

CREATE POLICY "budget_allocations_delete_own" ON budget_allocations
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM budgets WHERE budgets.id = budget_allocations.budget_id AND budgets.user_id = auth.uid())
  );

-- ──────────────────────────────────────────────────────────────
-- 7. BANK_ACCOUNTS — direct user_id ownership
-- ──────────────────────────────────────────────────────────────
ALTER TABLE bank_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "bank_accounts_select_own" ON bank_accounts
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "bank_accounts_insert_own" ON bank_accounts
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "bank_accounts_update_own" ON bank_accounts
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "bank_accounts_delete_own" ON bank_accounts
  FOR DELETE USING (user_id = auth.uid());

-- ──────────────────────────────────────────────────────────────
-- 8. TRANSACTIONS — indirect via bank_accounts.user_id
-- ──────────────────────────────────────────────────────────────
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "transactions_select_own" ON transactions
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM bank_accounts WHERE bank_accounts.id = transactions.bank_account_id AND bank_accounts.user_id = auth.uid())
  );

CREATE POLICY "transactions_insert_own" ON transactions
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM bank_accounts WHERE bank_accounts.id = transactions.bank_account_id AND bank_accounts.user_id = auth.uid())
  );

CREATE POLICY "transactions_update_own" ON transactions
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM bank_accounts WHERE bank_accounts.id = transactions.bank_account_id AND bank_accounts.user_id = auth.uid())
  );

CREATE POLICY "transactions_delete_own" ON transactions
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM bank_accounts WHERE bank_accounts.id = transactions.bank_account_id AND bank_accounts.user_id = auth.uid())
  );

-- ──────────────────────────────────────────────────────────────
-- 9. EXPORT_CONFIGS — direct user_id ownership
-- ──────────────────────────────────────────────────────────────
ALTER TABLE export_configs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "export_configs_select_own" ON export_configs
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "export_configs_insert_own" ON export_configs
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "export_configs_update_own" ON export_configs
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "export_configs_delete_own" ON export_configs
  FOR DELETE USING (user_id = auth.uid());

-- ──────────────────────────────────────────────────────────────
-- 10. FILES — direct user_id ownership
-- ──────────────────────────────────────────────────────────────
ALTER TABLE files ENABLE ROW LEVEL SECURITY;

CREATE POLICY "files_select_own" ON files
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "files_insert_own" ON files
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "files_update_own" ON files
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "files_delete_own" ON files
  FOR DELETE USING (user_id = auth.uid());

-- ──────────────────────────────────────────────────────────────
-- 11. ITEM_CLASSIFICATION_OVERRIDES — direct user_id ownership
-- ──────────────────────────────────────────────────────────────
ALTER TABLE item_classification_overrides ENABLE ROW LEVEL SECURITY;

CREATE POLICY "overrides_select_own" ON item_classification_overrides
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "overrides_insert_own" ON item_classification_overrides
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "overrides_update_own" ON item_classification_overrides
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "overrides_delete_own" ON item_classification_overrides
  FOR DELETE USING (user_id = auth.uid());

-- ──────────────────────────────────────────────────────────────
-- 12–15. SHARED REFERENCE TABLES — read-only for authenticated
-- ──────────────────────────────────────────────────────────────
ALTER TABLE merchants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "merchants_read_authenticated" ON merchants
  FOR SELECT USING (auth.role() = 'authenticated');
-- Allow insert/update for merchant upserts from the app
CREATE POLICY "merchants_insert_authenticated" ON merchants
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "merchants_update_authenticated" ON merchants
  FOR UPDATE USING (auth.role() = 'authenticated');

ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "stores_read_authenticated" ON stores
  FOR SELECT USING (auth.role() = 'authenticated');

ALTER TABLE canonical_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "canonical_items_read_authenticated" ON canonical_items
  FOR SELECT USING (auth.role() = 'authenticated');

ALTER TABLE price_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "price_history_read_authenticated" ON price_history
  FOR SELECT USING (auth.role() = 'authenticated');
