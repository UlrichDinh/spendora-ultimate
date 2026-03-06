---
trigger: always_on
---

# Coding Standards & Rules

---

# 1. TypeScript — Never Bypass Type Errors

When TypeScript reports a type error, NEVER suppress or bypass it.
Fix the root cause with proper typing.

## Never do this:
- `// @ts-ignore`
- `// @ts-expect-error`
- `as any`
- `as unknown as SomeType`
- `(item as any).property`
- `function foo(i: any)`
- `const x: any = ...`

## Always fix the root cause:

### Implicit `any` on parameters:
// ❌
items.map((i) => i.name)

// ✅ Type the array so inference flows through
const items: Item[] = [...]
items.map((i) => i.name)

// ✅ Or type the parameter directly
items.map((i: Item) => i.name)

### Implicit `any` in callbacks:
// ❌
const handler = (event) => event.target.value

// ✅
const handler = (event: React.ChangeEvent<HTMLInputElement>) => event.target.value

### Unknown API responses:
// ❌
const data: any = await response.json()

// ✅
const data: ApiResponse = await response.json()

### Truly unknown shapes — use type guards, never cast:
// ❌
const user = response as User

// ✅
function isUser(data: unknown): data is User {
  return typeof data === 'object' && data !== null && 'id' in data;
}

## Rules:
- Define and reuse types in a `types/` folder or `types.ts`
- Prefer `interface` for object shapes, `type` for unions/primitives
- If shape is unknown → use `unknown` + type guard, never `any`
- If a lib lacks types → install `@types/<package>`, never cast to `any`
- `as SomeType` is only acceptable when there is truly no alternative —
  always add a comment explaining why

---

# 2. Config Arrays — No Hardcoded Repetitive Structures

Whenever values share the same shape/pattern, extract them to a named
config array. Never hardcode repetitive JSX or inline arrays.

## Applies to:
- Navigation screens (`<Stack.Screen>`, `<Tab.Screen>`)
- Tab/menu/nav items
- Form fields and validation rules
- Settings and options lists
- Table column definitions
- Cards, tiles, button groups, action lists
- API endpoint maps, icon+label pairs, feature flags

## Pattern:

### Step 1 — Define a typed config array OUTSIDE the component:
const ITEMS: ItemType[] = [
  { id: 'a', label: 'Alpha', options: { ... } },
  { id: 'b', label: 'Beta',  options: { ... } },
];

### Step 2 — Render dynamically:
{ITEMS.map(({ id, label, options }) => (
  <Component key={id} label={label} options={options} />
))}

## Never inline arrays in JSX:
// ❌
{[
  { id: 'a', label: 'Alpha' },
  { id: 'b', label: 'Beta' },
].map((item) => <Item key={item.id} {...item} />)}

// ✅
const ITEMS = [
  { id: 'a', label: 'Alpha' },
  { id: 'b', label: 'Beta' },
];
{ITEMS.map((item) => <Item key={item.id} {...item} />)}

## Placement rules:
- Static data (never changes) → define OUTSIDE the component
- Dynamic data (depends on state/props) → define INSIDE the component,
  ABOVE the return statement
- 5+ items or reused across files → move to `config/`, `constants/`, or `data/`

## Naming conventions:
- Arrays: UPPER_SNAKE_CASE → `NAV_SCREENS`, `FORM_FIELDS`, `MENU_ITEMS`
- Types: PascalCase matching item → `NavScreen`, `FormField`, `MenuItem`

## Thresholds — mandatory when:
- 3+ elements share the same JSX shape
- 2+ elements likely to grow in the future
- Any list where order or content may change over time

---

# 3. Git — One Task, One Commit

Each commit must represent exactly one logical task, fix, or feature.
Never stage everything at once.

## Never do this:
git add .
git commit -m "add login, fix scanner, update nav, refactor form, fix typo"

## Always do this:
git add src/screens/LoginScreen.tsx
git commit -m "feat: add login screen UI"

git add src/components/ReceiptScanner.tsx
git commit -m "fix: correct item extraction in receipt scanner"

## Commit message rules:
- Use conventional prefixes: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `style:`, `test:`
- Describe WHAT changed and WHY — not a session changelog
- If the message contains "and" → split into 2 commits
- Stage specific files only — never `git add .`

## Good:
- `feat: add receipt scan result screen`
- `fix: resolve crash on empty scan response`
- `refactor: move form fields to config array`
- `chore: update expo SDK to 53`

## Bad:
- `updates`
- `fix stuff`
- `WIP`
- `final`
- `add login and fix scanner and update nav`
