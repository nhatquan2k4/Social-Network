---
name: api-change-impact-checker
description: Rà soát ảnh hưởng chéo trước merge cho thay đổi API backend: auth/perms, DB/index/pagination/select, realtime emit, media upload, response contract. Dùng ngay khi sửa hoặc thêm endpoint trong src/routes, đổi DTO/controller/service, hoặc khi có thay đổi về bảo mật, query, upload, hay payload response.
applyTo:
  - "src/routes/**"
version: 1.2.0
tools:
  - read_file
  - apply_patch
  - runSubagent
examples:
  - input: "Cập nhật POST /api/posts, đổi response payload"
    output: "Checklist: auth/perms, DB/index/pagination, realtime, media, response contract"
tests:
  - name: impact-checklist
    description: Checklist day du 5 nhom anh huong
    example: true
---

# API Change Impact Checker

## Mục tiêu
Rà soát ảnh hưởng chéo trước merge khi thay đổi API: auth/perms, DB/index/pagination/select, realtime, media, response contract.

## Khi nào dùng
Dùng skill này khi có bất kỳ thay đổi nào chạm đến route, DTO, controller, service, middleware, upload media, query danh sách, hoặc response payload của backend.

## Hợp đồng đầu vào
- `endpointOrModule`: endpoint/module thay đổi
- `changeType`: new|update|delete
- `responseChange`: mô tả thay đổi response

Nếu thiếu thông tin, hỏi ngắn gọn:
1) Endpoint/module nào đổi?
2) Loại thay đổi (new/update/delete)?
3) Response contract thay đổi gì?

## Hợp đồng đầu ra
- Danh sách ảnh hưởng cần kiểm tra
- Checklist xác nhận trước merge

## Checklist bắt buộc
- Auth/permissions: route private có auth middleware, ownership/permission được kiểm tra đúng chỗ
- DB/index/pagination/select: endpoint danh sách có pagination, select đủ nhỏ, index phù hợp với query/sort
- Realtime: emit sau khi DB save thành công, đúng user/room scope
- Media: validate mime/size, objectName an toàn, cleanup file cũ nếu thay thế
- Response contract: giữ format nhất quán { message, data, meta }

## Mẫu prompt (dùng với `skill-creator`)
```
Check API change impact:
- endpointOrModule: posts
- changeType: update
- responseChange: add field sharedCount

Return: checklist for auth, DB/index, realtime, media, response contract
```

## Tiêu chí hoàn thành
- Checklist đầy đủ 5 nhóm ảnh hưởng
- Không bỏ sót module liên quan

## Edge Cases
- Endpoint protected nhưng thiếu auth
- Query list không pagination
- Realtime emit trước DB save
- Upload thiếu validate mime/size

## Checklist kiểm thử
- Checklist hoàn thành đầy đủ 5 nhóm
- Không bỏ sót module liên quan hoặc contract bị đổi ngầm
