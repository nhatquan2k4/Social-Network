# Kỹ năng xây dựng module Express

Dùng skill này khi tạo mới hoặc chỉnh sửa một module backend theo tính năng.

## Áp dụng cho
- auth
- users
- posts
- media
- friends
- conversations
- messages
- notifications

## Mục tiêu
Triển khai tính năng theo đúng cấu trúc module của repository.

## Cách làm bắt buộc
1. Xác định đúng module trong src/routes
2. Xác định rõ mục đích endpoint
3. Thêm validation cho request
4. Giữ controller mỏng
5. Chuyển business logic sang service hoặc handler riêng
6. Dùng shared error và shared response nếu đã có
7. Thêm auth và permission checks nếu cần
8. Với endpoint danh sách, phải cân nhắc pagination, filter, sort
9. Nếu tính năng có ảnh hưởng giao diện realtime, cân nhắc emit event
10. Trả response theo format nhất quán

## Cấu trúc khuyến nghị
- route: đăng ký endpoint và middleware
- validator: kiểm tra dữ liệu đầu vào
- controller: nhận request và trả response
- service: xử lý business logic
- model hoặc repository: xử lý database nếu kiến trúc hiện tại có tách

## Quy tắc
- Không query database trực tiếp trong file route
- Không bỏ qua validation
- Không đưa logic của feature này sang shared nếu chưa thực sự là logic dùng chung
- Giữ thay đổi cục bộ trong module, trừ khi thật sự cần trích xuất phần dùng chung

## Gợi ý theo từng module
- posts: feed query, visibility, ownership, media
- messages: kiểm tra membership cuộc trò chuyện, quyền gửi tin, emit realtime
- notifications: đúng người nhận, trạng thái read/unread
- friends: chặn tự gửi lời mời cho chính mình, tránh duplicate request, xử lý status rõ ràng