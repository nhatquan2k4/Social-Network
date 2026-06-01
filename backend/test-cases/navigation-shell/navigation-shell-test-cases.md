# Navigation Shell Test Cases

## Phạm vi

Navigation shell gồm GoRouter config, initial route, ShellRoute, bottom nav, ẩn/hiện nav theo route, socket connect sau login, notification badge và realtime post engagement sync. Nguồn chính: `app_route_conf.dart`, `app_shell_page.dart`, `app_shell_bottom_nav_bar.dart`.

## Test Cases

| ID | Priority | Type | Kịch bản | Tiền điều kiện | Bước kiểm thử | Kết quả mong đợi |
| --- | --- | --- | --- | --- | --- | --- |
| NAV-001 | P0 | FE | Initial route mặc định | Không set `START_ROUTE` | Pump app | App mở `/onboarding` |
| NAV-002 | P1 | FE | Initial route static hợp lệ | Set `START_ROUTE=/login` | Pump app | App mở `/login` |
| NAV-003 | P1 | FE | Initial route chat room hợp lệ | Set `START_ROUTE=/chat/room/abc` | Pump app | App mở chat room fallback thread |
| NAV-004 | P1 | FE | Initial route không hợp lệ fallback | Set `START_ROUTE=/unknown` | Pump app | App mở welcome `/` |
| NAV-005 | P0 | FE | Shell bottom nav xuất hiện ở home | Đã login | Mở `/home` | Có nav home/create/notifications/profile |
| NAV-006 | P0 | FE | Nav tab home | Đã ở shell | Nhấn `nav.home` | Route `/home`, selected index 0 |
| NAV-007 | P0 | FE | Nav tab create post | Đã ở shell | Nhấn `nav.create` | Route `/create-post`, selected index 1 |
| NAV-008 | P0 | FE | Nav tab notifications | Đã ở shell | Nhấn `nav.notifications` | Route `/notifications`, selected index 2, badge clear |
| NAV-009 | P0 | FE | Nav tab profile | Đã ở shell | Nhấn `nav.profile` | Route `/profile`, selected index 3 |
| NAV-010 | P1 | FE | Ẩn bottom nav ở search | Đã login | Mở `/home/search` | Bottom nav không hiển thị |
| NAV-011 | P1 | FE | Ẩn bottom nav ở chat list | Đã login | Mở `/chat` | Bottom nav không hiển thị |
| NAV-012 | P1 | FE | Edit profile nằm ngoài shell | Đã login | Mở `/profile/edit` | Không có bottom nav; pop trả về profile |
| NAV-013 | P0 | RT | Socket ensureConnected khi shell mount | Sau login vào ShellRoute | Quan sát/mock `RealtimeSocketService.ensureConnected` | Được gọi một lần; không disconnect khi đổi tab |
| NAV-014 | P1 | RT | Notification stream cập nhật badge | Shell mounted | Phát notification payload | NotificationBloc nhận `NotificationRealtimeReceived` |
| NAV-015 | P1 | RT | Post engagement stream cập nhật PostBloc | Feed loaded, shell mounted | Phát like/comment payload có postId | PostBloc nhận `PostRealtimeEngagementChangedEvent` |
| NAV-016 | P1 | RT | Bỏ qua payload engagement không hợp lệ | Payload không có type like/comment hoặc postId | Phát event | Không dispatch PostBloc |
| NAV-017 | P1 | FE | App update check không chặn UI | Shell mount | Mock `AppUpdater.checkForUpdate` chậm/lỗi | UI vẫn render body và nav |
| NAV-018 | P0 | FE | Auth routes không nằm trong shell | Chưa login | Mở `/login`, `/register` | Không có bottom nav |
| NAV-019 | P1 | FE | `/auth` redirect về `/auth/login` | Mở `/auth` | Router redirect | LoginScreen hiển thị |
| NAV-020 | P1 | FE | Route profile người khác trong shell | Mở `/profile/:userId` | Điều hướng từ search/post | Body profile render trong shell nhưng settings ẩn |

## Data & Assertions

- Bottom nav selected index dựa vào path prefix: create post = 1, notifications = 2, profile = 3, còn lại = 0.
- Shell ẩn nav nếu path bắt đầu `/home/search` hoặc `/chat`.

