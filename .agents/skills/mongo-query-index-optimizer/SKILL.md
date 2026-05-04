---
name: mongo-query-index-optimizer
description: Tối ưu truy vấn MongoDB cho backend Social Network. Áp dụng cho feed, list post, list message, notifications: bắt buộc pagination, limit an toàn, sort, projection và gợi ý index.
applyTo:
   - "src/routes/**"
version: 1.1.0
tools:
   - read_file
   - apply_patch
   - runSubagent
examples:
   - input : "GET /api/posts/feed?limit=100, sort=createdAt"
     output: "Trả về feed với pagination, limit tối đa 50, sort theo createdAt desc, projection chỉ cần thiết, gợi ý index authorId + createdAt" 
tests:
   - name: list-pagination-index
     description: Endpoint list có pagination, limit an toàn, projection, sort có index
     example: true
---

# Mongo Query Index Optimizer

## Mục tiêu
Đảm bảo các endpoint danh sách (feed, list post, list message, notifications) có pagination, limit an toàn, sort hợp lý, projection tối thiểu và gợi ý index phù hợp.

## Phạm vi ưu tiên
- feed
- list posts
- list messages
- notifications

## Hợp đồng đầu vào
- `endpoint`: tên/đường dẫn endpoint list
- `query`: page/limit/sort/filter
- `defaultPagination`: page/limit mặc định
- `maxLimit`: giới hạn limit an toàn
- `projection`: danh sách field cần select

Nếu thiếu thông tin, hỏi ngắn gọn:
1) Đây là endpoint list nào?
2) Sort/filter theo field nào?
3) Cần select field tối thiểu?
4) Max limit mong muốn?

## Hợp đồng đầu ra
- Trả items + meta pagination (page, limit, total, totalPages)
- Không trả full document khi không cần

## Quy tắc bắt buộc
- Endpoint list bắt buộc pagination
- Limit phải được chặn bằng maxLimit
- Projection chỉ chọn field cần thiết
- Hạn chế populate lồng nhiều tầng
- Sort ưu tiên field có index

## Gợi ý kỹ thuật
- Dùng `normalizePagination` từ `shared/validators/pagination.validator.ts` nếu có
- Dùng `.lean()` cho list
- Dùng `select`/projection thay vì trả full document

## Gợi ý index theo module
- posts: `authorId + createdAt`
- messages: `conversationId + createdAt`
- notifications: `recipientId + read + createdAt`
- friends: `requesterId + receiverId + status`

## Mẫu prompt (dùng với `skill-creator`)
```
Optimize list query for:
- endpoint: GET /api/messages?conversationId=...
- sort: createdAt desc
- projection: _id, senderId, content, createdAt
- maxLimit: 50

Return: patch updating repo/service query with pagination, projection, sort, and index suggestion
```

## Tiêu chí hoàn thành
- Pagination áp dụng đúng
- Limit an toàn
- Projection tối thiểu
- Có đề xuất index phù hợp

## Edge Cases
- page/limit invalid
- limit vượt max
- sort theo field không có index
- filter thiếu field index

## Checklist kiểm thử
- Không query toàn bộ collection
- Pagination hoạt động đúng
- Projection giảm field trả về
- Sort có index phù hợp
