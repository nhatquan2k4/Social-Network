# Social Network FE Test Cases

## Phạm vi

Bộ tài liệu này mô tả kịch bản kiểm thử cho app Flutter trong `Social-Network-FE/frontend`.

Nguồn đã đọc khi lập test case:

- Routes: `lib/src/routes/app_route_conf.dart`, `lib/src/routes/app_route_path.dart`
- Test keys: `lib/src/core/testing/test_keys.dart`
- E2E hiện có: `integration_test/social_network_e2e_test.dart`, `integration_test/tests/*`
- Feature source: `lib/src/features/{auth,post,search,friend,profile,chat,message,notifications,home,story}`
- API constants: `lib/src/core/api/api_constants.dart`

## Cấu trúc thư mục

- `auth/`: đăng ký, đăng nhập, quên mật khẩu, đăng xuất.
- `feed-posts/`: bảng tin, tạo/sửa/xóa bài viết, like, comment, report, media.
- `search/`: tìm kiếm người dùng, lịch sử tìm kiếm, phân trang.
- `friends/`: gửi/chấp nhận/từ chối lời mời, danh sách bạn bè.
- `profile/`: hồ sơ cá nhân, hồ sơ người khác, cập nhật profile/avatar.
- `chat-messages/`: danh sách hội thoại, tạo hội thoại, phòng chat, tin nhắn realtime.
- `notifications/`: danh sách thông báo, badge, điều hướng từ notification, xử lý friend request.
- `navigation-shell/`: route, bottom navigation, socket shell, trạng thái đăng nhập.
- `settings-localization/`: đổi ngôn ngữ, đổi theme, local storage.
- `home-story/`: màn Home prototype và Story viewer hiện có trong code.

## Quy ước test case

- `P0`: luồng chính, có ảnh hưởng trực tiếp đến đăng nhập, đăng bài, chat, dữ liệu người dùng.
- `P1`: luồng quan trọng nhưng có thể workaround.
- `P2`: polish, edge case hoặc feature đang ở mức phụ trợ/prototype.
- `FE`: kiểm thử UI/frontend.
- `INT`: kiểm thử tích hợp với backend API.
- `E2E`: kiểm thử end-to-end qua app thật.
- `NEG`: kiểm thử lỗi/validation.

## Môi trường khuyến nghị

- Backend E2E đang chạy với endpoint reset dữ liệu: `/api/test/reset`.
- Chạy Flutter với `--dart-define` tương ứng:
  - `START_ROUTE`
  - `API_SCHEME`
  - `API_HOST`
  - `API_PORT`
  - `ENABLE_LOGGING`
  - `E2E_USERNAME`
  - `E2E_PASSWORD`
  - `E2E_EMAIL` nếu bật đăng ký tự động
  - `E2E_ENABLE_REGISTER`
- Seed data tối thiểu nên có: `seed_user`, `admin`, mật khẩu `Password123!`.
- Trước E2E nên reset backend và xóa Hive/local storage để tránh trạng thái cũ.

## Gợi ý tự động hóa

Các test P0 đã có một phần trong `integration_test/tests`. Khi mở rộng automation, ưu tiên dùng `TestKeys` thay vì text cứng:

- Auth: `login.username`, `login.password`, `login.submit`, `register.*`
- Feed/Post: `feed.search`, `feed.chat`, `nav.create`, `createPost.caption`, `post.like`, `post.comment`
- Search: `search.input`
- Chat: `chat.newConversation`, `chat.thread.{index}`, `chat.message.input`, `chat.message.send`
- Profile: `nav.profile`, `profile.settings`, `profile.edit`, `profile.logout`, `profile.edit.*`
- Notifications: `nav.notifications`

