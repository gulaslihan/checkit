import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/home_button.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../data/account_deletion.dart';
import '../../data/connections_provider.dart';
import '../../data/locale_provider.dart';
import '../../core/utils/error_feedback.dart';
import '../../l10n/app_localizations.dart';
import '../connections/connections_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_of_service_screen.dart';
import '../notification_settings/notification_settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isDeleting = false;

  Future<void> _startAccountDeletion() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmDeleteAccountTitle),
        content: Text(l10n.confirmDeleteAccountBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteMyAccountButton, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    final result = await deleteMyAccount();
    if (!mounted) return;

    if (result.needsReauth) {
      setState(() => _isDeleting = false);
      await _reauthenticateAndRetry();
      return;
    }

    setState(() => _isDeleting = false);
    if (result.errorKind != null) {
      final detail = localizedErrorMessage(context, result.errorKind!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorWithDetail(detail))));
    }
    // On success, FirebaseAuth's user becomes null and AuthGate switches
    // screens automatically — nothing else to do here.
  }

  Future<void> _reauthenticateAndRetry() async {
    final l10n = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmPasswordTitle),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.passwordLabel),
          onSubmitted: (v) => Navigator.of(dialogContext).pop(v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(passwordController.text),
            child: Text(l10n.confirmButton),
          ),
        ],
      ),
    );
    passwordController.dispose();
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _isDeleting = true);
    final errorKind = await reauthenticateAndDeleteAccount(password);
    if (!mounted) return;
    setState(() => _isDeleting = false);
    if (errorKind != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizedErrorMessage(context, errorKind))));
    }
  }

  Future<void> _showLanguagePicker() async {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(localeProvider);
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale?>(
              title: Text(l10n.systemLanguageOption),
              value: null,
              // ignore: deprecated_member_use
              groupValue: current,
              // ignore: deprecated_member_use
              onChanged: (_) {
                ref.read(localeProvider.notifier).setLocale(null);
                Navigator.of(sheetContext).pop();
              },
            ),
            RadioListTile<Locale?>(
              title: const Text('Türkçe'),
              value: const Locale('tr'),
              // ignore: deprecated_member_use
              groupValue: current,
              // ignore: deprecated_member_use
              onChanged: (_) {
                ref.read(localeProvider.notifier).setLocale(const Locale('tr'));
                Navigator.of(sheetContext).pop();
              },
            ),
            RadioListTile<Locale?>(
              title: const Text('English'),
              value: const Locale('en'),
              // ignore: deprecated_member_use
              groupValue: current,
              // ignore: deprecated_member_use
              onChanged: (_) {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.of(sheetContext).pop();
              },
            ),
            // Android's equivalent system screen needs API 33+ and isn't
            // reliably reachable via a generic deep link — the in-app
            // picker above covers every Android version instead.
            if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
              const Divider(height: 1),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  launchUrl(Uri.parse('app-settings:'));
                },
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: Text(l10n.openSystemLanguageSettings),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final pendingCount = (ref.watch(myConnectionsProvider).value ?? const [])
        .where((c) => !c.accepted && c.recipientEmail == email)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle), actions: const [HomeButton()]),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: InitialsAvatar(name: email, radius: 40)),
          const SizedBox(height: 16),
          Center(
            child: Text(email, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ConnectionsScreen()),
                );
              },
              icon: Badge(
                label: Text('$pendingCount'),
                isLabelVisible: pendingCount > 0,
                child: const Icon(Icons.people_alt_rounded),
              ),
              label: Text(l10n.connectionsScreenTitle),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                );
              },
              icon: const Icon(Icons.notifications_none_rounded),
              label: Text(l10n.notificationSettingsButton),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showLanguagePicker,
              icon: const Icon(Icons.language_rounded),
              label: Text(l10n.languageSettingLabel),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: Text(l10n.signOutButton, style: const TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
            child: Text(l10n.privacyPolicyTitle),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
            ),
            child: Text(l10n.termsOfServiceTitle),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isDeleting ? null : _startAccountDeletion,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger),
                    )
                  : const Icon(Icons.delete_forever_rounded, color: AppColors.danger),
              label: Text(l10n.deleteMyAccountButton, style: const TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }
}
