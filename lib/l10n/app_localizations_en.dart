// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CheckIt';

  @override
  String get paywallTitle => 'You\'ve used your free lists';

  @override
  String paywallBody(int limit) {
    return 'You\'ve created all $limit of your free lists. You can keep using, editing and sharing your existing lists — but creating a new one needs Premium.';
  }

  @override
  String get paywallComingSoon =>
      'Premium is coming very soon — you\'ll be able to subscribe right here once it\'s ready.';

  @override
  String get okButton => 'Got it';

  @override
  String get errorGeneric => 'Something went wrong, please try again.';

  @override
  String get errorPermissionDenied => 'You don\'t have permission to do this.';

  @override
  String get errorUnavailable =>
      'Connection problem — check your internet and try again.';

  @override
  String get errorNotFound => 'We couldn\'t find that record.';

  @override
  String get errorInvalidEmail => 'That email address doesn\'t look valid.';

  @override
  String get errorUserDisabled => 'This account has been disabled.';

  @override
  String get errorUserNotFound => 'No account found with this email.';

  @override
  String get errorWrongCredential => 'Incorrect email or password.';

  @override
  String get errorEmailAlreadyInUse =>
      'This email is already in use — try signing in instead.';

  @override
  String get errorWeakPassword => 'Password must be at least 6 characters.';

  @override
  String get errorTooManyRequests => 'Too many attempts — try again in a bit.';

  @override
  String get errorOperationNotAllowed =>
      'Email/password sign-in isn\'t enabled yet in the Firebase Console.';

  @override
  String get errorNoSession => 'No active session found.';

  @override
  String get errorCannotAddSelf => 'You can\'t add yourself.';

  @override
  String get errorConnectionAlreadySent =>
      'A connection request has already been sent to this person.';

  @override
  String get errorCannotInviteSelf => 'You can\'t invite yourself.';

  @override
  String get errorEmailNotVerified =>
      'You need to verify your email before accepting this invite. Check your inbox for the verification email sent at sign-up (look in spam if you don\'t see it).';

  @override
  String errorWithDetail(String detail) {
    return 'A problem occurred: $detail';
  }

  @override
  String get homeTooltip => 'Home';

  @override
  String get voiceInputTooltip => 'Voice input';

  @override
  String get resetPasswordEmailRequired =>
      'Enter your email first so we can send a password reset link.';

  @override
  String resetPasswordSent(String email) {
    return 'A password reset link was sent to $email.';
  }

  @override
  String get emailPasswordRequired => 'Email and password are required.';

  @override
  String get mustAcceptTerms =>
      'You must accept the Privacy Policy and Terms of Service to continue.';

  @override
  String get signInTab => 'Sign In';

  @override
  String get signUpTab => 'Sign Up';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get acceptTermsPrefix => 'I have read and accept:';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

  @override
  String get andConnector => ' and';

  @override
  String get notVerifiedYet =>
      'It doesn\'t look verified yet — click the link in your email and try again.';

  @override
  String get verificationResent => 'Verification email resent.';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String verifyEmailBody(String email) {
    return 'We sent a verification link to $email. You need to click that link to continue — this keeps sharing your lists with others secure.';
  }

  @override
  String get checkVerifiedButton => 'I\'ve verified, check now';

  @override
  String get resendEmailButton => 'Resend email';

  @override
  String get signOut => 'Sign out';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get emailInvalid => 'Enter a valid email.';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get pendingAcceptance => 'Awaiting acceptance';

  @override
  String get cancelTooltip => 'Cancel';

  @override
  String get alreadyInvited =>
      'An invite has already been sent to this person.';

  @override
  String inviteSentToEmail(String email) {
    return 'Invite sent — you\'ll be notified when $email accepts.';
  }

  @override
  String nicknameDialogTitle(String person) {
    return 'Nickname for $person';
  }

  @override
  String get nicknameHint => 'e.g. Mom';

  @override
  String shareScreenTitle(String title) {
    return 'Share \"$title\"';
  }

  @override
  String get shareInfoBanner =>
      'The person you invite needs a CheckIt account with that same email. Once they accept from their bell icon, their access opens right away.';

  @override
  String get welcomeTipsTitle => 'Welcome to CheckIt';

  @override
  String get welcomeTipAi =>
      'Tap \"New List\", then \"Create with AI\" to get a ready-made list from a short description.';

  @override
  String get welcomeTipShare =>
      'Share a list by inviting someone\'s email. They accept from the bell icon at the top, and you can assign items to each other.';

  @override
  String get welcomeTipVerify =>
      'Verify your email to accept invites. If the verification email doesn\'t arrive, check your spam folder.';

  @override
  String get invitesScreenInfoBanner =>
      'Accepting an invite adds you to someone\'s list. Connections are just shortcuts for people you invite often. You need a verified email to accept invites.';

  @override
  String get inviteByEmailLabel => 'Invite by Email';

  @override
  String get inviteButton => 'Invite';

  @override
  String get quickPicksLabel => 'Pick from your connections';

  @override
  String get ownerOnlyInviteNotice =>
      'Only the list owner can invite new people to this list.';

  @override
  String get pendingInvitesLabel => 'Pending Invites';

  @override
  String peopleWhoCanSeeList(int count) {
    return 'People who can see this list ($count)';
  }

  @override
  String ownerWithNickname(String nickname) {
    return 'Owner · Others see them as \"$nickname\"';
  }

  @override
  String get ownerLabel => 'Owner';

  @override
  String get editOwnNameTooltip => 'Change your own name';

  @override
  String get giveNicknameTooltip => 'Give a nickname';

  @override
  String get leaveListTooltip => 'Leave List';

  @override
  String get removeTooltip => 'Remove';

  @override
  String get connectionsScreenTitle => 'My Connections';

  @override
  String get connectionsInfoBanner =>
      'Connections are optional shortcuts: once connected, you can add that person to a list without typing their email. You can invite anyone by email without being connected.';

  @override
  String get addConnectionLabel => 'Add Connection';

  @override
  String get sendButton => 'Send';

  @override
  String get incomingRequestsLabel => 'Incoming Requests';

  @override
  String get rejectTooltip => 'Decline';

  @override
  String get acceptTooltip => 'Accept';

  @override
  String get sentRequestsLabel => 'Sent Requests';

  @override
  String yourConnectionsLabel(int count) {
    return 'Your Connections ($count)';
  }

  @override
  String get noConnectionsYet => 'You don\'t have any connections yet.';

  @override
  String get removeConnectionTooltip => 'Remove connection';

  @override
  String connectionRequestSent(String email) {
    return 'Connection request sent — $email';
  }

  @override
  String get removeConnectionTitle => 'Remove this connection?';

  @override
  String removeConnectionConfirm(String email) {
    return '$email will be removed from your connections. You can send a new request later if you change your mind.';
  }

  @override
  String get removeConnectionAction => 'Remove';

  @override
  String get listNotificationsToggleTitle => 'Notifications for this list';

  @override
  String get listNotificationsToggleSubtitle =>
      'New items, completions and assignments in this list notify everyone who shares it. Turn off to mute the whole list.';

  @override
  String get inviteSentTitle => 'Invite sent';

  @override
  String get connectionRequestSentTitle => 'Request sent';

  @override
  String noAccountInviteBody(String email) {
    return '$email doesn\'t use CheckIt yet. The invite is waiting for them: they need to download the app and sign up with this same email.';
  }

  @override
  String noAccountConnectionBody(String email) {
    return '$email doesn\'t use CheckIt yet. The request is waiting for them: they need to download the app and sign up with this same email.';
  }

  @override
  String get sortTooltip => 'Sort';

  @override
  String get selectItemsMenuItem => 'Select items';

  @override
  String get bulkAddMenuItem => 'Add multiple items';

  @override
  String get selectAllAction => 'Select all';

  @override
  String get deselectAllAction => 'Clear selection';

  @override
  String get selectionMoveAction => 'Move';

  @override
  String get selectionCopyAction => 'Copy';

  @override
  String get selectionNewListAction => 'New list';

  @override
  String get selectionHeadingAction => 'Sub-heading';

  @override
  String get addHeadingTitle => 'Add Sub-heading';

  @override
  String get addHeadingMenuItem => 'Add sub-heading';

  @override
  String addItemToHeadingTitle(String heading) {
    return 'Add item to \"$heading\"';
  }

  @override
  String get addItemToHeadingTooltip => 'Add an item to this heading';

  @override
  String get emptyHeadingBadge => 'empty';

  @override
  String get headingsOptionalLabel => 'Sub-headings (optional)';

  @override
  String get headingsOptionalHint =>
      'Set the headings now to group your items, and add the items later.';

  @override
  String get headingNameHint => 'Heading name';

  @override
  String get addAction => 'Add';

  @override
  String get keepScreenOnTitle => 'Keep screen on in lists';

  @override
  String get keepScreenOnSubtitle =>
      'The screen won\'t dim or lock while a list is open. Uses more battery.';

  @override
  String get removeCollaboratorTitle => 'Remove this person?';

  @override
  String removeCollaboratorConfirm(String person) {
    return '$person will lose access to this list, and any items assigned to them will become unassigned.';
  }

  @override
  String get resetListConfirmTitle => 'Reset this list?';

  @override
  String get resetListConfirmBody =>
      'Every item will be unchecked. This applies to everyone who shares this list.';

  @override
  String get confirmDeleteAccountTitle =>
      'Are you sure you want to delete your account?';

  @override
  String get confirmDeleteAccountBody =>
      'This can\'t be undone. All lists you own and their related data will be permanently deleted, and your account will be closed.';

  @override
  String get deleteMyAccountButton => 'Delete My Account';

  @override
  String get confirmPasswordTitle => 'Enter your password to continue';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get profileTitle => 'Profile';

  @override
  String get notificationSettingsButton => 'Notification Settings';

  @override
  String get signOutButton => 'Sign Out';

  @override
  String get languageSettingLabel => 'Language';

  @override
  String get systemLanguageOption => 'System Language';

  @override
  String get myInvitesTitle => 'My Invites';

  @override
  String get newInvitesLabel => 'New Invites';

  @override
  String get connectionRequestsLabel => 'Connection Requests';

  @override
  String get assignedTasksLabel => 'Tasks Assigned to You';

  @override
  String assignedInListSubtitle(String listTitle) {
    return 'Assigned to you in $listTitle';
  }

  @override
  String get wantsToConnect => 'Wants to connect';

  @override
  String invitedYouToList(String ownerEmail) {
    return '$ownerEmail invited you';
  }

  @override
  String get noPendingItems => 'Nothing pending';

  @override
  String get notificationSettingsTitle => 'Notification Settings';

  @override
  String get completionSoundToggleTitle => 'Completion sound';

  @override
  String get completionSoundToggleSubtitle =>
      'Play a short sound when you check off an item (follows your phone\'s media volume, not silent mode)';

  @override
  String get notifSettingsInfoBanner =>
      'Date/time reminders work instantly on this phone. Other settings are used when the app sends notifications through Firebase.';

  @override
  String get dueDateToggleTitle => 'Items with a due date';

  @override
  String get dueDateToggleSubtitle =>
      'Get reminded on this phone when an item\'s due date/time arrives';

  @override
  String get itemCompletedToggleTitle => 'When an item is completed';

  @override
  String get itemCompletedToggleSubtitle =>
      'Get notified when someone checks off an item on a shared list';

  @override
  String get itemAddedToggleTitle => 'When a new item is added';

  @override
  String get itemAddedToggleSubtitle =>
      'Get notified when a new item is added to a shared list';

  @override
  String get taskAssignedToggleTitle => 'When a task is assigned';

  @override
  String get taskAssignedToggleSubtitle =>
      'Get notified when an item is assigned to you';

  @override
  String get longPendingToggleTitle => 'Long-pending items';

  @override
  String get longPendingToggleSubtitle =>
      'Get reminded when an item has stayed unfinished for a while';

  @override
  String get daysThresholdLabel => 'After how many days:';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get you => 'You';

  @override
  String youWithNickname(String nickname) {
    return 'You - $nickname';
  }

  @override
  String get pendingItemsTitle => 'Pending Items';

  @override
  String get filterMine => 'Mine';

  @override
  String get filterOthers => 'With Others';

  @override
  String pendingItemSubtitle(String listTitle, String person) {
    return 'List: $listTitle · $person';
  }

  @override
  String get noPendingItemsMessage => 'No pending items';

  @override
  String get editTooltip => 'Edit';

  @override
  String get assignToTitle => 'Assign to whom?';

  @override
  String get unassignedLabel => 'Unassigned';

  @override
  String ownerPrefix(String owner) {
    return 'Owner: $owner';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String get editItemTitle => 'Edit Item';

  @override
  String get itemLabel => 'Item';

  @override
  String get noteOptionalLabel => 'Note (optional)';

  @override
  String get addDueDateButton => 'Add Date/Time';

  @override
  String get removeDueDateTooltip => 'Remove date';

  @override
  String get backPressToExit => 'Press back again to exit';

  @override
  String get myListsTitle => 'My Lists';

  @override
  String get invitesAndNotificationsTooltip => 'Invites and notifications';

  @override
  String get pendingTasksTooltip => 'Pending items assigned to people';

  @override
  String get archiveTooltip => 'Archive';

  @override
  String get profileTooltip => 'Profile';

  @override
  String get newListButton => 'New List';

  @override
  String get mineLabel => 'Mine';

  @override
  String get sharedLabel => 'Shared';

  @override
  String get allCollapsedTitle => 'Everything\'s tucked away.';

  @override
  String get allCollapsedSubtitle => 'Tap a header to see your lists again.';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get noListsYetTitle => 'You don\'t have any lists yet';

  @override
  String get noListsYetSubtitle =>
      'Create your first list with the + button below';

  @override
  String get searchListsHint => 'Search lists...';

  @override
  String get searchArchiveHint => 'Search archive...';

  @override
  String get archiveEmptyTitle => 'No lists in archive';

  @override
  String get archiveEmptySubtitle =>
      'When a list is finished, tap \"Archive\" to move it here';

  @override
  String get deleteListTitle => 'Delete list';

  @override
  String deleteListConfirm(String title) {
    return '\"$title\" will be permanently deleted. Are you sure?';
  }

  @override
  String get deleteAction => 'Delete';

  @override
  String get leaveListTitle => 'Leave list';

  @override
  String leaveListConfirm(String title) {
    return 'You\'ll leave \"$title\" and won\'t be able to access it again. Are you sure?';
  }

  @override
  String get leaveAction => 'Leave';

  @override
  String listDuplicated(String title) {
    return '\"$title\" duplicated';
  }

  @override
  String listUnarchived(String title) {
    return '\"$title\" removed from archive';
  }

  @override
  String listArchived(String title) {
    return '\"$title\" archived';
  }

  @override
  String get editListTitle => 'Edit List';

  @override
  String get closeTooltip => 'Close';

  @override
  String get listNameLabel => 'List name';

  @override
  String get checkableToggleTitle => 'Checkable list';

  @override
  String get checkableToggleSubtitle =>
      'If off, this list is only for keeping/ordering items';

  @override
  String get starRatingToggleTitle => 'Star rating';

  @override
  String get starRatingToggleSubtitle => 'Let items get a 1-5 star rating';

  @override
  String get dueDateToggleTitleGeneric => 'Due dates allowed';

  @override
  String get dueDateToggleSubtitleGeneric =>
      'Let items get a due date and be sorted by it';

  @override
  String get notesToggleTitle => 'Notes allowed';

  @override
  String get notesToggleSubtitle => 'Let items get a short note';

  @override
  String get categoryLabel => 'Category';

  @override
  String get duplicateListButton => 'Duplicate List';

  @override
  String get unarchiveButton => 'Remove from Archive';

  @override
  String get archiveButton => 'Archive';

  @override
  String get listNameRequired => 'Please enter a list name';

  @override
  String get listNameHint => 'e.g. Weekly Groceries';

  @override
  String get categoryOptionalLabel => 'Category (optional)';

  @override
  String get createListButton => 'Create List';

  @override
  String get addItemHint => 'Add a new item...';

  @override
  String get bulkImportTitle => 'Add Multiple Items';

  @override
  String get bulkImportSubtitle =>
      'Paste text you copied from your notes here — each line becomes a separate item.';

  @override
  String get bulkImportHint => 'Milk\nBread\nEggs\n...';

  @override
  String get addItemsButton => 'Add Items';

  @override
  String selectedCountLabel(int count) {
    return '$count selected';
  }

  @override
  String get newListNameTitle => 'New List Name';

  @override
  String newListFromSelectionDefaultTitle(String title) {
    return '$title (Selected)';
  }

  @override
  String get createAction => 'Create';

  @override
  String newListCreatedWithCount(String title, int count) {
    return '\"$title\" created ($count items)';
  }

  @override
  String get noOtherListsToMoveOrCopy =>
      'You don\'t have another list to move/copy to.';

  @override
  String get pickListToMoveTitle => 'Which list should it move to?';

  @override
  String get pickListToCopyTitle => 'Which list should it copy to?';

  @override
  String itemsMovedToList(int count, String title) {
    return '$count items moved to \"$title\"';
  }

  @override
  String itemsCopiedToList(int count, String title) {
    return '$count items copied to \"$title\"';
  }

  @override
  String get renameHeadingTitle => 'Rename Sub-heading';

  @override
  String get assignToHeadingMenuItem => 'Assign to Sub-heading';

  @override
  String get shareTooltip => 'Share';

  @override
  String get moreActionsTooltip => 'More actions';

  @override
  String get resetMenuItem => 'Reset';

  @override
  String get sortManualMenuItem => 'Sort manually';

  @override
  String get sortAlphaMenuItem => 'Sort alphabetically';

  @override
  String get sortNewestMenuItem => 'Newest first';

  @override
  String get sortOldestMenuItem => 'Oldest first';

  @override
  String get sortDueDateMenuItem => 'Sort by date';

  @override
  String get searchItemsHint => 'Search items...';

  @override
  String get listCompletedTitle => 'List completed 🎉';

  @override
  String get listCompletedNonOwnerBody =>
      'All items on the list are completed. The list owner can reset it for reuse, archive it, or delete it.';

  @override
  String get okAction => 'OK';

  @override
  String listCompletedOwnerBody(String title) {
    return 'All items in \"$title\" are completed. What would you like to do?';
  }

  @override
  String get keepAsIsAction => 'Keep as is';

  @override
  String itemDeletedSnackbar(String text) {
    return '\"$text\" deleted';
  }

  @override
  String get undoAction => 'Undo';

  @override
  String get completedSectionLabel => 'Completed';

  @override
  String get headingActionsTooltip => 'Sub-heading actions';

  @override
  String get renameAction => 'Rename';

  @override
  String get removeHeadingAction => 'Remove Heading';

  @override
  String get newHeadingNameHint => 'New heading name';

  @override
  String get noHeadingAction => 'No heading';

  @override
  String get noItemsYetTitle => 'No items yet';

  @override
  String get noItemsYetSubtitle =>
      'Type or use the mic below to add, or paste to bulk import';

  @override
  String get allFilterLabel => 'All';

  @override
  String get categoryGroceryShopping => 'Grocery Shopping';

  @override
  String get categoryPersonalShopping => 'Personal Shopping';

  @override
  String get categoryHousework => 'Housework';

  @override
  String get categoryDailyRoutines => 'Daily Routines';

  @override
  String get categoryHealthyLiving => 'Healthy Living';

  @override
  String get categoryWorkoutPlan => 'Workout Plan';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryPackingList => 'Packing List';

  @override
  String get categoryBusinessTrip => 'Business Trip';

  @override
  String get categoryPicnicPrep => 'Picnic Prep';

  @override
  String get categorySpecialOccasions => 'Special Occasions';

  @override
  String get categoryParty => 'Party';

  @override
  String get categoryBirthdayPrep => 'Birthday Prep';

  @override
  String get categoryGiftPlanning => 'Gift Planning';

  @override
  String get categoryBookList => 'Book List';

  @override
  String get categoryMovieList => 'Movie List';

  @override
  String get categoryKids => 'Kids';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryOther => 'Other';

  @override
  String get openSystemLanguageSettings => 'Open in System Settings';

  @override
  String get aiCreateButton => 'Create with AI';

  @override
  String get aiPromptSheetTitle => 'What kind of list do you want?';

  @override
  String get aiPromptHint =>
      'e.g. I\'m going to Rome Aug 5-12. I\'m interested in city experiences and art.';

  @override
  String get aiGenerating => 'Generating…';

  @override
  String get aiDailyLimitReached =>
      'You\'ve reached today\'s AI usage limit — try again tomorrow.';

  @override
  String get aiFreeLimitReached =>
      'You\'ve used your free lists — creating a new one needs Premium.';

  @override
  String get aiGenerationFailed =>
      'Couldn\'t generate the list, please try again.';

  @override
  String get aiItemsPreviewLabel => 'AI-suggested items';
}
