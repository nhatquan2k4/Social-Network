# Feed & Posts Test Cases

## Phạm vi

Feature post gồm feed, tạo bài, upload media, like, comment/reply, sửa/xóa bài, report, điều hướng profile tác giả và đồng bộ realtime engagement. Luồng dùng `PostBloc`, `CommentsSheet`, `PostRemoteDatasource`; API chính gồm `/posts/feed`, `/posts`, `/posts/{id}`, `/posts/{id}/like`, `/posts/{id}/comments`, `/posts/{id}/report`, `/media/upload`.

Routes liên quan: `/home`, `/create-post`, post detail mở bằng `MaterialPageRoute`.

## Test Cases

| ID | Priority | Type | Kịch bản | Tiền điều kiện | Bước kiểm thử | Kết quả mong đợi |
| --- | --- | --- | --- | --- | --- | --- |
| POST-001 | P0 | E2E | Load feed thành công | Đã login, backend có hoặc không có post | Mở `/home` | Nếu có data: render danh sách `PostCard`; nếu rỗng: hiển thị empty state hợp lệ |
| POST-002 | P0 | INT | Feed API lỗi | Mock `/posts/feed` lỗi | Mở `/home` hoặc pull refresh | Hiển thị snackbar lỗi từ `PostFailureState`, app không crash |
| POST-003 | P0 | E2E | Tạo bài chỉ có text | Đã login | Vào `/create-post`, nhập caption, submit | Gọi `PostCreateEvent`, reload feed, quay về `/home`, post mới xuất hiện |
| POST-004 | P0 | NEG | Không submit bài rỗng | Ở `/create-post` | Không nhập caption, không chọn ảnh, nhấn submit | Không gọi API, vẫn ở trang tạo bài |
| POST-005 | P1 | INT | Tạo bài chỉ có ảnh | Có quyền gallery/camera hoặc mock image picker | Chọn ảnh, không nhập caption, submit | Upload `/media/upload`, tạo `/posts` với media, quay về feed |
| POST-006 | P1 | INT | Tạo bài text + nhiều ảnh | Có nhiều ảnh hợp lệ | Chọn nhiều ảnh, nhập caption, submit | Upload đủ file, post hiển thị carousel/ảnh đúng thứ tự |
| POST-007 | P1 | NEG | Upload media thất bại | Mock `/media/upload` lỗi | Chọn ảnh và submit | Hiển thị lỗi, `_isSubmitting=false`, không tạo post |
| POST-008 | P1 | FE | Thay ảnh trong create post | Có ít nhất 1 ảnh đã chọn | Mở options ảnh, chọn replace | Ảnh tại index được thay, số lượng ảnh không đổi |
| POST-009 | P1 | FE | Xóa ảnh trong create post | Có ít nhất 1 ảnh đã chọn | Mở options ảnh, chọn remove | Ảnh bị xóa; nếu không còn text/ảnh thì submit disabled |
| POST-010 | P0 | E2E | Like post trên feed | Feed có ít nhất 1 post | Nhấn `post.like` | UI optimistic đổi icon/count, API `/posts/{id}/like` thành công thì giữ trạng thái |
| POST-011 | P0 | NEG | Like API lỗi phải rollback | Feed có post, mock like lỗi | Nhấn like | UI quay về trạng thái cũ, hiển thị `PostActionFailureState` |
| POST-012 | P0 | E2E | Mở comment sheet và comment | Feed có post | Nhấn `post.comment`, nhập nội dung, nhấn send | Comment mới xuất hiện, count tăng, sheet không đóng ngoài ý muốn |
| POST-013 | P1 | NEG | Không gửi comment rỗng | Comment sheet đang mở | Để input trống, nhấn send | Không gọi API, không tăng count |
| POST-014 | P1 | INT | Load comments từ server | Post có comments | Mở comment sheet | Gọi `/posts/{id}/comments`, render author/content/time, fallback nếu API lỗi |
| POST-015 | P1 | FE | Reply comment | Comment sheet có comment | Nhấn Reply, nhập nội dung, send | Hiển thị trạng thái replying, comment con nằm dưới parent với indentation |
| POST-016 | P1 | INT | Sửa comment của mình | User là owner comment | Mở actions comment, chọn edit, nhập nội dung mới | Gọi PATCH comment, UI cập nhật nội dung, snackbar thành công |
| POST-017 | P1 | INT | Xóa comment của mình | User là owner comment | Mở actions comment, chọn delete, confirm | Gọi DELETE comment, comment/thread con bị xóa, count giảm |
| POST-018 | P0 | FE | Mở post detail từ feed | Feed có post | Tap lên `PostCard` | Mở detail; nếu 1 ảnh dùng layout media detail, nhiều ảnh dùng scroll detail |
| POST-019 | P1 | FE | Like trong post detail đồng bộ feed | Đang ở detail | Nhấn like, quay lại feed | Count/icon được đồng bộ qua `PostBloc` |
| POST-020 | P1 | FE | Comment trong post detail đồng bộ feed | Đang ở detail | Mở comments, thêm comment, quay lại feed | Count comment trên feed cập nhật |
| POST-021 | P1 | INT | Owner sửa bài viết | Đang xem detail bài của mình | Mở owner actions, chọn edit, sửa content/media, save | Gọi PATCH `/posts/{id}`, UI cập nhật, feed cache đổi |
| POST-022 | P1 | NEG | Owner save bài không đổi | Đang edit post | Không thay đổi content/media, save | Hiển thị `noChangesToUpdate`, không gọi update |
| POST-023 | P0 | INT | Owner xóa bài viết | Đang xem detail bài của mình | Mở actions, chọn delete, confirm | Gọi DELETE `/posts/{id}`, detail pop về feed, post bị remove local |
| POST-024 | P1 | FE | Non-owner report bài viết | Feed có post người khác | Mở more, chọn report, chọn reason, submit | Gọi `/posts/{id}/report`, snackbar report success |
| POST-025 | P1 | FE | Hide post từ options | Feed có post | Mở more, chọn hide | Gọi delete/hide action hiện tại và post biến mất khỏi list local |
| POST-026 | P1 | FE | Tap tác giả post | Feed có post có `authorId` | Tap avatar/name tác giả | Điều hướng `/profile/:userId` |
| POST-027 | P1 | INT | Gửi friend request từ post author | Post của người chưa là bạn | Nhấn follow/add friend trên post | Gọi `/friends/requests`, hiển thị success, nút không gửi trùng |
| POST-028 | P1 | FE | Pull to refresh feed | Feed đang hiển thị | Kéo refresh | Gọi `PostLoadEvent`, danh sách reload và sort theo `createdAt` mới nhất |
| POST-029 | P1 | RT | Realtime like/comment notification cập nhật feed | Socket nhận payload type like/comment có postId | Phát event vào `postEngagementStream` | Count like/comment tăng đúng post, không nhân đôi notificationId |
| POST-030 | P2 | FE | Ảnh lỗi mạng hiển thị fallback | Post có `mediaUrl` hỏng | Mở feed/detail | Hiển thị broken image placeholder, không crash |

## Data & Assertions

- Dùng `MockData.postText`, `MockData.commentText` để tránh trùng dữ liệu.
- Test keys chính: `nav.create`, `createPost.caption`, `createPost.submit`, `post.like`, `post.comment`, `post.comment.input`, `post.comment.send`, `feed.search`.
- Khi test media trên web cần mock `XFile.readAsBytes`; mobile cần quyền gallery/camera.

