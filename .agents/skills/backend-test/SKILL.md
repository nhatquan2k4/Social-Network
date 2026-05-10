---
name: backend-test
description: Viết hoặc mở rộng test cho backend Social Network. Dùng skill này khi người dùng yêu cầu thêm, lập kế hoạch, sửa, hoặc review Smoke E2E, unit helper tests, Auth E2E, protected route E2E, Posts E2E, Friends E2E, Messages E2E, Media tests, hoặc Socket.IO tests. Trước khi viết test, phải đọc kỹ route, controller, service, repository, model, dto, util, constants, errors, middleware liên quan để test khớp với code thật và không tự bịa endpoint, payload, dependency.
applyTo:
  - "backend/src/**"
  - "backend/test/**"
version: 1.0.0
tools:
  - read_file
  - apply_patch
  - run_command
examples:
  - input: "viet e2e test cho auth"
    output: "Đọc auth route/controller/service/repo/model trước, sau đó thêm HTTP journey test dùng createApp và Mongo test database."
  - input: "them unit test helper media"
    output: "Đọc media util/service/constants/errors trước, sau đó thêm node:test cho logic parse/normalize thuần, không cần DB hoặc MinIO."
---

# Backend Test 

## Mục tiêu

Hỗ trợ viết test đáng tin cậy cho backend này mà không đoán mò. Backend là ứng dụng Express, TypeScript, ESM, Mongoose, tổ chức theo feature:

```txt
backend/src/routes/<domain>/<feature>/
  *.route.ts
  *.controller.ts
  *.service.ts
  *.dto.ts

backend/src/routes/<domain>/shared/
  *.repo.ts
  *.model.ts
  *.util.ts
  *.errors.ts
  *.constants.ts
```

Phải dùng kiến trúc hiện có. Không tự thêm Clean Architecture, Vitest, Jest, Supertest, testcontainers, hoặc mongodb-memory-server trừ khi người dùng yêu cầu rõ ràng hoặc project đã có sẵn.

Test runner hiện tại:

```txt
npm.cmd run test:e2e
tsx --test "test/**/*.test.ts"
```

Mặc định dùng Node built-in `node:test`, `node:assert/strict`, và global `fetch`.

## Quy trình bắt buộc

Trước khi viết hoặc sửa bất kỳ test nào, phải đọc implementation thật:

1. Đọc `*.route.ts` của mục tiêu để xác nhận method, path, middleware, và cách mount route.
2. Đọc `*.controller.ts` để xác nhận body, params, query, files, cookies, status code, response shape.
3. Đọc `*.service.ts` để hiểu nghiệp vụ và side effect.
4. Đọc các file liên quan trong `shared/*.repo.ts`, `shared/*.model.ts`, `shared/*.util.ts`, `shared/*.constants.ts`, `shared/*.errors.ts`.
5. Đọc middleware dùng chung như `auth.middleware.ts`, `friend.middleware.ts`, upload middleware, socket setup nếu có liên quan.
6. Sau khi đủ ngữ cảnh mới chọn test nhỏ nhất nhưng có giá trị.

Nếu route, payload, status code, hoặc response field không tồn tại trong code, không được tự bịa. Hãy đọc thêm file liên quan hoặc hỏi lại ngắn gọn.

## Điểm neo của project

- Import Express app từ `backend/src/app.ts`.
- Ưu tiên `createApp()` trong test.
- Không import `backend/src/server.ts` trong test vì file đó connect DB, bootstrap MinIO, init Socket.IO, và listen port thật.
- DB helper nằm ở `backend/src/shared/db/mongoose.ts`.
- `connectDB(connectionString)` nhận connection string rõ ràng.
- `disconnectDB()` dùng trong teardown của DB test.
- Media storage boundary là `backend/src/routes/media/shared/media.repo.ts`.
- Socket setup nằm ở `backend/src/shared/socket/socket.server.ts`.
- Project đã có dependency `socket.io-client`.
- Source và test dùng ESM import. Khi import local TypeScript module, dùng đuôi `.js`.

## Thứ tự test từ dễ đến khó

Dùng thứ tự này trừ khi người dùng yêu cầu cụ thể:

1. Build test
2. Smoke E2E
3. Unit helper tests
4. Auth E2E
5. Protected route E2E
6. Posts E2E
7. Friends E2E
8. Messages E2E
9. Media tests
10. Socket.IO E2E

Khi người dùng nói chung chung như "viết test", hãy bắt đầu từ nhóm test sớm nhất còn thiếu và có giá trị. Không nhảy thẳng sang Socket.IO hoặc Media nếu chưa được yêu cầu.

