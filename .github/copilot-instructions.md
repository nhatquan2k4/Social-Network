# Hướng dẫn tổng hợp (Backend Social Network)

Áp dụng cho toàn bộ backend, đặc biệt với các file TypeScript trong backend/src/**/*.ts.

## Source of truth
- File này là nguồn quy tắc duy nhất cho backend.
- Nếu rule đã có trong file này, không được suy luận ngược từ source code để phủ định rule.
- Chỉ đọc source code để bổ sung phần chưa được rule mô tả.

## Bối cảnh dự án
- Đây là backend cho ứng dụng mạng xã hội.
- Công nghệ: Node.js, ExpressJS, TypeScript, MongoDB, realtime communication, MinIO/local object storage.
- Module chính: auth, users, posts, media, friends, conversations, messages, notifications, realtime events.
- Mục tiêu: dễ bảo trì, dễ mở rộng, module rõ ràng, an toàn, nhất quán.

## Nguyên tắc làm việc cốt lõi
- Làm việc như kỹ sư backend production, không viết mã minh họa.
- Tôn trọng cấu trúc hiện có trong src/routes và src/shared.
- Ưu tiên thay đổi nhỏ, tập trung, tránh viết lại diện rộng.
- Giữ tên biến, hàm, module nhất quán với codebase hiện tại.
- Tái sử dụng middlewares, validators, types, utils, errors khi đã có.
- Không suy luận ngược rule từ source code nếu rule đã được mô tả rõ trong instruction.

## Quy trình bắt buộc khi làm feature mới
1. Xác định module và endpoint.
2. Xác định input contract: params/query/body/file.
3. Tạo validation tương ứng cho toàn bộ input.
4. Đảm bảo route riêng tư có auth middleware.
5. Controller chỉ nhận input, gọi service, trả response.
6. Service xử lý business logic và permission checks.
7. Chuẩn hóa response theo format chung.
8. Đẩy lỗi về middleware xử lý lỗi tập trung.
9. Đánh giá ảnh hưởng database/index/pagination/select.
10. Đánh giá ảnh hưởng realtime/media (nếu có).

## Quy trình bắt buộc khi sửa code cũ
1. Giữ nguyên kiến trúc hiện tại trừ khi có lý do mạnh.
2. Không tự ý đổi tên file/thư mục/module.
3. Không thêm abstraction mới nếu lợi ích maintainability không rõ ràng.
4. Giữ thay đổi cục bộ, tránh lan rộng ngoài phạm vi yêu cầu.

## Quy tắc kiến trúc
- Dùng TypeScript nhất quán.
- Ưu tiên async/await thay vì promise chain lồng nhau.
- Tổ chức theo module, theo tính năng.
- Tránh file quá lớn, tránh trộn nhiều trách nhiệm.
- Không lặp validator/helper response/helper error nếu đã có bản dùng chung.

## Route và module
- Route chỉ đăng ký endpoint, middleware, handler.
- Không đặt business logic trực tiếp trong file route.
- Bám đúng cấu trúc thư mục hiện có trong src/routes.
- Khi tạo/chỉnh module, đi theo chuỗi:
1. Xác định module và endpoint
2. Validation request
3. Controller mỏng
4. Tách business logic vào service/handler
5. Auth và permission checks
6. Chuẩn hóa response
7. Error handling tập trung
8. Đánh giá tác động database
9. Đánh giá tác động realtime
10. Đánh giá tác động media

## Cấu trúc lớp theo trách nhiệm
- route:
	- khai báo endpoint
	- gắn middleware (auth/validator/permission gate nếu có)
	- trỏ tới controller
- validator/dto:
	- validate params/query/body/file
	- chặn input sai trước business logic
- controller:
	- đọc input đã được xác thực
	- gọi service/handler
	- trả response chuẩn
	- next(error) cho middleware lỗi
- service:
	- xử lý business rule
	- check ownership/permission
	- phối hợp repo/model/storage/realtime
- repo/model (nếu module có tách):
	- thao tác truy vấn DB
	- tối ưu field select/index usage

## Controller
- Controller phải mỏng.
- Controller chỉ nên:
	- đọc params, query, body, files, auth context
	- gọi service/hàm xử lý chính
	- trả response theo format chuẩn
	- đẩy lỗi về middleware lỗi tập trung
- Controller không chứa query database phức tạp.
- Controller không chứa logic lưu trữ file chi tiết (trừ module điều phối media).

