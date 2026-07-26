import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/auth_provider.dart';
import 'data/due_date_reminders.dart';
import 'data/fcm_provider.dart';
import 'data/lists_provider.dart';
import 'data/local_notifications.dart';
import 'data/notification_navigation.dart';
import 'data/notification_settings_provider.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/verify_email_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

class CheckItApp extends StatelessWidget {
  const CheckItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: navigatorKey,
      home: const _AuthGate(),
    );
  }
}

/// Shows the sign-in screen while logged out, the app while logged in.
class _AuthGate extends ConsumerStatefulWidget {
  const _AuthGate();

  @override
  ConsumerState<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<_AuthGate> {
  String? _registeredForUid;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Whenever the visible lists change (new due dates, items done/deleted,
    // reassigned), reconcile the device's scheduled due-date reminders.
    ref.listen(listsProvider, (previous, lists) {
      final enabled = ref.read(notificationSettingsProvider).onDueDate;
      final myEmail = ref.read(authStateProvider).value?.email;
      syncDueDateReminders(lists, enabled: enabled, myEmail: myEmail);
    });

    return authState.when(
      data: (user) {
        if (user == null) return const AuthScreen();
        if (!user.emailVerified) return const VerifyEmailScreen();
        if (_registeredForUid != user.uid) {
          _registeredForUid = user.uid;
          requestLocalNotificationPermission();
          registerFcmToken(user.uid);
        }
        return const DashboardScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Bir hata oluştu: $error')),
      ),
    );
  }
}
