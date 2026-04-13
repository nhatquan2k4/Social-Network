# Bối cảnh dự án

Đây là dự án backend cho một ứng dụng mạng xã hội.

## Công nghệ sử dụng
- Node.js
- ExpressJS
- TypeScript
- MongoDB
- Realtime communication
- MinIO hoặc local object storage để lưu media

## Các module chính
- auth
- users
- posts
- media
- friends
- conversations
- messages
- notifications
- realtime events

## Cấu trúc dự án hiện tại
- src/routes/auth
- src/routes/users
- src/routes/posts
- src/routes/media
- src/routes/friends
- src/routes/conversations
- src/routes/messages
- src/routes/notifications
- src/shared/config
- src/shared/db
- src/shared/errors
- src/shared/http
- src/shared/middlewares
- src/shared/realtime
- src/shared/types
- src/shared/utils
- src/shared/validators

## Mục tiêu
Backend phải dễ bảo trì, dễ mở rộng, có tính module rõ ràng, an toàn và nhất quán.

## Ưu tiên khi sinh hoặc sửa mã
1. Tách module rõ ràng theo từng tính năng
2. Controller mỏng
3. Business logic phải được tách riêng
4. Validation và error handling phải nhất quán
5. Authentication và authorization phải an toàn
6. Xử lý media phải rõ ràng và mở rộng được
7. Response API phải có format thống nhất
8. Realtime event phải có tên rõ ràng, phát đúng thời điểm