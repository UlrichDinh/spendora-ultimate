# Spendora Build Plan

## PHASE 1: MVP (Weeks 1-6) - Core Scanning & Parsing

### Week 1: Project Setup & Scanner Foundation

#### Day 1-2: Project Initialization
- [x] **Task 1.1: Initialize Expo project with TypeScript**
  - [x] Create new Expo project: `npx create-expo-app@latest receipt-scanner --template`
  - [x] Install dependencies:
    - [x] `expo-sqlite` for local database (Replaced by direct Supabase integration)
    - [x] `expo-file-system` for file operations
    - [x] `react-native-fs` for advanced file handling
    - [x] `drizzle-orm` for database ORM (Replaced by Supabase)
    - [x] `zustand` for state management
  - [x] Configure TypeScript strict mode
  - [x] Set up folder structure
- [x] **Task 1.2: Setup database schema with Supabase (Shifted from Drizzle)**
  - [x] Create schema with tables:
    - [x] `users`
    - [x] `receipts`
    - [x] `files`
    - [x] `receipt_images`
    - [x] `canonical_items`
    - [x] `receipt_items`
  - [x] Create migrations
  - [x] Implement database initialization on app startup
- [x] **Task 1.3: Setup native module bridge for ML Kit Document Scanner (Android)**
  - [x] Implement ML Kit Document Scanner integration
  - [x] Add Google Play Services ML Kit dependencies
  - [x] Create `scanDocument()` method that launches scanner
  - [x] Configure scanner options
  - [x] Create React Native bridge
  - [x] Export TypeScript types

#### Day 3-4: Scan UI & Image Handling
- [x] **Task 1.4: Build scan entry screen UI**
  - [x] Create `history.tsx` & `index.tsx` for scanning entry points
  - [x] Design layout (Large scan button, recent scans)
  - [x] Implement components
  - [x] Loading spinner during scan
  - [x] Wire up native module call
  - [x] Handle permissions
- [x] **Task 1.5: Implement file storage service**
  - [x] Create file storage handlers (Supabase Storage)
  - [x] Save image to storage bucket
  - [x] Generate thumbnails
  - [x] Implement storage path strategy
  - [x] Insert file records into `files` table
- [x] **Task 1.6: Build image review screen**
  - [x] Create image review interface (integrated into edge flow)
  - [x] Features: image previews
  - [x] Navigation to OCR Processing

#### Day 5-7: OCR Integration (Cloud AI)
- [x] **Task 1.7: Integrate Vision LLM (Replaced on-device ML Kit)**
  - [x] Create Edge Function for parsing
  - [x] Extract text blocks, items, confidence via GPT-4o-mini
  - [x] Handle multi-page receipts
  - [x] Store raw response and confidence
- [x] **Task 1.8: Build OCR processing flow**
  - [x] Basic parser mapping to JSON schema
  - [x] Extract merchant name, date, total
  - [x] Update `receipts` table OCR status
  - [x] Show loading screen with progress

---

### Week 2: Line-Item Parsing & Manual Correction

#### Day 8-9: Line-Item Extraction Logic
- [x] **Task 2.1: Build basic line-item parser**
  - [x] Parse from AI response
  - [x] Identify item lines
  - [x] Extract name, qty, unit price, total
  - [x] Handle discount lines
  - [x] Handle tax lines
  - [x] Insert items into `receipt_items`
- [x] **Task 2.2: Build item review/edit screen UI**
  - [x] Create `scan-overview.tsx` and `scan-result.tsx`
  - [x] Display receipt metadata (Store name, date, total)
  - [x] Line items list
  - [x] Bottom summary
  - [x] Action buttons: Save, Cancel

#### Day 10-11: Manual Correction UI
- [x] **Task 2.3: Build item edit modal**
  - [x] Create `edit-receipt.tsx` fields
  - [x] Name input
  - [x] Quantity input
  - [x] Unit/Category selection
  - [x] Price and total calculation
  - [x] Validation on save
