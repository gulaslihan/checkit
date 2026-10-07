import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_feedback.dart';
import '../../core/widgets/home_button.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../data/connections_provider.dart';
import '../../data/invites_provider.dart';
import '../../data/notifications_provider.dart';
import '../../data/seen_notifications_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/connection.dart';
import '../../models/invite.dart';
import '../list_detail/list_detail_screen.dart';

class MyInvitesScreen extends ConsumerStatefulWidget {
  const MyInvitesScreen({super.key});

  @override
  ConsumerState<MyInvitesScreen> createState() => _MyInvitesScreenState();
}

class _MyInvitesScreenState extends ConsumerState<MyInvitesScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summary = ref.watch(notificationSummaryProvider);

    // Mark everything currently shown as "seen" so the dashboard badge
    // drops — scheduled for after this frame since it writes to another
    // provider, and guarded (see markSeen) so it's a no-op once caught up.
    final keys = summary.allKeys;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(seenNotificationsProvider.notifier).markSeen(keys);
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myInvitesTitle), actions: const [HomeButton()]),
      body: summary.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : summary.isEmpty
          ? const _EmptyInvites()
          : ListView(
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
                          l10n.invitesScreenInfoBanner,
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (summary.newInvites.isNotEmpty) ...[
                  Text(l10n.newInvitesLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  for (final invite in summary.newInvites) _PendingInviteCard(invite: invite),
                  const SizedBox(height: 24),
                ],
                if (summary.connectionRequests.isNotEmpty) ...[
                  Text(l10n.connectionRequestsLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  for (final c in summary.connectionRequests) _ConnectionRequestCard(connection: c),
                  const SizedBox(height: 24),
                ],
                if (summary.assignedTasks.isNotEmpty) ...[
                  Text(l10n.assignedTasksLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  for (final task in summary.assignedTasks) _AssignedTaskCard(task: task),
                ],
              ],
            ),
    );
  }
}

class _AssignedTaskCard extends StatelessWidget {
  final AssignedTask task;

  const _AssignedTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ListDetailScreen(listId: task.list.id)),
          );
        },
        leading: const CircleAvatar(
          backgroundColor: AppColors.background,
          child: Icon(Icons.assignment_ind_rounded, color: AppColors.primary),
        ),
        title: Text(task.item.text, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(AppLocalizations.of(context)!.assignedInListSubtitle(task.list.title)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ConnectionRequestCard extends ConsumerStatefulWidget {
  final Connection connection;

  const _ConnectionRequestCard({required this.connection});

  @override
  ConsumerState<_ConnectionRequestCard> createState() => _ConnectionRequestCardState();
}

class _ConnectionRequestCardState extends ConsumerState<_ConnectionRequestCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    await runGuarded(context, action);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(connectionsNotifierProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          InitialsAvatar(name: widget.connection.requesterEmail),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.connection.requesterEmail, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(l10n.wantsToConnect, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            IconButton(
              tooltip: l10n.rejectTooltip,
              icon: const Icon(Icons.close_rounded, color: AppColors.danger),
              onPressed: () => _run(() => notifier.remove(widget.connection.id)),
            ),
            IconButton(
              tooltip: l10n.acceptTooltip,
              icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
              onPressed: () => _run(() => notifier.accept(widget.connection.id)),
            ),
          ],
        ],
      ),
    );
  }
}

class _PendingInviteCard extends ConsumerStatefulWidget {
  final Invite invite;

  const _PendingInviteCard({required this.invite});

  @override
  ConsumerState<_PendingInviteCard> createState() => _PendingInviteCardState();
}

class _PendingInviteCardState extends ConsumerState<_PendingInviteCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    await runGuarded(context, action);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(invitesNotifierProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          InitialsAvatar(name: widget.invite.ownerEmail),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.invite.listTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  l10n.invitedYouToList(widget.invite.ownerEmail),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            IconButton(
              tooltip: l10n.rejectTooltip,
              icon: const Icon(Icons.close_rounded, color: AppColors.danger),
              onPressed: () => _run(() => notifier.deleteInvite(widget.invite.id)),
            ),
            IconButton(
              tooltip: l10n.acceptTooltip,
              icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
              onPressed: () => _run(() => notifier.acceptInvite(widget.invite)),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyInvites extends StatelessWidget {
  const _EmptyInvites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mail_outline_rounded, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.noPendingItems, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
