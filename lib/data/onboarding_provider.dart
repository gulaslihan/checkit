import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_provider.dart';

/// Whether this account has already been through (or skipped) the first-run
/// intro. `null` until the stored flag has been read, so callers don't flash
/// the intro at someone who already dismissed it. Kept locally per account.
class OnboardingNotifier extends StateNotifier<bool?> {
  final String? _uid;

  OnboardingNotifier(this._uid) : super(null) {
    _load();
  }

  String get _prefsKey => 'onboarding_done_${_uid ?? 'anon'}';

  Future<void> _load() async {
    if (_uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> markDone() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }
}

final onboardingDoneProvider = StateNotifierProvider<OnboardingNotifier, bool?>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  return OnboardingNotifier(uid);
});
