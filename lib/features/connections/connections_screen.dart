import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_feedback.dart';
import '../../core/widgets/home_button.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../data/connections_provider.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _controller.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir e-posta girin.')),
      );
      return;
    }
    setState(() => _isSending = true);
    String? error;
    try {
      error = await ref.read(connectionsNotifierProvider).sendRequest(email);
    } catch (e) {
      error = friendlyErrorMessage(e);
    }
    if (!mounted) return;
    setState(() => _isSending = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağlantı isteği gönderildi — $email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final connections = ref.watch(myConnectionsProvider).value ?? const [];
    final notifier = ref.read(connectionsNotifierProvider);

    final myUid = FirebaseAuth.instance.currentUser?.uid;
    final incoming = connections.where((c) => !c.accepted && c.recipientEmail == myEmail).toList();
    final sentPending = connections.where((c) => !c.accepted && c.requesterId == myUid).toList();
    final accepted = connections.where((c) => c.accepted).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Bağlantılarım'), actions: const [HomeButton()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bir kere bağlantı kurunca, o kişiyi her seferinde e-posta yazmadan istediğiniz listeye ekleyebilirsiniz.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Bağlantı Ekle', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'ornek@eposta.com'),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSending ? null : _send,
                child: _isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Gönder'),
              ),
            ],
          ),
          if (incoming.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Gelen İstekler', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            for (final c in incoming)
              _ConnectionRow(
                email: c.requesterEmail,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Reddet',
                      icon: const Icon(Icons.close_rounded, color: AppColors.danger),
                      onPressed: () => runGuarded(context, () => notifier.remove(c.id)),
                    ),
                    IconButton(
                      tooltip: 'Kabul Et',
                      icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                      onPressed: () => runGuarded(context, () => notifier.accept(c.id)),
                    ),
                  ],
                ),
              ),
          ],
          if (sentPending.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Gönderilen İstekler', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            for (final c in sentPending)
              _ConnectionRow(
                email: c.recipientEmail,
                subtitle: 'Kabul bekleniyor',
                trailing: IconButton(
                  tooltip: 'İptal Et',
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => notifier.remove(c.id),
                ),
              ),
          ],
          const SizedBox(height: 24),
          Text('Bağlantılarınız (${accepted.length})', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (accepted.isEmpty)
            const Text('Henüz bağlantınız yok.', style: TextStyle(color: AppColors.textSecondary))
          else
            for (final c in accepted)
              _ConnectionRow(
                email: c.otherEmail(myEmail),
                trailing: IconButton(
                  tooltip: 'Bağlantıyı kaldır',
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => notifier.remove(c.id),
                ),
              ),
        ],
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  final String email;
  final String? subtitle;
  final Widget trailing;

  const _ConnectionRow({required this.email, this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        leading: InitialsAvatar(name: email),
        title: Text(email),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
      ),
    );
  }
}
