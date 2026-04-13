# Hướng dẫn chung cho Copilot

Hãy làm việc như một kỹ sư backend có kinh nghiệm cho repository này.
Luôn tuân thủ cấu trúc thư mục và phong cách mã đã có trong dự án.
- .github/.copilot/instructions
- .github/.copilot/skills
- .github/instructions/*.instructions.md (auto-load theo ngữ cảnh file)

## Cơ chế nạp instructions
- File global này luôn là baseline chung cho toàn repo
- Các file trong .github/instructions/*.instructions.md được ưu tiên áp dụng tự động theo applyTo
- Bộ tài liệu trong .github/.copilot vẫn là nguồn tham chiếu nội bộ và có thể giữ nguyên

## Cách làm việc mong muốn
- Tôn trọng cấu trúc module hiện có trong src/routes và src/shared
- Ưu tiên thay đổi nhỏ, tập trung, tránh viết lại quá rộng
- Sinh mã theo hướng production, không phải mã minh họa
- Giữ tên biến, tên hàm, tên module nhất quán với dự án hiện tại
- Tái sử dụng middlewares, validators, types, utils, errors đã có nếu phù hợp

## Khi thêm tính năng mới
Luôn suy nghĩ theo các bước:
1. thiết kế route
2. validation
3. luồng controller
4. business logic trong service
5. auth và permission
6. format response
7. error handling
8. tác động tới database
9. tác động tới realtime nếu có
10. tác động tới media nếu có

## Khi chỉnh sửa mã cũ
- Giữ nguyên kiến trúc hiện tại nếu không có lý do mạnh để thay đổi
- Không tự ý đổi tên file, đổi tên thư mục hoặc thay đổi cấu trúc lớn
- Không thêm abstraction mới nếu không thực sự giúp giảm lặp hoặc tăng maintainability rõ rệt

## Phong cách mã
- Ưu tiên mã dễ đọc hơn là quá khéo léo
- Dùng kiểu dữ liệu rõ ràng khi cần
- Hàm nên ngắn, đúng một mục đích
- Ưu tiên early return cho case lỗi hoặc case đặc biệt
- Tránh lồng nhau quá sâu

## Hành vi API
- Endpoint phải dễ đoán và nhất quán
- Các tài nguyên dạng danh sách phải có pagination
- Trả lỗi rõ ràng nhưng không để lộ thông tin nội bộ
- Xử lý case không tìm thấy dữ liệu một cách sạch sẽ

## Bảo mật
- Validate mọi input
- Kiểm tra quyền trên mọi thao tác được bảo vệ
- Không làm lộ password, token, secret, credential của storage, stack trace nội bộ