# Chat & Messages Test Cases

## Phạm vi

Feature chat/message gồm danh sách hội thoại, search trong hội thoại, tab group, tạo direct/group conversation, chat room, gửi text/media, load history/cache, load older, realtime message/seen/delete/reaction, quản lý hội thoại. API chính gồm `/conversations`, `/messages/{conversationId}/messages`, `/messages/direct/text`, `/messages/group/text`, `/messages/direct/media`, `/messages/group/media`, `/messages/{id}/reaction`, seen/delete endpoints.

Routes liên quan: `/chat`, `/chat/new`, `/chat/room/:threadId`, `/chat/room/:threadId/manage`.

## Test Cases

| ID | Priority | Type | Kịch bản | Tiền điều kiện | Bước kiểm thử | Kết quả mong đợi |
| --- | --- | --- | --- | --- | --- | --- |
| CHAT-001 | P0 | E2E | Mở chat từ feed | Đã login ở feed | Nhấn `feed.chat` | Route `/chat`, thấy nút tạo hội thoại mới `chat.newConversation` |
| CHAT-002 | P0 | INT | Load danh sách hội thoại | Backend có conversations | Mở `/chat` | Gọi `/conversations`, render list, unread count/time/preview đúng |
| CHAT-003 | P1 | NEG | Conversations API lỗi | Mock API lỗi | Mở `/chat` | Hiển thị status view lỗi và retry |
| CHAT-004 | P1 | FE | Empty chat list | Backend trả rỗng | Mở `/chat` | Hiển thị no chat found/empty state hợp lệ |
| CHAT-005 | P1 | FE | Search trong danh sách chat | Có nhiều conversations | Nhập keyword ở top bar | Chỉ còn thread có senderName/preview khớp |
| CHAT-006 | P1 | FE | Tab group chỉ hiện group | Có direct và group threads | Chọn tab group | Danh sách chỉ còn `isGroup=true` |
| CHAT-007 | P1 | FE | Pin/unpin local thread | Có thread | Dùng action pin trên item | Thread đổi trạng thái pin trong `ChatBloc` local |
| CHAT-008 | P1 | FE | Hide/unhide local thread | Có thread | Dùng action hide | Thread đổi hidden local theo event |
| CHAT-009 | P1 | FE | Delete local thread có confirm | Có thread | Chọn delete, confirm | Thread bị remove khỏi list local |
| CHAT-010 | P0 | FE | Mở chat room từ thread | Có thread | Tap thread đầu tiên | Route `/chat/room/:id`, thấy `chat.message.input` |
| CHAT-011 | P0 | INT | Load message history | Ở chat room | Chờ bootstrap | Load cache nếu có, gọi remote history, scroll tới latest |
| CHAT-012 | P1 | NEG | History API lỗi không có cache | Mock history lỗi, cache rỗng | Mở room | Hiển thị snackbar `Unable to load messages`, composer vẫn dùng được nếu thread hợp lệ |
| CHAT-013 | P1 | FE | Load history từ cache rồi remote | Cache có messages, API thành công | Mở room | Messages cache hiện nhanh, sau đó remote hydrate và save cache |
| CHAT-014 | P1 | INT | Load older messages khi scroll top | History có `hasMore=true`, cursor | Scroll lên đầu | Gọi page older, prepend messages, giữ vị trí scroll |
| CHAT-015 | P0 | E2E | Gửi direct text message | Direct thread có `recipientId` | Nhập text, nhấn send | Gọi `/messages/direct/text`, bubble của mình xuất hiện, input clear |
| CHAT-016 | P0 | E2E | Gửi group text message | Group thread | Nhập text, send | Gọi `/messages/group/text`, bubble xuất hiện |
| CHAT-017 | P0 | NEG | Không gửi text rỗng | Ở room | Để input rỗng, nhấn send | Không gọi API |
| CHAT-018 | P1 | NEG | Direct message thiếu recipientId | Direct thread không có recipientId | Nhập text, send | Hiển thị `unknownRecipient`, không gọi API |
| CHAT-019 | P1 | NEG | Send text API lỗi | Mock send lỗi | Nhập text, send | Snackbar `Failed to send message`, input không clear hoặc trạng thái không mất dữ liệu |
| CHAT-020 | P1 | INT | Gửi ảnh direct | Direct thread, có image picker | Chọn ảnh từ gallery/camera | Gọi `/messages/direct/media`, media bubble xuất hiện |
| CHAT-021 | P1 | INT | Gửi ảnh group | Group thread | Chọn ảnh | Gọi `/messages/group/media`, media bubble xuất hiện |
| CHAT-022 | P1 | NEG | Pick media lỗi | Mock image picker throw | Nhấn gallery/camera | Snackbar `messagePickMediaFailed` |
| CHAT-023 | P0 | RT | Nhận realtime message đúng room | Socket payload conversationId trùng room | Phát `newMessageStream` | Message append, tự mark all read nếu sender khác current user |
| CHAT-024 | P1 | RT | Bỏ qua realtime message room khác | Socket payload conversationId khác | Phát event | UI room hiện tại không đổi |
| CHAT-025 | P1 | RT | Không append trùng message id | Đã có message id X | Nhận realtime message id X | Không nhân đôi bubble |
| CHAT-026 | P1 | RT | Realtime seen update read receipt | Room có message của mình | Nhận `messageSeenStream` từ peer | Last message hiển thị `Đã xem` hoặc avatar read receipt group |
| CHAT-027 | P1 | RT | Realtime delete message | Room có message id X | Nhận delete payload | Bubble chuyển trạng thái deleted, reaction bị clear |
| CHAT-028 | P1 | RT | Realtime reaction update | Room có message id X | Nhận reaction payload | Reaction chips cập nhật đúng |
| CHAT-029 | P1 | INT | Long press reaction | Room có message chưa deleted | Long press bubble, chọn emoji | Gọi PUT reaction, chip cập nhật khi socket trả về |
| CHAT-030 | P1 | INT | Toggle off reaction của mình | Message có reaction của current user | Tap reaction chip | Gọi DELETE reaction |
| CHAT-031 | P1 | INT | Delete message của mình | Long press own message, chọn delete | Gọi DELETE message, UI optimistic deleted | Nếu API lỗi thì revert và snackbar lỗi |
| CHAT-032 | P1 | FE | Scroll-to-latest button | Đang đọc message cũ, nhận message mới | Scroll xa cuối, nhận message | Hiện nút xuống cuối; nhấn thì scroll latest và ẩn |
| CHAT-033 | P0 | INT | Tạo direct conversation | Có friend trong `/chat/new` | Nhấn new conversation, chọn friend | Gọi `/conversations`, pop về `/chat`, mở room mới |
| CHAT-034 | P1 | NEG | Tạo direct conversation lỗi | Mock create lỗi | Chọn friend | Snackbar create failed, vẫn ở `/chat/new` |
| CHAT-035 | P1 | INT | Tạo group conversation | Có nhiều friends | Mở create group, nhập tên, chọn members, create | Gọi create group fallback/usecase, trả ChatEntity và mở room |
| CHAT-036 | P1 | NEG | New conversation không có bạn | Friend list rỗng | Mở `/chat/new` | Hiển thị `noFriendsFound` |
| CHAT-037 | P1 | FE | Conversation management profile action | Direct room có recipientId | Mở manage, nhấn view profile | Push `/profile/:recipientId` |
| CHAT-038 | P2 | FE | Conversation management feature soon actions | Ở manage | Nhấn group members/call/theme/media nếu chưa implement | Không crash; action chưa implement giữ trạng thái ổn định |

## Data & Assertions

- Test keys chính: `feed.chat`, `chat.newConversation`, `chat.thread.0`, `chat.newFriend.0`, `chat.message.input`, `chat.message.send`.
- Với realtime, nên dùng backend socket E2E hoặc mock `RealtimeSocketService` stream.

