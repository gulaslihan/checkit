import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'keep_screen_on_in_lists';

/// Whether the screen should stay awake while a list is open (Profile switch).
/// A per-device preference, kept locally — default off since it costs battery.
class KeepScreenOnNotifier extends StateNotifier<bool> {
  KeepScreenOnNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> set(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }
}

final keepScreenOnProvider = StateNotifierProvider<KeepScreenOnNotifier, bool>((ref) => KeepScreenOnNotifier());
