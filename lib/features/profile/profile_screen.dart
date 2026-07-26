import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/home_button.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../data/account_deletion.dart';
import '../../data/connections_provider.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hesabınızı silmek istediğinize emin misiniz?'),
        content: const Text(
          'Bu işlem geri alınamaz. Sahibi olduğunuz tüm listeler ve ilişkili tüm verileriniz kalıcı '
          'olarak silinecek, hesabınız kapatılacaktır.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hesabımı Sil', style: TextStyle(color: AppColors.danger)),
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
    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bir sorun oluştu: ${result.error}')));
    }
    // On success, FirebaseAuth's user becomes null and AuthGate switches
    // screens automatically — nothing else to do here.
  }

  Future<void> _reauthenticateAndRetry() async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Devam etmek için şifrenizi girin'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Şifre'),
          onSubmitted: (v) => Navigator.of(dialogContext).pop(v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(passwordController.text),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
    passwordController.dispose();
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _isDeleting = true);
    final error = await reauthenticateAndDeleteAccount(password);
    if (!mounted) return;
    setState(() => _isDeleting = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final pendingCount = (ref.watch(myConnectionsProvider).value ?? const [])
        .where((c) => !c.accepted && c.recipientEmail == email)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), actions: const [HomeButton()]),
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
              label: const Text('Bağlantılarım'),
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
              label: const Text('Bildirim Ayarları'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: const Text('Çıkış Yap', style: TextStyle(color: AppColors.danger)),
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
            child: const Text('Gizlilik Politikası'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
            ),
            child: const Text('Kullanım Şartları'),
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
              label: const Text('Hesabımı Sil', style: TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }
}
