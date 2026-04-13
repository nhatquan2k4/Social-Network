# Kỹ năng xử lý realtime

Dùng skill này khi triển khai tính năng realtime cho messages, notifications, presence hoặc live updates.

## Mục tiêu
Emit event realtime một cách nhất quán và chỉ sau khi trạng thái backend đã thay đổi thành công.

## Áp dụng cho
- tin nhắn mới
- đã xem tin nhắn
- thông báo mới
- thay đổi trạng thái lời mời kết bạn
- cập nhật tương tác bài viết nếu cần realtime

## Quy tắc
- Phải lưu dữ liệu thành công trước khi emit
- Tên event phải rõ ràng và ổn định
- Payload chỉ nên chứa dữ liệu tối thiểu
- User thao tác phải được kiểm tra quyền
- Chỉ emit tới đúng user hoặc room liên quan
- Phần realtime không được chứa business logic nặng

## Gợi ý tên event
- message:created
- message:seen
- notification:created
- friend_request:created
- friend_request:accepted

## Không được
- emit trước khi lưu database thành công
- gửi cả document lớn khi chỉ cần payload nhỏ
- tin room membership từ client nếu chưa xác minh phía server