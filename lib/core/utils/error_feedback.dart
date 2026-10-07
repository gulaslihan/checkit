import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// A caught error's category, independent of any BuildContext — the classify
/// step happens wherever the raw exception is (often a data-layer function
/// with no context), the actual message lookup happens wherever a
/// BuildContext is (always a widget, via [localizedErrorMessage]).
enum AppErrorKind {
  permissionDenied,
  unavailable,
  notFound,
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongCredential,
  emailAlreadyInUse,
  weakPassword,
  tooManyRequests,
  operationNotAllowed,
  noSession,
  cannotAddSelf,
  connectionAlreadySent,
  cannotInviteSelf,
  emailNotVerified,
  generic,
}

/// Thrown by [acceptInvite] (see invites_provider.dart) when the signed-in
/// user tries to accept before verifying their email — the Firestore rule
/// would reject the write anyway (see firestore.rules' accept-invite
/// clause), but checking client-side first gives a clear message instead of
/// a generic "permission denied" that doesn't explain what to do.
class EmailNotVerifiedException implements Exception {
  const EmailNotVerifiedException();
}

AppErrorKind classifyError(Object error) {
  if (error is EmailNotVerifiedException) return AppErrorKind.emailNotVerified;
  if (error is FirebaseAuthException) return classifyAuthError(error);
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return AppErrorKind.permissionDenied;
      case 'unavailable':
        return AppErrorKind.unavailable;
      case 'not-found':
        return AppErrorKind.notFound;
    }
  }
  return AppErrorKind.generic;
}

AppErrorKind classifyAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return AppErrorKind.invalidEmail;
    case 'user-disabled':
      return AppErrorKind.userDisabled;
    case 'user-not-found':
      return AppErrorKind.userNotFound;
    case 'wrong-password':
    case 'invalid-credential':
      return AppErrorKind.wrongCredential;
    case 'email-already-in-use':
      return AppErrorKind.emailAlreadyInUse;
    case 'weak-password':
      return AppErrorKind.weakPassword;
    case 'too-many-requests':
      return AppErrorKind.tooManyRequests;
    case 'operation-not-allowed':
      return AppErrorKind.operationNotAllowed;
    default:
      return AppErrorKind.generic;
  }
}

String localizedErrorMessage(BuildContext context, AppErrorKind kind) {
  final l10n = AppLocalizations.of(context)!;
  switch (kind) {
    case AppErrorKind.permissionDenied:
      return l10n.errorPermissionDenied;
    case AppErrorKind.unavailable:
      return l10n.errorUnavailable;
    case AppErrorKind.notFound:
      return l10n.errorNotFound;
    case AppErrorKind.invalidEmail:
      return l10n.errorInvalidEmail;
    case AppErrorKind.userDisabled:
      return l10n.errorUserDisabled;
    case AppErrorKind.userNotFound:
      return l10n.errorUserNotFound;
    case AppErrorKind.wrongCredential:
      return l10n.errorWrongCredential;
    case AppErrorKind.emailAlreadyInUse:
      return l10n.errorEmailAlreadyInUse;
    case AppErrorKind.weakPassword:
      return l10n.errorWeakPassword;
    case AppErrorKind.tooManyRequests:
      return l10n.errorTooManyRequests;
    case AppErrorKind.operationNotAllowed:
      return l10n.errorOperationNotAllowed;
    case AppErrorKind.noSession:
      return l10n.errorNoSession;
    case AppErrorKind.cannotAddSelf:
      return l10n.errorCannotAddSelf;
    case AppErrorKind.connectionAlreadySent:
      return l10n.errorConnectionAlreadySent;
    case AppErrorKind.cannotInviteSelf:
      return l10n.errorCannotInviteSelf;
    case AppErrorKind.emailNotVerified:
      return l10n.errorEmailNotVerified;
    case AppErrorKind.generic:
      return l10n.errorGeneric;
  }
}

/// Runs [action] and, if it throws, shows a friendly SnackBar instead of
/// letting the failure vanish silently — release builds show no visible
/// error otherwise, so a failed write looks exactly like a successful one.
/// Returns whether [action] completed without throwing, so callers can skip
/// any success-only follow-up (closing a sheet, showing a success message).
Future<bool> runGuarded(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedErrorMessage(context, classifyError(e)))),
      );
    }
    return false;
  }
}
