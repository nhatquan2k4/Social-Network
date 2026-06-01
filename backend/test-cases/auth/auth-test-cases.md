# Auth Test Cases

## Phạm vi

Feature auth gồm welcome/onboarding, login, register, forgot password, register success, logout. Luồng dùng `AuthBloc`, `AuthLoginFormBloc`, `AuthRegisterFormBloc`; API chính gồm `/auth/login`, `/auth/register`, `/auth/logout`, `/auth/forgot-password`.

Routes liên quan: `/`, `/onboarding`, `/login`, `/register`, `/auth/login`, `/auth/register`, `/forgot-password`, `/verification-code`, `/reset-password`, `/register-success`.

## Test Cases

| ID | Priority | Type | Kịch bản | Tiền điều kiện | Bước kiểm thử | Kết quả mong đợi |
| --- | --- | --- | --- | --- | --- | --- |
| AUTH-001 | P0 | E2E | Đăng nhập thành công bằng tài khoản seed | Backend có `seed_user` và token storage sạch | Mở `/login`, nhập username/password hợp lệ, nhấn submit | Hiển thị snackbar thành công, route chuyển sang `/home`, thấy `feed.search` |
| AUTH-002 | P0 | NEG | Không cho submit login khi thiếu username | Ở `/login` | Để trống username, nhập password | Nút submit ở trạng thái disabled/không gọi `AuthLoginEvent` |
| AUTH-003 | P0 | NEG | Không cho submit login khi thiếu password | Ở `/login` | Nhập username, để trống password | Nút submit disabled/không điều hướng |
| AUTH-004 | P0 | NEG | Login sai mật khẩu | Backend đang chạy | Nhập username đúng, password sai, submit | Vẫn ở `/login`, hiển thị lỗi từ `AuthLoginFailureState` |
| AUTH-005 | P1 | FE | Toggle remember me | Ở `/login` | Nhấn checkbox `login.remember` hai lần | Checkbox đổi true/false đúng, login event truyền `rememberMe` hiện tại |
| AUTH-006 | P1 | FE | Toggle hiển thị mật khẩu login | Ở `/login` | Nhấn icon visibility trong ô password | Trạng thái obscureText đổi, text không bị mất |
| AUTH-007 | P1 | FE | Điều hướng từ login sang register | Ở `/login` | Nhấn link `login.register.link` | Route chuyển sang `/register`, thấy các field register |
| AUTH-008 | P0 | E2E | Đăng ký tài khoản hợp lệ | Backend cho phép register, email unique | Mở `/register`, nhập first name, last name, username, email, password hợp lệ và confirm khớp, submit | Gọi register API, chuyển sang `/register-success` |
| AUTH-009 | P0 | NEG | Register thiếu first name/last name | Ở `/register` | Bỏ trống một trong hai field tên, các field còn lại hợp lệ, submit | Không gọi register hoặc báo lỗi, không chuyển route |
| AUTH-010 | P0 | NEG | Register email sai định dạng | Ở `/register` | Nhập email không có `@`, password hợp lệ | Nút submit disabled hoặc hiển thị lỗi đăng ký |
| AUTH-011 | P0 | NEG | Register password yếu | Ở `/register` | Nhập password dưới chuẩn validator | Form invalid, không gọi API |
| AUTH-012 | P0 | NEG | Register confirm password không khớp | Ở `/register` | Nhập password và confirm khác nhau | Form invalid, không gọi API |
| AUTH-013 | P1 | NEG | Register username/email đã tồn tại | Backend có user trùng | Nhập thông tin trùng user seed, submit | Vẫn ở `/register`, hiển thị lỗi từ backend |
| AUTH-014 | P1 | FE | Từ register success quay về login | Sau AUTH-008 | Nhấn nút bắt đầu `register.success.start` | Route chuyển về `/login`, field login xuất hiện |
| AUTH-015 | P1 | INT | Forgot password email hợp lệ | Backend hỗ trợ endpoint forgot password | Mở `/forgot-password`, nhập email có `@`, submit | Hiển thị snackbar thành công, quay về `/login` |
| AUTH-016 | P1 | NEG | Forgot password email không hợp lệ | Ở `/forgot-password` | Nhập chuỗi không có `@` | Nút gửi disabled, không gọi API |
| AUTH-017 | P0 | E2E | Logout từ profile | Đã login | Vào Profile, mở settings, nhấn Logout | Socket disconnect, token/local session bị xóa theo repository, route về `/login` |
| AUTH-018 | P1 | NEG | Logout API lỗi | Đã login, mock logout failure | Nhấn Logout | Không mất UI đột ngột, hiển thị lỗi `logoutFailed`, vẫn ở profile/session hiện tại |
| AUTH-019 | P1 | FE | Start route không hợp lệ | Chạy app với `START_ROUTE=/unknown` | Pump app | Router fallback về `/` welcome theo logic `_resolveInitialLocation` |
| AUTH-020 | P1 | FE | Start route `/chat/room/:id` hợp lệ | Chạy app với `START_ROUTE=/chat/room/abc` | Pump app | Router cho phép mở room route và dựng `MessageChatRoomPage` với thread fallback |

## Data & Assertions

- Dữ liệu hợp lệ: username `seed_user`, password `Password123!`.
- Dữ liệu register unique nên dùng timestamp như `MockData.username`, `MockData.generateEmail`.
- Assertion chính nên dựa vào `TestKeys.loginUsernameField`, `TestKeys.loginSubmitButton`, `TestKeys.registerSubmitButton`, `TestKeys.registerSuccessStartButton`, `TestKeys.feedSearchButton`.

