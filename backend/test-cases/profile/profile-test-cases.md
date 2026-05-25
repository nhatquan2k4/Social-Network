# Profile Test Cases

## Phạm vi

Feature profile gồm xem hồ sơ của mình/người khác, posts/photos tabs, cập nhật display name/bio/phone, cập nhật avatar, mở danh sách bạn bè, gửi kết bạn, mở direct message và logout. API chính gồm `/users/{id}/profile`, `/users/{id}/posts`, `/users/me`, `/users/me/avatar`, `/friends`, `/friends/requests`, `/conversations`.

Routes liên quan: `/profile`, `/profile/:userId`, `/profile/edit`, `/profile/friends`.

## Test Cases

| ID | Priority | Type | Kịch bản | Tiền điều kiện | Bước kiểm thử | Kết quả mong đợi |
| --- | --- | --- | --- | --- | --- | --- |
| PROFILE-001 | P0 | E2E | Mở profile của mình từ bottom nav | Đã login | Nhấn `nav.profile` | Route `/profile`, load profile, thấy `profile.settings` |
| PROFILE-002 | P0 | INT | Load profile thành công | Có `user_id` trong secure storage | Mở `/profile` | Gọi `/users/{id}/profile`, render header, count, tabs |
| PROFILE-003 | P0 | NEG | Thiếu session user id | Secure storage không có `user_id` | Mở `/profile` | Hiển thị no-session empty state |
| PROFILE-004 | P1 | NEG | Load profile lỗi | Mock API lỗi | Mở `/profile` | Hiển thị error view và nút retry |
| PROFILE-005 | P1 | INT | Retry profile sau lỗi | PROFILE-004, API phục hồi | Nhấn retry | Reload thành công, error biến mất |
| PROFILE-006 | P1 | FE | Posts tab render bài viết user | User có posts | Mở profile, chọn tab posts | Hiển thị các post của user, hỗ trợ refresh |
| PROFILE-007 | P1 | FE | Photos tab render ảnh từ posts | User có media posts | Chọn tab photos | Hiển thị ảnh đúng, bỏ qua post không có media |
| PROFILE-008 | P1 | FE | Posts API lỗi nhưng profile thành công | Mock `/users/{id}/posts` lỗi | Mở profile | Header vẫn hiển thị, posts tab có error/empty phù hợp |
| PROFILE-009 | P0 | E2E | Mở edit profile từ settings | Đã ở profile của mình | Nhấn settings, chọn edit | Route `/profile/edit`, thấy display name/bio/phone/save |
| PROFILE-010 | P0 | E2E | Cập nhật display name và bio | Ở edit profile | Sửa displayName, bio, save | Gọi PATCH `/users/me`, pop về profile, hiển thị snackbar success |
| PROFILE-011 | P0 | NEG | Display name rỗng | Ở edit profile | Xóa displayName, save | Validator báo lỗi, không gọi API |
| PROFILE-012 | P1 | NEG | Save khi không thay đổi | Ở edit profile, giữ nguyên dữ liệu | Nhấn save | Hiển thị `profileNoChanges`, không gọi update |
| PROFILE-013 | P1 | NEG | Update profile API lỗi | Mock PATCH lỗi | Sửa dữ liệu và save | Hiển thị lỗi, vẫn ở edit page, input không mất |
| PROFILE-014 | P1 | FE | Cancel edit profile | Ở edit profile | Nhấn Cancel/back | Pop về profile, không gọi update |
| PROFILE-015 | P1 | INT | Cập nhật avatar thành công | Có quyền chọn ảnh hoặc mock bytes | Tap avatar, chọn change avatar, chọn ảnh | Gọi PATCH `/users/me/avatar`, loading dialog đóng, profile refresh |
| PROFILE-016 | P1 | NEG | Avatar upload lỗi | Mock API lỗi | Chọn ảnh update avatar | Hiển thị lỗi, loading tắt, avatar cũ giữ nguyên |
| PROFILE-017 | P1 | FE | Xem avatar của mình | Profile có avatar | Tap avatar | Dialog viewer mở; có action change avatar |
| PROFILE-018 | P1 | FE | Xem avatar người khác | Mở `/profile/:userId` | Tap avatar | Dialog viewer mở; không có action change avatar |
| PROFILE-019 | P1 | FE | Mở profile người khác từ search/post/comment | Có target user | Tap user result/author/comment author | Route `/profile/:userId`, không hiển thị settings |
| PROFILE-020 | P1 | INT | Gửi friend request từ profile người khác | Target chưa là bạn | Nhấn add friend | Trạng thái sending -> sent/friends, snackbar thành công |
| PROFILE-021 | P1 | INT | Mở direct message từ profile người khác | Target hợp lệ | Nhấn Message | Gọi `/conversations`, mở `/chat/room/:threadId` với ChatEntity |
| PROFILE-022 | P1 | NEG | Open message lỗi | Mock create conversation lỗi | Nhấn Message | Hiển thị snackbar cannotOpenChat, không điều hướng |
| PROFILE-023 | P0 | E2E | Logout từ settings | Ở profile của mình | Settings > Logout | Auth logout loading overlay, route về `/login` |
| PROFILE-024 | P2 | FE | Đổi theme trong settings | Ở settings sheet | Toggle theme | App đổi light/dark, lưu mode theo ThemeBloc |
| PROFILE-025 | P2 | FE | Đổi ngôn ngữ trong settings | Ở settings sheet | Chọn English/Vietnamese | Text UI đổi locale, lựa chọn hiển thị đúng |

## Data & Assertions

- Test keys chính: `nav.profile`, `profile.settings`, `profile.edit`, `profile.logout`, `profile.edit.displayName`, `profile.edit.bio`, `profile.edit.phone`, `profile.edit.save`.
- Khi test profile người khác, target route lấy từ `AppRoutes.otherProfile` và không nên hiển thị `profile.settings`.

