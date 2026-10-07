import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/error_feedback.dart';
import '../models/invite.dart';
import 'auth_provider.dart';

final _invitesCollection = FirebaseFirestore.instance.collection('invites');

/// Deterministic doc id (list + recipient) instead of a random auto-id —
/// lets the `lists` security rule prove a genuine invite exists (via
/// `exists()` on this exact path) when the recipient grants themselves
/// access on accept, without needing a server-side function.
String _inviteDocId(String listId, String recipientEmail) => '${listId}__$recipientEmail';

Invite _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  return Invite(
    id: doc.id,
    listId: data['listId'] as String,
    listTitle: data['listTitle'] as String? ?? '',
    ownerId: data['ownerId'] as String,
    ownerEmail: data['ownerEmail'] as String? ?? '',
    recipientEmail: data['recipientEmail'] as String,
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

/// Invites *sent* for a given list — shown to the owner in ShareScreen.
/// Filters by ownerId too (not just listId): Firestore's security rules
/// can only allow a *query* (as opposed to a single-doc read) when the
/// query's own filters are provably a subset of what the rule permits —
/// listId alone doesn't tie back to request.auth, so the rule engine
/// rejected it with permission-denied even though every matching document
/// did belong to the current owner.
final sentInvitesProvider = StreamProvider.family<List<Invite>, String>((ref, listId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return _invitesCollection
      .where('listId', isEqualTo: listId)
      .where('ownerId', isEqualTo: user.uid)
      .snapshots()
      .map((snap) => snap.docs.map(_fromDoc).toList());
});

/// Invites *received* by the signed-in user's email, across all lists —
/// each one just needs an accept/decline, there's no further step.
final myInvitesProvider = StreamProvider<List<Invite>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user?.email == null) return Stream.value(const []);
  return _invitesCollection
      .where('recipientEmail', isEqualTo: user!.email)
      .snapshots()
      .map((snap) => snap.docs.map(_fromDoc).toList());
});

class InvitesNotifier {
  final _lists = FirebaseFirestore.instance.collection('lists');

  Future<AppErrorKind?> sendInvite({required String listId, required String listTitle, required String recipientEmail}) async {
    final email = recipientEmail.trim().toLowerCase();
    if (email.isEmpty) return null;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    if (email == user.email?.toLowerCase()) {
      return AppErrorKind.cannotInviteSelf;
    }

    // No separate "does it already exist" read: the doc id is deterministic
    // (list + recipient), so re-inviting the same person just overwrites
    // their existing invite with a fresh timestamp — harmless, and avoids a
    // Firestore quirk where reading a *nonexistent* doc whose security rule
    // touches `resource.data` fails with permission-denied instead of just
    // reporting "not found". (The UI-level "already invited" check lives in
    // ShareScreen, using the invites it already has loaded.)
    final docId = _inviteDocId(listId, email);
    await _invitesCollection.doc(docId).set({
      'listId': listId,
      'listTitle': listTitle,
      'ownerId': user.uid,
      'ownerEmail': user.email,
      'recipientEmail': email,
      'createdAt': Timestamp.now(),
    });
    return null;
  }

  /// Recipient accepts — grants real access and clears the invite in one
  /// atomic batch. No separate owner confirmation step: a genuine invite
  /// (proven via the deterministic doc id) is enough.
  ///
  /// The security rule for this write also requires a verified email (see
  /// firestore.rules) — checked here first too, so an unverified user gets
  /// a clear message instead of a generic "permission denied" once the
  /// write itself is rejected.
  Future<void> acceptInvite(Invite invite) async {
    if (FirebaseAuth.instance.currentUser?.emailVerified != true) {
      throw const EmailNotVerifiedException();
    }
    final batch = FirebaseFirestore.instance.batch();
    batch.update(_lists.doc(invite.listId), {
      'sharedWith': FieldValue.arrayUnion([invite.recipientEmail]),
    });
    batch.delete(_invitesCollection.doc(invite.id));
    await batch.commit();
  }

  /// Recipient declines, or owner cancels — either way the invite just goes away.
  Future<void> deleteInvite(String inviteId) {
    return _invitesCollection.doc(inviteId).delete();
  }
}

final invitesNotifierProvider = Provider((ref) => InvitesNotifier());
