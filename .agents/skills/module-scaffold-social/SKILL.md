---
name: module-scaffold-social
description: Scaffold module mới theo đúng cấu trúc shared/* (model/repo/util/constants/errors) để tránh lệch kiến trúc. Dùng khi tạo module mới hoặc thêm feature lớn.
applyTo:
  - "src/routes/**"
version: 1.1.0
tools:
  - read_file
  - apply_patch
  - runSubagent
examples:
  - input: "Tạo module reactions với features: create, list"
    output: "Tạo routes/reactions/shared/* và các feature folders chuẩn"
tests:
  - name: scaffold-module-shared
    description: Module có shared đủ model/repo/util/constants/errors và feature đúng chuẩn
    example: true
---

# Module Scaffold Social

## Mục tiêu
Scaffold module mới theo đúng cấu trúc dự án: `routes/<module>/shared/*` (model/repo/util/constants/errors) và các feature tuân thủ route → dto → controller → service.

## Hợp đồng đầu vào
- `moduleName`
- `features`: danh sách feature cần tạo
- `needModelRepo`: có cần model/repo riêng không

Nếu thiếu thông tin, hỏi ngắn gọn:
1) Tên module là gì?
2) Cần những feature nào?
3) Có cần model/repo riêng không?

## Hợp đồng đầu ra
- Tạo đủ folder `shared/` và các feature
- Không thay đổi cấu trúc module hiện có

## Quy tắc bắt buộc
- Mọi module mới phải có `shared/` gồm:
	- `<module>.model.ts`
	- `<module>.repo.ts`
	- `<module>.util.ts`
	- `<module>.constants.ts`
	- `<module>.errors.ts`
- Mỗi feature có 4 file: `<feature>.route.ts`, `<feature>.dto.ts`, `<feature>.controller.ts`, `<feature>.service.ts`
- Không ghi đè nếu module/feature đã tồn tại; dùng `.new.ts` và hỏi lại

## Template nội dung shared/* (tối thiểu)
### <module>.constants.ts
```ts
export const <MODULE>_DEFAULT_LIMIT = 20;
```

### <module>.errors.ts
```ts
import { AppError } from "../../../shared/errors/app-error.js";

export class <Module>NotFoundError extends AppError {
	constructor() {
		super("<Module> not found", 404);
	}
}

export class <Module>ForbiddenError extends AppError {
	constructor() {
		super("Forbidden", 403);
	}
}
```

### <module>.util.ts
```ts
export const normalize<Module>Input = (value: string) => value.trim();
```

### <module>.model.ts
```ts
import { Schema, model } from "mongoose";

const <module>Schema = new Schema(
	{
		createdBy: { type: Schema.Types.ObjectId, ref: "users", required: true },
	},
	{ timestamps: true }
);

export const <Module>Model = model("<module>", <module>Schema);
```

### <module>.repo.ts
```ts
import { <Module>Model } from "./<module>.model.js";

export class <Module>Repository {
	async findById(id: string) {
		return <Module>Model.findById(id);
	}
}
```

## Mẫu prompt (dùng với `skill-creator`)
```
Scaffold module:
- moduleName: reactions
- features: create, list
- needModelRepo: true

Return: patch creating routes/reactions/shared/* and feature folders with route/dto/controller/service
```

## Tiêu chí hoàn thành
- Module có đủ shared artifacts
- Feature tuân thủ route → dto → controller → service
- Không phát sinh cấu trúc ngoài chuẩn

## Edge Cases
- Module trùng tên
- Feature đã tồn tại
- Không muốn tạo model/repo

## Checklist kiểm thử
- Đủ folder shared và feature
- Naming thống nhất
- Không phá cấu trúc module khác
