# Refactoring Rules

Refactoring = improving structure and clarity **without changing behavior**.[web:40]

## 1. When Refactoring Is Allowed

- You may refactor when:
  - The user explicitly asks you to refactor.
  - The code is clearly violating obvious principles (duplication, huge function, unreadable logic).
- For mixed work (feature + refactor):
  - Prefer to **refactor first in a separate PR**, then implement the feature.[web:39]

## 2. Non‑Negotiable Guardrails

- Behavior must not change:
  - Keep public APIs and component props compatible unless instructed to change them.
  - Maintain existing side effects and data flows.
- All tests must pass after refactor.
- Do not silently remove error handling, logging, or edge-case branches.
- **Run `npx tsc --noEmit` after every refactor — zero TypeScript errors is a hard requirement.**
- **TypeScript is enforced throughout: no `any`, no `@ts-ignore`, no unsafe casts.**
- **No unused imports** — remove everything not referenced in the file.
- **Consistent code style via ESLint + Prettier** — run lint after each change.

## 3. Refactoring Priorities

- First: **clarity**
  - Extract smaller functions/components.
  - Improve naming (functions, hooks, variables) to reflect intent.
  - **Components must stay under 200–300 lines; JSX blocks under 50 lines** — split into sub-components if exceeded.
- Second: **duplication**
  - DRY up obviously repeated logic (validation, formatting, fetch wrappers).
- Third: **structure**
  - Apply simple patterns (custom hooks, presentational vs container components).
  - **Separate logic from presentation** — hooks hold data/logic, components are presentational.
- Fourth: **performance**
  - Optimize only where there is a clear hotspot or obvious waste.

## 4. Safe Refactoring Techniques

- Extract method / extract component.
- Inline temporary variables that add no clarity.
- Replace magic literals with named constants or enums.
- Introduce small, focused custom hooks for repeated side effects (e.g. data fetching, subscriptions).[web:44]
- Move files into more appropriate folders **only if imports can be reliably updated.**

## 5. React Native–Specific Guidance

- Do not refactor navigation structure (stacks, tabs) unless requested.
- Be careful with hooks:
  - Preserve call order.
  - Do not put hooks inside conditionals.
- When splitting components:
  - Keep styling and layout intact.
  - Preserve test IDs and accessibility labels.

## 6. Communication & Scope

- Describe the refactor intent in comments or PR description:
  - “Pure refactor: extracted X from Y for readability.”
  - “No behavior changes intended.”
- If you suspect behavior might change, **call it out explicitly** and document why.

Refactor with the mindset from “Refactoring: Improving the Design of Existing Code”: lots of **small, verifiable steps**, not big bang rewrites.[web:44]
