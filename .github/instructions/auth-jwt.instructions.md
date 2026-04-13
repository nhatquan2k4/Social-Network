---
applyTo: "backend/src/**/*.ts"
---

# Kỹ năng xác thực JWT

Dùng skill này khi triển khai hoặc chỉnh sửa chức năng authentication và authorization.

## Mục tiêu
Cung cấp luồng xác thực an toàn cho backend mạng xã hội.

## Phạm vi
- đăng ký
- đăng nhập
- đăng xuất
- refresh token
- bảo vệ route riêng tư
- kiểm tra quyền hoặc ownership

## Quy tắc
- Password phải được hash an toàn
- Không bao giờ trả password hash ra response
- Validate credential cẩn thận
- Route riêng tư phải dùng auth middleware
- Ưu tiên user lấy từ middleware xác thực thay vì userId từ client
- Từ chối truy cập trái phép một cách rõ ràng
- Nếu có refresh token, phải có cơ chế revoke hoặc invalidate phù hợp

## Checklist cho thao tác được bảo vệ
Trước khi update, delete hoặc read dữ liệu nhạy cảm phải kiểm tra:
- user đã đăng nhập chưa
- tài nguyên có tồn tại không
- user có sở hữu tài nguyên hoặc có quyền thao tác không
- trạng thái hiện tại của tài nguyên có cho phép thao tác không

## Lỗi thường gặp cần tránh
- tin req.body.userId để xác định ownership
- làm lộ chi tiết token
- quên auth middleware ở route riêng tư
- trả lỗi quá chi tiết giúp kẻ tấn công đoán tài khoản tồn tại hay không