## Service
- Business logic nằm ở service/handler riêng.
- Service phải tái sử dụng được, dễ test.
- Service không phụ thuộc trực tiếp vào Express request/response.

## Validation và lỗi
- Luôn validate params, query, body, file (nếu có).
- Validate id trước khi query database.
- Validate enum/tập giá trị cố định.
- Validate pagination params cho endpoint danh sách.
- Chặn sớm các case sai phổ biến:
	- id sai định dạng
	- thiếu field bắt buộc
	- user không thuộc conversation
	- mime type không được hỗ trợ
	- thao tác khi không có quyền
	- duplicate friend request
	- page/limit không hợp lệ
- Dùng shared typed errors nếu đã có.
- Không để lộ stack trace thô trong production.
- Lỗi client có thể sửa được phải có message rõ ràng.
- Duy trì cơ chế đẩy lỗi về middleware xử lý lỗi tập trung.

## Danh sách lỗi phải chặn sớm
- id sai định dạng.
- thiếu field bắt buộc.
- mime type không nằm trong whitelist.
- kích thước file vượt giới hạn.
- user không thuộc conversation.
- user không có quyền cập nhật/xóa tài nguyên.
- duplicate friend request.
- page/limit không hợp lệ.

## Nguyên tắc message lỗi
- Dễ hiểu để client sửa request.
- Không lộ thông tin nội bộ (DB schema chi tiết, stack trace, secret).
- Không trả lỗi quá chi tiết gây lộ thông tin xác thực/tài khoản.

## Auth và phân quyền (JWT)
- Password phải hash an toàn.
- Không bao giờ trả password hash trong response.
- Validate credential cẩn thận.
- Route riêng tư bắt buộc có auth middleware.
- Ưu tiên user từ middleware xác thực, không tin userId từ client.
- Từ chối truy cập trái phép rõ ràng nhưng không lộ thông tin nhạy cảm.
- Nếu có refresh token, phải có cơ chế revoke/invalidate phù hợp.
- Checklist cho thao tác protected (update/delete/read dữ liệu nhạy cảm):
	- user đã đăng nhập
	- tài nguyên tồn tại
	- user có ownership hoặc quyền thao tác
	- trạng thái tài nguyên cho phép thao tác

## Các lỗi auth phổ biến cần tránh
- Tin req.body.userId để xác định ownership.
- Quên gắn auth middleware cho route riêng tư.
- Lộ token/chi tiết token trong response hoặc log không an toàn.
- Trả lỗi đăng nhập quá chi tiết giúp đoán tài khoản tồn tại hay không.

## Database và model MongoDB
- Schema:
	- dùng timestamps khi phù hợp
	- đánh dấu field bắt buộc rõ ràng
	- dùng enum cho giá trị cố định
	- tạo index cho field lọc/sort thường xuyên
	- tránh field dư thừa nếu không cần cho hiệu năng
	- ẩn field nhạy cảm khỏi output API
- Query:
	- endpoint danh sách bắt buộc có pagination
	- validate id trước query
	- chỉ select field cần thiết
	- tránh populate lồng nhau không cần thiết
- Index gợi ý:
	- posts: author + createdAt
	- messages: conversation + createdAt
	- notifications: recipient + read + createdAt
	- friends: requester + receiver + status
- Không được:
	- lạm dụng populate
	- lấy toàn bộ collection khi có thể phân trang
	- trả password hash, refresh token, secret nội bộ

## Thực hành query an toàn và ổn định
- Endpoint list luôn có pagination.
- Ưu tiên select field cần thiết thay vì trả full document.
- Tránh populate lồng nhiều tầng nếu không bắt buộc.
- Validate ObjectId trước query để giảm lỗi runtime không cần thiết.
- Kiểm tra quyền trước mọi thao tác ghi/xóa dữ liệu protected.

## Media upload (MinIO/local object storage)
- Luồng bắt buộc:
1. Parse multipart bằng middleware phù hợp
2. Kiểm tra có file
3. Validate mime type
4. Validate kích thước
5. Tạo object name an toàn và duy nhất
6. Upload object lên storage
7. Lưu metadata vào database
8. Trả response metadata chuẩn
9. Xóa object cũ nếu thay thế và không còn tham chiếu
- Metadata cần lưu:
	- bucket
	- objectName
	- originalName
	- mimeType
	- size
	- uploadedBy
	- id tài nguyên liên quan
	- url/public path (nếu có)
	- createdAt
