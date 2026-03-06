# Release & Delivery Rules (Mobile / React Native)

These rules guide how AI should prepare code for release workflows.

## 1. Branching & Versioning

- Use a clear branching model (e.g. `main` + `develop` + `release/x.y.z`).
- For each release:
  - Bump app version and build number consistently (Android + iOS + app config).[web:38]
  - Update changelog with user-facing changes and notable fixes.[web:34]
- Patch releases (x.y.z+1) should contain **only** bug fixes or small safe changes.

## 2. CI/CD Requirements

- A release build must only be created from:
  - A branch where all tests pass.
  - Linting and type-checking pass cleanly.[web:33]
- The pipeline should:
  - Install deps.
  - Run lint + tests.
  - Build Android and iOS artifacts.
  - Sign builds using configured keys/profiles.[web:38]

## 3. Pre‑Release Checklist

Before cutting a release candidate build:

- Confirm:
  - No critical/blocker issues open for this version.
  - New features have tests and documentation where relevant.[web:34]
- Ensure:
  - Environment variables and API URLs point to the correct backend (staging vs production).
  - No debug flags or dummy data are enabled.
  - `console.log` and `debugger` statements are removed from production code.

## 4. Release Candidate & Testing

- Create a release branch and RC build.
- Distribute RC to testers (TestFlight / internal track).
- Ensure:
  - All merged PRs intended for this release are tested on **both** iOS and Android.[web:34]
  - Known issues are documented for this version.

## 5. Final Release

On final release:

- Tag the commit with the version (e.g. `v1.2.0`).[web:38]
- Submit builds to App Store / Play Store with:
  - Correct version notes.
  - Clear minimum OS and backend version requirements if relevant.[web:34]
- After approval:
  - Merge release branch back to main and update any version references.
  - Plan/announce dates for the next release cycle.[web:34]

## 6. Hotfixes

- For urgent bugs:
  - Branch from the latest release tag (e.g. `hotfix/1.2.1`).
  - Keep change scope minimal and well-tested.
  - Bump patch version only.
  - Reuse the same testing checklist in a shortened form.

AI changes must **not** modify release automation scripts, signing configs, or CI secrets unless explicitly requested.
