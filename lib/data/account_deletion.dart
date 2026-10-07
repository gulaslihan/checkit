import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/utils/error_feedback.dart';
import '../models/checklist_item.dart';
import 'lists_provider.dart';

class AccountDeletionResult {
  final bool needsReauth;
  final AppErrorKind? errorKind;

  const AccountDeletionResult({this.needsReauth = false, this.errorKind});
}

/// Deletes everything the signed-in user owns or is party to (their lists,
/// sent/received invites, connections — and their email is scrubbed from
/// other people's `sharedWith` lists), then deletes the Auth account itself.
/// KVKK/GDPR "right to erasure".
Future<AccountDeletionResult> deleteMyAccount() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const AccountDeletionResult();
  final uid = user.uid;
  final email = user.email;

  try {
    await _deleteOwnedData(uid: uid, email: email);
  } catch (e) {
    return AccountDeletionResult(errorKind: classifyError(e));
  }

  try {
    await user.delete();
    return const AccountDeletionResult();
  } on FirebaseAuthException catch (e) {
    if (e.code == 'requires-recent-login') {
      return const AccountDeletionResult(needsReauth: true);
    }
    return AccountDeletionResult(errorKind: classifyAuthError(e));
  }
}

Future<void> _deleteOwnedData({required String uid, required String? email}) async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  final ownedLists = await firestore.collection('lists').where('ownerId', isEqualTo: uid).get();
  for (final doc in ownedLists.docs) {
    batch.delete(doc.reference);
  }

  if (email != null) {
    final sharedLists = await firestore.collection('lists').where('sharedWith', arrayContains: email).get();
    for (final doc in sharedLists.docs) {
      // Also clear any items assigned to the departing user — otherwise
      // they'd be left "assigned" to an email that's no longer a
      // collaborator (or even a real account), same as removeCollaborator
      // already does for a normal (non-deletion) removal.
      final rawItems = (doc.data()['items'] as List? ?? const [])
          .map((raw) => checklistItemFromMap(Map<String, dynamic>.from(raw as Map)))
          .toList();
      final clearedItems = [
        for (final item in rawItems)
          if (item.assignedTo == email)
            ChecklistItem(
              id: item.id,
              text: item.text,
              isDone: item.isDone,
              assignedTo: null,
              createdAt: item.createdAt,
              rating: item.rating,
              note: item.note,
              dueDate: item.dueDate,
              subheading: item.subheading,
            )
          else
            item,
      ];
      batch.update(doc.reference, {
        'sharedWith': FieldValue.arrayRemove([email]),
        'items': checklistItemsToMaps(clearedItems),
      });
    }
  }

  final sentInvites = await firestore.collection('invites').where('ownerId', isEqualTo: uid).get();
  for (final doc in sentInvites.docs) {
    batch.delete(doc.reference);
  }

  if (email != null) {
    final receivedInvites = await firestore.collection('invites').where('recipientEmail', isEqualTo: email).get();
    for (final doc in receivedInvites.docs) {
      batch.delete(doc.reference);
    }
  }

  final sentConnections = await firestore.collection('connections').where('requesterId', isEqualTo: uid).get();
  for (final doc in sentConnections.docs) {
    batch.delete(doc.reference);
  }

  if (email != null) {
    final receivedConnections =
        await firestore.collection('connections').where('recipientEmail', isEqualTo: email).get();
    for (final doc in receivedConnections.docs) {
      batch.delete(doc.reference);
    }
  }

  await batch.commit();
}

/// Firestore cleanup already happened in [deleteMyAccount] — this just
/// re-proves identity (Firebase requires a *recent* login for account
/// deletion) and finishes deleting the Auth account.
Future<AppErrorKind?> reauthenticateAndDeleteAccount(String password) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.email == null) return AppErrorKind.noSession;
  try {
    final credential = EmailAuthProvider.credential(email: user.email!, password: password);
    await user.reauthenticateWithCredential(credential);
    await user.delete();
    return null;
  } on FirebaseAuthException catch (e) {
    return classifyAuthError(e);
  } catch (e) {
    return classifyError(e);
  }
}
