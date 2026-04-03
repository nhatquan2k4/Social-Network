import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @welcomeTaglineConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect everyone'**
  String get welcomeTaglineConnect;

  /// No description provided for @welcomeTaglineRelationship.
  ///
  /// In en, this message translates to:
  /// **'Open new relationships'**
  String get welcomeTaglineRelationship;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @loginUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get loginUsernameHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get loginPasswordHint;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember password'**
  String get rememberPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @orText.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orText;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Log in with Google'**
  String get loginWithGoogle;

  /// No description provided for @noAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'No account yet?'**
  String get noAccountQuestion;

  /// No description provided for @haveAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'I already have an account.'**
  String get haveAccountQuestion;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the email linked to your account to receive a reset code.'**
  String get forgotPasswordDescription;

  /// No description provided for @enterEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmailHint;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendVerificationCode;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @otpEnterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get otpEnterCodeTitle;

  /// No description provided for @otpDescription.
  ///
  /// In en, this message translates to:
  /// **'To verify your account, enter the 6-digit code we sent to {maskedEmail}.'**
  String otpDescription(Object maskedEmail);

  /// No description provided for @otpCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get otpCodeHint;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @pleaseEnterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a 6-digit code'**
  String get pleaseEnterSixDigitCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @didNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'I did not receive the code'**
  String get didNotReceiveCode;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @createNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get createNewPasswordTitle;

  /// No description provided for @createNewPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a password with at least 6 letters or digits. Choose one that is hard to guess.'**
  String get createNewPasswordDescription;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get confirmPasswordHint;

  /// No description provided for @invalidOrMismatchedPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid or mismatched password'**
  String get invalidOrMismatchedPassword;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameHint;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameHint;

  /// No description provided for @reenterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get reenterPasswordHint;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter first and last name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @passwordTooShortOrMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password is too short or does not match'**
  String get passwordTooShortOrMismatch;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registerSuccess;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @profileChooseAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose account'**
  String get profileChooseAccount;

  /// No description provided for @profileAccountSwitched.
  ///
  /// In en, this message translates to:
  /// **'Account switched.'**
  String get profileAccountSwitched;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccount;

  /// No description provided for @addAccountSoon.
  ///
  /// In en, this message translates to:
  /// **'Add account feature is coming soon.'**
  String get addAccountSoon;

  /// No description provided for @settingsAndActivity.
  ///
  /// In en, this message translates to:
  /// **'Settings and activity'**
  String get settingsAndActivity;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @switchToProfessionalAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch to professional account'**
  String get switchToProfessionalAccount;

  /// No description provided for @switchToBusinessAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch to business account'**
  String get switchToBusinessAccount;

  /// No description provided for @switchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get switchAccount;

  /// No description provided for @featureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature is in development.'**
  String get featureInDevelopment;

  /// No description provided for @loadingProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'Loading profile information...'**
  String get loadingProfileInfo;

  /// No description provided for @noProfileData.
  ///
  /// In en, this message translates to:
  /// **'No profile data available.'**
  String get noProfileData;

  /// No description provided for @postsLabel.
  ///
  /// In en, this message translates to:
  /// **'posts'**
  String get postsLabel;

  /// No description provided for @followersLabel.
  ///
  /// In en, this message translates to:
  /// **'followers'**
  String get followersLabel;

  /// No description provided for @followingLabel.
  ///
  /// In en, this message translates to:
  /// **'following'**
  String get followingLabel;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @shareProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get shareProfileAction;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @taggedPostsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tagged posts yet.'**
  String get taggedPostsEmpty;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @pageNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'This page has not been implemented yet.'**
  String get pageNotImplemented;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editAvatarAction.
  ///
  /// In en, this message translates to:
  /// **'Edit photo or avatar'**
  String get editAvatarAction;

  /// No description provided for @pleaseEnterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Please enter display name'**
  String get pleaseEnterDisplayName;

  /// No description provided for @updateAvatarSuccess.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated successfully.'**
  String get updateAvatarSuccess;

  /// No description provided for @updateAvatarFailed.
  ///
  /// In en, this message translates to:
  /// **'Cannot update avatar.'**
  String get updateAvatarFailed;

  /// No description provided for @profileSavedLocal.
  ///
  /// In en, this message translates to:
  /// **'Profile changes saved locally.'**
  String get profileSavedLocal;

  /// No description provided for @privateAccount.
  ///
  /// In en, this message translates to:
  /// **'Private account'**
  String get privateAccount;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @profileFormSampleData.
  ///
  /// In en, this message translates to:
  /// **'The form data currently uses frontend UI sample data.'**
  String get profileFormSampleData;

  /// No description provided for @mediaLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get mediaLibrary;

  /// No description provided for @mediaSelectedReady.
  ///
  /// In en, this message translates to:
  /// **'Image selected, ready for next step.'**
  String get mediaSelectedReady;

  /// No description provided for @chatGroupInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Group info'**
  String get chatGroupInfoTitle;

  /// No description provided for @groupNotFound.
  ///
  /// In en, this message translates to:
  /// **'Group information not found'**
  String get groupNotFound;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersCount(Object count);

  /// No description provided for @groupRename.
  ///
  /// In en, this message translates to:
  /// **'Rename group'**
  String get groupRename;

  /// No description provided for @groupChangeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change group avatar'**
  String get groupChangeAvatar;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMember;

  /// No description provided for @searchMessages.
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get searchMessages;

  /// No description provided for @photosAndVideos.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos'**
  String get photosAndVideos;

  /// No description provided for @adminOnlyManageGroupInfo.
  ///
  /// In en, this message translates to:
  /// **'Only admins can update group info and add members.'**
  String get adminOnlyManageGroupInfo;

  /// No description provided for @memberList.
  ///
  /// In en, this message translates to:
  /// **'Member list'**
  String get memberList;

  /// No description provided for @youSuffix.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get youSuffix;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRole;

  /// No description provided for @memberRole.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberRole;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveGroup;

  /// No description provided for @lastAdminCannotLeave.
  ///
  /// In en, this message translates to:
  /// **'You are the last admin. Transfer admin rights before leaving.'**
  String get lastAdminCannotLeave;

  /// No description provided for @groupChatFallback.
  ///
  /// In en, this message translates to:
  /// **'Group chat'**
  String get groupChatFallback;

  /// No description provided for @groupMemberAdded.
  ///
  /// In en, this message translates to:
  /// **'Members added to group'**
  String get groupMemberAdded;

  /// No description provided for @leaveGroupQuestion.
  ///
  /// In en, this message translates to:
  /// **'Leave group?'**
  String get leaveGroupQuestion;

  /// No description provided for @leaveGroupNoNewMessages.
  ///
  /// In en, this message translates to:
  /// **'You will no longer receive new messages from this group.'**
  String get leaveGroupNoNewMessages;

  /// No description provided for @selectNewAdminBeforeLeave.
  ///
  /// In en, this message translates to:
  /// **'You are the last admin. Choose a new admin before leaving.'**
  String get selectNewAdminBeforeLeave;

  /// No description provided for @noMemberToTransfer.
  ///
  /// In en, this message translates to:
  /// **'No members available for transfer.'**
  String get noMemberToTransfer;

  /// No description provided for @currentRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Current role: Admin'**
  String get currentRoleAdmin;

  /// No description provided for @currentRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Current role: Member'**
  String get currentRoleMember;

  /// No description provided for @cannotLeaveGroupCheckAdmin.
  ///
  /// In en, this message translates to:
  /// **'Cannot leave group. Please recheck admin permissions.'**
  String get cannotLeaveGroupCheckAdmin;

  /// No description provided for @leftGroupSuccess.
  ///
  /// In en, this message translates to:
  /// **'You left the group'**
  String get leftGroupSuccess;

  /// No description provided for @handoverAndLeaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Admin rights transferred and you left the group'**
  String get handoverAndLeaveSuccess;

  /// No description provided for @secondConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Second confirmation'**
  String get secondConfirmation;

  /// No description provided for @aboutToHandoverAndLeave.
  ///
  /// In en, this message translates to:
  /// **'You are about to transfer admin rights and leave the group.'**
  String get aboutToHandoverAndLeave;

  /// No description provided for @newAdminWillBe.
  ///
  /// In en, this message translates to:
  /// **'Will become the new admin'**
  String get newAdminWillBe;

  /// No description provided for @afterConfirmLeaveImmediately.
  ///
  /// In en, this message translates to:
  /// **'After confirmation, you will leave the group immediately.'**
  String get afterConfirmLeaveImmediately;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @confirmHandover.
  ///
  /// In en, this message translates to:
  /// **'Confirm transfer'**
  String get confirmHandover;

  /// No description provided for @adminOnlyAction.
  ///
  /// In en, this message translates to:
  /// **'Only admins can perform this action'**
  String get adminOnlyAction;

  /// No description provided for @chatInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get chatInviteLink;

  /// No description provided for @inviteLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Group invite link copied'**
  String get inviteLinkCopied;

  /// No description provided for @addPeople.
  ///
  /// In en, this message translates to:
  /// **'Add people'**
  String get addPeople;

  /// No description provided for @youBlockedUser.
  ///
  /// In en, this message translates to:
  /// **'You blocked {name}'**
  String youBlockedUser(Object name);

  /// No description provided for @youRestrictedUser.
  ///
  /// In en, this message translates to:
  /// **'You restricted {name}'**
  String youRestrictedUser(Object name);

  /// No description provided for @noOnlineOrReadStatus.
  ///
  /// In en, this message translates to:
  /// **'They will not know when you are online or read their messages'**
  String get noOnlineOrReadStatus;

  /// No description provided for @blockAction.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockAction;

  /// No description provided for @unblockAction.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblockAction;

  /// No description provided for @unrestrictAction.
  ///
  /// In en, this message translates to:
  /// **'Unrestrict'**
  String get unrestrictAction;

  /// No description provided for @onlyAdminCanAddMembers.
  ///
  /// In en, this message translates to:
  /// **'Only admins can add members'**
  String get onlyAdminCanAddMembers;

  /// No description provided for @messagesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get messagesSearchHint;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @pendingMessages.
  ///
  /// In en, this message translates to:
  /// **'Message requests'**
  String get pendingMessages;

  /// No description provided for @noConversationFound.
  ///
  /// In en, this message translates to:
  /// **'No conversations found'**
  String get noConversationFound;

  /// No description provided for @chatPinned.
  ///
  /// In en, this message translates to:
  /// **'Chat pinned'**
  String get chatPinned;

  /// No description provided for @chatUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Chat unpinned'**
  String get chatUnpinned;

  /// No description provided for @chatHidden.
  ///
  /// In en, this message translates to:
  /// **'Chat hidden'**
  String get chatHidden;

  /// No description provided for @chatDeleted.
  ///
  /// In en, this message translates to:
  /// **'Chat deleted'**
  String get chatDeleted;

  /// No description provided for @pinAction.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pinAction;

  /// No description provided for @unpinAction.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpinAction;

  /// No description provided for @hideAction.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @mutedNow.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get mutedNow;

  /// No description provided for @feedNotificationSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications will be added later.'**
  String get feedNotificationSoon;

  /// No description provided for @sessionExpiredRelogin.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get sessionExpiredRelogin;

  /// No description provided for @emptyNoPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get emptyNoPosts;

  /// No description provided for @emptyFollowFriends.
  ///
  /// In en, this message translates to:
  /// **'Check back later or follow more friends'**
  String get emptyFollowFriends;

  /// No description provided for @shareSoon.
  ///
  /// In en, this message translates to:
  /// **'Share will be added later.'**
  String get shareSoon;

  /// No description provided for @saveSoon.
  ///
  /// In en, this message translates to:
  /// **'Save post will be added later.'**
  String get saveSoon;

  /// No description provided for @createPostCannotPickGallery.
  ///
  /// In en, this message translates to:
  /// **'Cannot pick images from gallery'**
  String get createPostCannotPickGallery;

  /// No description provided for @createPostCannotOpenCamera.
  ///
  /// In en, this message translates to:
  /// **'Cannot open camera'**
  String get createPostCannotOpenCamera;

  /// No description provided for @createPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Create post'**
  String get createPostTitle;

  /// No description provided for @postAction.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postAction;

  /// No description provided for @captionHint.
  ///
  /// In en, this message translates to:
  /// **'Write a caption for your post...\nTip: add hashtags for better reach.'**
  String get captionHint;

  /// No description provided for @addMediaForPost.
  ///
  /// In en, this message translates to:
  /// **'Add photo/video to your post'**
  String get addMediaForPost;

  /// No description provided for @pickFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Pick from library'**
  String get pickFromLibrary;

  /// No description provided for @libraryLabel.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryLabel;

  /// No description provided for @cameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraLabel;

  /// No description provided for @friendsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get friendsSearchHint;

  /// No description provided for @cannotOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Cannot open chat: {error}'**
  String cannotOpenChat(Object error);

  /// No description provided for @placeholderLastMessage.
  ///
  /// In en, this message translates to:
  /// **'This is a placeholder for the last message.'**
  String get placeholderLastMessage;

  /// No description provided for @messageInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get messageInputHint;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// No description provided for @myLoveLabel.
  ///
  /// In en, this message translates to:
  /// **'my love'**
  String get myLoveLabel;

  /// No description provided for @searchInConversationHint.
  ///
  /// In en, this message translates to:
  /// **'Search in conversation'**
  String get searchInConversationHint;

  /// No description provided for @enterKeywordToSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter a keyword to search messages'**
  String get enterKeywordToSearch;

  /// No description provided for @noMatchingResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results found'**
  String get noMatchingResults;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @enterNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter nickname'**
  String get enterNicknameHint;

  /// No description provided for @nicknameRemoved.
  ///
  /// In en, this message translates to:
  /// **'Nickname removed for {name}'**
  String nicknameRemoved(Object name);

  /// No description provided for @nicknameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Nickname updated for {name}'**
  String nicknameUpdated(Object name);

  /// No description provided for @nicknameVisibleInChat.
  ///
  /// In en, this message translates to:
  /// **'Everyone in this chat will see this nickname for {name}.'**
  String nicknameVisibleInChat(Object name);

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get groupNameHint;

  /// No description provided for @invitedMembers.
  ///
  /// In en, this message translates to:
  /// **'Invited members'**
  String get invitedMembers;

  /// No description provided for @searchGeneric.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchGeneric;

  /// No description provided for @safetyProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get safetyProfile;

  /// No description provided for @restrictAction.
  ///
  /// In en, this message translates to:
  /// **'Restrict'**
  String get restrictAction;

  /// No description provided for @blockAccount.
  ///
  /// In en, this message translates to:
  /// **'Block account'**
  String get blockAccount;

  /// No description provided for @unblockAccount.
  ///
  /// In en, this message translates to:
  /// **'Unblock account'**
  String get unblockAccount;

  /// No description provided for @nicknameAction.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameAction;

  /// No description provided for @createGroupChat.
  ///
  /// In en, this message translates to:
  /// **'Create group chat'**
  String get createGroupChat;

  /// No description provided for @optionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsLabel;

  /// No description provided for @muteOffLabel.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get muteOffLabel;

  /// No description provided for @photosAndVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos and Videos'**
  String get photosAndVideoTitle;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get viewAll;

  /// No description provided for @blockedMediaHidden.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos are hidden because you blocked this account.'**
  String get blockedMediaHidden;

  /// No description provided for @mute10Minutes.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get mute10Minutes;

  /// No description provided for @mute30Minutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get mute30Minutes;

  /// No description provided for @mute1Hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get mute1Hour;

  /// No description provided for @mute2Hours.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get mute2Hours;

  /// No description provided for @mute12Hours.
  ///
  /// In en, this message translates to:
  /// **'12 hours'**
  String get mute12Hours;

  /// No description provided for @mute24Hours.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get mute24Hours;

  /// No description provided for @mute48Hours.
  ///
  /// In en, this message translates to:
  /// **'48 hours'**
  String get mute48Hours;

  /// No description provided for @muteConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'Mute conversation notifications'**
  String get muteConversationTitle;

  /// No description provided for @turnOnNotifications.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get turnOnNotifications;

  /// No description provided for @grantAdmin.
  ///
  /// In en, this message translates to:
  /// **'Grant admin role'**
  String get grantAdmin;

  /// No description provided for @revokeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Revoke admin role'**
  String get revokeAdmin;

  /// No description provided for @revokeAdminLocked.
  ///
  /// In en, this message translates to:
  /// **'Revoke admin role (locked)'**
  String get revokeAdminLocked;

  /// No description provided for @onlyAdminCanChangeRole.
  ///
  /// In en, this message translates to:
  /// **'Only admins can change roles'**
  String get onlyAdminCanChangeRole;

  /// No description provided for @privateMessage.
  ///
  /// In en, this message translates to:
  /// **'Private message'**
  String get privateMessage;

  /// No description provided for @thisIsYourAccount.
  ///
  /// In en, this message translates to:
  /// **'This is your account'**
  String get thisIsYourAccount;

  /// No description provided for @newGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroupTitle;

  /// No description provided for @editGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroupTitle;

  /// No description provided for @createAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createAction;

  /// No description provided for @peopleWhoCanContactYou.
  ///
  /// In en, this message translates to:
  /// **'People who can contact you'**
  String get peopleWhoCanContactYou;

  /// No description provided for @editNicknameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit nickname'**
  String get editNicknameTitle;

  /// No description provided for @groupRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Group role'**
  String get groupRoleTitle;

  /// No description provided for @memberIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Member ID'**
  String get memberIdTitle;

  /// No description provided for @adminGrantedTo.
  ///
  /// In en, this message translates to:
  /// **'Granted admin role to {name}'**
  String adminGrantedTo(Object name);

  /// No description provided for @cannotGrantAdmin.
  ///
  /// In en, this message translates to:
  /// **'Cannot grant admin role'**
  String get cannotGrantAdmin;

  /// No description provided for @adminRevokedFrom.
  ///
  /// In en, this message translates to:
  /// **'Revoked admin role from {name}'**
  String adminRevokedFrom(Object name);

  /// No description provided for @cannotRevokeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Cannot revoke admin role'**
  String get cannotRevokeAdmin;

  /// No description provided for @cannotRevokeOwnAdminTooltip.
  ///
  /// In en, this message translates to:
  /// **'You cannot revoke your own role. Grant admin to someone else first.'**
  String get cannotRevokeOwnAdminTooltip;

  /// No description provided for @cannotRevokeOwnAdmin.
  ///
  /// In en, this message translates to:
  /// **'You cannot revoke your own admin role'**
  String get cannotRevokeOwnAdmin;

  /// No description provided for @onlyAdminCanGrantOrRevokeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Only admins can grant or revoke admin role.'**
  String get onlyAdminCanGrantOrRevokeTooltip;

  /// No description provided for @noAdminPermissionForAction.
  ///
  /// In en, this message translates to:
  /// **'You do not have admin permission for this action'**
  String get noAdminPermissionForAction;

  /// No description provided for @cannotRevokeLastAdmin.
  ///
  /// In en, this message translates to:
  /// **'Cannot revoke the last admin in the group.'**
  String get cannotRevokeLastAdmin;

  /// No description provided for @youAreCurrentAdmin.
  ///
  /// In en, this message translates to:
  /// **'You are the current admin'**
  String get youAreCurrentAdmin;

  /// No description provided for @adminHasFullControl.
  ///
  /// In en, this message translates to:
  /// **'Admin has full control'**
  String get adminHasFullControl;

  /// No description provided for @canGrantOrRevokeForOthers.
  ///
  /// In en, this message translates to:
  /// **'You can grant/revoke admin role for other members.'**
  String get canGrantOrRevokeForOthers;

  /// No description provided for @youHaveAdminRights.
  ///
  /// In en, this message translates to:
  /// **'You have admin rights'**
  String get youHaveAdminRights;

  /// No description provided for @canChangeMemberRoles.
  ///
  /// In en, this message translates to:
  /// **'You can change member roles in this group.'**
  String get canChangeMemberRoles;

  /// No description provided for @noPermissionChangeRole.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to change roles'**
  String get noPermissionChangeRole;

  /// No description provided for @onlyAdminCanGrantOrRevoke.
  ///
  /// In en, this message translates to:
  /// **'Only admins are allowed to grant/revoke admin role.'**
  String get onlyAdminCanGrantOrRevoke;

  /// No description provided for @mutePriorityHint.
  ///
  /// In en, this message translates to:
  /// **'Top priority: clear all current mute states.'**
  String get mutePriorityHint;

  /// No description provided for @muteUntilTurnedOn.
  ///
  /// In en, this message translates to:
  /// **'Until turned on again'**
  String get muteUntilTurnedOn;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @reelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get reelsTitle;

  /// No description provided for @postOptionAddToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get postOptionAddToFavorites;

  /// No description provided for @postOptionAboutThisAccount.
  ///
  /// In en, this message translates to:
  /// **'About this account'**
  String get postOptionAboutThisAccount;

  /// No description provided for @postOptionHidePost.
  ///
  /// In en, this message translates to:
  /// **'Hide post'**
  String get postOptionHidePost;

  /// No description provided for @postOptionReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get postOptionReport;

  /// No description provided for @postOptionAddToFavoritesDone.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get postOptionAddToFavoritesDone;

  /// No description provided for @postOptionHidePostDone.
  ///
  /// In en, this message translates to:
  /// **'Post hidden'**
  String get postOptionHidePostDone;

  /// No description provided for @postOptionReportDone.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get postOptionReportDone;

  /// No description provided for @postOptionReportDoneWithReason.
  ///
  /// In en, this message translates to:
  /// **'Report submitted with reason: {reason}'**
  String postOptionReportDoneWithReason(Object reason);

  /// No description provided for @postReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get postReportTitle;

  /// No description provided for @postReportSelectReason.
  ///
  /// In en, this message translates to:
  /// **'Select the most relevant reason'**
  String get postReportSelectReason;

  /// No description provided for @postReportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get postReportSubmit;

  /// No description provided for @postReportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get postReportReasonSpam;

  /// No description provided for @postReportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or bullying'**
  String get postReportReasonHarassment;

  /// No description provided for @postReportReasonFalseInfo.
  ///
  /// In en, this message translates to:
  /// **'False information'**
  String get postReportReasonFalseInfo;

  /// No description provided for @postReportReasonHateSpeech.
  ///
  /// In en, this message translates to:
  /// **'Hate speech'**
  String get postReportReasonHateSpeech;

  /// No description provided for @postReportReasonViolence.
  ///
  /// In en, this message translates to:
  /// **'Violence or dangerous acts'**
  String get postReportReasonViolence;

  /// No description provided for @postReportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get postReportReasonOther;

  /// No description provided for @postOptionAllHiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'You have hidden all posts'**
  String get postOptionAllHiddenTitle;

  /// No description provided for @postOptionAllHiddenDescription.
  ///
  /// In en, this message translates to:
  /// **'Refresh to load new content or wait for other posts.'**
  String get postOptionAllHiddenDescription;

  /// No description provided for @followingStatus.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingStatus;

  /// No description provided for @yourStory.
  ///
  /// In en, this message translates to:
  /// **'Your Story'**
  String get yourStory;

  /// No description provided for @viewAllComments.
  ///
  /// In en, this message translates to:
  /// **'View all {count} comments'**
  String viewAllComments(Object count);

  /// No description provided for @likesCountText.
  ///
  /// In en, this message translates to:
  /// **'{count} likes'**
  String likesCountText(Object count);

  /// No description provided for @followAction.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followAction;

  /// No description provided for @recentSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentSearchTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
