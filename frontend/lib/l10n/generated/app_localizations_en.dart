// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTaglineConnect => 'Connect everyone';

  @override
  String get welcomeTaglineRelationship => 'Open new relationships';

  @override
  String get login => 'Log in';

  @override
  String get register => 'Register';

  @override
  String get loginUsernameHint => 'Enter username';

  @override
  String get loginPasswordHint => 'Enter password';

  @override
  String get rememberPassword => 'Remember password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get orText => 'or';

  @override
  String get loginWithGoogle => 'Log in with Google';

  @override
  String get noAccountQuestion => 'No account yet?';

  @override
  String get haveAccountQuestion => 'I already have an account.';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordDescription =>
      'Enter the email linked to your account to receive a reset code.';

  @override
  String get enterEmailHint => 'Enter email';

  @override
  String get sendVerificationCode => 'Send verification code';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get otpEnterCodeTitle => 'Enter verification code';

  @override
  String otpDescription(Object maskedEmail) {
    return 'To verify your account, enter the 6-digit code we sent to $maskedEmail.';
  }

  @override
  String get otpCodeHint => 'Enter verification code';

  @override
  String get next => 'Next';

  @override
  String get pleaseEnterSixDigitCode => 'Please enter a 6-digit code';

  @override
  String get resendCode => 'Resend code';

  @override
  String get didNotReceiveCode => 'I did not receive the code';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get createNewPasswordTitle => 'Create a new password';

  @override
  String get createNewPasswordDescription =>
      'Create a password with at least 6 letters or digits. Choose one that is hard to guess.';

  @override
  String get confirmPasswordHint => 'Re-enter password';

  @override
  String get invalidOrMismatchedPassword => 'Invalid or mismatched password';

  @override
  String get firstNameHint => 'First name';

  @override
  String get lastNameHint => 'Last name';

  @override
  String get usernameHint => 'Username';

  @override
  String get reenterPasswordHint => 'Re-enter password';

  @override
  String get pleaseEnterFullName => 'Please enter first and last name';

  @override
  String get pleaseEnterUsername => 'Please enter username';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get passwordTooShortOrMismatch =>
      'Password is too short or does not match';

  @override
  String get registerSuccess => 'Registration successful';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get profileChooseAccount => 'Choose account';

  @override
  String get profileAccountSwitched => 'Account switched.';

  @override
  String get addAccount => 'Add account';

  @override
  String get addAccountSoon => 'Add account feature is coming soon.';

  @override
  String get settingsAndActivity => 'Settings and activity';

  @override
  String get archive => 'Archive';

  @override
  String get switchToProfessionalAccount => 'Switch to professional account';

  @override
  String get switchToBusinessAccount => 'Switch to business account';

  @override
  String get switchAccount => 'Switch account';

  @override
  String get featureInDevelopment => 'Feature is in development.';

  @override
  String get loadingProfileInfo => 'Loading profile information...';

  @override
  String get noProfileData => 'No profile data available.';

  @override
  String get postsLabel => 'posts';

  @override
  String get followersLabel => 'followers';

  @override
  String get followingLabel => 'following';

  @override
  String get editAction => 'Edit';

  @override
  String get shareProfileAction => 'Share profile';

  @override
  String get newLabel => 'New';

  @override
  String get taggedPostsEmpty => 'No tagged posts yet.';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get pageNotImplemented => 'This page has not been implemented yet.';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editAvatarAction => 'Edit photo or avatar';

  @override
  String get pleaseEnterDisplayName => 'Please enter display name';

  @override
  String get updateAvatarSuccess => 'Avatar updated successfully.';

  @override
  String get updateAvatarFailed => 'Cannot update avatar.';

  @override
  String get profileSavedLocal => 'Profile changes saved locally.';

  @override
  String get privateAccount => 'Private account';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get genderLabel => 'Gender';

  @override
  String get profileFormSampleData =>
      'The form data currently uses frontend UI sample data.';

  @override
  String get mediaLibrary => 'Library';

  @override
  String get mediaSelectedReady => 'Image selected, ready for next step.';

  @override
  String get chatGroupInfoTitle => 'Group info';

  @override
  String get groupNotFound => 'Group information not found';

  @override
  String membersCount(Object count) {
    return '$count members';
  }

  @override
  String get groupRename => 'Rename group';

  @override
  String get groupChangeAvatar => 'Change group avatar';

  @override
  String get addMember => 'Add member';

  @override
  String get searchMessages => 'Search messages';

  @override
  String get photosAndVideos => 'Photos and videos';

  @override
  String get adminOnlyManageGroupInfo =>
      'Only admins can update group info and add members.';

  @override
  String get memberList => 'Member list';

  @override
  String get youSuffix => 'you';

  @override
  String get adminRole => 'Admin';

  @override
  String get memberRole => 'Member';

  @override
  String get leaveGroup => 'Leave group';

  @override
  String get lastAdminCannotLeave =>
      'You are the last admin. Transfer admin rights before leaving.';

  @override
  String get groupChatFallback => 'Group chat';

  @override
  String get groupMemberAdded => 'Members added to group';

  @override
  String get leaveGroupQuestion => 'Leave group?';

  @override
  String get leaveGroupNoNewMessages =>
      'You will no longer receive new messages from this group.';

  @override
  String get selectNewAdminBeforeLeave =>
      'You are the last admin. Choose a new admin before leaving.';

  @override
  String get noMemberToTransfer => 'No members available for transfer.';

  @override
  String get currentRoleAdmin => 'Current role: Admin';

  @override
  String get currentRoleMember => 'Current role: Member';

  @override
  String get cannotLeaveGroupCheckAdmin =>
      'Cannot leave group. Please recheck admin permissions.';

  @override
  String get leftGroupSuccess => 'You left the group';

  @override
  String get handoverAndLeaveSuccess =>
      'Admin rights transferred and you left the group';

  @override
  String get secondConfirmation => 'Second confirmation';

  @override
  String get aboutToHandoverAndLeave =>
      'You are about to transfer admin rights and leave the group.';

  @override
  String get newAdminWillBe => 'Will become the new admin';

  @override
  String get afterConfirmLeaveImmediately =>
      'After confirmation, you will leave the group immediately.';

  @override
  String get goBack => 'Go back';

  @override
  String get confirmHandover => 'Confirm transfer';

  @override
  String get adminOnlyAction => 'Only admins can perform this action';

  @override
  String get chatInviteLink => 'Invite link';

  @override
  String get inviteLinkCopied => 'Group invite link copied';

  @override
  String get addPeople => 'Add people';

  @override
  String youBlockedUser(Object name) {
    return 'You blocked $name';
  }

  @override
  String youRestrictedUser(Object name) {
    return 'You restricted $name';
  }

  @override
  String get noOnlineOrReadStatus =>
      'They will not know when you are online or read their messages';

  @override
  String get blockAction => 'Block';

  @override
  String get unblockAction => 'Unblock';

  @override
  String get unrestrictAction => 'Unrestrict';

  @override
  String get onlyAdminCanAddMembers => 'Only admins can add members';

  @override
  String get messagesSearchHint => 'Search';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get pendingMessages => 'Message requests';

  @override
  String get noConversationFound => 'No conversations found';

  @override
  String get chatPinned => 'Chat pinned';

  @override
  String get chatUnpinned => 'Chat unpinned';

  @override
  String get chatHidden => 'Chat hidden';

  @override
  String get chatDeleted => 'Chat deleted';

  @override
  String get pinAction => 'Pin';

  @override
  String get unpinAction => 'Unpin';

  @override
  String get hideAction => 'Hide';

  @override
  String get deleteAction => 'Delete';

  @override
  String get mutedNow => 'Muted';

  @override
  String get feedNotificationSoon => 'Notifications will be added later.';

  @override
  String get sessionExpiredRelogin => 'Session expired. Please sign in again.';

  @override
  String get emptyNoPosts => 'No posts yet';

  @override
  String get emptyFollowFriends => 'Check back later or follow more friends';

  @override
  String get shareSoon => 'Share will be added later.';

  @override
  String get saveSoon => 'Save post will be added later.';

  @override
  String get createPostCannotPickGallery => 'Cannot pick images from gallery';

  @override
  String get createPostCannotOpenCamera => 'Cannot open camera';

  @override
  String get createPostTitle => 'Create post';

  @override
  String get postAction => 'Post';

  @override
  String get captionHint =>
      'Write a caption for your post...\nTip: add hashtags for better reach.';

  @override
  String get addMediaForPost => 'Add photo/video to your post';

  @override
  String get pickFromLibrary => 'Pick from library';

  @override
  String get libraryLabel => 'Library';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get friendsSearchHint => 'Search';

  @override
  String cannotOpenChat(Object error) {
    return 'Cannot open chat: $error';
  }

  @override
  String get placeholderLastMessage =>
      'This is a placeholder for the last message.';

  @override
  String get messageInputHint => 'Type a message...';

  @override
  String get bioLabel => 'Bio';

  @override
  String get myLoveLabel => 'my love';

  @override
  String get searchInConversationHint => 'Search in conversation';

  @override
  String get enterKeywordToSearch => 'Enter a keyword to search messages';

  @override
  String get noMatchingResults => 'No matching results found';

  @override
  String get youLabel => 'You';

  @override
  String get enterNicknameHint => 'Enter nickname';

  @override
  String nicknameRemoved(Object name) {
    return 'Nickname removed for $name';
  }

  @override
  String nicknameUpdated(Object name) {
    return 'Nickname updated for $name';
  }

  @override
  String nicknameVisibleInChat(Object name) {
    return 'Everyone in this chat will see this nickname for $name.';
  }

  @override
  String get groupNameHint => 'Enter group name';

  @override
  String get invitedMembers => 'Invited members';

  @override
  String get searchGeneric => 'Search';

  @override
  String get safetyProfile => 'Profile';

  @override
  String get restrictAction => 'Restrict';

  @override
  String get blockAccount => 'Block account';

  @override
  String get unblockAccount => 'Unblock account';

  @override
  String get nicknameAction => 'Nickname';

  @override
  String get createGroupChat => 'Create group chat';

  @override
  String get optionsLabel => 'Options';

  @override
  String get muteOffLabel => 'Off';

  @override
  String get photosAndVideoTitle => 'Photos and Videos';

  @override
  String get viewAll => 'See all';

  @override
  String get blockedMediaHidden =>
      'Photos and videos are hidden because you blocked this account.';

  @override
  String get mute10Minutes => '10 minutes';

  @override
  String get mute30Minutes => '30 minutes';

  @override
  String get mute1Hour => '1 hour';

  @override
  String get mute2Hours => '2 hours';

  @override
  String get mute12Hours => '12 hours';

  @override
  String get mute24Hours => '24 hours';

  @override
  String get mute48Hours => '48 hours';

  @override
  String get muteConversationTitle => 'Mute conversation notifications';

  @override
  String get turnOnNotifications => 'Turn on notifications';

  @override
  String get grantAdmin => 'Grant admin role';

  @override
  String get revokeAdmin => 'Revoke admin role';

  @override
  String get revokeAdminLocked => 'Revoke admin role (locked)';

  @override
  String get onlyAdminCanChangeRole => 'Only admins can change roles';

  @override
  String get privateMessage => 'Private message';

  @override
  String get thisIsYourAccount => 'This is your account';

  @override
  String get newGroupTitle => 'New group';

  @override
  String get editGroupTitle => 'Edit group';

  @override
  String get createAction => 'Create';

  @override
  String get peopleWhoCanContactYou => 'People who can contact you';

  @override
  String get editNicknameTitle => 'Edit nickname';

  @override
  String get groupRoleTitle => 'Group role';

  @override
  String get memberIdTitle => 'Member ID';

  @override
  String adminGrantedTo(Object name) {
    return 'Granted admin role to $name';
  }

  @override
  String get cannotGrantAdmin => 'Cannot grant admin role';

  @override
  String adminRevokedFrom(Object name) {
    return 'Revoked admin role from $name';
  }

  @override
  String get cannotRevokeAdmin => 'Cannot revoke admin role';

  @override
  String get cannotRevokeOwnAdminTooltip =>
      'You cannot revoke your own role. Grant admin to someone else first.';

  @override
  String get cannotRevokeOwnAdmin => 'You cannot revoke your own admin role';

  @override
  String get onlyAdminCanGrantOrRevokeTooltip =>
      'Only admins can grant or revoke admin role.';

  @override
  String get noAdminPermissionForAction =>
      'You do not have admin permission for this action';

  @override
  String get cannotRevokeLastAdmin =>
      'Cannot revoke the last admin in the group.';

  @override
  String get youAreCurrentAdmin => 'You are the current admin';

  @override
  String get adminHasFullControl => 'Admin has full control';

  @override
  String get canGrantOrRevokeForOthers =>
      'You can grant/revoke admin role for other members.';

  @override
  String get youHaveAdminRights => 'You have admin rights';

  @override
  String get canChangeMemberRoles =>
      'You can change member roles in this group.';

  @override
  String get noPermissionChangeRole =>
      'You do not have permission to change roles';

  @override
  String get onlyAdminCanGrantOrRevoke =>
      'Only admins are allowed to grant/revoke admin role.';

  @override
  String get mutePriorityHint => 'Top priority: clear all current mute states.';

  @override
  String get muteUntilTurnedOn => 'Until turned on again';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get reelsTitle => 'Reels';

  @override
  String get postOptionAddToFavorites => 'Add to favorites';

  @override
  String get postOptionAboutThisAccount => 'About this account';

  @override
  String get postOptionHidePost => 'Hide post';

  @override
  String get postOptionReport => 'Report';

  @override
  String get postOptionAddToFavoritesDone => 'Added to favorites';

  @override
  String get postOptionHidePostDone => 'Post hidden';

  @override
  String get postOptionReportDone => 'Report submitted';

  @override
  String postOptionReportDoneWithReason(Object reason) {
    return 'Report submitted with reason: $reason';
  }

  @override
  String get postReportTitle => 'Report post';

  @override
  String get postReportSelectReason => 'Select the most relevant reason';

  @override
  String get postReportSubmit => 'Submit report';

  @override
  String get postReportReasonSpam => 'Spam';

  @override
  String get postReportReasonHarassment => 'Harassment or bullying';

  @override
  String get postReportReasonFalseInfo => 'False information';

  @override
  String get postReportReasonHateSpeech => 'Hate speech';

  @override
  String get postReportReasonViolence => 'Violence or dangerous acts';

  @override
  String get postReportReasonOther => 'Other';

  @override
  String get postOptionAllHiddenTitle => 'You have hidden all posts';

  @override
  String get postOptionAllHiddenDescription =>
      'Refresh to load new content or wait for other posts.';

  @override
  String get followingStatus => 'Following';

  @override
  String get yourStory => 'Your Story';

  @override
  String viewAllComments(Object count) {
    return 'View all $count comments';
  }

  @override
  String likesCountText(Object count) {
    return '$count likes';
  }

  @override
  String get followAction => 'Follow';

  @override
  String get recentSearchTitle => 'Recent';
}
