import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/connection.dart';
import '../models/invite.dart';
import 'auth_provider.dart';
import 'connections_provider.dart';
import 'invites_provider.dart';
import 'lists_provider.dart';
import 'seen_notifications_provider.dart';

class AssignedTask {
  final Checklist list;
  final ChecklistItem item;
  const AssignedTask(this.list, this.item);
}

/// Single source of truth for "things needing your attention" — both the
/// dashboard's badge count and the Davetlerim screen's sections read from
/// this, so the two can never drift out of sync with each other.
class NotificationSummary {
  final List<Invite> newInvites;
  final List<Connection> connectionRequests;
  final List<AssignedTask> assignedTasks;
  final Set<String> seenIds;

  /// True until every underlying stream (invites, connections, lists) has
  /// delivered its first snapshot — screens should show a loading state
  /// instead of "Bekleyen bir şeyiniz yok" while this is true.
  final bool isLoading;

  const NotificationSummary({
    required this.newInvites,
    required this.connectionRequests,
    required this.assignedTasks,
    required this.seenIds,
    required this.isLoading,
  });

  static String inviteKey(Invite i) => 'invite:${i.id}';
  static String connectionKey(Connection c) => 'connection:${c.id}';
  static String taskKey(AssignedTask t) => 'task:${t.list.id}:${t.item.id}';

  /// Every key currently on screen — used both to compute the unseen count
  /// and to mark everything seen when Davetlerim is opened.
  Set<String> get allKeys => {
        for (final i in newInvites) inviteKey(i),
        for (final c in connectionRequests) connectionKey(c),
        for (final t in assignedTasks) taskKey(t),
      };

  /// Dashboard badge number — like an email inbox, drops once you've opened
  /// Davetlerim and seen an item, even though it may still need action.
  int get actionableCount => allKeys.where((k) => !seenIds.contains(k)).length;

  bool get isEmpty => newInvites.isEmpty && connectionRequests.isEmpty && assignedTasks.isEmpty;
}

final notificationSummaryProvider = Provider<NotificationSummary>((ref) {
  final myEmail = ref.watch(authStateProvider).value?.email ?? '';
  final incomingAsync = ref.watch(myInvitesProvider);
  final connectionsAsync = ref.watch(myConnectionsProvider);
  final incoming = incomingAsync.value ?? const [];
  final connections = connectionsAsync.value ?? const [];
  final lists = ref.watch(listsProvider);
  final listsLoading = ref.watch(listsLoadingProvider);
  final seenIds = ref.watch(seenNotificationsProvider);

  final assignedTasks = [
    for (final list in lists)
      for (final item in list.items)
        if (!item.isDone && item.assignedTo == myEmail) AssignedTask(list, item),
  ]..sort((a, b) => b.item.createdAt.compareTo(a.item.createdAt));

  return NotificationSummary(
    newInvites: [...incoming]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    connectionRequests: connections.where((c) => !c.accepted && c.recipientEmail == myEmail).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    assignedTasks: assignedTasks,
    seenIds: seenIds,
    isLoading: incomingAsync.isLoading || connectionsAsync.isLoading || listsLoading,
  );
});
