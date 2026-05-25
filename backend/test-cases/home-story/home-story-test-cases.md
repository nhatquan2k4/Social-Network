# Home Prototype & Story Test Cases

## Phạm vi

Trong code hiện có, `home` và `story` là nhóm màn hình/phần tử phụ trợ: `MochiMainPage`, `MochiSearchPage`, `HomeBloc`, `HomeRemoteDataSource`, `StoryViewScreen`. Lưu ý route `/home` hiện đang trỏ tới `FeedScreen`, còn `AppRoutes.stories` chưa được khai báo trong `app_route_conf.dart`. Vì vậy nhóm test này chủ yếu dùng cho widget/integration riêng hoặc khi các route này được nối lại.

## Test Cases

| ID | Priority | Type | Kịch bản | Tiền điều kiện | Bước kiểm thử | Kết quả mong đợi |
| --- | --- | --- | --- | --- | --- | --- |
| HOME-001 | P2 | FE | HomeBloc fetch posts feed thành công | Mock `/posts/feed` trả items | Pump `MochiMainPage` | Render composer, stories strip, post cards từ API mapping |
| HOME-002 | P2 | FE | Home fallback mock data khi API lỗi | Mock API lỗi | Pump `MochiMainPage` | Sau delay render `_mockItems`, không crash |
| HOME-003 | P2 | FE | Home loading state | Pump page khi fetch chưa xong | Quan sát UI | Loading hiển thị trong scaffold |
| HOME-004 | P2 | FE | Home retry khi failure state | Mock usecase trả failure | Pump page | Error title/message và retry action gọi `HomeFetchedEvent` |
| HOME-005 | P2 | FE | Home stories strip có "Your Story" | Items people rỗng hoặc có data | Pump `MochiMainPage` | Stories strip luôn có story của mình ở đầu |
| HOME-006 | P2 | FE | Home search prototype explore grid | Pump `MochiSearchPage`, query rỗng | Quan sát body | Hiển thị category chips và grid ảnh explore |
| HOME-007 | P2 | FE | Home search prototype filter people | Mock HomeBloc có people | Nhập query khớp user | People section chỉ hiển thị user khớp |
| HOME-008 | P2 | FE | Home search no results | Mock không có people/discovery khớp | Nhập query không khớp | Hiển thị no results |
| HOME-009 | P2 | FE | Tap user trong Home search | Có people result | Tap user | Push `/profile/:userId` |
| STORY-001 | P2 | FE | Story viewer load story đầu | Có `storyGroups` và `initialGroupIndex` hợp lệ | Pump `StoryViewScreen` | Ảnh story đầu render, progress bar chạy |
| STORY-002 | P2 | FE | Tap vùng phải chuyển story tiếp theo | Group có nhiều stories | Tap 2/3 phải màn hình | `_currentStoryIndex` tăng, progress reset |
| STORY-003 | P2 | FE | Tap vùng trái quay story trước | Đang ở story index > 0 | Tap 1/3 trái màn hình | `_currentStoryIndex` giảm, progress reset |
| STORY-004 | P2 | FE | Chuyển sang group tiếp theo | Story cuối của group hiện tại, còn group sau | Tap next hoặc chờ duration hết | Group index tăng, story index reset 0 |
| STORY-005 | P2 | FE | Kết thúc story cuối pop screen | Đang ở story cuối của group cuối | Tap next hoặc chờ duration hết | `Navigator.pop` được gọi |
| STORY-006 | P2 | FE | Long press pause/resume | Story đang chạy | Long press start rồi end | Progress dừng khi giữ, chạy tiếp khi thả |
| STORY-007 | P2 | FE | Close story từ header | Story viewer mở | Nhấn close | Pop screen |
| STORY-008 | P2 | NEG | Story image URL lỗi | Story url hỏng | Pump viewer | Loading/error không làm app crash; nên bổ sung errorBuilder nếu cần |
| STORY-009 | P2 | NEG | Story groups rỗng | Truyền list rỗng | Pump viewer | Hiện tại có nguy cơ out-of-range; cần guard trước khi route public |
| STORY-010 | P2 | NEG | initialGroupIndex ngoài range | Truyền index lớn hơn length | Pump viewer | Hiện tại có nguy cơ crash; cần validate index trước khi dùng |

## Ghi chú

- Nếu muốn đưa Story vào E2E thật, cần thêm route builder cho `AppRoutes.stories` hoặc action mở `StoryViewScreen`.
- `StoryViewScreen` hiện chưa có `errorBuilder` cho `Image.network`; nên thêm trước khi kiểm thử negative trên mạng lỗi.

