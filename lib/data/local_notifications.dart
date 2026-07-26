import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_navigation.dart';

final _plugin = FlutterLocalNotificationsPlugin();

/// Call once before runApp. Hardcodes Europe/Istanbul rather than pulling in
/// a device-timezone-detection package — fine while the app is Turkish-only
/// (see the P3 decision to defer multi-language/multi-region support).
Future<void> initializeLocalNotifications() async {
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  await _plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (response) {
      final payload = response.payload;
      if (payload == null || payload.isEmpty) return;
      handleNotificationTapData(jsonDecode(payload) as Map<String, dynamic>);
    },
  );
}

Future<void> requestLocalNotificationPermission() async {
  await _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  await _plugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}

/// Notification ids are ints, item ids are strings — derive a stable one.
int notificationIdForItem(String itemId) => itemId.hashCode & 0x7fffffff;

Future<void> scheduleDueDateReminder({
  required String itemId,
  required String listTitle,
  required String itemText,
  required DateTime dueDate,
}) async {
  if (dueDate.isBefore(DateTime.now())) return;
  await _plugin.zonedSchedule(
    notificationIdForItem(itemId),
    listTitle,
    itemText,
    tz.TZDateTime.from(dueDate, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'due_dates',
        'Tarih/Saat Hatırlatmaları',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}

Future<void> cancelDueDateReminder(String itemId) => _plugin.cancel(notificationIdForItem(itemId));

Future<void> cancelAllDueDateReminders() => _plugin.cancelAll();

/// Shows an immediate notification for a push received while the app is in
/// the foreground — FCM's own tray notification only auto-displays when the
/// app is backgrounded/terminated, so foreground pushes need to be surfaced
/// this way instead.
Future<void> showPushNotification({
  required String title,
  required String body,
  Map<String, dynamic>? data,
}) {
  return _plugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(0x7fffffff),
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'push',
        'Bildirimler',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: data == null ? null : jsonEncode(data),
  );
}
