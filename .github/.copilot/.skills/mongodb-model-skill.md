# Kỹ năng thiết kế model MongoDB

Dùng skill này khi tạo mới hoặc sửa model MongoDB hoặc các query liên quan.

## Mục tiêu
Tạo schema và query ổn định, an toàn, phù hợp cho backend mạng xã hội.

## Quy tắc về schema
- Dùng timestamps nếu phù hợp
- Đánh dấu field bắt buộc rõ ràng
- Dùng enum cho các giá trị cố định
- Tạo index cho các field thường xuyên được lọc hoặc sắp xếp
- Tránh lưu field dư thừa nếu không thật sự cần cho hiệu năng
- Ẩn các field nhạy cảm khỏi output API

## Quy tắc về query
- Endpoint danh sách phải có pagination
- Validate id trước khi query
- Chỉ select các field cần thiết
- Tránh populate lồng nhau không cần thiết
- Cân nhắc mối quan hệ nào nên đọc nhiều, mối quan hệ nào ghi nhiều

## Gợi ý mô hình cho backend mạng xã hội
- users: hồ sơ, thông tin auth, avatar hoặc metadata media
- posts: tác giả, nội dung, media, quyền riêng tư, bộ đếm, thời gian tạo
- conversations: danh sách participants, thông tin last message, timestamps
- messages: conversation id, sender id, nội dung, media, seen info
- notifications: actor, recipient, type, target, read state
- friends: requester, receiver, status
- media metadata: objectName, bucket, mimeType, size, url, owner

## Ví dụ index nên cân nhắc
- posts theo author + createdAt
- messages theo conversation + createdAt
- notifications theo recipient + read + createdAt
- friends theo requester, receiver, status

## Không được
- lạm dụng populate
- lấy toàn bộ collection cho endpoint có thể phân trang
- trả password hash, refresh token hoặc secret nội bộ