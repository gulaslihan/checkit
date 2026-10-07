import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

/// Free tier is a single lifetime cap across every list the user creates
/// themselves (manual or AI — no distinction). Shared/invited lists never
/// count against it. See firestore.rules' `canCreateList()` for the
/// server-side enforcement this mirrors — this provider exists only to
/// gate the UI proactively (show a paywall before a write would be
/// rejected), it isn't itself a security boundary.
class SubscriptionState {
  final int createdListCount;
  final bool subscriptionActive;
  final int freeTotalListLimit;

  const SubscriptionState({
    this.createdListCount = 0,
    this.subscriptionActive = false,
    this.freeTotalListLimit = 5,
  });

  bool get canCreateList => subscriptionActive || createdListCount < freeTotalListLimit;

  int get remainingFreeLists => (freeTotalListLimit - createdListCount).clamp(0, freeTotalListLimit);
}

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final user = ref.watch(authStateProvider).value;
  return SubscriptionNotifier(uid: user?.uid);
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final String? uid;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _configSub;

  int _createdListCount = 0;
  bool _subscriptionActive = false;
  int _freeTotalListLimit = 5;

  SubscriptionNotifier({required this.uid}) : super(const SubscriptionState()) {
    if (uid == null) return;
    _userSub = FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((snap) {
      final data = snap.data();
      _createdListCount = data?['createdListCount'] as int? ?? 0;
      _subscriptionActive = data?['subscriptionActive'] as bool? ?? false;
      _emit();
    });
    // Falls back to the 5/5 default (matching firestore.rules) until/unless
    // this doc exists — see consolidated_backlog.md item 15 for the one-time
    // Firebase Console setup step that creates it.
    _configSub = FirebaseFirestore.instance.collection('config').doc('appConfig').snapshots().listen((snap) {
      _freeTotalListLimit = snap.data()?['freeTotalListLimit'] as int? ?? 5;
      _emit();
    });
  }

  void _emit() {
    state = SubscriptionState(
      createdListCount: _createdListCount,
      subscriptionActive: _subscriptionActive,
      freeTotalListLimit: _freeTotalListLimit,
    );
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _configSub?.cancel();
    super.dispose();
  }
}
