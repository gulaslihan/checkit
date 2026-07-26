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

  const NotificationSummary({
    required this.newInvites,
    required this.connectionRequests,
    required this.assignedTasks,
    required this.seenIds,
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
  final incoming = ref.watch(myInvitesProvider).value ?? const [];
  final connections = ref.watch(myConnectionsProvider).value ?? const [];
  final lists = ref.watch(listsProvider);
  final seenIds = ref.watch(seenNotificationsProvider);

  return NotificationSummary(
    newInvites: incoming,
    connectionRequests: connections.where((c) => !c.accepted && c.recipientEmail == myEmail).toList(),
    assignedTasks: [
      for (final list in lists)
        for (final item in list.items)
          if (!item.isDone && item.assignedTo == myEmail) AssignedTask(list, item),
    ],
    seenIds: seenIds,
  );
});
