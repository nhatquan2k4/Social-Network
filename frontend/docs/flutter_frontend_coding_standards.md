# Flutter Frontend Coding Standards v1.0

## 1. Purpose
This document defines mandatory coding standards for the Flutter frontend team.

Goals:
- Keep code readable and predictable.
- Reduce regressions and inconsistent implementations.
- Improve onboarding speed for new members.
- Make code reviews objective and faster.

Scope:
- Applies to all new Flutter frontend code.
- Applies to modified files in existing features.
- Legacy code can be improved incrementally when touched.

## 2. Core Principles
- Readability over cleverness.
- Consistency over personal preference.
- Single responsibility for classes and methods.
- Stateless by default; add state only when required.
- Business logic must not live in UI widgets.
- Side effects (API, storage, analytics, navigation decisions) are explicit and isolated.

## 3. Project Structure
Use the current layered structure consistently:

- lib/core
  - constants, theme, shared utilities, extensions, base classes, shared widgets
- lib/data
  - datasource, model, repository implementation, mapper
- lib/domain
  - entity, repository abstraction, use case
- lib/presentation
  - page/screen, widget, state management, controllers/view-models

Rules:
- One public class per file.
- Split large widgets into dedicated files.
- Avoid files larger than ~400 lines unless justified.
- Do not import data layer directly inside UI if domain abstraction exists.

## 4. Naming Conventions
### 4.1 File and Type Naming
- File name: snake_case (example: user_profile_page.dart)
- Class/Enum/Typedef: PascalCase (example: UserProfilePage)
- Variable/Function/Parameter: lowerCamelCase (example: fetchUserProfile)
- Private members: prefix with underscore (example: _loadData)

### 4.2 Semantic Naming Rules
- bool names must start with is/has/can/should.
- Lists use plural nouns.
- Map names describe key-value relation.
- Stream names end with Stream.
- Controllers end with Controller.
- Global keys end with Key.
- Callback props start with on (UI) or handle (internal method).

Good:
- isLoading, hasError, users, userById, messageStream, scrollController, formKey

Avoid:
- data, temp, value1, flag, doStuff, process

## 5. Formatting and Linting
- Run dart format before committing.
- No avoidable lint warnings in PR.
- Prefer final for local variables and fields that are not reassigned.
- Prefer const constructors and const widgets whenever possible.
- Avoid print in production code; use logging abstraction.

Required baseline lint behavior:
- avoid_print
- prefer_final_locals
- prefer_const_constructors
- prefer_const_literals_to_create_immutables
- directives_ordering
- always_declare_return_types
- sort_constructors_first

## 6. Import Rules
Import order:
1. Dart SDK imports.
2. Flutter SDK imports.
3. Third-party package imports.
4. Internal project imports.

Additional rules:
- Keep one blank line between import groups.
- Remove unused imports.
- Prefer stable project import patterns over deep relative paths.

## 7. Widget Rules
- Build methods only compose UI.
- Move heavy logic to state layer/use case.
- Extract repeated UI into reusable widgets.
- Constructor parameters must use required when mandatory.
- Do not hardcode design tokens directly in random widgets.

Every major screen should handle:
- loading state
- empty state
- error state
- content state

## 8. State Management Rules
Independent of Bloc/Riverpod/Provider choice:
- State must be immutable.
- State transitions must be explicit.
- Side effects are handled in state/controller/use-case layers, not inline UI callbacks.
- Keep each state unit focused on one feature boundary.

If using Bloc/Cubit:
- Events/actions are verb-based and specific.
- State uses copyWith and explicit status.

If using Riverpod:
- Provider names end with Provider.
- Use AsyncValue for async flows.
- Minimize rebuilds by scoping watch/select carefully.

## 9. Data and API Rules
- Keep DTO/model separate from domain entity.
- Use mappers for conversion.
- Validate and sanitize API inputs at boundaries.
- Normalize API errors into a consistent app error model.
- Do not pass raw Map payloads across multiple layers.
- Token/session handling must not leak into presentational widgets.

## 10. Error Handling Rules
- Never silently swallow errors.
- Catch blocks must either:
  - rethrow with context, or
  - map to a domain/app failure type.
- User-facing messages must be safe and friendly.
- Do not expose stack traces or internal server details in UI.
- Retry options should exist for recoverable errors.

## 11. Null-Safety Rules
- Avoid forced null check (!) unless absolutely safe and documented.
- Prefer explicit null handling with guard clauses.
- Keep non-null types by default.
- Validate navigation arguments and external data at entry points.

## 12. UI Consistency and Design Tokens
- Use centralized theme and design tokens.
- Use a shared spacing scale (e.g. 4, 8, 12, 16, 24, 32).
- Use semantic text styles from theme.
- Ensure minimum touch target size around 44x44.
- Support different screen sizes and orientation where required.

## 13. Localization Rules
- No hardcoded user-facing strings in widgets.
- All UI text must be localizable.
- Localization keys follow feature-based naming.

Example:
- auth.login.title
- profile.edit.save_button

## 14. Navigation Rules
- Route names/definitions must be centralized.
- Typed arguments are preferred over generic maps.
- Auth guards and access checks are handled consistently.
- Navigation logic should not exist in data/repository layer.

## 15. Testing Rules
Minimum expectation per feature:
- Unit tests for use cases and key mappers.
- Widget tests for critical UI behavior.
- Regression tests for fixed critical bugs.

Recommended:
- Golden tests for important reusable components.

## 16. Git, Branch, and PR Rules
- Branch naming:
  - feature/<short-description>
  - fix/<short-description>
  - refactor/<short-description>
  - chore/<short-description>
- Keep commits focused and descriptive.
- One PR should target one purpose.
- PR must include test notes and impact summary.
- Do not merge with failing CI.

## 17. Definition of Done
A task is done only when:
- Code follows naming/lint/format rules.
- UI states are complete and verified.
- Error handling is present.
- Required tests are added/updated.
- PR passes CI and receives approval.
- Related docs/comments are updated when needed.

## 18. Code Review Quality Bar
Reviewers must verify:
- Naming clarity
- Layering boundaries
- Null-safety and error handling
- Test adequacy
- No hardcoded strings/styles violating standards
- No unnecessary rebuild/performance regressions

## 19. Technical Debt Rules
- Do not leave vague TODO comments.
- TODO must include context and tracking reference.

Format:
TODO(<owner|ticket>): <clear action and reason>

Example:
TODO(FE-142): Replace temporary mapper once backend returns normalized payload.

## 20. Adoption Plan
- Week 1: Use standards for all new code.
- Week 2: Apply review checklist in all PRs.
- Week 3+: Incrementally refactor touched legacy files.

Ownership:
- Tech lead owns version updates of this standard.
- Team members can propose changes via PR to this document.
