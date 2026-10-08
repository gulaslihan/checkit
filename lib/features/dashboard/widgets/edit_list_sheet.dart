import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_feedback.dart';
import '../../../data/lists_provider.dart';
import '../../../data/subscription_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/checklist.dart';
import '../../create_list/widgets/category_selector.dart';
import '../../create_list/widgets/settings_toggle.dart';
import '../../subscription/paywall_sheet.dart';

class EditListSheet extends ConsumerStatefulWidget {
  final Checklist checklist;

  const EditListSheet({super.key, required this.checklist});

  @override
  ConsumerState<EditListSheet> createState() => _EditListSheetState();
}

class _EditListSheetState extends ConsumerState<EditListSheet> {
  late final TextEditingController _titleController;
  String? _category;
  late bool _allowRating;
  late bool _isCheckable;
  late bool _allowDueDates;
  late bool _allowNotes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.checklist.title);
    _category = widget.checklist.category;
    _allowRating = widget.checklist.allowRating;
    _isCheckable = widget.checklist.isCheckable;
    _allowDueDates = widget.checklist.allowDueDates;
    _allowNotes = widget.checklist.allowNotes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final succeeded = await runGuarded(
      context,
      () => ref.read(listsProvider.notifier).updateListMeta(
            widget.checklist.id,
            title: title,
            category: _category,
            allowRating: _allowRating,
            isCheckable: _isCheckable,
            allowDueDates: _allowDueDates,
            allowNotes: _allowNotes,
          ),
    );
    if (succeeded && mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteListTitle),
        content: Text(l10n.deleteListConfirm(widget.checklist.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteAction, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final succeeded = await runGuarded(context, () => ref.read(listsProvider.notifier).deleteList(widget.checklist.id));
      if (succeeded && mounted) Navigator.of(context).pop();
    }
  }

  /// Only the owner can delete a list — a shared collaborator who no longer
  /// wants to see it removes themselves instead (same action as the
  /// "Listeden Ayrıl" button in the Paylaş screen).
  Future<void> _confirmLeave() async {
    final l10n = AppLocalizations.of(context)!;
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.leaveListTitle),
        content: Text(l10n.leaveListConfirm(widget.checklist.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.leaveAction, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final succeeded = await runGuarded(
        context,
        () => ref.read(listsProvider.notifier).removeCollaborator(widget.checklist.id, myEmail),
      );
      if (succeeded && mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _duplicate() async {
    final l10n = AppLocalizations.of(context)!;
    final subscription = ref.read(subscriptionProvider);
    if (!subscription.canCreateList) {
      showPaywallSheet(context, freeLimit: subscription.freeTotalListLimit);
      return;
    }
    final succeeded =
        await runGuarded(context, () => ref.read(listsProvider.notifier).duplicateList(widget.checklist.id));
    if (!succeeded || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.listDuplicated(widget.checklist.title))),
    );
    Navigator.of(context).pop();
  }

  Future<void> _toggleArchive() async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(listsProvider.notifier);
    final succeeded = await runGuarded(
      context,
      () => widget.checklist.archived ? notifier.unarchiveList(widget.checklist.id) : notifier.archiveList(widget.checklist.id),
    );
    if (!succeeded || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.checklist.archived
          ? l10n.listUnarchived(widget.checklist.title)
          : l10n.listArchived(widget.checklist.title))),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final isOwner = (widget.checklist.ownerEmail ?? '').toLowerCase() == myEmail.toLowerCase();
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.editListTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                tooltip: l10n.closeTooltip,
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            decoration: InputDecoration(labelText: l10n.listNameLabel),
          ),
          const SizedBox(height: 20),
          SettingsToggle(
            icon: Icons.check_circle_outline_rounded,
            title: l10n.checkableToggleTitle,
            subtitle: l10n.checkableToggleSubtitle,
            value: _isCheckable,
            onChanged: (v) => setState(() => _isCheckable = v),
          ),
          const SizedBox(height: 12),
          SettingsToggle(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: l10n.starRatingToggleTitle,
            subtitle: l10n.starRatingToggleSubtitle,
            value: _allowRating,
            onChanged: (v) => setState(() => _allowRating = v),
          ),
          const SizedBox(height: 12),
          SettingsToggle(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.secondary,
            title: l10n.dueDateToggleTitleGeneric,
            subtitle: l10n.dueDateToggleSubtitleGeneric,
            value: _allowDueDates,
            onChanged: (v) => setState(() => _allowDueDates = v),
          ),
          const SizedBox(height: 12),
          SettingsToggle(
            icon: Icons.notes_rounded,
            iconColor: AppColors.secondary,
            title: l10n.notesToggleTitle,
            subtitle: l10n.notesToggleSubtitle,
            value: _allowNotes,
            onChanged: (v) => setState(() => _allowNotes = v),
          ),
          const SizedBox(height: 20),
          Text(l10n.categoryLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          CategorySelector(value: _category, onChanged: (c) => setState(() => _category = c)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _duplicate,
              icon: const Icon(Icons.copy_all_rounded),
              label: Text(l10n.duplicateListButton),
            ),
          ),
          if (isOwner) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _toggleArchive,
                icon: Icon(widget.checklist.archived ? Icons.unarchive_outlined : Icons.archive_outlined),
                label: Text(widget.checklist.archived ? l10n.unarchiveButton : l10n.archiveButton),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: isOwner
                    ? OutlinedButton.icon(
                        onPressed: _confirmDelete,
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                        label: Text(l10n.deleteAction, style: const TextStyle(color: AppColors.danger)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
                      )
                    : OutlinedButton.icon(
                        onPressed: _confirmLeave,
                        icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                        label: Text(l10n.leaveAction, style: const TextStyle(color: AppColors.danger)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
