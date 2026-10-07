import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_settings.dart';
import 'auth_provider.dart';

final usersCollection = FirebaseFirestore.instance.collection('users');

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  final user = ref.watch(authStateProvider).value;
  return NotificationSettingsNotifier(uid: user?.uid, email: user?.email);
});

/// Firestore-backed (not just local) — a Cloud Function needs to read these
/// same preferences server-side to decide whether a given push should be
/// sent at all (e.g. skip "task assigned" pushes for someone who turned
/// that off).
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final String? uid;
  final String? email;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  NotificationSettingsNotifier({required this.uid, required this.email}) : super(const NotificationSettings()) {
    if (uid == null) return;
    _sub = usersCollection.doc(uid).snapshots().listen((snap) {
      final data = snap.data();
      if (data == null) {
        // First time this account has a `users` doc — seed it with defaults
        // and the email, so the Cloud Function can look this user up by email.
        usersCollection.doc(uid).set({'email': email, ...state.toMap()}, SetOptions(merge: true));
        return;
      }
      state = NotificationSettings.fromMap(data);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Applies [next] optimistically, then persists it — if the write fails,
  /// reverts the optimistic change and rethrows so the caller (wrapped in
  /// `runGuarded`) can tell the user, instead of leaving the toggle showing
  /// a preference that was never actually saved.
  Future<void> _update(NotificationSettings next) async {
    final previous = state;
    state = next;
    if (uid == null) return;
    try {
      await usersCollection.doc(uid).set({'email': email, ...next.toMap()}, SetOptions(merge: true));
    } catch (e) {
      state = previous;
      rethrow;
    }
  }

  Future<void> setItemCompleted(bool value) => _update(state.copyWith(onItemCompleted: value));
  Future<void> setItemAdded(bool value) => _update(state.copyWith(onItemAdded: value));
  Future<void> setTaskAssigned(bool value) => _update(state.copyWith(onTaskAssigned: value));
  Future<void> setLongPending(bool value) => _update(state.copyWith(onLongPending: value));
  Future<void> setLongPendingDays(int days) => _update(state.copyWith(longPendingDays: days));
  Future<void> setDueDate(bool value) => _update(state.copyWith(onDueDate: value));
  Future<void> setCompletionSoundEnabled(bool value) => _update(state.copyWith(completionSoundEnabled: value));
}