- [x] **Task 2.4: Implement quick-edit gestures**
  - [x] Swipe left on item → Delete
  - [x] Red delete bin implemented with Neumorphic theme
  - [ ] Long press → Multi-select mode
  - [ ] Drag handle → Reorder items

#### Day 12-14: Tax & Discount Handling
- [x] **Task 2.5: Build tax allocation logic**
  - [x] Calculate VAT row breakdowns
  - [x] Update item specific tax allocation
  - [ ] Add tax handling mode selector in settings
- [x] **Task 2.6: Implement discount handling**
  - [x] Parse discount lines from OCR
  - [x] Map discounts to negative values via JSON schema parsing
  - [x] Update `receipt_items` amounts

---

### Week 3: Receipt List & Search

#### Day 15-16: Receipt List Screen
- [x] **Task 3.1: Build main receipts list UI**
  - [x] Create `history.tsx`
  - [x] `FlatList`/`ScrollView` layout
  - [x] Each card: thumbnail, store name, date, total
  - [x] Neumorphic list items integration
- [x] **Task 3.2: Implement search functionality**
  - [x] Add search bar at top of list
  - [x] Filter by term
  - [ ] Debounce search input

#### Day 17-18: Receipt Detail View
- [x] **Task 3.3: Build receipt detail screen**
  - [x] Header: store name, date, total
  - [x] Image gallery
  - [x] Actions: Edit, Delete
- [x] **Task 3.4: Implement delete receipt flow**
  - [x] Delete confirmation modal (Themed overlay)
  - [x] Delete receipt logic
  - [x] Supabase cascading

#### Day 19-21: Categories & Basic Insights
- [x] **Task 3.5: Build category management**
  - [x] Category picker structure (Super → Cat → Sub)
  - [x] Icons and predefined sets mapped
- [x] **Task 3.6: Build simple spending breakdown**
  - [x] Create `trends.tsx`
  - [x] Display month total spending
  - [x] Top stores and categories

---

### Week 4: Export & Settings

#### Day 22-23: CSV Export
- [ ] **Task 4.1: Implement CSV export**
  - [ ] Create `ExportService.ts`
  - [ ] Enable sharing
- [ ] **Task 4.2: Build export screen UI**
  - [ ] Options: Date range
  - [ ] "Export & Share" action

#### Day 24-25: Settings & App Configuration
- [x] **Task 4.3: Build settings screen**
  - [x] Create `settings.tsx`
  - [x] Applied Neumorphic theme (`GlassCard` settings rows)
- [ ] **Task 4.4: Implement data management**
  - [ ] "Clear all data" feature
  - [ ] Export backup

#### Day 26-28: Testing & Bug Fixes
- [x] **Task 4.5: End-to-end testing**
  - [x] Test core parsing capabilities via tests in `tests-ai.ts`
- [x] **Task 4.6: Bug fixes & polish**
  - [x] Fix GPT parsing edge cases (prompt updates)
  - [x] Improve loading states using Neumorphic skeleton loaders

---

## PHASE 2: Enhanced Features (Weeks 7-12)

### Week 7-8: Canonical Items & Learning Loop
- [x] **Task 5.1: Build canonical items database**
  - [x] `canonical_items` table created and populated
- [x] **Task 5.2: Implement item matching algorithm**
  - [x] `normalize-items` edge function created
- [x] **Task 5.3: Build alias learning system**
  - [x] `item_aliases` tracking implemented
- [x] **Task 5.4: Build merchant & store database**
  - [x] `merchants` and `stores` tables created

### Week 9-10: Price History & Insights
- [x] **Task 6.1: Implement price tracking**
  - [x] `price_history` tracking working in DB
- [x] **Task 6.2: Build price history UI**
  - [x] Item detail graphs (`Svg` charts) built and themed
