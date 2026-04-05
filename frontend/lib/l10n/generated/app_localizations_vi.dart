// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get welcomeTaglineConnect => 'Kết nối mọi người';

  @override
  String get welcomeTaglineRelationship => 'Mở ra các mối quan hệ mới';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get loginUsernameHint => 'Nhập tên đăng nhập';

  @override
  String get loginPasswordHint => 'Nhập mật khẩu';

  @override
  String get rememberPassword => 'Nhớ mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get loginSuccess => 'Đăng nhập thành công';

  @override
  String get loginFailed => 'Đăng nhập thất bại';

  @override
  String get orText => 'hoặc';

  @override
  String get loginWithGoogle => 'Đăng nhập với Google';

  @override
  String get noAccountQuestion => 'Chưa có tài khoản?';

  @override
  String get haveAccountQuestion => 'Tôi đã có tài khoản rồi.';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get forgotPasswordDescription =>
      'Nhập email liên kết với tài khoản để được gửi mã đặt lại mật khẩu của bạn';

  @override
  String get enterEmailHint => 'Nhập email';

  @override
  String get sendVerificationCode => 'Gửi mã xác nhận';

  @override
  String get pleaseEnterEmail => 'Vui lòng nhập email';

  @override
  String get otpEnterCodeTitle => 'Nhập mã xác nhận';

  @override
  String otpDescription(Object maskedEmail) {
    return 'Để xác nhận tài khoản, hãy nhập mã gồm 6 chữ số mà chúng tôi đã gửi đến địa chỉ $maskedEmail.';
  }

  @override
  String get otpCodeHint => 'Nhập mã xác nhận';

  @override
  String get next => 'Tiếp';

  @override
  String get pleaseEnterSixDigitCode => 'Vui lòng nhập mã 6 chữ số';

  @override
  String get resendCode => 'Gửi lại mã';

  @override
  String get didNotReceiveCode => 'Tôi không nhận được mã';

  @override
  String get alreadyHaveAccount => 'Tôi có tài khoản rồi';

  @override
  String get createNewPasswordTitle => 'Tạo mật khẩu mới';

  @override
  String get createNewPasswordDescription =>
      'Tạo mật khẩu gồm ít nhất 6 chữ cái hoặc chữ số. Bạn nên chọn mật khẩu thật khó đoán.';

  @override
  String get confirmPasswordHint => 'Nhập lại mật khẩu';

  @override
  String get invalidOrMismatchedPassword =>
      'Mật khẩu không hợp lệ hoặc không trùng khớp';

  @override
  String get firstNameHint => 'Tên';

  @override
  String get lastNameHint => 'Họ';

  @override
  String get usernameHint => 'Tên người dùng';

  @override
  String get reenterPasswordHint => 'Nhập lại mật khẩu';

  @override
  String get pleaseEnterFullName => 'Vui lòng nhập họ và tên';

  @override
  String get pleaseEnterUsername => 'Vui lòng nhập tên người dùng';

  @override
  String get pleaseEnterValidEmail => 'Vui lòng nhập email hợp lệ';

  @override
  String get passwordTooShortOrMismatch => 'Mật khẩu quá ngắn hoặc không khớp';

  @override
  String get registerSuccess => 'Đăng ký thành công';

  @override
  String get registerFailed => 'Đăng ký thất bại';

  @override
  String get done => 'Xong';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get profileChooseAccount => 'Chọn tài khoản';

  @override
  String get profileAccountSwitched => 'Đã chuyển tài khoản.';

  @override
  String get addAccount => 'Thêm tài khoản';

  @override
  String get addAccountSoon => 'Tính năng thêm tài khoản sẽ có sớm.';

  @override
  String get settingsAndActivity => 'Cài đặt và hoạt động';

  @override
  String get archive => 'Kho lưu trữ';

  @override
  String get switchToProfessionalAccount =>
      'Chuyển sang tài khoản chuyên nghiệp';

  @override
  String get switchToBusinessAccount => 'Chuyển sang tài khoản công ty';

  @override
  String get switchAccount => 'Chuyển tài khoản';

  @override
  String get featureInDevelopment => 'Tính năng đang phát triển.';

  @override
  String get loadingProfileInfo => 'Đang tải thông tin...';

  @override
  String get noProfileData => 'Chưa có dữ liệu hồ sơ.';

  @override
  String get postsLabel => 'bài viết';

  @override
  String get followersLabel => 'người theo dõi';

  @override
  String get followingLabel => 'đang theo dõi';

  @override
  String get editAction => 'Chỉnh sửa';

  @override
  String get shareProfileAction => 'Chia sẻ trang cá nhân';

  @override
  String get newLabel => 'Mới';

  @override
  String get taggedPostsEmpty => 'Chưa có bài viết được gắn thẻ.';

  @override
  String get linkCopied => 'Đã sao liên kết';

  @override
  String get pageNotImplemented => 'Trang này chưa được triển khai.';

  @override
  String get editProfileTitle => 'Chỉnh sửa trang cá nhân';

  @override
  String get editAvatarAction => 'Chỉnh sửa ảnh hoặc avatar';

  @override
  String get pleaseEnterDisplayName => 'Vui lòng nhập tên hiển thị';

  @override
  String get updateAvatarSuccess => 'Đã cập nhật ảnh đại diện.';

  @override
  String get updateAvatarFailed => 'Không thể cập nhật ảnh đại diện.';

  @override
  String get profileSavedLocal =>
      'Đã lưu thông tin trang cá nhân (lưu cục bộ).';

  @override
  String get privateAccount => 'Tài khoản riêng tư';

  @override
  String get personalInfo => 'Thông tin cá nhân';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Điện thoại';

  @override
  String get genderLabel => 'Giới tính';

  @override
  String get profileFormSampleData =>
      'Dữ liệu form đang dùng mẫu UI cho phần frontend.';

  @override
  String get mediaLibrary => 'Thư viện';

  @override
  String get mediaSelectedReady => 'Đã chọn ảnh, sẵn sàng bước tiếp.';

  @override
  String get chatGroupInfoTitle => 'Thông tin nhóm';

  @override
  String get groupNotFound => 'Không tìm thấy thông tin nhóm';

  @override
  String membersCount(Object count) {
    return '$count thành viên';
  }

  @override
  String get groupRename => 'Đổi tên nhóm';

  @override
  String get groupChangeAvatar => 'Đổi ảnh nhóm';

  @override
  String get addMember => 'Thêm thành viên';

  @override
  String get searchMessages => 'Tìm tin nhắn';

  @override
  String get photosAndVideos => 'Ảnh và video';

  @override
  String get adminOnlyManageGroupInfo =>
      'Chỉ quản trị viên mới có thể đổi thông tin và thêm thành viên.';

  @override
  String get memberList => 'Danh sách thành viên';

  @override
  String get youSuffix => 'bạn';

  @override
  String get adminRole => 'Quản trị viên';

  @override
  String get memberRole => 'Thành viên';

  @override
  String get leaveGroup => 'Rời nhóm';

  @override
  String get lastAdminCannotLeave =>
      'Bạn là quản trị viên cuối cùng. Hãy chuyển quyền admin trước khi rời nhóm.';

  @override
  String get groupChatFallback => 'Nhóm chat';

  @override
  String get groupMemberAdded => 'Đã thêm thành viên vào nhóm';

  @override
  String get leaveGroupQuestion => 'Rời nhóm?';

  @override
  String get leaveGroupNoNewMessages =>
      'Bạn sẽ không nhận được tin nhắn mới từ nhóm này nữa.';

  @override
  String get selectNewAdminBeforeLeave =>
      'Bạn là quản trị viên cuối cùng. Hãy chọn người nhận quyền trước khi rời nhóm.';

  @override
  String get noMemberToTransfer =>
      'Hiện không có thành viên nào để chuyển quyền.';

  @override
  String get currentRoleAdmin => 'Vai trò hiện tại: Quản trị viên';

  @override
  String get currentRoleMember => 'Vai trò hiện tại: Thành viên';

  @override
  String get cannotLeaveGroupCheckAdmin =>
      'Không thể rời nhóm. Vui lòng kiểm tra lại quyền quản trị.';

  @override
  String get leftGroupSuccess => 'Bạn đã rời nhóm';

  @override
  String get handoverAndLeaveSuccess =>
      'Đã chuyển quyền admin và rời nhóm thành công';

  @override
  String get secondConfirmation => 'Xác nhận lần 2';

  @override
  String get aboutToHandoverAndLeave =>
      'Bạn sắp chuyển quyền quản trị viên và rời nhóm.';

  @override
  String get newAdminWillBe => 'Sẽ trở thành quản trị viên mới';

  @override
  String get afterConfirmLeaveImmediately =>
      'Sau khi xác nhận, bạn sẽ rời nhóm ngay.';

  @override
  String get goBack => 'Quay lại';

  @override
  String get confirmHandover => 'Xác nhận chuyển quyền';

  @override
  String get adminOnlyAction =>
      'Chỉ quản trị viên mới có quyền thực hiện thao tác này';

  @override
  String get chatInviteLink => 'Liên kết mời';

  @override
  String get inviteLinkCopied => 'Đã sao chép liên kết mời nhóm';

  @override
  String get addPeople => 'Thêm người';

  @override
  String youBlockedUser(Object name) {
    return 'Bạn đã chặn $name';
  }

  @override
  String youRestrictedUser(Object name) {
    return 'Bạn đã hạn chế $name';
  }

  @override
  String get noOnlineOrReadStatus =>
      'Họ sẽ không biết khi nào bạn online hoặc đọc tin nhắn của họ';

  @override
  String get blockAction => 'Chặn';

  @override
  String get unblockAction => 'Bỏ chặn';

  @override
  String get unrestrictAction => 'Bỏ hạn chế';

  @override
  String get onlyAdminCanAddMembers =>
      'Chỉ quản trị viên mới có thể thêm thành viên';

  @override
  String get messagesSearchHint => 'Tìm kiếm';

  @override
  String get messagesTitle => 'Tin nhắn';

  @override
  String get pendingMessages => 'Tin nhắn đang chờ';

  @override
  String get noConversationFound => 'Không tìm thấy cuộc trò chuyện';

  @override
  String get chatPinned => 'Đã ghim đoạn chat';

  @override
  String get chatUnpinned => 'Đã bỏ ghim đoạn chat';

  @override
  String get chatHidden => 'Đã ẩn đoạn chat';

  @override
  String get chatDeleted => 'Đã xóa đoạn chat';

  @override
  String get pinAction => 'Ghim';

  @override
  String get unpinAction => 'Bỏ ghim';

  @override
  String get hideAction => 'Ẩn';

  @override
  String get deleteAction => 'Xóa';

  @override
  String get mutedNow => 'Đang tắt';

  @override
  String get feedNotificationSoon => 'Thông báo sẽ được thêm sau.';

  @override
  String get sessionExpiredRelogin =>
      'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';

  @override
  String get emptyNoPosts => 'Chưa có bài viết nào';

  @override
  String get emptyFollowFriends => 'Hãy quay lại sau hoặc theo dõi thêm bạn bè';

  @override
  String get shareSoon => 'Chia sẻ sẽ được thêm sau.';

  @override
  String get saveSoon => 'Lưu bài viết sẽ được thêm sau.';

  @override
  String get createPostCannotPickGallery => 'Không thể chọn ảnh từ thư viện';

  @override
  String get createPostCannotOpenCamera => 'Không thể mở camera';

  @override
  String get createPostTitle => 'Tạo bài viết';

  @override
  String get postAction => 'Đăng';

  @override
  String get captionHint =>
      'Viết caption cho bài viết...\nGợi ý: thêm hashtag để tiếp cận tốt hơn.';

  @override
  String get addMediaForPost => 'Thêm ảnh/video cho bài viết';

  @override
  String get pickFromLibrary => 'Chọn từ thư viện';

  @override
  String get libraryLabel => 'Thư viện';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get friendsSearchHint => 'Search';

  @override
  String cannotOpenChat(Object error) {
    return 'Không thể mở chat: $error';
  }

  @override
  String get placeholderLastMessage =>
      'This is a placeholder for the last message.';

  @override
  String get messageInputHint => 'Nhắn tin...';

  @override
  String get bioLabel => 'Tiểu sử';

  @override
  String get myLoveLabel => 'my love';

  @override
  String get searchInConversationHint => 'Tìm trong cuộc trò chuyện';

  @override
  String get enterKeywordToSearch => 'Nhập từ khóa để tìm tin nhắn';

  @override
  String get noMatchingResults => 'Không tìm thấy kết quả phù hợp';

  @override
  String get youLabel => 'Bạn';

  @override
  String get enterNicknameHint => 'Nhập biệt danh';

  @override
  String nicknameRemoved(Object name) {
    return 'Đã xóa biệt danh của $name';
  }

  @override
  String nicknameUpdated(Object name) {
    return 'Đã cập nhật biệt danh của $name';
  }

  @override
  String nicknameVisibleInChat(Object name) {
    return 'Mọi người trong đoạn chat đều sẽ nhìn thấy biệt danh này của $name.';
  }

  @override
  String get groupNameHint => 'Nhập tên nhóm';

  @override
  String get invitedMembers => 'Thành viên được mời';

  @override
  String get searchGeneric => 'Tìm kiếm';

  @override
  String get safetyProfile => 'Trang cá nhân';

  @override
  String get restrictAction => 'Hạn chế';

  @override
  String get blockAccount => 'Chặn tài khoản';

  @override
  String get unblockAccount => 'Bỏ chặn tài khoản';

  @override
  String get nicknameAction => 'Biệt danh';

  @override
  String get createGroupChat => 'Tạo nhóm chat';

  @override
  String get optionsLabel => 'Lựa chọn';

  @override
  String get muteOffLabel => 'Tắt';

  @override
  String get photosAndVideoTitle => 'Ảnh và Video';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get blockedMediaHidden =>
      'Nội dung ảnh và video bị ẩn do bạn đã chặn tài khoản này.';

  @override
  String get mute10Minutes => '10 phút';

  @override
  String get mute30Minutes => '30 phút';

  @override
  String get mute1Hour => '1 giờ';

  @override
  String get mute2Hours => '2 giờ';

  @override
  String get mute12Hours => '12 giờ';

  @override
  String get mute24Hours => '24 giờ';

  @override
  String get mute48Hours => '48 giờ';

  @override
  String get muteConversationTitle => 'Tắt thông báo đoạn chat';

  @override
  String get turnOnNotifications => 'Bật thông báo';

  @override
  String get grantAdmin => 'Cấp quyền quản trị viên';

  @override
  String get revokeAdmin => 'Gỡ quyền quản trị viên';

  @override
  String get revokeAdminLocked => 'Gỡ quyền quản trị viên (bị khóa)';

  @override
  String get onlyAdminCanChangeRole => 'Quản trị viên mới được đổi quyền';

  @override
  String get privateMessage => 'Nhắn tin riêng';

  @override
  String get thisIsYourAccount => 'Đây là tài khoản của bạn';

  @override
  String get newGroupTitle => 'Nhóm mới';

  @override
  String get editGroupTitle => 'Chỉnh sửa nhóm';

  @override
  String get createAction => 'Tạo';

  @override
  String get peopleWhoCanContactYou => 'Người có thể liên hệ với bạn';

  @override
  String get editNicknameTitle => 'Chỉnh sửa biệt danh';

  @override
  String get groupRoleTitle => 'Vai trò trong nhóm';

  @override
  String get memberIdTitle => 'ID thành viên';

  @override
  String adminGrantedTo(Object name) {
    return 'Đã cấp quyền admin cho $name';
  }

  @override
  String get cannotGrantAdmin => 'Không thể cấp quyền admin';

  @override
  String adminRevokedFrom(Object name) {
    return 'Đã gỡ quyền admin của $name';
  }

  @override
  String get cannotRevokeAdmin => 'Không thể gỡ quyền admin';

  @override
  String get cannotRevokeOwnAdminTooltip =>
      'Bạn không thể tự gỡ quyền của chính mình. Hãy cấp quyền admin cho người khác trước.';

  @override
  String get cannotRevokeOwnAdmin => 'Bạn không thể tự gỡ quyền quản trị viên';

  @override
  String get onlyAdminCanGrantOrRevokeTooltip =>
      'Chỉ quản trị viên mới có thể cấp hoặc gỡ quyền admin.';

  @override
  String get noAdminPermissionForAction =>
      'Bạn không có quyền quản trị để thực hiện thao tác này';

  @override
  String get cannotRevokeLastAdmin =>
      'Không thể gỡ quyền admin cuối cùng trong nhóm.';

  @override
  String get youAreCurrentAdmin => 'Bạn là admin hiện tại';

  @override
  String get adminHasFullControl => 'Admin có toàn quyền';

  @override
  String get canGrantOrRevokeForOthers =>
      'Bạn có thể cấp/gỡ quyền admin cho thành viên khác.';

  @override
  String get youHaveAdminRights => 'Bạn có quyền quản trị';

  @override
  String get canChangeMemberRoles =>
      'Bạn có thể thay đổi quyền thành viên trong nhóm.';

  @override
  String get noPermissionChangeRole => 'Bạn không có quyền đổi role';

  @override
  String get onlyAdminCanGrantOrRevoke =>
      'Chỉ quản trị viên mới được phép cấp/gỡ quyền admin.';

  @override
  String get mutePriorityHint =>
      'Ưu tiên cao nhất: Hủy toàn bộ trạng thái tắt thông báo hiện tại.';

  @override
  String get muteUntilTurnedOn => 'Cho đến khi bật lại';

  @override
  String get exploreTitle => 'Khám phá';

  @override
  String get reelsTitle => 'Reels';

  @override
  String get postOptionAddToFavorites => 'Thêm vào mục yêu thích';

  @override
  String get postOptionAboutThisAccount => 'Giới thiệu về tài khoản này';

  @override
  String get postOptionHidePost => 'Ẩn bài viết';

  @override
  String get postOptionReport => 'Báo cáo';

  @override
  String get postOptionAddToFavoritesDone => 'Đã thêm vào mục yêu thích';

  @override
  String get postOptionHidePostDone => 'Đã ẩn bài viết';

  @override
  String get postOptionReportDone => 'Đã gửi báo cáo';

  @override
  String postOptionReportDoneWithReason(Object reason) {
    return 'Đã gửi báo cáo với lý do: $reason';
  }

  @override
  String get postReportTitle => 'Báo cáo bài viết';

  @override
  String get postReportSelectReason => 'Chọn lý do phù hợp nhất';

  @override
  String get postReportSubmit => 'Gửi báo cáo';

  @override
  String get postReportReasonSpam => 'Spam';

  @override
  String get postReportReasonHarassment => 'Quấy rối hoặc bắt nạt';

  @override
  String get postReportReasonFalseInfo => 'Thông tin sai lệch';

  @override
  String get postReportReasonHateSpeech => 'Ngôn từ thù ghét';

  @override
  String get postReportReasonViolence => 'Bạo lực hoặc nguy hiểm';

  @override
  String get postReportReasonOther => 'Lý do khác';

  @override
  String get postOptionAllHiddenTitle => 'Bạn đã ẩn tất cả bài viết';

  @override
  String get postOptionAllHiddenDescription =>
      'Hãy tải lại để xem nội dung mới hoặc chờ bài viết khác.';

  @override
  String get followingStatus => 'Đang theo dõi';

  @override
  String get yourStory => 'Your Story';

  @override
  String viewAllComments(Object count) {
    return 'Xem tất cả $count bình luận';
  }

  @override
  String likesCountText(Object count) {
    return '$count lượt thích';
  }

  @override
  String get followAction => 'Theo dõi';

  @override
  String get recentSearchTitle => 'Gần đây';
}
