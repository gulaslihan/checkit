import 'package:flutter/material.dart';

import '../features/invites/my_invites_screen.dart';
import '../features/list_detail/list_detail_screen.dart';

/// Lets FCM/local-notification tap handlers push a route without a
/// BuildContext of their own — assigned to MaterialApp.navigatorKey.
final navigatorKey = GlobalKey<NavigatorState>();

/// Routes a tapped push notification's `data` payload (see
/// functions/index.js) to the relevant screen. Invites don't grant list
/// access until accepted, so they open "Davetlerim" instead of the list.
void handleNotificationTapData(Map<String, dynamic> data) {
  final navigator = navigatorKey.currentState;
  if (navigator == null) return;

  final type = data['type'] as String?;
  final listId = data['listId'] as String?;

  if (type == 'invite' || type == 'connection_request') {
    navigator.push(MaterialPageRoute(builder: (_) => const MyInvitesScreen()));
    return;
  }
  if (listId != null) {
    navigator.push(MaterialPageRoute(builder: (_) => ListDetailScreen(listId: listId)));
  }
}
