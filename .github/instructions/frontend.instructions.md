---
name: Social Network Frontend
description: "Dùng khi chỉnh sửa frontend Flutter: widget, quản lý state, localization, networking và mã tính năng trong frontend/lib."
applyTo: "frontend/lib/**/*.dart, frontend/test/**/*.dart"
---
# Hướng Dẫn Frontend

- Tuân thủ kiến trúc layered hiện có: `lib/core`, `lib/data`, `lib/domain`, `lib/presentation`.
- Không đặt business logic trong widget; chuyển sang controller/view-model/use-case.
- Mỗi màn hình chính cần xử lý rõ bốn trạng thái: loading, empty, error và content.
- Không hardcode chuỗi hiển thị cho người dùng; dùng luồng localization trong `frontend/lib/l10n`.
- Dùng theme/design token và spacing dùng chung; tránh style rời rạc trong widget của feature.
- Giữ state bất biến và tách side effect rõ ràng để dễ kiểm thử.
- Tuân thủ quy ước đặt tên của team: file snake_case, type PascalCase, member lowerCamelCase.
- Giữ imports gọn và loại bỏ import không dùng.
- Chạy `dart format` và giữ cảnh báo analyzer ở mức tối thiểu trước khi hoàn tất.
- Bám theo tài liệu dự án: `frontend/docs/flutter_frontend_coding_standards.md` và `frontend/docs/flutter_code_review_checklist.md`.
