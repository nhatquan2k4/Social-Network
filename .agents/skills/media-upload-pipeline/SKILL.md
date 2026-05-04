---
name: media-upload-pipeline
description: Chuẩn hóa flow upload MinIO/local: multipart → mime/size validate → objectName an toàn → upload → lưu metadata → cleanup file cũ.
applyTo:
  - "src/routes/**"
version: 1.1.0
tools:
  - read_file
  - apply_patch
  - runSubagent
examples:
  - input: "Upload avatar (1 file), mime image/*, thay thế file cũ"
    output: "Parse multipart, validate mime/size, tạo objectName an toàn, upload, lưu metadata, cleanup file cũ"
tests:
  - name: media-upload-flow
    description: Upload theo đúng flow, metadata đầy đủ, cleanup file cũ
    example: true
---

# Media Upload Pipeline

## Mục tiêu
Chuẩn hóa flow upload media MinIO/local theo thứ tự bắt buộc: multipart → validate mime/size → tạo objectName an toàn → upload → lưu metadata → cleanup file cũ.

## Hợp đồng đầu vào
- `files`: số lượng, size, mime type
- `purpose`: avatar|post|message
- `resourceId`: id tài nguyên liên quan
- `replace`: có thay file cũ hay không

Nếu thiếu thông tin, hỏi ngắn gọn:
1) Upload cho mục đích gì? (avatar/post/message)
2) Số lượng file, size, mime type?
3) Có thay thế file cũ không?

## Hợp đồng đầu ra
- Trả metadata chuẩn (bucket, objectName, mimeType, size, url)
- Không trả thông tin credential storage

Metadata cần lưu:
- bucket
- objectName
- originalName
- mimeType
- size
- uploadedBy
- resourceId liên quan
- createdAt

## Quy tắc bắt buộc
- Parse multipart trước
- Validate mime/size trước upload
- objectName an toàn, duy nhất
- Upload lên MinIO/local
- Lưu metadata vào DB
- Cleanup file cũ nếu thay thế và không còn tham chiếu

## Gợi ý đặt tên object
- avatars/{userId}/{timestamp}-{sanitizedName}
- posts/{postId}/{timestamp}-{sanitizedName}
- messages/{conversationId}/{timestamp}-{sanitizedName}

## Mẫu prompt (dùng với `skill-creator`)
```
Standardize media upload for:
- purpose: avatar
- files: 1
- mime: image/png,image/jpeg
- maxSize: 5242880
- replace: true

Return: patch implementing multipart, validation, safe objectName, upload, metadata save, cleanup old file
```

## Tiêu chí hoàn thành
- Upload đúng flow
- Metadata đầy đủ
- File sai bị chặn sớm
- Cleanup file cũ đúng khi thay thế

## Edge Cases
- Không có file
- Sai mime type
- File vượt size
- Upload thất bại
- File cũ còn tham chiếu

## Checklist kiểm thử
- Upload đúng flow
- Metadata đầy đủ
- File sai bị chặn sớm
- Thay thế file cũ và cleanup đúng
