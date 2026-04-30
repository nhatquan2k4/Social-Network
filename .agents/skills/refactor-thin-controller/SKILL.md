---
name: refactor-thin-controller
description: Tự động phát hiện fat controller và tách business logic sang service. Dùng khi controller có query DB, xử lý logic phức tạp, hoặc nhiều nhánh điều kiện.
applyTo:
  - "src/routes/**"
version: 1.1.0
tools:
  - read_file
  - apply_patch
  - runSubagent
examples:
  - input: "Refactor notifications.controller.ts để bỏ query DB trong controller"
    output: "Controller chỉ parse input + gọi service; service chứa truy vấn DB"
tests:
  - name: thin-controller
    description: Controller khong query DB, service chua business logic, response khong doi
    example: true
---

# Refactor Thin Controller

## Mục tiêu
Phát hiện controller quá dày (fat controller) và tách business logic sang service, giữ controller mỏng và dễ test.

## Hợp đồng đầu vào
- `controllerFile`: file controller cần refactor
- `logicToMove`: danh sách logic cần tách
- `targetService`: service hiện có hoặc tạo mới

Nếu thiếu thông tin, hỏi ngắn gọn:
1) File controller nào cần refactor?
2) Những đoạn logic nào cần tách?
3) Dùng service hiện có hay tạo mới?

## Hợp đồng đầu ra
- Controller chỉ parse input và gọi service
- Service chứa business logic và truy vấn DB
- Không đổi contract response

## Quy tắc bắt buộc
- Không query DB trực tiếp trong controller
- Không đặt xử lý nghiệp vụ phức tạp trong controller
- Controller chỉ đọc params/query/body/files và gọi service
- Service không phụ thuộc Express req/res

## Mẫu prompt (dùng với `skill-creator`)
```
Refactor thin controller:
- controllerFile: notifications.controller.ts
- logicToMove: DB queries, permission checks
- targetService: notifications.service.ts

Return: patch moving logic to service and keeping controller thin
```

## Tiêu chí hoàn thành
- Controller mỏng, không query DB
- Service reusable, testable
- Response contract giữ nguyên

## Edge Cases
- Logic phụ thuộc req/res
- Controller có nhiều middleware liên quan
- Logic cần chia nhỏ nhiều service

## Checklist kiểm thử
- Controller mỏng
- Service hoạt động đúng
- Response không đổi
