---
name: endpoint-contract-guard
description: Ép validate đầy đủ params/query/body/files cho endpoint backend Social Network. Dùng skill này khi tạo mới hoặc chỉnh sửa endpoint để chặn sớm input lỗi: ObjectId, enum, pagination, file mime/size. Luôn dùng khi người dùng yêu cầu "validate", "DTO", "request contract" hoặc thêm endpoint mới.
---

# Endpoint Contract Guard

## Mục đích - Tại sao cần
Đảm bảo mọi input được kiểm tra chặt chẽ trước khi vào business logic, giảm lỗi runtime và lỗ hổng bảo mật do dữ liệu không hợp lệ.

## Use Cases - Ví dụ thực tế
- "Thêm validate cho POST /api/posts"
- "Chuẩn hóa DTO cho /api/messages/:conversationId"
- "Chặn upload sai mime type"

## Input Contract - Request format
Cần có đầy đủ:
- Params: danh sách param, kiểu dữ liệu, ràng buộc
- Query: danh sách query, kiểu dữ liệu, ràng buộc, pagination nếu list
- Body: field bắt buộc/tùy chọn, kiểu dữ liệu, enum
- Files: có hay không, số lượng, size, mime type
- Auth: protected hay public

Nếu thiếu thông tin, hỏi ngắn gọn:
1) Params/Query/Body gồm những field nào?
2) Field nào bắt buộc?
3) Có enum không?
4) Có files không? (số lượng, size, mime type)
5) Có pagination không? (page/limit)

## Output Contract - Response format
- Lỗi trả về qua error middleware tập trung
- Message lỗi rõ ràng để client sửa request
- Không trả stack trace hoặc chi tiết nội bộ

Gợi ý message lỗi:
- ObjectId không hợp lệ
- Thiếu field bắt buộc
- Pagination không hợp lệ
- Mime type không được hỗ trợ
- File vượt quá giới hạn

## File Templates - Code được generate
- dto.ts: các hàm parse/validate params/query/body/files
- Nếu cần: shared validator dùng chung

Gợi ý cấu trúc hàm validate:
- parseParams(params)
- parseQuery(query)
- parseBody(body)
- parseFiles(files)

## Success Criteria - Định nghĩa "xong"
- Validate đầy đủ params/query/body/files
- ObjectId được kiểm tra trước khi query DB
- Pagination hợp lệ (page/limit)
- Enum được kiểm tra
- File được kiểm tra mime/size/number
- Input sai bị chặn tại DTO, không vào service

## Edge Cases - Trường hợp phải xử lý
- ObjectId không hợp lệ
- Thiếu field bắt buộc
- Enum không hợp lệ
- Pagination invalid
- File vượt size hoặc sai mime type
- Files rỗng hoặc không tồn tại
- Field kiểu số nhưng nhận string rỗng

## Test Cases - Verification checklist
- Input sai bị chặn sớm
- Input hợp lệ đi qua
- Không để lọt req.body.userId dùng cho auth
- Pagination vượt max bị chặn
- Enum sai trả lỗi rõ ràng

## Quy trình
1) Xác định contract đầy đủ cho params/query/body/files.
2) Viết parse/validate trong dto.ts.
3) Gọi validate ngay tại controller trước khi service.
4) Trả lỗi qua error middleware tập trung.
5) Chỉ gọi service khi mọi validate đã hợp lệ.
