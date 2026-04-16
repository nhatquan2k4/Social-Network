# Kỹ năng validation và xử lý lỗi

Dùng skill này khi triển khai validation request và xử lý lỗi API.

## Mục tiêu
Từ chối request không hợp lệ từ sớm và trả lỗi theo format nhất quán.

## Quy tắc validation
- validate params
- validate query
- validate body
- validate file nếu có
- validate id trước khi query database
- validate enum hoặc các giá trị có tập cố định
- validate các tham số pagination

## Quy tắc xử lý lỗi
- dùng shared typed errors nếu dự án đã có
- chuyển lỗi nội bộ thành response an toàn
- không để lộ stack trace thô trong production
- với lỗi do client có thể sửa được, message phải đủ rõ
- vẫn phải giữ luồng đẩy lỗi về middleware xử lý lỗi tập trung

## Ví dụ các trạng thái sai cần chặn sớm
- id sai định dạng
- thiếu field bắt buộc
- user không thuộc conversation
- mime type không được hỗ trợ
- update tài nguyên khi không có quyền
- gửi lời mời kết bạn trùng lặp
- page hoặc limit không hợp lệ

## Kết quả mong muốn
- client dễ xử lý lỗi hơn
- debug dễ hơn
- controller và service sạch hơn