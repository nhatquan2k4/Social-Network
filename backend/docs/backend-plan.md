# Kế hoạch backend (ExpressJS + MongoDB)

> Mục tiêu: tổ chức code theo feature/module (mỗi nghiệp vụ một thư mục) nhưng bên trong vẫn theo layered (route -> controller -> service -> repo/model), có shared cho phần dùng chung.

## 1. Tổng quan cấu trúc đề xuất

```text
backend/
  src/
    server.ts
    routes/
      auth/
      users/
      profile/
      posts/
      media/
      feed/
      comments/
      likes/
      follows/
      friends/
      notifications/
      messages/               # optional
    shared/
      config/
      db/
      middlewares/
      errors/
      validators/
      utils/
      types/
      http/
  test/
```


## 2. Nguyên tắc kiến trúc và luồng request

### 2.1. Luồng chuẩn cho một API endpoint

1. route nhận request và gắn middleware (auth/validate/upload...)
2. controller đọc `req`, gọi service, trả response
3. service chứa business logic và orchestration
4. repo thao tác database/query phức tạp
5. model định nghĩa schema/index (nếu dùng Mongoose)
6. lỗi đẩy qua `next(err)` và xử lý tập trung ở `shared/errors/error-handler`

### 2.2. Quy ước import

- `routes/<feature>` được import từ `shared/*`.
- `shared/*` không import ngược lại từ `routes/*`.
- Feature A hạn chế gọi trực tiếp repo/model của feature B; ưu tiên đi qua service hoặc tách phần dùng chung vào `shared/`.

## 3. Chuẩn thư mục trong mỗi feature

Ví dụ `src/routes/posts/`:

- `posts.route.ts`
  - Khai báo endpoint và gắn middleware.
- `posts.controller.ts`
  - Xử lý HTTP concern: parse request, gọi service, map response.
- `posts.service.ts`
  - Chứa business logic.
- `posts.repo.ts`
  - Gom query database/aggregation.
- `posts.model.ts` (nếu dùng Mongoose)
  - Định nghĩa schema/index/hooks.
- `posts.dto.ts`
  - Validate schema và khai báo type request/query.

## 4. Danh sách module nghiệp vụ 

### auth
- register/login/logout
- refresh token
- forgot/reset password (optional)

### users
- user lookup
- user settings cơ bản

### profile
- xem/sửa profile
- dữ liệu profile public (counts)

### posts
- tạo/sửa/xóa bài viết
- post detail, list theo user
- index gợi ý: `(authorId, createdAt)`

### media
- upload ảnh/video
- xử lý MinIO và metadata
- chuẩn hóa object key, xóa file liên quan khi post bị xóa

### feed
- home feed theo following + pagination
- explore feed (optional)
- thường cần aggregation riêng trong repo

### comments
- tạo/sửa/xóa comment
- list comment theo post, có pagination
- replies/threads (optional)

### likes
- like/unlike post
- đồng bộ likesCount an toàn

### follows
- follow/unfollow
- list followers/following
- index gợi ý: unique `(followerId, followingId)` ( có thể làm sau )

### friends
- lời mời kết bạn / chấp nhận / hủy / unfriend

### notifications
- tạo notification từ like/comment/follow
- list và mark-as-read

### messages (optional)
- chat/inbox
- có thể tách realtime layer (WebSocket/Socket.IO) ở phần sau

## 5. Shared layer (cross-cutting + infrastructure)

### shared/config
- đọc và validate env
- export object cấu hình tập trung

### shared/db
- kết nối MongoDB/Mongoose

### shared/middlewares
- auth, role (optional), rate limit, request id, logger, cors, upload

### shared/errors
- `AppError`
- map lỗi validation/db sang HTTP code
- `error-handler` đặt cuối pipeline

### shared/validators
- schema dùng chung: pagination, objectId
- middleware validate(body/query/params)

### shared/utils
- helper thuần: hash/jwt/date/sanitize/cursor pagination...

### shared/types
- express request augmentation (`req.user`)
- shared interfaces/types

### shared/http
- chuẩn hóa response `{ data, meta, error }`
- helper pagination response

## 6. Quy tắc naming và conventions

- URL prefix: `/api/<feature>`
- File naming: `<feature>.<role>.ts`
- Controller không query DB trực tiếp.
- Service không gọi `res.json`.
- Repo/Model không chứa business logic phức tạp.

## 7. Lộ trình refactor theo phase

1. Chuẩn hóa `shared/errors` và error handler tập trung.
2. Chuẩn hóa `shared/db` và luồng connect MongoDB.
3. Refactor `auth` theo mẫu route/controller/service/(repo/model/dto).
4. Refactor `posts` + `media`.
5. Refactor `feed` (aggregation + pagination + indexes).
6. Refactor `comments/likes/follows/friends/notifications`.
7. Hoàn thiện test cho flow trọng yếu.

## 8. Checklist kiểm tra sau mỗi phase

- API response shape nhất quán.
- Không còn business logic nặng ở controller.
- Lỗi được map đúng và có status code rõ ràng.
- Có index cho các truy vấn chính.
- Swagger cập nhật theo endpoint mới/chỉnh sửa.
- Test tối thiểu cho luồng thay đổi.

## 9. Nguyên tắc triển khai 

- Làm từng module nhỏ một
- Không làm 1 lúc quá nhiều việc, làm từng tí một để review, tránh làm quá nhiều dẫn đến lỗi và khó hiểu.
- Nếu có lỗi, trước khi fix thì giải thích xem đó là lỗi gì và hướng giải quyết như thế nào.
