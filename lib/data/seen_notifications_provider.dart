import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_provider.dart';

/// Tracks which notification "keys" (see `NotificationSummary`'s key
/// helpers) the signed-in user has already seen by opening Davetlerim —
/// once seen, an item stops contributing to the dashboard badge count even
/// though it's still outstanding, the way an email inbox's unread count
/// works. Persisted locally per-account so it survives app restarts.
class SeenNotificationsNotifier extends StateNotifier<Set<String>> {
  final String? _uid;

  SeenNotificationsNotifier(this._uid) : super(const {}) {
    _load();
  }

  String get _prefsKey => 'seen_notifications_${_uid ?? 'anon'}';

  Future<void> _load() async {
    if (_uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_prefsKey) ?? const []).toSet();
  }

  Future<void> markSeen(Iterable<String> keys) async {
    if (_uid == null) return;
    final next = {...state, ...keys};
    if (next.length == state.length) return; // nothing new
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, next.toList());
  }
}

final seenNotificationsProvider = StateNotifierProvider<SeenNotificationsNotifier, Set<String>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  return SeenNotificationsNotifier(uid);
});
