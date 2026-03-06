# Spendora Architecture

## Overview
Spendora is a mobile application built with React Native (Expo) for receipt scanning, expense tracking, and item-level analytics. It utilizes a local-first UI architecture with cloud-based capabilities (Supabase) for data persistence and AI-powered receipt parsing.

## 1. Tech Stack
- **Frontend Framework**: React Native with Expo (Expo Router for navigation)
- **Language**: TypeScript
- **State Management**: Zustand
- **Styling**: `react-native-paper` (being phased out) & Custom Neumorphic Styling (`NeoTheme`, `GlassCard`)
- **Backend / Database**: Supabase (PostgreSQL)
- **Serverless Compute**: Supabase Edge Functions (Deno/TypeScript)

## 2. Frontend Architecture
The frontend is organized into standard Expo structure:
- `app/`: Contains the Expo Router screen definitions (tabs like `index`, `history`, `trends`, `settings`, and modals/sub-screens like `scan-overview`, `item-detail`).
- `components/`: Reusable UI components. The app relies heavily on the `GlassCard` component which provides a consistent neumorphic/glassmorphic aesthetic.
- `store/`: Zustand stores for managing global state without prop drilling.
  - `useItemAnalyticsStore`: Manages 3-level taxonomy (super_category → category → subcategory) and item-level data (purchase history, store comparisons).
  - `useTrendsStore`: Manages month-over-month trend data.
  - `usePendingReceiptStore`: Manages the state of a receipt currently being scanned/edited.
  - `useReceiptStore`: Manages the user's historical receipts list.
  - `useInsightsStore`: Provides AI-driven smart insights based on spending habits.
- `constants/`: Design tokens, particularly `NeoTheme` for consistent dark-mode neumorphism colors and shadows.
- `config/`: Taxonomy and category configurations.

## 3. Backend Architecture (Supabase)
The backend leverages Supabase for authentication, database, storage, and edge functions.

### Edge Functions
- `parse-receipt`: Invoked when a user uploads a receipt image. It interfaces with an external Vision Language Model (e.g., GPT-4o-mini) to extract line items, merchant details, and totals accurately based purely on the receipt's printed data.
- `normalize-items`: Handles the normalization and categorization of parsed receipt items. It maps raw item strings to a master catalog (`canonical_items`) and applies a 3-level classification taxonomy, considering user-defined overrides.

### Database Schema (Core Models)
The PostgreSQL database is fully typed via `types/supabase.ts` and managed via migrations (`supabase/migrations/`). Key tables:

#### Users & Preferences
- **`users`**: User account details.
- **`export_configs`**: Configurations for exporting data to external sources like Google Sheets.

#### Receipts & Scans
- **`receipts`**: Metadata about a scanned receipt (date, totals, OCR status, linked store).
- **`receipt_images`**: Links receipts to image files hosted in Supabase Storage.
- **`receipt_items`**: Individual line items parsed from a receipt, linked to specific `canonical_items`.

#### Item Taxonomy & Normalization
- **`canonical_items`**: The global catalog of recognized products, containing the 3-level taxonomy (`super_category`, `category`, `subcategory`), barcodes, and other metadata (carbon footprint).
- **`item_aliases`**: Maps variations of raw item names found on receipts back to their `canonical_item`.
- **`item_classification_overrides`**: Allows users to override the default AI classification for specific items.

#### Pricing & Merchants
- **`merchants`**: High-level merchant brands (e.g., "Lidl").
- **`stores`**: Specific physical store locations linked to merchants.
- **`price_history`**: Tracks the historical unit price of canonical items at specific stores to enable cross-store price comparisons and trend graphs.

#### Budgeting & Banking
- **`budgets`**: User-defined budgets with specific category filters and time periods.
- **`budget_allocations`**: Maps specific receipt items against active budgets.
- **`bank_accounts`**: Bank accounts linked (likely via an aggregator API like Plaid).
- **`transactions`**: Raw bank transactions that can be matched against scanned receipts.

## 4. Key Workflows
1. **Receipt Scanning**: User takes a photo → Uploaded to Supabase Storage → `parse-receipt` Edge Function extracts JSON data via AI → User reviews in `scan-overview` and edits line items (managed by `usePendingReceiptStore`) → Saved to DB.
2. **Item Analytics**: Once saved, items are processed by `normalize-items` to apply taxonomy → Frontend `useItemAnalyticsStore` fetches aggregated `price_history` and `receipt_items` → Displayed in `trends` and `item-detail` screens for deep-dive analytics.
3. **Theming**: The app enforces a strict UI design system. Screens MUST use `NeoTheme` colors and avoid hardcoded styles. `GlassCard` is the foundational wrapper for structural content.