- [x] **Task 6.3: Enhanced insights dashboard**
  - [x] `useTrendsStore` implementation for 3-level breakdown over months
- [ ] **Task 6.4: Grocery intelligence features**
  - [ ] Environmental impact (CO2 tracking)
  - [ ] Seasonal/Local indicators

### Week 11-12: Budgeting & Multi-Budget
- [x] **Task 7.1: Build budget management structure**
  - [x] `budgets` schema added
- [ ] **Task 7.2: Implement budget allocations**
  - [ ] UI for splitting single items
- [ ] **Task 7.3: Budget insights**
  - [ ] Historical trends UI
- [ ] **Task 7.4: Notifications & alerts**
  - [ ] Budget thresholds logic

---

## PHASE 3: Cloud Sync (Weeks 13-16)

### Week 13-14: Supabase Integration
- [x] **Task 8.1: Setup Supabase project**
  - [x] Database schema setup natively in cloud
- [x] **Task 8.2: Implement authentication**
  - [x] User management setup
- [x] **Task 8.3: Setup Supabase Storage**
  - [x] Buckets defined and integrated
- [x] **Task 8.4: Build sync service**
  - [x] Direct API reads established

### Week 15-16: Multi-Device Sync & Settings
- [ ] **Task 8.5: Implement offline sync (Local-first)**
  - [ ] Queueing mechanism
- [ ] **Task 8.6: Build cloud backup toggle**
- [ ] **Task 8.7: Multi-device conflict resolution**
- [ ] **Task 8.8: Account management UI**

---

## PHASE 4: Polish & Launch Prep (Weeks 17-18)

### Week 17: UX Polish & Onboarding
- [ ] **Task 9.1: Build onboarding flow**
- [ ] **Task 9.2: Add empty states & illustrations**
- [ ] **Task 9.3: Improve loading & error states**
- [ ] **Task 9.4: Accessibility improvements**

### Week 18: Testing, Analytics & Launch
- [ ] **Task 9.5: Implement analytics**
- [ ] **Task 9.6: Beta testing**
- [ ] **Task 9.7: Performance optimization**
- [ ] **Task 9.8: Pre-launch checklist**

---

## Receipt Scanning: Edge Cases & Robustness

### Image Quality
- [ ] **Faded thermal ink**
- [ ] **Shadows & lighting**
- [ ] **Crumpled/folded receipts**
- [x] **Partial photos** — User properly handles total recalculation logic (`hasEditedItems` flag implemented)
- [ ] **Blurry text**

### Image Preprocessing & Capture Intelligence
- [ ] **Flash-on suggestion**
- [ ] **Shadow detection heuristic**
- [ ] **Adaptive thresholding**
- [ ] **Blur detection before upload**
- [ ] **Focus lock UX**
- [ ] **Retry with zoom guidance**

### Receipt Format Variations
- [ ] **Multi-page receipts**
- [ ] **Digital receipts**
- [x] **Multi-column layouts** — GPT handles structural inference
- [x] **Multiple tax rates** — Extracted mapped correctly in Edit Receipt
- [ ] **Multi-currency**
- [ ] **Bundle pricing**

### Financial Edge Cases
- [x] **Buy-one-get-one-free** — Negative extraction logic covers
- [x] **Refunds/returns** — Support for negative values
- [ ] **Partial payments**
- [ ] **Tipping**
- [x] **Rounding** — Proper handling within total alignment

### Globalization
- [ ] **Right-to-left languages**
- [ ] **CJK characters**
- [x] **Date formats** — Edge function standardizes outputs
- [x] **Decimal separators** — Handled intelligently by Vision LLM
- [ ] **Dynamic currency symbol**

### Quick Wins & Reliability
- [ ] **Dynamic currency mapping**
- [ ] **Confidence/mismatch indicator**
- [ ] **Retry mechanism**
- [x] **Image compression tuning** — Compressed images to fit Edge Function limits