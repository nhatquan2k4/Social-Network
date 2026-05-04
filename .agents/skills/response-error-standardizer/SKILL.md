---
name: response-error-standardizer
description: Chuẩn hóa response dạng { message, data, meta }, dùng AppError/typed errors, đẩy lỗi về middleware tập trung. Áp dụng khi controller còn trả lỗi thủ công (vd: notifications.controller.ts).
applyTo:
  - "src/routes/**"
version: 1.1.0
tools:
  - read_file
  - apply_patch
  - runSubagent
examples:
  - input: "Chuẩn hóa response/error cho notifications.controller.ts"
    output: "Controller chỉ trả response chuẩn và next(error), lỗi raw được thay bằng AppError"
tests:
  - name: response-contract
    description: Response co message/data/meta, loi qua error middleware, khong res.json loi thu cong
    example: true
---

# Response Error Standardizer

## Mục tiêu
Chuẩn hóa response theo `{ message, data, meta }`, đảm bảo lỗi đi qua middleware tập trung và không trả lỗi thủ công trong controller. Ưu tiên thay thế các controller còn trả lỗi trực tiếp (ví dụ: `notifications.controller.ts`).

## Hợp đồng đầu vào
- `endpoint`: đường dẫn hoặc file controller cần chuẩn hóa
- `response`: yêu cầu message/data/meta
- `errors`: danh sách lỗi có thể xảy ra

Nếu thiếu thông tin, hỏi ngắn gọn:
1) Endpoint hoặc controller nào cần chuẩn hóa?
2) Response cần message/data/meta gì?
3) Lỗi nào cần typed error?

## Hợp đồng đầu ra
- Response chuẩn `{ message, data, meta }`
- Không trả lỗi raw trong controller; dùng `next(error)`
- Lỗi không lộ stack trace

## Quy tắc bắt buộc
- Controller không `res.status(...).json({ message: ... })` cho lỗi; dùng `next(error)`
- Service throw typed errors/AppError, không throw Error trần
- Response helper được dùng nhất quán nếu module đã có

## Mẫu prompt (dùng với `skill-creator`)
```
Standardize response/error for:
- controller: notifications.controller.ts
- response: { message, data, meta }
- errors: NotFound, Forbidden

Return: patch updating controller to use response helper and next(error), service throws AppError
```

## Tiêu chí hoàn thành
- Response đúng format `{ message, data, meta }`
- Lỗi qua middleware tập trung
- Không có trả lỗi thủ công trong controller

## Edge Cases
- Controller còn `res.json` cho lỗi
- Service throw Error thô
- Response thiếu `message` hoặc `data`

## Checklist kiểm thử
- Response format đúng chuẩn
- Lỗi không lộ thông tin nội bộ
- Error middleware nhận error