## Cấu trúc file test

Ưu tiên cấu trúc:

```txt
backend/test/e2e/app-smoke.test.ts
backend/test/e2e/auth.test.ts
backend/test/e2e/protected-routes.test.ts
backend/test/e2e/posts.test.ts
backend/test/e2e/friends.test.ts
backend/test/e2e/messages.test.ts
backend/test/e2e/media.test.ts
backend/test/e2e/socket.test.ts

backend/test/unit/<domain>/<helper>.test.ts
backend/test/helpers/
```

Chỉ tạo helper test khi có ít nhất hai test cần dùng lại. Không tạo abstraction cho một test đơn lẻ.

## Mẫu HTTP E2E

Start app ở port ngẫu nhiên và gọi như client thật:

```ts
import assert from "node:assert/strict";
import { after, before, describe, it } from "node:test";
import type { Server } from "node:http";
import type { AddressInfo } from "node:net";
import { createApp } from "../../src/app.js";

describe("example e2e", () => {
    let server: Server;
    let baseUrl: string;

    before(async () => {
        const app = createApp();
        server = app.listen(0);
        await new Promise<void>((resolve) => server.once("listening", resolve));

        const address = server.address();
        if (!address || typeof address === "string") {
            throw new Error("Test server did not bind to a TCP port");
        }

        baseUrl = `http://127.0.0.1:${(address as AddressInfo).port}`;
    });

    after(async () => {
        await new Promise<void>((resolve, reject) => {
            server.close((error) => error ? reject(error) : resolve());
        });
    });

    it("calls the API over HTTP", async () => {
        const response = await fetch(`${baseUrl}/`);
        assert.equal(response.status, 200);
    });
});
```

Trong E2E test, không gọi controller hoặc service trực tiếp.

## Quy tắc DB E2E

Với E2E có DB:

- Dùng Mongo database riêng cho test.
- Không dùng hoặc cleanup database dev.
- Ưu tiên env var rõ ràng như `MONGODB_TEST_CONNECTIONSTRING`.
- Nếu không có test connection string an toàn, dừng lại và hỏi người dùng thay vì đoán.
- Connect trong `before` hoặc `beforeEach` bằng `connectDB(testUri)`.
- Cleanup collections giữa test khi đã xác nhận đó là test DB an toàn.
- Disconnect trong `after` bằng `disconnectDB()`.
- Ưu tiên tạo dữ liệu qua public API. Chỉ setup trực tiếp bằng model/repo cho precondition khó tạo qua API, và phải giữ setup đó thật cục bộ trong test.

Không âm thầm dùng `MONGODB_CONNECTIONSTRING` trừ khi nó rõ ràng trỏ tới database test.

## Unit helper tests

Unit test nên bắt đầu từ các helper thuần hoặc gần thuần:

- `parseManualMedia`
- `sanitizeMedia`
- `normalizeUploadedMedia`
- `formatPost`
- `hashVerificationToken`
- object id validators
- pagination validators
- response formatting helpers

Unit test không start Express, không connect Mongo, không chạm MinIO, không gửi email, không mở socket.

Nếu helper import gián tiếp infrastructure, phải đọc file trước. Sau đó hoặc giữ ở mức E2E, hoặc chỉ refactor rất nhỏ nếu phù hợp với code hiện có.

## Service unit tests

Service unit test là tùy chọn và nên làm sau helper tests. Chỉ thêm khi service có thể nhận dependency mà không cần refactor lớn.

Nếu service đang tự tạo repository trong constructor, chỉ dùng dependency injection nhẹ:

```ts
constructor(private postRepository = new PostRepository()) {}
```

Không tạo interface repository cho toàn project chỉ để test một service.

## Auth E2E

Trước khi viết Auth E2E, đọc:

- `auth.route.ts`
- route của feature mục tiêu trong `auth/*/*.route.ts`
- controller và service của feature
- `auth/shared/auth.repo.ts`
- `auth/shared/auth.model.ts`
- `auth/shared/auth.util.ts`
- `users/shared/users.repo.ts`
- `users/shared/users.model.ts`

Test journey thật theo thứ tự:

1. Register một user unique.
2. Login bằng user đó.
3. Assert status, access token, refresh token cookie/body theo controller thật.
4. Test refresh token nếu route đã implement.
5. Test logout nếu route đã implement.

Dùng username/email unique cho mỗi test run.

## Protected Route E2E

Trước khi viết protected route tests, đọc:

- `shared/middlewares/auth.middleware.ts`
- route cần test
- controller/service của route đó

Nên cover:

- thiếu token trả response unauthorized đúng implementation
- token sai trả response forbidden đúng implementation
- token hợp lệ truy cập được ít nhất một protected endpoint

Tạo token hợp lệ qua login, trừ khi test chỉ tập trung vào middleware và setup qua API quá nặng.

## Posts E2E

Trước khi viết Posts E2E, đọc:

- `posts.route.ts`
- các file route/controller/service của `post`, `feed`, `like`, `comment`, `report` nếu liên quan
- `posts/shared/posts.repo.ts`
- `posts/shared/posts.model.ts`
- `posts/shared/posts.util.ts`
- `posts/shared/posts.constants.ts`
- auth middleware route đang dùng

Bắt đầu với:

1. login user
2. create text-only post
3. get post by id
4. update own post
5. like/unlike post
6. comment post
7. delete own post

Chỉ thêm report/admin path sau khi basic post behavior đã ổn.

## Friends E2E

Trước khi viết Friends E2E, đọc:

- `friends.route.ts`
- feature files của `request`, `friend`, `block`
- `friends/shared/friends.repo.ts`
- `friends/shared/friends.model.ts`
- `friends/shared/friends.errors.ts`

Dùng hai user tạo qua auth helper:

1. user A gửi friend request tới user B
2. test duplicate/self request nếu implementation có
3. user B accept request
4. list friends xác nhận quan hệ
5. block behavior chỉ làm sau khi request/accept cơ bản đã pass

## Messages và Conversations E2E

Trước khi viết message tests, đọc:

- `conversations/conversations.route.ts`
- `conversations/conversation/*`
- `messages/messages.route.ts`
- `messages/message/*`
- `messages/read/*`
- `messages/reaction/*`
- `messages/delete/*`
- `shared/middlewares/friend.middleware.ts`
- conversation và message repositories/models

Dùng hai user đã login. Nếu route yêu cầu friendship, tạo friendship qua public friend API trước. Sau đó:

1. create direct conversation
2. send message
3. read/list messages
4. mark read/seen nếu đã implement
5. reaction/delete sau khi basic send/read path hoạt động

## Media tests

Trước khi viết media tests, đọc:

- `media/media.route.ts`
- `media/upload/*`
- `media/shared/media.repo.ts`
- `media/shared/media.constants.ts`
- `media/shared/media.errors.ts`
- route tiêu thụ uploaded media, ví dụ posts hoặc messages

Bắt đầu bằng unit test cho parse/normalize media nếu có thể.

Với upload E2E, không yêu cầu MinIO thật nếu người dùng chưa cung cấp môi trường MinIO test. Nếu MinIO chưa sẵn sàng, chọn một trong hai:

- viết unit/service test hẹp cho validation và object-key behavior
- hỏi người dùng test MinIO config

Không mock MinIO global theo cách làm thay đổi behavior production.

## Socket.IO E2E

Trước khi viết socket tests, đọc:

- `shared/socket/socket.server.ts`
- `shared/socket/socket.events.ts`
- `shared/socket/socket.emitter.ts`
- `shared/socket/presence.service.ts`
- message/conversation services dùng trong socket flow

Dùng `socket.io-client`. Chỉ bắt đầu socket tests sau khi đã có Auth, Friends, Conversations, Messages E2E helpers.

Nên cover:

1. connect thiếu token thất bại
2. connect với token hợp lệ thành công
3. client join room đúng theo behavior hiện tại của server
4. gửi message qua HTTP thì client khác nhận socket event tương ứng

Quản lý timeout cẩn thận. Tránh sleep dễ flaky, ưu tiên event promise có timeout cleanup rõ ràng.

## Checklist kiểm chứng

Sau khi thêm hoặc sửa test:

1. Chạy `npm.cmd run build` trong `backend`.
2. Chạy test hẹp nhất nếu có thể.
3. Chạy `npm.cmd run test:e2e` trong `backend`.
4. Báo pass/fail, và tách warning ra khỏi lỗi thật.

Nếu command fail vì thiếu external test service an toàn, nói rõ nguyên nhân. Không che giấu bằng workaround.

## Không được làm

- Không tự bịa route, request body, response field.
- Không import `server.ts` trong test.
- Không connect vào database dev cho E2E có cleanup/destructive behavior.
- Không thêm dependency test nếu chưa kiểm tra `package.json` và chưa giải thích lý do.
- Không rewrite service/controller chỉ để làm E2E.
- Không tạo helper lớn trước khi thấy setup lặp lại.
- Không làm yếu production code chỉ để test pass.
- Không assert implementation detail khi assert HTTP behavior là đủ.

