# Testing Rules (React Native)

All non-trivial changes must include or update tests.

## 1. Tooling

- Use **Jest** as the test runner.
- Use **React Native Testing Library (RNTL)** for component tests.[web:30][web:27]
- Use `@testing-library/jest-native` for better matchers where configured.

## 2. What Must Be Tested

- New features:
  - At least one happy-path test per new user-visible behavior.[web:33]
  - Negative/error path where meaningful (invalid input, API error).
- Bug fixes:
  - A regression test that fails before the fix and passes after.
- Pure functions:
  - Unit tests covering main branches and edge cases.
- Complex components:
  - Rendering with required props.
  - Key interactions (taps, input, navigation calls).
  - Important visual states (loading, empty, error, success).

## 3. How to Write Tests

- Test **behavior, not implementation**:
  - Query by text, role, or accessible labels instead of internal state.[web:21]
- Use RNTL patterns:
  - `render(...)` to mount.
  - `fireEvent.press`, `fireEvent.changeText` for interactions.
  - `waitFor` / `findBy*` for async UI updates.[web:27]
- Mock external boundaries:
  - Network calls, AsyncStorage, device APIs.
  - Navigation side effects where needed.

## 4. Coverage & CI Expectations

- All tests must pass before a change is considered complete.
- New code should **not reduce overall coverage** meaningfully.
- Tests and linters should run in CI for every PR:
  - Lint (ESLint) must pass.
  - Jest test suite must succeed.[web:33]

## 5. React Native–Specific Testing Notes

- Prefer testing at the component boundary:
  - Do not mock React Native core components unless required.
- For navigation:
  - Use simple navigation stubs/mocks where necessary.
  - Assert that navigation functions are called with correct params.
- For platform-specific behavior:
  - Use `jest.mock('react-native/Libraries/Utilities/Platform', ...)` or similar to simulate iOS/Android.

## 6. Test Code Quality

- Keep test files readable:
  - Arrange / Act / Assert structure.
  - Meaningful test names describing behavior.
- Do not duplicate boilerplate setup; extract helpers where useful.
- Avoid snapshot tests for complex dynamic UIs unless they are very stable.

No code without tests should be merged for significant logic changes; minimal, focused tests are always better than none.[web:33]