- Quy ước tên gợi ý:
	- avatars/{userId}/{timestamp}-{sanitizedName}
	- posts/{postId}/{timestamp}-{sanitizedName}
	- messages/{conversationId}/{timestamp}-{sanitizedName}
- Bảo mật media:
	- không chỉ dựa extension
	- không lộ credential storage
	- không dùng tên file dễ đoán
	- từ chối sai loại file/sai dung lượng
	- kiểm tra quyền trước khi thay thế hoặc xóa
- API media:
	- trả metadata có cấu trúc
	- ẩn chi tiết triển khai storage
	- không trộn logic storage chi tiết vào controller không liên quan

## Checklist upload ảnh/file (bắt buộc tuần tự)
1. Parse multipart bằng middleware phù hợp.
2. Xác nhận request có file.
3. Validate mime type theo whitelist.
4. Validate kích thước theo giới hạn từng loại file.
5. Tạo objectName an toàn, duy nhất, khó đoán.
6. Upload object lên MinIO/local object storage.
7. Lưu metadata vào DB.
8. Trả metadata chuẩn cho client.
9. Nếu thay file cũ: xóa object cũ khi không còn tham chiếu.

## Realtime
- Chỉ emit sau khi database đã lưu thành công.
- Event name rõ ràng, ổn định, dễ hiểu.
- Payload tối thiểu, không gửi dư dữ liệu.
- Chỉ emit đúng user/room liên quan.
- Không đặt business logic nặng trong realtime layer.
- Gợi ý event:
	- message:created
	- message:seen
	- notification:created
	- friend_request:created
	- friend_request:accepted
- Không được:
	- emit trước khi lưu DB thành công
	- gửi cả document lớn khi chỉ cần payload nhỏ
	- tin membership room từ client khi chưa xác minh server-side

## Quy tắc emit event
- Emit đúng scope nhận:
	- user-specific event: emit đúng user
	- conversation event: emit đúng room conversation
- Payload tối thiểu:
	- id tài nguyên
	- actor/recipient cần thiết
	- trạng thái thay đổi chính
- Không đặt business logic nặng trong socket/realtime layer.

## Chuẩn API response
Ưu tiên format nhất quán:

{
	"message": "Thành công",
	"data": ...,
	"meta": ...
}

## Hành vi API
- Endpoint phải dễ đoán, nhất quán.
- Endpoint danh sách cần cân nhắc pagination/filter/sort.
- Trả lỗi rõ ràng nhưng không lộ chi tiết nội bộ.
- Xử lý not-found sạch và rõ.

## Gợi ý theo từng module
- posts:
	- kiểm tra ownership/visibility
	- tối ưu feed query
	- quản lý media metadata tách biệt
- messages:
	- kiểm tra membership conversation trước khi gửi/đọc
	- emit realtime sau khi lưu DB thành công
- notifications:
	- đảm bảo đúng recipient
	- quản lý read/unread rõ ràng
- friends:
	- chặn tự gửi lời mời cho chính mình
	- chặn request trùng lặp
	- quản lý status transition nhất quán
- media:
	- validate file chặt chẽ
	- không lộ chi tiết storage
	- xử lý vòng đời object (upload/replace/delete)

## Definition of done cho endpoint mới/chỉnh sửa
- Đủ validation cho params/query/body/file.
- Có auth/permission checks khi endpoint protected.
- Controller mỏng, service chứa business logic.
- Response theo format chuẩn.
- Error đi qua middleware tập trung.
- Query DB có pagination/select/id validation phù hợp.
- Realtime emit đúng thời điểm và đúng đối tượng nhận (nếu có).
- Media flow đúng thứ tự và lưu metadata đầy đủ (nếu có upload).

## Không được làm
- Không viết fat controller.
- Không query database trực tiếp trong file route.
- Không dùng req.body trực tiếp khi chưa validate.
- Không catch lỗi rồi bỏ qua im lặng.
- Không trả lỗi nội bộ thô cho client.
- Không ghi database khi chưa kiểm tra quyền ở tài nguyên protected.
- Không tự ý đổi tên file/thư mục hay thay đổi kiến trúc lớn nếu không có lý do mạnh.
- Không thêm abstraction mới nếu không tăng maintainability rõ rệt.