import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_feedback.dart';
import '../../core/widgets/home_button.dart';
import '../../core/utils/person_label.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../data/connections_provider.dart';
import '../../data/invites_provider.dart';
import '../../data/lists_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/checklist.dart';
import '../../models/invite.dart';

class ShareScreen extends ConsumerStatefulWidget {
  final String listId;

  const ShareScreen({super.key, required this.listId});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _invite(String listTitle) async {
    final l10n = AppLocalizations.of(context)!;
    final email = _controller.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emailInvalid)),
      );
      return;
    }

    final alreadyInvited = (ref.read(sentInvitesProvider(widget.listId)).value ?? const [])
        .any((i) => i.recipientEmail == email);
    if (alreadyInvited) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.alreadyInvited)),
      );
      return;
    }

    setState(() => _isSending = true);
    AppErrorKind? errorKind;
    try {
      errorKind = await ref
          .read(invitesNotifierProvider)
          .sendInvite(listId: widget.listId, listTitle: listTitle, recipientEmail: email);
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
        SnackBar(content: Text(l10n.inviteSentToEmail(email))),
      );
    }
  }

  Future<void> _editNickname(Checklist list, String person) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: list.nicknames[person] ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.nicknameDialogTitle(person)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          maxLength: 40,
          decoration: InputDecoration(hintText: l10n.nicknameHint),
          onSubmitted: (v) => Navigator.of(dialogContext).pop(v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || !mounted) return;
    await runGuarded(context, () => ref.read(listsProvider.notifier).setNickname(widget.listId, person, result));
  }

  /// Same confirm treatment for both leaving a list and removing someone —
  /// either way access is gone and can't be undone from here.
  Future<void> _confirmRemove(Checklist list, String person, String myEmail) async {
    final l10n = AppLocalizations.of(context)!;
    final isSelf = person.toLowerCase() == myEmail.toLowerCase();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isSelf ? l10n.leaveListTitle : l10n.removeCollaboratorTitle),
        content: Text(
          isSelf ? l10n.leaveListConfirm(list.title) : l10n.removeCollaboratorConfirm(listPersonLabel(context, list, person)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(isSelf ? l10n.leaveAction : l10n.removeTooltip, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await runGuarded(context, () => ref.read(listsProvider.notifier).removeCollaborator(widget.listId, person));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lists = ref.watch(listsProvider);
    final matches = lists.where((l) => l.id == widget.listId);
    if (matches.isEmpty) {
      // The list is gone (you just left it, or the owner deleted it) — close
      // this screen too instead of leaving a blank page; ListDetailScreen
      // underneath does the same, so the stack unwinds back to the dashboard.
      if (!ref.watch(listsLoadingProvider)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
      }
      return const Scaffold(body: SizedBox.shrink());
    }
    final list = matches.first;
    final invites = ref.watch(sentInvitesProvider(widget.listId)).value ?? const [];
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final isOwner = list.ownerEmail != null && list.ownerEmail!.toLowerCase() == myEmail.toLowerCase();
    final quickPicks = (ref.watch(myConnectionsProvider).value ?? const [])
        .where((c) => c.accepted)
        .map((c) => c.otherEmail(myEmail))
        .where((email) => !list.sharedWith.contains(email) && !invites.any((i) => i.recipientEmail == email))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shareScreenTitle(list.title), overflow: TextOverflow.ellipsis),
        actions: const [HomeButton()],
      ),
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
                const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.shareInfoBanner,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (isOwner) ...[
            Text(l10n.inviteByEmailLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: l10n.emailHint),
                    onSubmitted: (_) => _invite(list.title),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSending ? null : () => _invite(list.title),
                  child: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.inviteButton),
                ),
              ],
            ),
            if (quickPicks.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(l10n.quickPicksLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final email in quickPicks)
                    ActionChip(
                      avatar: InitialsAvatar(name: email, radius: 10),
                      label: Text(email),
                      onPressed: _isSending
                          ? null
                          : () {
                              _controller.text = email;
                              _invite(list.title);
                            },
                    ),
                ],
              ),
            ],
          ] else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.ownerOnlyInviteNotice,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          if (isOwner && invites.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l10n.pendingInvitesLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  for (final invite in invites) _InviteRow(invite: invite),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            l10n.peopleWhoCanSeeList(list.sharedWith.length + 1),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: InitialsAvatar(name: list.labelFor(list.ownerEmail ?? '?'), colorKey: list.ownerEmail),
                  title: Text(listPersonLabel(context, list, list.ownerEmail ?? '?')),
                  subtitle: Text(
                    list.nicknames.containsKey(list.ownerEmail)
                        ? l10n.ownerWithNickname(list.nicknames[list.ownerEmail] ?? '')
                        : l10n.ownerLabel,
                  ),
                  trailing: isOwner
                      ? IconButton(
                          tooltip: l10n.editOwnNameTooltip,
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                          onPressed: () => _editNickname(list, list.ownerEmail ?? ''),
                        )
                      : null,
                ),
                for (final person in list.sharedWith)
                  ListTile(
                    leading: InitialsAvatar(name: list.labelFor(person), colorKey: person),
                    title: Text(listPersonLabel(context, list, person)),
                    subtitle: list.nicknames.containsKey(person) ? Text(person) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isOwner)
                          IconButton(
                            tooltip: l10n.giveNicknameTooltip,
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                            onPressed: () => _editNickname(list, person),
                          ),
                        if (isOwner || person.toLowerCase() == myEmail.toLowerCase())
                          IconButton(
                            tooltip: person.toLowerCase() == myEmail.toLowerCase()
                                ? l10n.leaveListTooltip
                                : l10n.removeTooltip,
                            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                            onPressed: () => _confirmRemove(list, person, myEmail),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteRow extends ConsumerWidget {
  final Invite invite;

  const _InviteRow({required this.invite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(invitesNotifierProvider);

    return ListTile(
      leading: InitialsAvatar(name: invite.recipientEmail),
      title: Text(invite.recipientEmail),
      subtitle: Text(l10n.pendingAcceptance, style: const TextStyle(color: AppColors.textSecondary)),
      trailing: IconButton(
        tooltip: l10n.cancelTooltip,
        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
        onPressed: () => runGuarded(context, () => notifier.deleteInvite(invite.id)),
      ),
    );
  }
}
