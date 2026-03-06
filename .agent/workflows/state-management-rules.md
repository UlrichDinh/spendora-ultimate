---
description: Rules and guidelines for using State Management (Zustand) in Spendora
---

# State Management Guidelines for Spendora

When writing or refactoring code in this project, you MUST adhere to the following rules regarding state management. We use `zustand` as our global state provider.

## 1. When to use Global State (Zustand)
Do **NOT** bypass the global store if the data belongs in it. Use Zustand for:
- **Domain Data:** Receipts, Budgets, Subscriptions, AI parsing results.
- **Shared Activity:** Data that needs to be displayed or accessed on more than one screen (e.g., Dashboard + History).
- **User Settings:** Theme, Language, Default Currency, Export preferences.
- **Caching:** Data fetched from Supabase that rarely changes second-to-second. Avoid pinging the database in `useEffect` on every screen focus. 

## 2. When to use Local State (useState)
Local state is strictly reserved for ephemeral, component-level UI state that no other part of the app cares about. Use local state for:
- **Form Inputs:** Controlled TextInputs before they are submitted.
- **UI Toggles:** Modals (isOpen), Dropdowns (isExpanded), Tab selection within a single screen.
- **Animation States:** Hover, pressed, or dragged states.

## 3. The "Store Update" Rule
When mutating data in Supabase (e.g., `INSERT INTO receipts`), you MUST eagerly update the corresponding Zustand store immediately after the database confirms success. 
Do **NOT** force the app to completely re-fetch the entire list from the database just because one item was added or deleted.

Example:
```typescript
// After successful Supabase insert
await supabase.from('receipts').insert(newReceipt)
useReceiptStore.getState().addReceipt(newReceipt) // Update global cache instantly
```
