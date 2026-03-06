---
trigger: always_on
---

# Spendora Developer Rules & Guidelines

## General Architecture
- **Tech Stack**: React Native (Expo), TypeScript, Zustand, Supabase, Drizzle ORM
- **Styling**: `react-native-paper` component library. Leverage the existing `theme.colors` rather than hardcoding colors where possible. No HTML DOM tags (`<div>`, `<span>`) are permitted in React Native; always use `<View>`, `<Text>`.
- **Database**: The source of truth is always `supabase/migrations/` and `src/db/schema.ts` (or `types/supabase.ts`). Verify field names precisely before using them in UI components.

## AI & Receipt Parsing
- **Receipt Parsing Globalization**: 
   - All receipt-related AI prompts and examples must be language-agnostic and globally applicable.
   - Do NOT use localized or Finnish-specific terms (e.g., "Lidl Plus -säästösi", "S-Bonus", "Pyöristys").
   - Use universal descriptions in Prompts (e.g., "Loyalty discount", "Coupon", "Rounding").
- **Offline / Cloud Dual-Tier Storage**: Evaluate standard DB calls. Free-tier users must have offline local-first sync behavior before interacting with the cloud.
- **Handling OCR Data**: AI prompt parsing strategy relies on pure JSON output and contextual mapping (counting items, multipliers, totals). The AI is told "READ THE RECEIPT, DO NOT RE-CALCULATE." All mathematical totals are explicitly derived from exactly what is printed on the physical receipt.

## Troubleshooting & Commits
- Check `lessons_learned.md` for undocumented behaviors or recurring errors before asking the user for system configurations.
- Use explicit and semantic Conventional Commits for git pushes (e.g. `feat(scanner): ...`, `fix(ui): ...`).
- **Strict Chunking**: Never stage or commit more than 3 files at once. Every commit must be atomic.
- **No 'And' In Messages**: If the commit message contains the word "and", it must be split into two separate commits.
- **Only commit and push to git AFTER the user has explicitly confirmed the feature works or the bug is fixed.** Never auto-commit immediately after making code changes.
- **Model selection for commits**: When performing git operations (staging, committing, pushing), switch to a lower-tier model (e.g. Claude Haiku or Gemini Flash). Reserve Sonnet/Opus only for coding tasks that require reasoning, architecture decisions, or complex debugging.



