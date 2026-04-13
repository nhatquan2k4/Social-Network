# Kỹ năng upload media với MinIO

Dùng skill này cho các luồng upload, thay thế, lấy metadata hoặc xóa media bằng MinIO hoặc local object storage.

## Mục tiêu
Xử lý media an toàn, nhất quán và phù hợp với backend hiện tại.

## Áp dụng cho
- upload avatar
- upload ảnh hoặc video bài viết
- upload file đính kèm tin nhắn
- thay thế media cũ
- xóa media

## Luồng bắt buộc
1. parse multipart input bằng middleware phù hợp
2. kiểm tra file có tồn tại không
3. validate mime type
4. validate kích thước file
5. tạo object name an toàn và duy nhất
6. upload file lên object storage
7. lưu metadata vào database
8. trả response media theo format chuẩn
9. xóa object cũ nếu file bị thay thế và không còn được tham chiếu

## Metadata cần lưu
- bucket
- objectName
- originalName
- mimeType
- size
- uploadedBy
- id của tài nguyên liên quan
- url hoặc public path nếu có
- createdAt

## Ví dụ quy ước đặt tên
- avatars/{userId}/{timestamp}-{sanitizedName}
- posts/{postId}/{timestamp}-{sanitizedName}
- messages/{conversationId}/{timestamp}-{sanitizedName}

## Quy tắc bảo mật
- Không chỉ dựa vào extension
- Không để lộ credential storage
- Không dùng tên file dễ đoán một cách đơn giản
- Từ chối file không đúng loại cho phép
- Từ chối file quá dung lượng
- Kiểm tra quyền trước khi thay thế hoặc xóa media

## Hành vi API
- Trả metadata media có cấu trúc
- Ẩn chi tiết triển khai storage
- Không trộn logic chi tiết của storage vào controller không liên quan