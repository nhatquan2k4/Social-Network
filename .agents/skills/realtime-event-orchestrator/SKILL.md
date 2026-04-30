---
name: realtime-event-orchestrator
description: Chuẩn hóa emit socket emit sau khi DB lưu thành công, đúng room/user, payload tối thiểu, không đặt business logic nặng trong socket layer.
applyTo:
  - "src/routes/**"
version: 1.1.0
tools:
  - read_file
  - apply_patch
  - runSubagent
examples:
  - input: "Emit message:created sau khi lưu message"
    output: "Service emit sau khi save, scope đúng room, payload tối thiểu"
tests:
  - name: realtime-emit-after-save
    description: Emit sau DB save, dung user/room, payload toi thieu
    example: true
---

# Realtime Event Orchestrator

## Mục tiêu
Chuẩn hóa emit realtime: chỉ emit sau khi DB lưu thành công, đúng scope (user/room), payload tối thiểu và không đặt business logic trong socket layer.

## Hợp đồng đầu vào
- `eventName`
- `scope`: user|room
- `payloadKeys`: danh sách field tối thiểu
- `emitTiming`: afterSave

Nếu thiếu thông tin, hỏi ngắn gọn:
1) Event name là gì?
2) Emit cho user hay room?
3) Payload tối thiểu gồm field nào?

## Hợp đồng đầu ra
- Payload tối thiểu, không gửi document lớn
- Không emit trước khi DB save thành công

## Quy tắc bắt buộc
- Emit sau khi DB save thành công
- Emit đúng user hoặc room liên quan
- Payload tối thiểu (id, actor/recipient, trạng thái)
- Không đặt business logic nặng trong socket layer

## Gợi ý event
- message:created
- message:seen
- notification:created
- friend_request:created
- friend_request:accepted

## Mẫu prompt (dùng với `skill-creator`)
```
Orchestrate realtime emit for:
- eventName: message:created
- scope: room
- payloadKeys: messageId, conversationId, senderId, createdAt
- emitTiming: afterSave

Return: patch to emit after DB save, to correct room/user with minimal payload
```

## Tiêu chí hoàn thành
- Emit sau DB save thành công
- Emit đúng scope (user/room)
- Payload tối thiểu
- Không đặt business logic trong socket layer

## Edge Cases
- DB save thất bại
- User không thuộc room/conversation
- Emit nhầm room
- Payload thiếu field bắt buộc

## Checklist kiểm thử
- Emit đúng thời điểm
- Payload đúng fields
- Không emit khi DB fail
- Emit đúng scope
