# Flutter Code Review Checklist (Quick)

Use this checklist in every frontend PR.

## 1. Naming and Readability
- Names are clear and semantic.
- bool starts with is/has/can/should.
- No ambiguous names like data/temp/value1.

## 2. Architecture and Layering
- UI code is not doing business logic.
- Data/domain/presentation boundaries are respected.
- No direct datasource usage in UI where abstraction exists.

## 3. State and Side Effects
- State is immutable and explicit.
- Async status is handled correctly.
- API/storage/analytics side effects are not hidden in widget build methods.

## 4. UI Quality
- Handles loading, empty, error, content states.
- No hardcoded design values that should be themed.
- Responsive behavior is considered.

## 5. Error and Null Safety
- No unsafe null assertions without clear reason.
- Errors are mapped and user-safe.
- No silent catch blocks.

## 6. Localization
- No hardcoded user-facing strings.
- New strings are localized consistently.

## 7. Test Coverage
- Unit tests added/updated for logic changes.
- Widget tests added/updated for key UI behavior.
- Critical bug fixes include regression tests.

## 8. Code Hygiene
- Formatted with dart format.
- No avoidable lint warnings.
- No debug print in production code.

## 9. PR Quality
- Scope is focused and clear.
- PR description includes what/why/how to test.
- CI is green before merge.
