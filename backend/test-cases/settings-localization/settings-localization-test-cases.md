# Settings, Localization & Local State Test Cases

## Phạm vi

Nhóm này bao phủ các trạng thái cross-cutting: đổi ngôn ngữ, đổi theme, secure storage/session, Hive cache/search history, message cache, notification handled ids và UI text localized. Entry point chính nằm trong `ProfileSettingsSheet`, `LanguageBloc`, `ThemeBloc`, local/secure storage và các generated l10n files.

## Test Cases

| ID | Priority | Type | Kịch bản | Tiền điều kiện | Bước kiểm thử | Kết quả mong đợi |
| --- | --- | --- | --- | --- | --- | --- |
| SET-001 | P1 | FE | Mở settings sheet | Đã ở profile của mình | Nhấn `profile.settings` | Sheet hiển thị title, edit profile, language, theme, logout |
| SET-002 | P1 | FE | Đổi ngôn ngữ sang English | Settings đang mở, locale vi | Mở language menu, chọn English | Text settings và app đổi sang English |
| SET-003 | P1 | FE | Đổi ngôn ngữ sang Vietnamese | Locale en | Chọn Vietnamese | Text đổi sang Vietnamese |
| SET-004 | P1 | FE | Language menu hiển thị check item hiện tại | Settings mở | Mở menu language | Locale hiện tại có icon check |
| SET-005 | P1 | FE | Theme light -> dark | Settings mở, theme light | Toggle theme | ThemeBloc mode dark, màu UI đổi đúng |
| SET-006 | P1 | FE | Theme dark -> light | Settings mở, theme dark | Toggle theme | ThemeBloc mode light, màu UI đổi đúng |
| SET-007 | P1 | FE | Theme không làm mất route hiện tại | Đang ở profile/settings | Toggle theme | Vẫn ở profile, sheet không crash |
| SET-008 | P1 | FE | Locale không làm mất input đang nhập | Ở edit profile có draft | Đổi locale rồi quay lại edit | Draft input không bị reset ngoài ý muốn nếu widget còn sống |
| SET-009 | P0 | INT | Secure storage lưu user_id sau login | Login thành công | Kiểm tra flow vào profile/feed | Các feature đọc được `user_id` để xác định current user |
| SET-010 | P0 | INT | Logout xóa session/token | Đã login | Logout | Secure/local session không còn dùng để mở profile; route về login |
| SET-011 | P1 | FE | Search history persist qua reload app | Search thành công một query | Restart/pump lại app, mở search | History query vẫn còn |
| SET-012 | P1 | FE | Clear search history persist | Có history | Clear all, restart app | History vẫn rỗng |
| SET-013 | P1 | FE | Notification handled ids persist | Accept/reject friend request | Restart app, load notifications | Request đã xử lý không xuất hiện lại |
| SET-014 | P1 | FE | Message history cache hydrate | Đã mở chat room có messages | Tắt network/mocking remote lỗi, mở lại room | Cache messages hiển thị nếu có |
| SET-015 | P1 | NEG | Hive storage lỗi đọc cache | Mock Hive load lỗi | Mở feature dùng cache | Feature fallback sang remote/empty, không crash |
| SET-016 | P1 | FE | Localized fallback text không rỗng | App ở vi/en | Mở login, profile, notification, chat | Các label quan trọng có text; không lộ key localization |
| SET-017 | P2 | FE | Format ngày giờ theo locale | Có post/comment/message date | Chuyển vi/en và render | Date labels hợp lý, không exception `Intl` |
| SET-018 | P2 | FE | Dark mode media/detail vẫn đọc được | Theme dark | Mở post detail, chat room, notifications | Contrast text/icon đủ rõ, không mất icon |

## Data & Assertions

- Không chỉ assert text cụ thể khi test đa ngôn ngữ; nên assert state/route/widget key trước, text localized sau.
- Với local state, nên reset Hive giữa các E2E độc lập để tránh test phụ thuộc lẫn nhau.

