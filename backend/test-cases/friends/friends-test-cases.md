# Friends Test Cases

## Phạm vi

Feature friend gồm gửi lời mời từ profile/feed, danh sách bạn bè, danh sách request, accept/reject và trạng thái nút kết bạn. API chính gồm `/friends`, `/friends/requests`, `/friends/requests/{id}/accept`, `/friends/requests/{id}/reject`.

Routes liên quan: `/profile/friends`, `/profile/:userId`, notification tab friends.

## Test Cases

| ID | Priority | Type | Kịch bản | Tiền điều kiện | Bước kiểm thử | Kết quả mong đợi |
| --- | --- | --- | --- | --- | --- | --- |
| FRIEND-001 | P0 | E2E | Gửi lời mời kết bạn từ profile người khác | Đã login, có user khác `admin`, chưa là bạn | Search `admin`, mở profile, nhấn add friend | Gọi `/friends/requests`, nút chuyển trạng thái sent/check, snackbar thành công |
| FRIEND-002 | P0 | NEG | Không gửi request trùng | Đã gửi request hoặc đã là bạn | Nhấn add friend lần nữa nếu còn thấy nút | Không gọi API trùng, nút disabled/không tương tác |
| FRIEND-003 | P1 | NEG | Gửi request lỗi | Mock API lỗi | Nhấn add friend | Hiển thị lỗi, trạng thái nút quay về idle nếu chưa là bạn |
| FRIEND-004 | P0 | INT | Accept friend request từ notification | Có notification `FRIEND_REQUEST` với entityId request | Vào Notifications > Friends, nhấn Accept | Gọi accept endpoint, item bị remove, unread giảm, handled id lưu Hive |
| FRIEND-005 | P0 | INT | Reject friend request từ notification | Có notification `FRIEND_REQUEST` | Nhấn Reject | Gọi reject endpoint, item bị remove, unread giảm, handled id lưu Hive |
| FRIEND-006 | P1 | NEG | Accept request lỗi | Mock accept lỗi | Nhấn Accept | Button re-enable, hiển thị errorMessage, item vẫn còn |
| FRIEND-007 | P1 | NEG | Reject request lỗi | Mock reject lỗi | Nhấn Reject | Button re-enable, hiển thị errorMessage, item vẫn còn |
| FRIEND-008 | P1 | FE | Không hiển thị request đã xử lý sau reload | Đã accept/reject một request | Reload Notifications | Request có id đã lưu không xuất hiện lại |
| FRIEND-009 | P1 | INT | Mở danh sách bạn bè của mình | Đã login, có bạn bè | Vào Profile, tap friends count/list | Route `/profile/friends`, list friend render đúng |
| FRIEND-010 | P1 | FE | Empty friends list | User chưa có bạn | Mở `/profile/friends` | Hiển thị empty state "Chưa có bạn bè" và pull refresh hoạt động |
| FRIEND-011 | P1 | NEG | Friends API lỗi | Mock `/friends` lỗi | Mở `/profile/friends` | Hiển thị error state và nút thử lại |
| FRIEND-012 | P1 | FE | Pull refresh friends list | Đang ở list friends | Kéo refresh | Future reload, list cập nhật |
| FRIEND-013 | P1 | FE | Tap friend mở profile | List có friend | Tap một friend | Push `/profile/:userId` đúng friend id |
| FRIEND-014 | P1 | INT | FriendRequestsPage load requests | Có provider `FriendRequestsBloc` | Mở page request | Loading -> list request hoặc empty state |
| FRIEND-015 | P1 | INT | Accept trong FriendRequestsPage | Có request | Nhấn accept trên tile | Gọi bloc.accept, request biến mất/cập nhật list |
| FRIEND-016 | P1 | INT | Reject trong FriendRequestsPage | Có request | Nhấn reject trên tile | Gọi bloc.reject, request biến mất/cập nhật list |
| FRIEND-017 | P1 | FE | Trạng thái already friend trong ProfileActionBar | Target đã là bạn | Mở profile target | Button hiển thị `friends/check`, disabled; message button vẫn dùng được |
| FRIEND-018 | P2 | FE | Friend avatar URL lỗi | Friend có avatar hỏng | Mở friends list | Hiển thị fallback initial, không crash |

## Data & Assertions

- Dữ liệu seed nên có quan hệ hoặc request giữa `seed_user`, `admin`, `seed_friend`.
- Với automation hiện có, luồng gửi request đang được kiểm tra trong `friends_e2e_test.dart` qua search `@admin`.

