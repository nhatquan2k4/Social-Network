---
name: Social Network Backend
description: "Dùng khi chỉnh sửa backend Node.js/Express TypeScript: API, route module, service, MongoDB/Mongoose và luồng media với MinIO."
applyTo: "backend/src/**/*.ts"
---

# Hướng Dẫn Backend

- Tài liệu kế hoạch refactor đầy đủ nằm ở `backend/docs/backend-refactor-plan.md`; giữ file instructions này ngắn gọn để tối ưu context cho agent.

- Tổ chức theo feature trong `backend/src/routes/<feature>`, đặt tên file nhất quán: `<feature>.route.ts`, `<feature>.controller.ts`, `<feature>.service.ts`; có thể thêm `<feature>.repo.ts`, `<feature>.dto.ts` khi cần.
- `route` chỉ khai báo endpoint và gắn middleware.
- `controller` chỉ xử lý HTTP concern: đọc request, gọi service, trả response, đẩy lỗi bằng `next(error)`.
- `service` chứa business logic; service trả data hoặc throw error, không gọi `res.json`.
- `repo/model` chỉ xử lý truy cập dữ liệu và schema/index; không nhúng rule nghiệp vụ phức tạp vào lớp persistence.
- Đặt phần dùng chung và hạ tầng vào `backend/src/shared` (`config`, `db`, `middlewares`, `errors`, `validators`, `utils`, `types`, `http`).
- `shared/*` không import ngược lại từ `routes/*` để tránh vòng phụ thuộc.
- Giữ thứ tự middleware và bootstrap app theo mẫu hiện tại trong `backend/src/server.ts`.
- Giữ convention prefix API theo dạng `/api/<feature>` và cập nhật Swagger khi thay đổi endpoint.
- Với media, tôn trọng các giới hạn theo env (`MEDIA_MAX_FILE_SIZE`, `MEDIA_MAX_FILES`) và logic tạo object key an toàn cho MinIO.
- Refactor theo từng feature nhỏ, tránh sửa diện rộng toàn backend trong một lần.
- Khi thay đổi hành vi, cần bổ sung/cập nhật test, ưu tiên các flow chính: auth, posts, media, feed, follows, notifications.
