---
name: express-route-generator
description: Tạo endpoint Express cho backend Social Network theo cấu trúc chuẩn (route, dto, controller, service) và tự tạo shared/ (errors/constants/util/model/repo) duy nhất cho mỗi module khi cần.
applyTo:
  - "src/routes/**"
version: 1.2.0
tools:
  - read_file
  - apply_patch
  - runSubagent
examples:
  - input: "Tạo POST /api/posts/:id/share, protected, body { message?: string }, validate :id ObjectId"
    output: "Tạo 4 file endpoint + shared/ (errors/constants/util/model/repo) nếu module chưa có"
tests:
  - name: tao-endpoint-toi-thieu
    description: Tao du 4 file, co protectedRoute neu protected, co validate ObjectId
    example: true
---
# Express Route Generator

## Mục tiêu
Tạo endpoint mới theo đúng cách triển khai hiện có trong dự án: tách `route` → `dto` → `controller` → `service`, ưu tiên tái sử dụng helpers và giữ phong cách code nhất quán. Nếu module chưa có `shared/` thì tự scaffold một bộ `shared` duy nhất theo chuẩn module để tất cả feature cùng dùng.

## Quy ước đã quan sát trong dự án
- TypeScript, import ESM có đuôi `.js`.
- `route.ts` dùng `express.Router()` và có block Swagger cho endpoint (các route auth/posts đều có).
- Route protected dùng `protectedRoute` từ `shared/middlewares/auth.middleware.ts`.
- Validation ObjectId có trong `shared/validators/object-id.validator.ts` (`isValidObjectId`), pagination dùng `shared/validators/pagination.validator.ts`.
- Response thường trả `{ message, data }` hoặc `{ data }`. Nếu module đã dùng helper ở `shared/http/response.ts` thì tiếp tục dùng helper đó.
- Upload file dùng `multer.memoryStorage()` và giới hạn từ `MEDIA_MAX_FILE_SIZE`, `MEDIA_MAX_FILES`.

## Hợp đồng đầu vào
Yêu cầu tối thiểu (thiếu thì phải hỏi lại):
- `method` (GET|POST|PUT|PATCH|DELETE)
- `path` (ví dụ: `/api/posts/:id/share`)
- `module`, `feature`
- `auth` (protected|public)
- `params` (nếu có) — tên + type (ObjectId|string|number)
- `query` (nếu có) — key + type + optional
- `body` (nếu có) — fields với type và required flag
- `files` (nếu có) — field name, mime whitelist, maxSize
- `realtime` (nếu có) — { emit, eventName, payloadKeys }
- `response` (nếu có) — message|data|meta
- `businessRules` (nếu có) — ownership/permission

Nếu thông tin chưa đủ, trả về danh sách câu hỏi ngắn gọn.

## Hợp đồng đầu ra
Chọn một trong hai:
- `patch`: patch dạng git để tạo/cập nhật file trong workspace (ưu tiên)
- `files`: danh sách file → nội dung (phục vụ review)

## Quy tắc bắt buộc khi sinh code
- Tạo đủ 4 file: `<feature>.route.ts`, `<feature>.dto.ts`, `<feature>.controller.ts`, `<feature>.service.ts`.
- Không viết business logic trong controller; controller chỉ đọc input đã validate, gọi service, trả response.
- Service xử lý permission/ownership và gọi repo/model.
- Mỗi module chỉ có một `shared/`, mọi feature dùng chung.
- Nếu module đã có `shared/` thì dùng lại, không tạo mới.
- Nếu module chưa có `shared/` thì tạo `shared/` gồm:
  - `<module>.errors.ts`
  - `<module>.constants.ts`
  - `<module>.util.ts`
  - `<module>.model.ts`
  - `<module>.repo.ts`
- Nếu `shared/` đã tồn tại nhưng thiếu một phần, chỉ tạo file còn thiếu.
- Nếu feature folder đã tồn tại, không overwrite; tạo file đuôi `.new.ts` và hỏi lại.

## Mẫu prompt (dùng với `skill-creator`)
Khi gọi tự động, truyền prompt dạng cấu trúc:

```
Create an endpoint with the following spec:
- method: <METHOD>
- path: <PATH>
- module: <MODULE>
- feature: <FEATURE>
- auth: <protected|public>
- params:
  - <name>: <type>
- query:
  - <name>: <type>
- body:
  - <name>: <type>
- files:
  field: <fieldName>
  mime: <list>
  maxSize: <number>
- realtime:
  emit: <true|false>
  eventName: <event:name>

Return: (preferred) `patch` that creates files: <module>/<feature>/<feature>.route.ts, <feature>.dto.ts, <feature>.controller.ts, <feature>.service.ts, and a single shared/<module>.* per module if missing
```

## Ví dụ mẫu (ngắn)
- Input: "Tạo POST /api/posts/:id/share, protected, body { message?: string }"
- Output: patch tạo `src/routes/posts/share/share.route.ts`, `share.dto.ts`, `share.controller.ts`, `share.service.ts`; nếu module chưa có `shared/` thì tạo một lần `src/routes/posts/shared/posts.errors.ts`, `posts.constants.ts`, `posts.util.ts`, `posts.model.ts`, `posts.repo.ts` (dùng chung cho mọi feature trong module)

## Checklist kiểm tra
- Có swagger block cho endpoint nếu module đang dùng swagger.
- `protectedRoute` có mặt khi `auth: protected`.
- DTO validate ObjectId/pagination khi có params/query tương ứng.
- Controller mỏng, response theo style module hiện có.
- Service có kiểm tra quyền/ownership và không phụ thuộc trực tiếp `req/res`.
- Nếu module chưa có `shared/`, đảm bảo tạo đủ errors/constants/util/model/repo (chỉ một lần cho module).
