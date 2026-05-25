# Notifications Test Cases

## Phạm vi

Feature notifications gồm load danh sách, phân tab post/friend, badge unread, mark read, load more, pull refresh, mở post/chat/profile từ notification, accept/reject friend request và lọc request đã xử lý. API chính gồm `/notifications`, `/notifications/{id}/read`, `/notifications/seen`, `/friends/requests/{id}/accept`, `/friends/requests/{id}/reject`.

Route liên quan: `/notifications`.

## Test Cases

| ID | Priority | Type | Kịch bản | Tiền điều kiện | Bước kiểm thử | Kết quả mong đợi |
| --- | --- | --- | --- | --- | --- | --- |
| NOTI-001 | P0 | E2E | Mở Notifications từ bottom nav | Đã login ở shell | Nhấn `nav.notifications` | Route `/notifications`, tab Posts/Friends hiển thị, badge nav bị clear |
| NOTI-002 | P0 | INT | Load notification page đầu | Backend có notifications | Mở screen | Gọi `/notifications?page=1&limit=20&unreadOnly=false`, list render |
| NOTI-003 | P1 | NEG | Load notifications lỗi | Mock API lỗi | Mở screen | Snackbar errorMessage, screen không crash |
| NOTI-004 | P1 | FE | Empty post notifications | Không có post/message notifications | Mở tab Posts | Hiển thị empty message posts |
| NOTI-005 | P1 | FE | Empty friend notifications | Không có friend request notifications | Mở tab Friends | Hiển thị empty message friends |
| NOTI-006 | P1 | INT | Pull refresh | Đang ở notifications | Kéo refresh | Gọi load page 1 refresh, list cập nhật |
| NOTI-007 | P1 | INT | Load more khi scroll cuối | API trả `hasMore=true` | Scroll gần cuối | Gọi page tiếp theo, append items |
| NOTI-008 | P0 | INT | Mark single notification as read | Notification unread | Tap notification | Gọi PATCH read, item đổi background read, unreadCount giảm |
| NOTI-009 | P1 | NEG | Mark read API lỗi | Mock read lỗi | Tap unread notification | Hiển thị error, item vẫn unread |
| NOTI-010 | P1 | INT | Mark all read | Có unread và action được bật lại | Trigger `NotificationMarkAllAsReadRequested` | Gọi `/notifications/seen`, tất cả item read, unreadCount=0 |
| NOTI-011 | P0 | FE | Realtime notification tăng badge | AppShell đang listen socket | Phát `NotificationRealtimeReceived` | `hasUnreadBadge=true`, unreadCount +1 |
| NOTI-012 | P0 | FE | Clear badge khi vào tab notifications | Badge đang hiện | Nhấn nav notifications | `NotificationBadgeCleared`, badge ẩn |
| NOTI-013 | P0 | FE | Mở post notification đã có trong PostBloc | Post notification có postId đã loaded | Tap item | Mark read, mở `PostDetailScreen` ngay từ cached post |
| NOTI-014 | P0 | INT | Mở post notification cần fetch by id | Post chưa có trong PostBloc | Tap item | Hiện spinner trailing, gọi get post by id, mở detail |
| NOTI-015 | P1 | NEG | Fetch post by id lỗi | Mock get post lỗi | Tap post notification | Spinner tắt, snackbar lỗi, vẫn ở notifications |
| NOTI-016 | P0 | FE | Mở message notification | Notification type `MESSAGE_NEW` có conversationId | Tap item | Mark read, push `/chat/room/:conversationId` với ChatEntity fallback |
| NOTI-017 | P1 | FE | Message notification thiếu conversationId | Type message nhưng entityId rỗng | Tap item | Fallback mở actor profile nếu có actorId |
| NOTI-018 | P1 | FE | Friend request notification tap avatar/body | Friend notification có actorId | Tap item | Mark read, push `/profile/:actorId` |
| NOTI-019 | P0 | INT | Accept friend request từ tab Friends | Có friend request notification | Nhấn Accept | Gọi accept, remove notification, persist handled id |
| NOTI-020 | P0 | INT | Reject friend request từ tab Friends | Có friend request notification | Nhấn Reject | Gọi reject, remove notification, persist handled id |
| NOTI-021 | P1 | NEG | Accept/reject disabled khi entityId rỗng | Friend request notification thiếu entityId | Quan sát buttons | Buttons disabled, không gọi usecase |
| NOTI-022 | P1 | NEG | Accept/reject lỗi | Mock usecase throw | Nhấn action | errorMessage hiển thị, item không bị remove |
| NOTI-023 | P1 | FE | Lọc friend request đã xử lý qua Hive | handled ids đã lưu | Reload notifications | Friend request matching entityId/notificationId bị filter khỏi list |
| NOTI-024 | P2 | FE | Avatar actor lỗi hoặc rỗng | Notification thiếu avatar | Render list | Fallback initial/icon person hiển thị |
| NOTI-025 | P2 | FE | Time format notification | Notification có `createdAt` | Render item | Subtitle format `dd/MM/yyyy HH:mm`, màu khác nhau read/unread |

## Data & Assertions

- Notification type quan trọng: `LIKE`, `COMMENT`, `MESSAGE_NEW`, `FRIEND_REQUEST`.
- Các notification post dùng `entityId` làm post id; message dùng `entityId` làm conversation id; friend request dùng `entityId` làm request id.

