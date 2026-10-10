import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CheckIt'**
  String get appTitle;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used your free lists'**
  String get paywallTitle;

  /// No description provided for @paywallBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve created all {limit} of your free lists. You can keep using, editing and sharing your existing lists — but creating a new one needs Premium.'**
  String paywallBody(int limit);

  /// No description provided for @paywallComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Premium is coming very soon — you\'ll be able to subscribe right here once it\'s ready.'**
  String get paywallComingSoon;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get okButton;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again.'**
  String get errorGeneric;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do this.'**
  String get errorPermissionDenied;

  /// No description provided for @errorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Connection problem — check your internet and try again.'**
  String get errorUnavailable;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that record.'**
  String get errorNotFound;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email address doesn\'t look valid.'**
  String get errorInvalidEmail;

  /// No description provided for @errorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get errorUserDisabled;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get errorUserNotFound;

  /// No description provided for @errorWrongCredential.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorWrongCredential;

  /// No description provided for @errorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use — try signing in instead.'**
  String get errorEmailAlreadyInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get errorWeakPassword;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts — try again in a bit.'**
  String get errorTooManyRequests;

  /// No description provided for @errorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Email/password sign-in isn\'t enabled yet in the Firebase Console.'**
  String get errorOperationNotAllowed;

  /// No description provided for @errorNoSession.
  ///
  /// In en, this message translates to:
  /// **'No active session found.'**
  String get errorNoSession;

  /// No description provided for @errorCannotAddSelf.
  ///
  /// In en, this message translates to:
  /// **'You can\'t add yourself.'**
  String get errorCannotAddSelf;

  /// No description provided for @errorConnectionAlreadySent.
  ///
  /// In en, this message translates to:
  /// **'A connection request has already been sent to this person.'**
  String get errorConnectionAlreadySent;

  /// No description provided for @errorCannotInviteSelf.
  ///
  /// In en, this message translates to:
  /// **'You can\'t invite yourself.'**
  String get errorCannotInviteSelf;

  /// No description provided for @errorEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'You need to verify your email before accepting this invite. Check your inbox for the verification email sent at sign-up (look in spam if you don\'t see it).'**
  String get errorEmailNotVerified;

  /// No description provided for @errorWithDetail.
  ///
  /// In en, this message translates to:
  /// **'A problem occurred: {detail}'**
  String errorWithDetail(String detail);

  /// No description provided for @homeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTooltip;

  /// No description provided for @voiceInputTooltip.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get voiceInputTooltip;

  /// No description provided for @resetPasswordEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email first so we can send a password reset link.'**
  String get resetPasswordEmailRequired;

  /// No description provided for @resetPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'A password reset link was sent to {email}.'**
  String resetPasswordSent(String email);

  /// No description provided for @emailPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and password are required.'**
  String get emailPasswordRequired;

  /// No description provided for @mustAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Privacy Policy and Terms of Service to continue.'**
  String get mustAcceptTerms;

  /// No description provided for @signInTab.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInTab;

  /// No description provided for @signUpTab.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTab;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @acceptTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept:'**
  String get acceptTermsPrefix;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @andConnector.
  ///
  /// In en, this message translates to:
  /// **' and'**
  String get andConnector;

  /// No description provided for @notVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'It doesn\'t look verified yet — click the link in your email and try again.'**
  String get notVerifiedYet;

  /// No description provided for @verificationResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent.'**
  String get verificationResent;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. You need to click that link to continue — this keeps sharing your lists with others secure.'**
  String verifyEmailBody(String email);

  /// No description provided for @checkVerifiedButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified, check now'**
  String get checkVerifiedButton;

  /// No description provided for @resendEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmailButton;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

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

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get emailInvalid;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get emailHint;

  /// No description provided for @pendingAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Awaiting acceptance'**
  String get pendingAcceptance;

  /// No description provided for @cancelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelTooltip;

  /// No description provided for @alreadyInvited.
  ///
  /// In en, this message translates to:
  /// **'An invite has already been sent to this person.'**
  String get alreadyInvited;

  /// No description provided for @inviteSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Invite sent — you\'ll be notified when {email} accepts.'**
  String inviteSentToEmail(String email);

  /// No description provided for @nicknameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Nickname for {person}'**
  String nicknameDialogTitle(String person);

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mom'**
  String get nicknameHint;

  /// No description provided for @shareScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Share \"{title}\"'**
  String shareScreenTitle(String title);

  /// No description provided for @shareInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'The person you invite needs a CheckIt account with that same email. Once they accept from their bell icon, their access opens right away.'**
  String get shareInfoBanner;

  /// No description provided for @welcomeTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CheckIt'**
  String get welcomeTipsTitle;

  /// No description provided for @welcomeTipAi.
  ///
  /// In en, this message translates to:
  /// **'Tap \"New List\", then \"Create with AI\" to get a ready-made list from a short description.'**
  String get welcomeTipAi;

  /// No description provided for @welcomeTipShare.
  ///
  /// In en, this message translates to:
  /// **'Share a list by inviting someone\'s email. They accept from the bell icon at the top, and you can assign items to each other.'**
  String get welcomeTipShare;

  /// No description provided for @welcomeTipVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify your email to accept invites. If the verification email doesn\'t arrive, check your spam folder.'**
  String get welcomeTipVerify;

  /// No description provided for @invitesScreenInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Accepting an invite adds you to someone\'s list. Connections are just shortcuts for people you invite often. You need a verified email to accept invites.'**
  String get invitesScreenInfoBanner;

  /// No description provided for @inviteByEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite by Email'**
  String get inviteByEmailLabel;

  /// No description provided for @inviteButton.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get inviteButton;

  /// No description provided for @quickPicksLabel.
  ///
  /// In en, this message translates to:
  /// **'Pick from your connections'**
  String get quickPicksLabel;

  /// No description provided for @ownerOnlyInviteNotice.
  ///
  /// In en, this message translates to:
  /// **'Only the list owner can invite new people to this list.'**
  String get ownerOnlyInviteNotice;

  /// No description provided for @pendingInvitesLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending Invites'**
  String get pendingInvitesLabel;

  /// No description provided for @peopleWhoCanSeeList.
  ///
  /// In en, this message translates to:
  /// **'People who can see this list ({count})'**
  String peopleWhoCanSeeList(int count);

  /// No description provided for @ownerWithNickname.
  ///
  /// In en, this message translates to:
  /// **'Owner · Others see them as \"{nickname}\"'**
  String ownerWithNickname(String nickname);

  /// No description provided for @ownerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get ownerLabel;

  /// No description provided for @editOwnNameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change your own name'**
  String get editOwnNameTooltip;

  /// No description provided for @giveNicknameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Give a nickname'**
  String get giveNicknameTooltip;

  /// No description provided for @leaveListTooltip.
  ///
  /// In en, this message translates to:
  /// **'Leave List'**
  String get leaveListTooltip;

  /// No description provided for @removeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeTooltip;

  /// No description provided for @connectionsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Connections'**
  String get connectionsScreenTitle;

  /// No description provided for @connectionsInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Connections are optional shortcuts: once connected, you can add that person to a list without typing their email. You can invite anyone by email without being connected.'**
  String get connectionsInfoBanner;

  /// No description provided for @addConnectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Connection'**
  String get addConnectionLabel;

  /// No description provided for @sendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendButton;

  /// No description provided for @incomingRequestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Incoming Requests'**
  String get incomingRequestsLabel;

  /// No description provided for @rejectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get rejectTooltip;

  /// No description provided for @acceptTooltip.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptTooltip;

  /// No description provided for @sentRequestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sent Requests'**
  String get sentRequestsLabel;

  /// No description provided for @yourConnectionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Connections ({count})'**
  String yourConnectionsLabel(int count);

  /// No description provided for @noConnectionsYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any connections yet.'**
  String get noConnectionsYet;

  /// No description provided for @removeConnectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove connection'**
  String get removeConnectionTooltip;

  /// No description provided for @connectionRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Connection request sent — {email}'**
  String connectionRequestSent(String email);

  /// No description provided for @removeConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this connection?'**
  String get removeConnectionTitle;

  /// No description provided for @removeConnectionConfirm.
  ///
  /// In en, this message translates to:
  /// **'{email} will be removed from your connections. You can send a new request later if you change your mind.'**
  String removeConnectionConfirm(String email);

  /// No description provided for @removeConnectionAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeConnectionAction;

  /// No description provided for @listNotificationsToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications for this list'**
  String get listNotificationsToggleTitle;

  /// No description provided for @listNotificationsToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New items, completions and assignments in this list notify everyone who shares it. Turn off to mute the whole list.'**
  String get listNotificationsToggleSubtitle;

  /// No description provided for @removeCollaboratorTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this person?'**
  String get removeCollaboratorTitle;

  /// No description provided for @removeCollaboratorConfirm.
  ///
  /// In en, this message translates to:
  /// **'{person} will lose access to this list, and any items assigned to them will become unassigned.'**
  String removeCollaboratorConfirm(String person);

  /// No description provided for @resetListConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset this list?'**
  String get resetListConfirmTitle;

  /// No description provided for @resetListConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Every item will be unchecked. This applies to everyone who shares this list.'**
  String get resetListConfirmBody;

  /// No description provided for @confirmDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get confirmDeleteAccountTitle;

  /// No description provided for @confirmDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone. All lists you own and their related data will be permanently deleted, and your account will be closed.'**
  String get confirmDeleteAccountBody;

  /// No description provided for @deleteMyAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccountButton;

  /// No description provided for @confirmPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to continue'**
  String get confirmPasswordTitle;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @notificationSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsButton;

  /// No description provided for @signOutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutButton;

  /// No description provided for @languageSettingLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingLabel;

  /// No description provided for @systemLanguageOption.
  ///
  /// In en, this message translates to:
  /// **'System Language'**
  String get systemLanguageOption;

  /// No description provided for @myInvitesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Invites'**
  String get myInvitesTitle;

  /// No description provided for @newInvitesLabel.
  ///
  /// In en, this message translates to:
  /// **'New Invites'**
  String get newInvitesLabel;

  /// No description provided for @connectionRequestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Connection Requests'**
  String get connectionRequestsLabel;

  /// No description provided for @assignedTasksLabel.
  ///
  /// In en, this message translates to:
  /// **'Tasks Assigned to You'**
  String get assignedTasksLabel;

  /// No description provided for @assignedInListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assigned to you in {listTitle}'**
  String assignedInListSubtitle(String listTitle);

  /// No description provided for @wantsToConnect.
  ///
  /// In en, this message translates to:
  /// **'Wants to connect'**
  String get wantsToConnect;

  /// No description provided for @invitedYouToList.
  ///
  /// In en, this message translates to:
  /// **'{ownerEmail} invited you'**
  String invitedYouToList(String ownerEmail);

  /// No description provided for @noPendingItems.
  ///
  /// In en, this message translates to:
  /// **'Nothing pending'**
  String get noPendingItems;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @completionSoundToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Completion sound'**
  String get completionSoundToggleTitle;

  /// No description provided for @completionSoundToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play a short sound when you check off an item (follows your phone\'s media volume, not silent mode)'**
  String get completionSoundToggleSubtitle;

  /// No description provided for @notifSettingsInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Date/time reminders work instantly on this phone. Other settings are used when the app sends notifications through Firebase.'**
  String get notifSettingsInfoBanner;

  /// No description provided for @dueDateToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Items with a due date'**
  String get dueDateToggleTitle;

  /// No description provided for @dueDateToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminded on this phone when an item\'s due date/time arrives'**
  String get dueDateToggleSubtitle;

  /// No description provided for @itemCompletedToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'When an item is completed'**
  String get itemCompletedToggleTitle;

  /// No description provided for @itemCompletedToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone checks off an item on a shared list'**
  String get itemCompletedToggleSubtitle;

  /// No description provided for @itemAddedToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'When a new item is added'**
  String get itemAddedToggleTitle;

  /// No description provided for @itemAddedToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a new item is added to a shared list'**
  String get itemAddedToggleSubtitle;

  /// No description provided for @taskAssignedToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'When a task is assigned'**
  String get taskAssignedToggleTitle;

  /// No description provided for @taskAssignedToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when an item is assigned to you'**
  String get taskAssignedToggleSubtitle;

  /// No description provided for @longPendingToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Long-pending items'**
  String get longPendingToggleTitle;

  /// No description provided for @longPendingToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminded when an item has stayed unfinished for a while'**
  String get longPendingToggleSubtitle;

  /// No description provided for @daysThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'After how many days:'**
  String get daysThresholdLabel;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @youWithNickname.
  ///
  /// In en, this message translates to:
  /// **'You - {nickname}'**
  String youWithNickname(String nickname);

  /// No description provided for @pendingItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Items'**
  String get pendingItemsTitle;

  /// No description provided for @filterMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get filterMine;

  /// No description provided for @filterOthers.
  ///
  /// In en, this message translates to:
  /// **'With Others'**
  String get filterOthers;

  /// No description provided for @pendingItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List: {listTitle} · {person}'**
  String pendingItemSubtitle(String listTitle, String person);

  /// No description provided for @noPendingItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'No pending items'**
  String get noPendingItemsMessage;

  /// No description provided for @editTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTooltip;

  /// No description provided for @assignToTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign to whom?'**
  String get assignToTitle;

  /// No description provided for @unassignedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassignedLabel;

  /// No description provided for @ownerPrefix.
  ///
  /// In en, this message translates to:
  /// **'Owner: {owner}'**
  String ownerPrefix(String owner);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @editItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItemTitle;

  /// No description provided for @itemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get itemLabel;

  /// No description provided for @noteOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptionalLabel;

  /// No description provided for @addDueDateButton.
  ///
  /// In en, this message translates to:
  /// **'Add Date/Time'**
  String get addDueDateButton;

  /// No description provided for @removeDueDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove date'**
  String get removeDueDateTooltip;

  /// No description provided for @backPressToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get backPressToExit;

  /// No description provided for @myListsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Lists'**
  String get myListsTitle;

  /// No description provided for @invitesAndNotificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Invites and notifications'**
  String get invitesAndNotificationsTooltip;

  /// No description provided for @pendingTasksTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pending items assigned to people'**
  String get pendingTasksTooltip;

  /// No description provided for @archiveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveTooltip;

  /// No description provided for @profileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTooltip;

  /// No description provided for @newListButton.
  ///
  /// In en, this message translates to:
  /// **'New List'**
  String get newListButton;

  /// No description provided for @mineLabel.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mineLabel;

  /// No description provided for @sharedLabel.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get sharedLabel;

  /// No description provided for @allCollapsedTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything\'s tucked away.'**
  String get allCollapsedTitle;

  /// No description provided for @allCollapsedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap a header to see your lists again.'**
  String get allCollapsedSubtitle;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noListsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any lists yet'**
  String get noListsYetTitle;

  /// No description provided for @noListsYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first list with the + button below'**
  String get noListsYetSubtitle;

  /// No description provided for @searchListsHint.
  ///
  /// In en, this message translates to:
  /// **'Search lists...'**
  String get searchListsHint;

  /// No description provided for @searchArchiveHint.
  ///
  /// In en, this message translates to:
  /// **'Search archive...'**
  String get searchArchiveHint;

  /// No description provided for @archiveEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No lists in archive'**
  String get archiveEmptyTitle;

  /// No description provided for @archiveEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'When a list is finished, tap \"Archive\" to move it here'**
  String get archiveEmptySubtitle;

  /// No description provided for @deleteListTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get deleteListTitle;

  /// No description provided for @deleteListConfirm.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be permanently deleted. Are you sure?'**
  String deleteListConfirm(String title);

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @leaveListTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave list'**
  String get leaveListTitle;

  /// No description provided for @leaveListConfirm.
  ///
  /// In en, this message translates to:
  /// **'You\'ll leave \"{title}\" and won\'t be able to access it again. Are you sure?'**
  String leaveListConfirm(String title);

  /// No description provided for @leaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveAction;

  /// No description provided for @listDuplicated.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" duplicated'**
  String listDuplicated(String title);

  /// No description provided for @listUnarchived.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" removed from archive'**
  String listUnarchived(String title);

  /// No description provided for @listArchived.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" archived'**
  String listArchived(String title);

  /// No description provided for @editListTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit List'**
  String get editListTitle;

  /// No description provided for @closeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTooltip;

  /// No description provided for @listNameLabel.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listNameLabel;

  /// No description provided for @checkableToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkable list'**
  String get checkableToggleTitle;

  /// No description provided for @checkableToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If off, this list is only for keeping/ordering items'**
  String get checkableToggleSubtitle;

  /// No description provided for @starRatingToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Star rating'**
  String get starRatingToggleTitle;

  /// No description provided for @starRatingToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let items get a 1-5 star rating'**
  String get starRatingToggleSubtitle;

  /// No description provided for @dueDateToggleTitleGeneric.
  ///
  /// In en, this message translates to:
  /// **'Due dates allowed'**
  String get dueDateToggleTitleGeneric;

  /// No description provided for @dueDateToggleSubtitleGeneric.
  ///
  /// In en, this message translates to:
  /// **'Let items get a due date and be sorted by it'**
  String get dueDateToggleSubtitleGeneric;

  /// No description provided for @notesToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes allowed'**
  String get notesToggleTitle;

  /// No description provided for @notesToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let items get a short note'**
  String get notesToggleSubtitle;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @duplicateListButton.
  ///
  /// In en, this message translates to:
  /// **'Duplicate List'**
  String get duplicateListButton;

  /// No description provided for @unarchiveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove from Archive'**
  String get unarchiveButton;

  /// No description provided for @archiveButton.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveButton;

  /// No description provided for @listNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a list name'**
  String get listNameRequired;

  /// No description provided for @listNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Weekly Groceries'**
  String get listNameHint;

  /// No description provided for @categoryOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get categoryOptionalLabel;

  /// No description provided for @createListButton.
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get createListButton;

  /// No description provided for @addItemHint.
  ///
  /// In en, this message translates to:
  /// **'Add a new item...'**
  String get addItemHint;

  /// No description provided for @bulkImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste to Bulk Add'**
  String get bulkImportTitle;

  /// No description provided for @bulkImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste text you copied from your notes here — each line becomes a separate item.'**
  String get bulkImportSubtitle;

  /// No description provided for @bulkImportHint.
  ///
  /// In en, this message translates to:
  /// **'Milk\nBread\nEggs\n...'**
  String get bulkImportHint;

  /// No description provided for @addItemsButton.
  ///
  /// In en, this message translates to:
  /// **'Add Items'**
  String get addItemsButton;

  /// No description provided for @selectedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCountLabel(int count);

  /// No description provided for @newListNameTitle.
  ///
  /// In en, this message translates to:
  /// **'New List Name'**
  String get newListNameTitle;

  /// No description provided for @newListFromSelectionDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} (Selected)'**
  String newListFromSelectionDefaultTitle(String title);

  /// No description provided for @createAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createAction;

  /// No description provided for @newListCreatedWithCount.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" created ({count} items)'**
  String newListCreatedWithCount(String title, int count);

  /// No description provided for @noOtherListsToMoveOrCopy.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have another list to move/copy to.'**
  String get noOtherListsToMoveOrCopy;

  /// No description provided for @pickListToMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Which list should it move to?'**
  String get pickListToMoveTitle;

  /// No description provided for @pickListToCopyTitle.
  ///
  /// In en, this message translates to:
  /// **'Which list should it copy to?'**
  String get pickListToCopyTitle;

  /// No description provided for @itemsMovedToList.
  ///
  /// In en, this message translates to:
  /// **'{count} items moved to \"{title}\"'**
  String itemsMovedToList(int count, String title);

  /// No description provided for @itemsCopiedToList.
  ///
  /// In en, this message translates to:
  /// **'{count} items copied to \"{title}\"'**
  String itemsCopiedToList(int count, String title);

  /// No description provided for @renameHeadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Sub-heading'**
  String get renameHeadingTitle;

  /// No description provided for @selectedItemsMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'With selected items'**
  String get selectedItemsMenuTooltip;

  /// No description provided for @createNewListMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Create New List'**
  String get createNewListMenuItem;

  /// No description provided for @moveToOtherListMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Move to Another List'**
  String get moveToOtherListMenuItem;

  /// No description provided for @copyToOtherListMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Copy to Another List'**
  String get copyToOtherListMenuItem;

  /// No description provided for @assignToHeadingMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Assign to Sub-heading'**
  String get assignToHeadingMenuItem;

  /// No description provided for @shareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareTooltip;

  /// No description provided for @moreActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActionsTooltip;

  /// No description provided for @resetMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetMenuItem;

  /// No description provided for @sortManualMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Sort manually'**
  String get sortManualMenuItem;

  /// No description provided for @sortAlphaMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Sort alphabetically'**
  String get sortAlphaMenuItem;

  /// No description provided for @sortNewestMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewestMenuItem;

  /// No description provided for @sortOldestMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldestMenuItem;

  /// No description provided for @sortDueDateMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Sort by date'**
  String get sortDueDateMenuItem;

  /// No description provided for @createListFromItemsMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Create new list from items'**
  String get createListFromItemsMenuItem;

  /// No description provided for @pasteToAddMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Paste to add'**
  String get pasteToAddMenuItem;

  /// No description provided for @searchItemsHint.
  ///
  /// In en, this message translates to:
  /// **'Search items...'**
  String get searchItemsHint;

  /// No description provided for @listCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'List completed 🎉'**
  String get listCompletedTitle;

  /// No description provided for @listCompletedNonOwnerBody.
  ///
  /// In en, this message translates to:
  /// **'All items on the list are completed. The list owner can reset it for reuse, archive it, or delete it.'**
  String get listCompletedNonOwnerBody;

  /// No description provided for @okAction.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okAction;

  /// No description provided for @listCompletedOwnerBody.
  ///
  /// In en, this message translates to:
  /// **'All items in \"{title}\" are completed. What would you like to do?'**
  String listCompletedOwnerBody(String title);

  /// No description provided for @keepAsIsAction.
  ///
  /// In en, this message translates to:
  /// **'Keep as is'**
  String get keepAsIsAction;

  /// No description provided for @itemDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'\"{text}\" deleted'**
  String itemDeletedSnackbar(String text);

  /// No description provided for @undoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// No description provided for @completedSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedSectionLabel;

  /// No description provided for @headingActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sub-heading actions'**
  String get headingActionsTooltip;

  /// No description provided for @renameAction.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameAction;

  /// No description provided for @removeHeadingAction.
  ///
  /// In en, this message translates to:
  /// **'Remove Heading'**
  String get removeHeadingAction;

  /// No description provided for @newHeadingNameHint.
  ///
  /// In en, this message translates to:
  /// **'New heading name'**
  String get newHeadingNameHint;

  /// No description provided for @noHeadingAction.
  ///
  /// In en, this message translates to:
  /// **'No heading'**
  String get noHeadingAction;

  /// No description provided for @noItemsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsYetTitle;

  /// No description provided for @noItemsYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type or use the mic below to add, or paste to bulk import'**
  String get noItemsYetSubtitle;

  /// No description provided for @allFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilterLabel;

  /// No description provided for @categoryGroceryShopping.
  ///
  /// In en, this message translates to:
  /// **'Grocery Shopping'**
  String get categoryGroceryShopping;

  /// No description provided for @categoryPersonalShopping.
  ///
  /// In en, this message translates to:
  /// **'Personal Shopping'**
  String get categoryPersonalShopping;

  /// No description provided for @categoryHousework.
  ///
  /// In en, this message translates to:
  /// **'Housework'**
  String get categoryHousework;

  /// No description provided for @categoryDailyRoutines.
  ///
  /// In en, this message translates to:
  /// **'Daily Routines'**
  String get categoryDailyRoutines;

  /// No description provided for @categoryHealthyLiving.
  ///
  /// In en, this message translates to:
  /// **'Healthy Living'**
  String get categoryHealthyLiving;

  /// No description provided for @categoryWorkoutPlan.
  ///
  /// In en, this message translates to:
  /// **'Workout Plan'**
  String get categoryWorkoutPlan;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryPackingList.
  ///
  /// In en, this message translates to:
  /// **'Packing List'**
  String get categoryPackingList;

  /// No description provided for @categoryBusinessTrip.
  ///
  /// In en, this message translates to:
  /// **'Business Trip'**
  String get categoryBusinessTrip;

  /// No description provided for @categoryPicnicPrep.
  ///
  /// In en, this message translates to:
  /// **'Picnic Prep'**
  String get categoryPicnicPrep;

  /// No description provided for @categorySpecialOccasions.
  ///
  /// In en, this message translates to:
  /// **'Special Occasions'**
  String get categorySpecialOccasions;

  /// No description provided for @categoryParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get categoryParty;

  /// No description provided for @categoryBirthdayPrep.
  ///
  /// In en, this message translates to:
  /// **'Birthday Prep'**
  String get categoryBirthdayPrep;

  /// No description provided for @categoryGiftPlanning.
  ///
  /// In en, this message translates to:
  /// **'Gift Planning'**
  String get categoryGiftPlanning;

  /// No description provided for @categoryBookList.
  ///
  /// In en, this message translates to:
  /// **'Book List'**
  String get categoryBookList;

  /// No description provided for @categoryMovieList.
  ///
  /// In en, this message translates to:
  /// **'Movie List'**
  String get categoryMovieList;

  /// No description provided for @categoryKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get categoryKids;

  /// No description provided for @categoryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get categoryWork;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @openSystemLanguageSettings.
  ///
  /// In en, this message translates to:
  /// **'Open in System Settings'**
  String get openSystemLanguageSettings;

  /// No description provided for @aiCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create with AI'**
  String get aiCreateButton;

  /// No description provided for @aiPromptSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'What kind of list do you want?'**
  String get aiPromptSheetTitle;

  /// No description provided for @aiPromptHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. I\'m going to Rome Aug 5-12. I\'m interested in city experiences and art.'**
  String get aiPromptHint;

  /// No description provided for @aiGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get aiGenerating;

  /// No description provided for @aiDailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s AI usage limit — try again tomorrow.'**
  String get aiDailyLimitReached;

  /// No description provided for @aiFreeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used your free lists — creating a new one needs Premium.'**
  String get aiFreeLimitReached;

  /// No description provided for @aiGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t generate the list, please try again.'**
  String get aiGenerationFailed;

  /// No description provided for @aiItemsPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'AI-suggested items'**
  String get aiItemsPreviewLabel;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
