# Code Review Rules (React Native App)

These rules apply to any AI-assisted change (Claude, Cursor, etc.) in this repo.

## 1. Scope & PR Hygiene

- Keep changes **focused**: one feature or refactor per PR. Do not mix refactors with new features.
- If a refactor is needed first, **create a separate refactor-only PR** and ship it before adding new behavior.[web:39]
- Avoid huge PRs: aim to keep diffs small and reviewable. If a file grows beyond ~300 lines, suggest splitting components.[web:39]
- Ensure all PRs include:
  - A short summary of the change.
  - Notes on breaking changes or migrations.
  - How it was tested (devices, simulators, test commands).

## 2. Correctness & Behavior

- Do not change behavior unless explicitly requested.
- Understand the feature intent before editing: read surrounding code, types, and usage sites.
- For any bug fix, ensure:
  - The bug is reproducible.
  - The fix is minimal and well-contained.
  - A test (unit or integration) is added or updated.[web:35]

## 3. Readability & Style

- Prefer **simple, idiomatic TypeScript** over clever one-liners.
- Use meaningful names for components, hooks, functions, and variables.
- Follow project ESLint/Prettier rules; never introduce conflicting styles — run `eslint` before marking a change complete.
- **No unused imports** — always clean up import statements after editing.
- Keep functions and components small:
  - **Components must stay under 200–300 lines; JSX blocks under 50 lines.**
  - Extract UI-only subcomponents and custom hooks to reduce complexity.
- **Separate logic from presentation**:
  - Components should be presentational with no direct data fetching.
  - Hooks should contain all state, side effects, and business logic.

## 4. React Native–Specific Rules

- Always respect **platform differences** (`Platform.OS === 'ios' | 'android'`) where needed.
- Use `SafeAreaView` correctly for top-level screens.
- Avoid unnecessary re-renders:
  - Use `React.memo`, `useCallback`, and `useMemo` where it clearly improves performance.
  - Keep props stable for frequently rendered components.
- Do not block the JS thread with heavy computations; offload to background/Native/module where appropriate.
- Do not introduce new native modules or heavy dependencies without explicit instruction.

## 5. Architecture & Dependencies

- Reuse existing patterns and utilities; do not re-invent helpers already present.[web:39]
- Keep concerns separated:
  - UI components: presentational, no direct data fetching.
  - Hooks/services: data fetching, business logic.
- Minimize additional dependencies. If adding one:
  - Justify why built-in / existing libs are insufficient.
  - Prefer well-maintained, widely used packages.

## 6. TypeScript Enforcement

- **`any` is never allowed** — use proper types, interfaces, or type guards.
- **No `@ts-ignore` or `@ts-expect-error`** — fix the root cause instead.
- **Run `npx tsc --noEmit` before every PR** — zero errors is a hard requirement.
- Install `@types/<package>` for any untyped library; never cast to `any` as a workaround.

## 7. Testing Expectations (per PR)

- All new or changed logic must be covered by tests when feasible:
  - Unit tests for pure logic.
  - Component tests for UI behavior and interactions.
- Ensure `npm test` or `yarn test` passes before considering the change complete.
- Do not comment out or delete existing tests unless they are clearly obsolete and replaced.

## 8. Security & Data Handling

- Never log secrets, tokens, or sensitive user data.
- Sanitize and validate all user inputs before using them (forms, search, network calls).[web:43]
- Avoid insecure storage of sensitive data (no plain-text secrets in code or AsyncStorage).
- Use HTTPS endpoints only; do not introduce insecure URLs.

## 9. Version Control & Comments

- Keep commits logical and incremental; avoid huge “mixed” commits.[web:35]
- Do not leave temporary code:
  - Remove `console.log`, `debugger`, and commented-out blocks.
  - Replace TODO-style comments with clear, actionable comments or GitHub issues.
- Document non-obvious decisions with short comments or a link to a design/issue.

When in doubt, optimize for **readability, testability, and least surprise** for the next engineer.
