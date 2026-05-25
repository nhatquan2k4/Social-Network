# Search Test Cases

## Phạm vi

Feature search gồm tìm kiếm user, debounce 600ms, lịch sử tìm kiếm local, clear history, load more và điều hướng profile. Luồng dùng `SearchBloc`; API chính là `/users/search?name={name}&page={page}&limit=20`.

Route liên quan: `/home/search`.

## Test Cases

| ID | Priority | Type | Kịch bản | Tiền điều kiện | Bước kiểm thử | Kết quả mong đợi |
| --- | --- | --- | --- | --- | --- | --- |
| SEARCH-001 | P0 | E2E | Mở search từ feed | Đã login ở `/home` | Nhấn `feed.search` | Route `/home/search`, thấy `search.input`, bottom nav bị ẩn |
| SEARCH-002 | P0 | INT | Tìm user tồn tại | Backend có user `admin` | Nhập `admin`, chờ debounce hoặc submit | Gọi API, hiển thị kết quả có `@admin` hoặc display name đúng |
| SEARCH-003 | P0 | FE | Tìm và mở profile user | Có kết quả search | Tap một user result | Lưu lịch sử, push `/profile/:userId`, khi pop input được clear |
| SEARCH-004 | P1 | FE | Debounce khi nhập liên tục | Ở search screen | Gõ `a`, `ad`, `adm`, `admin` nhanh | Chỉ query cuối được gửi sau 600ms |
| SEARCH-005 | P1 | FE | Submit search bỏ qua debounce | Ở search screen | Nhập từ khóa và nhấn enter | Gửi `SearchUserEvent` ngay |
| SEARCH-006 | P1 | NEG | Query rỗng không gọi API | Ở search screen | Xóa toàn bộ input | Hiển thị lịch sử tìm kiếm, không gọi API search |
| SEARCH-007 | P1 | FE | Clear input bằng suffix icon | Input đang có text | Nhấn icon close | Input rỗng, state trở về history |
| SEARCH-008 | P1 | INT | Không có kết quả | Backend trả `data=[]` | Search một chuỗi không tồn tại | Hiển thị empty state `searchNoResults` |
| SEARCH-009 | P1 | NEG | API search lỗi | Mock API lỗi | Search từ khóa bất kỳ | Hiển thị error state với icon error, không crash |
| SEARCH-010 | P1 | INT | Load more bằng nút See more | API trả `hasMore=true` | Search, nhấn See more | Page tăng, append user mới vào list |
| SEARCH-011 | P1 | INT | Load more bằng scroll cuối danh sách | API trả nhiều trang | Scroll tới cuối | Gửi `LoadMoreSearchEvent`, append đúng |
| SEARCH-012 | P1 | FE | Lưu lịch sử query sau search thành công | Local storage sạch | Search `admin` thành công | Lịch sử có query `admin` khi input rỗng |
| SEARCH-013 | P1 | FE | Lưu lịch sử user sau tap result | Có result user | Tap result rồi quay lại search | Lịch sử có entry user với label/avatar/userId |
| SEARCH-014 | P1 | FE | Clear all history | Có lịch sử | Xóa input, nhấn Clear all | History rỗng |
| SEARCH-015 | P1 | FE | Tap history query chạy search lại | Có history query | Tap item history | Input nhận label, gọi search API |
| SEARCH-016 | P1 | FE | Back về feed | Đang ở `/home/search` | Nhấn back appbar | Route về `/home`, thấy `feed.search` |
| SEARCH-017 | P2 | FE | User result thiếu avatar | API trả avatar rỗng | Search user đó | Hiển thị fallback avatar/initial |
| SEARCH-018 | P2 | FE | User result thiếu display name | API trả displayName rỗng, username có | Search user đó | Label fallback sang username/userId |

## Data & Assertions

- Dùng `admin` hoặc username đang login để search dữ liệu chắc chắn tồn tại.
- Assertion automation chính: `TestKeys.searchTextField`, text `@admin`, route `/profile/:userId`.

