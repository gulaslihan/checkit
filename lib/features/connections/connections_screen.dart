import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_feedback.dart';
import '../../core/widgets/home_button.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../data/connections_provider.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final email = _controller.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emailInvalid)),
      );
      return;
    }
    setState(() => _isSending = true);
    AppErrorKind? errorKind;
    try {
      errorKind = await ref.read(connectionsNotifierProvider).sendRequest(email);
    } catch (e) {
      errorKind = classifyError(e);
    }
    if (!mounted) return;
    setState(() => _isSending = false);
    if (errorKind != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizedErrorMessage(context, errorKind))));
    } else {
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.connectionRequestSent(email))),
      );
    }
  }

  /// Only for accepted connections — an accidental tap here silently drops a
  /// real, established relationship (unlike cancelling a still-pending
  /// request), so it gets the same confirm-dialog treatment as deleting or
  /// leaving a list.
  Future<void> _confirmRemove(String connectionId, String email) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeConnectionTitle),
        content: Text(l10n.removeConnectionConfirm(email)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.removeConnectionAction, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await runGuarded(context, () => ref.read(connectionsNotifierProvider).remove(connectionId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final connectionsAsync = ref.watch(myConnectionsProvider);
    final connections = connectionsAsync.value ?? const [];
    final notifier = ref.read(connectionsNotifierProvider);

    final myUid = FirebaseAuth.instance.currentUser?.uid;
    final incoming = connections.where((c) => !c.accepted && c.recipientEmail == myEmail).toList();
    final sentPending = connections.where((c) => !c.accepted && c.requesterId == myUid).toList();
    final accepted = connections.where((c) => c.accepted).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.connectionsScreenTitle), actions: const [HomeButton()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.connectionsInfoBanner,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.addConnectionLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(hintText: l10n.emailHint),
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
                    : Text(l10n.sendButton),
              ),
            ],
          ),
          if (incoming.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l10n.incomingRequestsLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            for (final c in incoming)
              _ConnectionRow(
                email: c.requesterEmail,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.rejectTooltip,
                      icon: const Icon(Icons.close_rounded, color: AppColors.danger),
                      onPressed: () => runGuarded(context, () => notifier.remove(c.id)),
                    ),
                    IconButton(
                      tooltip: l10n.acceptTooltip,
                      icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                      onPressed: () => runGuarded(context, () => notifier.accept(c.id)),
                    ),
                  ],
                ),
              ),
          ],
          if (sentPending.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l10n.sentRequestsLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            for (final c in sentPending)
              _ConnectionRow(
                email: c.recipientEmail,
                subtitle: l10n.pendingAcceptance,
                trailing: IconButton(
                  tooltip: l10n.cancelTooltip,
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => notifier.remove(c.id),
                ),
              ),
          ],
          const SizedBox(height: 24),
          Text(l10n.yourConnectionsLabel(accepted.length), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (connectionsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            )
          else if (accepted.isEmpty)
            Text(l10n.noConnectionsYet, style: const TextStyle(color: AppColors.textSecondary))
          else
            for (final c in accepted)
              _ConnectionRow(
                email: c.otherEmail(myEmail),
                trailing: IconButton(
                  tooltip: l10n.removeConnectionTooltip,
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => _confirmRemove(c.id, c.otherEmail(myEmail)),
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
        border: Border.all(color: AppColors.cardBorder),
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
