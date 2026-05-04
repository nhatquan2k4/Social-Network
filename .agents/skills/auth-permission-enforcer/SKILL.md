---
name: auth-permission-enforcer
description: Bắt buộc cho API private: kiểm tra auth middleware, ownership/permission trong service, tuyệt đối không tin req.body.userId. Rất cần cho post/friend/message/notification.
applyTo:
  - "src/routes/**"
version: 1.1.0
tools:
  - read_file
  - apply_patch
  - runSubagent
examples:
  - input: "PATCH /api/posts/:postId, protected, chỉ chủ sở hữu được sửa"
    output: "Route có protectedRoute; service check ownership bằng req.user"
tests:
  - name: private-api-ownership
    description: Endpoint private có auth middleware, service check permission, không dùng req.body.userId
    example: true
---

# Auth Permission Enforcer

## Mục tiêu
Đảm bảo mọi API private đều có auth middleware và kiểm tra ownership/permission trong service. Không tin `req.body.userId` hoặc bất kỳ userId từ client.

## Phạm vi ưu tiên
- posts
- friends
- messages
- notifications

## Hợp đồng đầu vào
- `auth`: protected|public
- `resource`: post|comment|message|friend|notification|user|media
- `action`: create|read|update|delete
- `ownershipRule`: mô tả ai được thao tác

Nếu thiếu thông tin, hỏi ngắn gọn:
1) Endpoint protected hay public?
2) Resource và action cụ thể?
3) Rule ownership/permission?

## Hợp đồng đầu ra
- Lỗi qua error middleware, không lộ chi tiết nội bộ
- Message rõ ràng, tránh tiết lộ nhạy cảm

Ví dụ lỗi an toàn:
- "Chưa xác thực"
- "Không có quyền thao tác"

## Quy tắc bắt buộc
- Route private phải gắn `protectedRoute`
- Service lấy user từ `req.user`
- Ownership/permission check trước mọi thao tác ghi/xóa
- Không dùng `req.body.userId` để xác định user

## Gợi ý kiểm tra trong service
- Tài nguyên tồn tại
- User đã đăng nhập
- User có quyền (ownership hoặc role)

## Mẫu prompt (dùng với `skill-creator`)
```
Enforce auth & permission for:
- auth: protected
- resource: post
- action: update
- ownershipRule: chi chu so huu moi duoc sua

Return: patch updating route to include protectedRoute and service to check ownership using req.user
```

## Tiêu chí hoàn thành
- Route private có auth middleware
- Service có ownership/permission check
- Không sử dụng userId từ client
- Trả lỗi chuẩn hóa khi không đủ quyền

## Edge Cases
- User chưa đăng nhập
- Tài nguyên không tồn tại
- User không có quyền thao tác
- Token hợp lệ nhưng user bị khóa

## Checklist kiểm thử
- Endpoint private không hoạt động nếu thiếu token
- Ownership check chặn truy cập trái phép
- Không dùng req.body.userId
- Người không phải chủ sở hữu bị từ chối
