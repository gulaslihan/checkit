import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_provider.dart';

/// Whether the dashboard's welcome-tips card should be showing. Starts hidden
/// and only turns on once the stored "dismissed" flag has been read, so a
/// returning user who already dismissed it never sees it flash on startup.
/// Stored locally per account.
class WelcomeTipsNotifier extends StateNotifier<bool> {
  final String? _uid;

  WelcomeTipsNotifier(this._uid) : super(false) {
    _load();
  }

  String get _prefsKey => 'welcome_tips_dismissed_${_uid ?? 'anon'}';

  Future<void> _load() async {
    if (_uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    state = !(prefs.getBool(_prefsKey) ?? false);
  }

  Future<void> dismiss() async {
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }
}

final welcomeTipsVisibleProvider = StateNotifierProvider<WelcomeTipsNotifier, bool>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  return WelcomeTipsNotifier(uid);
});
