# Hardcoded Text Migration Status

## Scan Summary
- Scope: `lib/presentation/**/*.dart`
- Initial scan matches: 116
- After Auth batch migration: 95
- After Phase-2 migration: 28
- After final hotspot cleanup: 0 (for tracked hotspot files)
- Reduced in phase-2: 67
- Total reduced so far: 88

## Completed in this batch
- Finalized remaining hotspot literal migration to localization keys in:
  - `screens/chat/profile/chat_user_profile_screen.dart`
  - `screens/chat/group/chat_group_member_profile_screen.dart`
  - `screens/chat/group/chat_group_create_screen.dart`
  - `screens/chat/group/chat_group_setup_screen.dart`
  - `screens/chat/group/chat_group_add_members_screen.dart`
  - `screens/chat/profile/chat_nickname_screen.dart`
  - `screens/chat/profile/chat_safety_screen.dart`
- Added Flutter localization infrastructure (`gen-l10n`).
- Migrated Auth feature texts to localization keys:
  - `welcome_screen.dart`
  - `login_screen.dart`
  - `register_screen.dart`
  - `fogot_screen.dart`
  - `otp_verification_screen.dart`
  - `reset_password_screen.dart`
- Migrated major texts in Profile feature:
  - `profile_screen.dart`
  - `edit_profile_screen.dart`
  - `profile_media_picker_screen.dart`
- Migrated major texts in Chat group + Chat main features:
  - `chat_group_info_screen.dart`
  - `chat_screen.dart`
  - `messages_screen.dart`
- Migrated major texts in Feed + Friends + common widgets:
  - `feed_screen.dart`
  - `create_post_screen.dart`
  - `friends_screen.dart`
  - `message_input.dart`
- Extracted shared bottom-nav route logic from large screens to controller:
  - `presentation/controllers/common/bottom_nav_route_controller.dart`

## Remaining hotspots (highest impact)
- No remaining matches in previously tracked hotspot files.
- Remaining hardcoded strings (if any) are outside hotspot scope and can be migrated in a separate pass.

## Suggested next migration order
1. Profile feature (`profile_screen`, `edit_profile_screen`, media picker)
2. Chat group feature (`chat_group_info_screen`, member profile, setup/create/add)
3. Chat main feature (`chat_screen`, `messages_screen`, search/profile)
4. Feed + Friends + common chat widgets

## Rule for follow-up PRs
- Add keys to both `app_vi.arb` and `app_en.arb`.
- Replace inline text/hint/label/snackbar messages with `context.l10n`.
- Keep visual styles unchanged while replacing only text sources.
