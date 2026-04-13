SOCIAL-NETWORK BACKEND - ROUTE/FUNCTION MAP
Legend:
  [PUB]   = public (không cần auth)
  [AUTH]  = cần JWT
  [FRIEND]= kiểm tra quan hệ bạn bè
  [GROUP] = kiểm tra thành viên nhóm
  [CONV]  = kiểm tra thành viên conversation
  [UP]    = có upload file/media

/
├─ GET / 
│  └─ Health/hello endpoint ("Hello World")
└─ /api
   ├─ /auth
   │  ├─ POST /register                               [PUB]
   │  │  └─ Đăng ký tài khoản mới
   │  ├─ POST /login                                  [PUB]
   │  │  └─ Đăng nhập, trả access token + set refresh cookie
   │  ├─ POST /logout                                 [PUB]
   │  │  └─ Đăng xuất (xóa/thu hồi phiên refresh token)
   │  ├─ POST /email-verification/verify              [PUB]
   │  │  └─ Xác thực email bằng token
   │  └─ POST /email-verification/resend              [PUB]
   │     └─ Gửi lại email xác thực
   │
   ├─ /users
   │  ├─ GET   /me                                    [AUTH]
   │  │  └─ Lấy thông tin user hiện tại
   │  ├─ PATCH /me                                    [AUTH]
   │  │  └─ Cập nhật hồ sơ cá nhân (displayName/bio/phone)
   │  ├─ PATCH /me/avatar                             [AUTH][UP]
   │  │  └─ Cập nhật avatar
   │  ├─ GET   /:userId/profile                       [AUTH]
   │  │  └─ Xem profile + thống kê cơ bản của user
   │  └─ GET   /:userId/posts                         [AUTH]
   │     └─ Lấy danh sách bài post của user
   │
   ├─ /friends
   │  ├─ POST /requests                               [AUTH]
   │  │  └─ Gửi lời mời kết bạn
   │  ├─ POST /requests/:requestId/accept             [AUTH]
   │  │  └─ Chấp nhận lời mời kết bạn
   │  ├─ POST /requests/:requestId/reject             [AUTH]
   │  │  └─ Từ chối lời mời kết bạn
   │  ├─ GET  /                                       [AUTH]
   │  │  └─ Lấy danh sách bạn bè
   │  └─ GET  /requests                               [AUTH]
   │     └─ Lấy danh sách lời mời kết bạn
   │
   ├─ /posts
   │  ├─ POST   /                                     [AUTH][UP]
   │  │  └─ Tạo bài viết mới (text + media)
   │  ├─ GET    /feed                                 [AUTH]
   │  │  └─ Lấy feed bài viết
   │  ├─ GET    /:postId                              [AUTH]
   │  │  └─ Lấy chi tiết 1 bài viết
   │  ├─ PATCH  /:postId                              [AUTH][UP]
   │  │  └─ Chỉnh sửa bài viết
   │  ├─ DELETE /:postId                              [AUTH]
   │  │  └─ Xóa bài viết
   │  ├─ POST   /:postId/like                         [AUTH]
   │  │  └─ Like/Unlike bài viết
   │  ├─ POST   /:postId/comments                     [AUTH]
   │  │  └─ Tạo comment (hỗ trợ parentCommentId)
   │  ├─ GET    /:postId/comments                     [AUTH]
   │  │  └─ Lấy danh sách comment (dạng cây)
   │  └─ DELETE /:postId/comments/:commentId          [AUTH]
   │     └─ Xóa comment
   │
   ├─ /media
   │  └─ POST /upload                                 [AUTH][UP]
   │     └─ Upload media lên storage (post/message/avatar)
   │
   ├─ /notifications
   │  ├─ GET   /                                      [AUTH]
   │  │  └─ Lấy danh sách thông báo (có lọc unread/paging)
   │  ├─ PATCH /:notificationId/read                  [AUTH]
   │  │  └─ Đánh dấu 1 thông báo đã đọc
   │  └─ PATCH /read-all                              [AUTH]
   │     └─ Đánh dấu tất cả thông báo đã đọc
   │
   ├─ /messages
   │  ├─ POST /direct/text                            [AUTH][FRIEND]
   │  │  └─ Gửi tin nhắn text trực tiếp cho bạn bè
   │  ├─ POST /direct/media                           [AUTH][FRIEND][UP]
   │  │  └─ Gửi tin nhắn media trực tiếp
   │  ├─ POST /group/text                             [AUTH][GROUP]
   │  │  └─ Gửi tin nhắn text trong nhóm
   │  ├─ POST /group/media                            [AUTH][GROUP][UP]
   │  │  └─ Gửi tin nhắn media trong nhóm
   │  ├─ POST /direct                                 [AUTH][FRIEND][UP]
   │  │  └─ Endpoint unified direct (text và/hoặc media)
   │  └─ POST /group                                  [AUTH][GROUP][UP]
   │     └─ Endpoint unified group (text và/hoặc media)
   │
   └─ /conversations
      ├─ POST   /                                     [AUTH][FRIEND]
      │  └─ Tạo conversation mới (direct/group)
      ├─ GET    /                                     [AUTH]
      │  └─ Lấy danh sách conversations của user
      ├─ PATCH  /:conversationId/seen                 [AUTH][CONV]
      │  └─ Đánh dấu conversation đã xem
      ├─ PATCH  /:conversationId/leave                [AUTH][CONV]
      │  └─ Rời nhóm chat
      ├─ GET    /:conversationId/messages             [AUTH][CONV]
      │  └─ Lấy lịch sử tin nhắn theo conversation
      ├─ PUT    /:conversationId/messages/:messageId/reaction   [AUTH][CONV]
      │  └─ Thêm/Cập nhật reaction cho tin nhắn
      ├─ DELETE /:conversationId/messages/:messageId/reaction   [AUTH][CONV]
      │  └─ Gỡ reaction khỏi tin nhắn
      ├─ PATCH  /:conversationId/messages/:messageId/read       [AUTH][CONV]
      │  └─ Đánh dấu 1 tin nhắn đã đọc
      └─ PATCH  /:conversationId/messages/read-all              [AUTH][CONV]
         └─ Đánh dấu đã đọc hàng loạt trong conversation