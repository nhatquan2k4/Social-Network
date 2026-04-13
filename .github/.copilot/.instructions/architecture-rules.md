# Quy tắc kiến trúc

Áp dụng các quy tắc sau cho mọi phần mã được tạo mới hoặc chỉnh sửa trong backend này.

## Quy tắc chung
- Luôn dùng TypeScript nhất quán
- Ưu tiên async/await thay vì promise chain lồng nhau
- Giữ cấu trúc theo module, theo tính năng
- Tránh file quá lớn và trộn nhiều trách nhiệm
- Tái sử dụng mã trong src/shared nếu đã có
- Không lặp lại validator, helper xử lý lỗi, helper response nếu đã tồn tại

## Quy tắc về route và module
- Mỗi module route phải tách biệt theo tính năng
- File route chỉ nên khai báo endpoint, middleware và handler
- Không đặt business logic trực tiếp trong file đăng ký route
- Tên file, tên module và cách tổ chức phải bám theo cấu trúc hiện có trong src/routes

## Quy tắc về controller
- Controller phải mỏng
- Controller chỉ nên:
  - đọc params, query, body, files, auth context
  - gọi service hoặc hàm xử lý chính
  - trả response theo format chuẩn
  - chuyển lỗi về middleware xử lý lỗi tập trung
- Controller không nên chứa logic truy vấn database phức tạp
- Controller không nên chứa logic lưu trữ file chi tiết, trừ khi module đó chuyên điều phối media

## Quy tắc về service
- Business logic phải nằm trong service hoặc handler riêng
- Service phải có thể tái sử dụng và dễ test
- Service không được phụ thuộc trực tiếp vào Express request hoặc response

## Quy tắc về database
- Truy cập MongoDB phải có cấu trúc rõ ràng
- Tránh populate lồng nhau quá nhiều
- Tạo index cho các field được truy vấn thường xuyên
- Các endpoint dạng danh sách phải có pagination
- Luôn kiểm tra id hợp lệ trước khi query
- Không trả về các field nhạy cảm từ document của user

## Quy tắc về validation
- Mọi dữ liệu đầu vào đều phải được validate
- Validate params, query, body, file nếu có
- Từ chối id sai định dạng, enum không hợp lệ, field bắt buộc bị thiếu, input không an toàn
- Validation phải chạy trước business logic chính

## Quy tắc về xử lý lỗi
- Dùng cơ chế xử lý lỗi tập trung
- Dùng typed errors từ src/shared/errors nếu dự án đã có
- Không để lộ stack trace, chi tiết database hoặc storage trong response production

## Quy tắc về auth và phân quyền
- Endpoint riêng tư phải có auth middleware
- Các thao tác update, delete, read dữ liệu nhạy cảm phải kiểm tra quyền
- Không tin userId gửi từ client nếu đã có user xác thực từ middleware

## Quy tắc về response
Ưu tiên dùng format JSON thống nhất như sau:

{
  "message": "Thành công",
  "data": ...,
  "meta": ...
}

## Quy tắc về realtime
- Chỉ emit event sau khi dữ liệu đã được lưu thành công
- Tên event phải ổn định và dễ hiểu
- Payload realtime phải tối thiểu, tránh gửi thừa
- Chỉ emit tới đúng user hoặc đúng room cần nhận

## Quy tắc về media
- File media phải được lưu ở object storage
- Database chỉ lưu metadata
- File upload phải được kiểm tra mime type và kích thước
- Tên object phải an toàn và có tính duy nhất
- Không để lộ credential hoặc đường dẫn nội bộ của storage

## Những điều không được làm
- Không viết fat controller
- Không copy-paste logic giữa các module nếu có thể tách dùng chung
- Không dùng req.body trực tiếp mà không validate
- Không catch lỗi rồi bỏ qua im lặng
- Không trả lỗi nội bộ thô ra client
- Không ghi database khi chưa kiểm tra quyền ở các tài nguyên được bảo vệ