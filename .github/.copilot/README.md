# Beacon Copilot Agent Pack

Thư mục này là bộ hướng dẫn vận hành GitHub Copilot Agent theo chuẩn nội bộ.

## Mục tiêu

1. Giữ mọi thay đổi đúng kiến trúc dự án ExpressJS Backend hiện tại.
2. Chuẩn hóa cách AI Agent lập kế hoạch, code, verify và review.
3. Giảm lỗi do hardcode, sửa lan phạm vi, hoặc bỏ qua kiểm chứng.

## Cấu trúc

```
.github/
└── .copilot/
    ├── .agent/                # Định nghĩa các vai trò AI
    │   ├── api-bundler.md
    │   ├── code-reviewer.md
    │   ├── security-auditor.md
    │   └── test-engineer.md
    │
    ├── .instructions/         # Luật và context toàn project
    │   ├── architecture-rules.md
    │   └── project-context.md
    │
    ├── .skills/               # Các kỹ năng cụ thể theo task
    │   ├── auth-jwt-skill.md
    │   ├── express-module-skill.md
    │   ├── minio-upload-skill.md
    │   ├── mongodb-model-skill.md
    │   ├── realtime-socket-skill.md
    │   └── validation-error-skill.md
    │
    ├── README.md              # Mô tả chung cho copilot
    └── copilot-instructions.md# Rule global cho AI
```

## Trình tự dùng chuẩn cho mỗi task

1. Đọc `instructions/project-context.md` để nạp ngữ cảnh dự án.
2. Đọc `instructions/architecture-rules.md` để nắm rule bắt buộc.
3. Chọn 1-3 skill phù hợp trong `skills/` theo loại công việc.
4. Nếu cần review chuyên sâu, kích hoạt agent trong `agents/` tương ứng.

## Mapping theo vòng đời phát triển (Backend)

### 1. Define (Xác định yêu cầu)
- `project-context.md` (instructions) → hiểu domain và module
- `architecture-rules.md` (instructions) → nắm rule bắt buộc
- `mongodb-model-skill.md` → thiết kế schema, quan hệ dữ liệu
- `express-module-skill.md` → xác định structure API

---

### 2. Build (Xây dựng tính năng)
- `express-module-skill.md` → tạo route / controller / service / validation
- `auth-jwt-skill.md` → xử lý authentication & authorization
- `minio-upload-skill.md` → upload media (avatar, post, message)
- `mongodb-model-skill.md` → query & tối ưu database
- `realtime-socket-skill.md` → emit event (message, notification, friend)

---

### 3. Verify (Kiểm thử & đảm bảo đúng)
- `validation-error-skill.md` → validate input & xử lý lỗi
- `test-engineer.md` (agent) → viết test API & business logic
- `code-reviewer.md` (agent) → check logic sai, thiếu case

---

### 4. Review (Rà soát & tối ưu)
- `code-reviewer.md` → kiểm tra kiến trúc, clean code
- `security-auditor.md` → kiểm tra auth, permission, upload, data leak
- `mongodb-model-skill.md` → tối ưu query, index

---

### 5. Ship (Hoàn thiện & triển khai)
- `validation-error-skill.md` → đảm bảo error nhất quán
- `auth-jwt-skill.md` → đảm bảo bảo mật endpoint
- `realtime-socket-skill.md` → đảm bảo event đúng luồng
- `minio-upload-skill.md` → đảm bảo media flow ổn định

---

### Quy tắc chọn nhanh
- API mới → `express-module-skill.md`
- Có auth → `auth-jwt-skill.md`
- Có upload → `minio-upload-skill.md`
- Có DB → `mongodb-model-skill.md`
- Có realtime → `realtime-socket-skill.md`
- Có validate → `validation-error-skill.md`
- Cần test → `test-engineer.md`
- Cần review → `code-reviewer.md` / `security-auditor.md`

## Nguyên tắc bảo trì

1. Ưu tiên cập nhật `instructions/*` khi kiến trúc đổi.
2. Khi team có quy trình lặp mới, bổ sung skill mới trong `skills/*`.
3. Nội dung luôn bám code thực tế trong repo, không sao chép bừa từ nguồn bên ngoài.
