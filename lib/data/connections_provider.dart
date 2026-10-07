import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/error_feedback.dart';
import '../models/connection.dart';
import 'auth_provider.dart';

final _connectionsCollection = FirebaseFirestore.instance.collection('connections');

Connection _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  return Connection(
    id: doc.id,
    requesterId: data['requesterId'] as String,
    requesterEmail: data['requesterEmail'] as String? ?? '',
    recipientEmail: data['recipientEmail'] as String,
    accepted: (data['status'] as String?) == 'accepted',
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

/// Every connection you're party to — sent, received, pending or accepted.
final myConnectionsProvider = StreamProvider<List<Connection>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);

  final sent = _connectionsCollection.where('requesterId', isEqualTo: user.uid).snapshots();
  final received = user.email == null
      ? null
      : _connectionsCollection.where('recipientEmail', isEqualTo: user.email).snapshots();

  final controller = StreamController<List<Connection>>();
  List<Connection> sentList = [];
  List<Connection> receivedList = [];
  void emit() {
    final merged = <String, Connection>{};
    for (final c in sentList) {
      merged[c.id] = c;
    }
    for (final c in receivedList) {
      merged[c.id] = c;
    }
    controller.add(merged.values.toList());
  }

  final subs = <StreamSubscription>[
    sent.listen((snap) {
      sentList = snap.docs.map(_fromDoc).toList();
      emit();
    }),
    if (received != null)
      received.listen((snap) {
        receivedList = snap.docs.map(_fromDoc).toList();
        emit();
      }),
  ];

  ref.onDispose(() {
    for (final s in subs) {
      s.cancel();
    }
    controller.close();
  });

  return controller.stream;
});

class ConnectionsNotifier {
  Future<AppErrorKind?> sendRequest(String recipientEmail) async {
    final email = recipientEmail.trim().toLowerCase();
    if (email.isEmpty) return null;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    if (email == user.email?.toLowerCase()) return AppErrorKind.cannotAddSelf;

    final existingAsSender = await _connectionsCollection
        .where('requesterId', isEqualTo: user.uid)
        .where('recipientEmail', isEqualTo: email)
        .limit(1)
        .get();
    if (existingAsSender.docs.isNotEmpty) return AppErrorKind.connectionAlreadySent;

    await _connectionsCollection.add({
      'requesterId': user.uid,
      'requesterEmail': user.email,
      'recipientEmail': email,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
    return null;
  }

  Future<void> accept(String connectionId) {
    return _connectionsCollection.doc(connectionId).update({'status': 'accepted'});
  }

  Future<void> remove(String connectionId) {
    return _connectionsCollection.doc(connectionId).delete();
  }
}

final connectionsNotifierProvider = Provider((ref) => ConnectionsNotifier());
