import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../models/checklist_item.dart';
import 'assignee_picker.dart';

class ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDismissed;
  final bool showRating;
  final ValueChanged<int>? onRatingChanged;
  final bool isCheckable;
  final bool showNote;
  final bool showDueDate;

  /// Non-null when this tile sits inside a ReorderableListView at this
  /// index — shows a drag handle wired to that index.
  final int? dragIndex;

  /// Names the item can be assigned to — an avatar/assign button only shows
  /// when this is non-empty (i.e. the list is shared).
  final List<String> collaborators;
  final ValueChanged<String?>? onAssigneeChanged;

  /// This list's per-list nicknames (email -> display name), if any.
  final Map<String, String> nicknames;

  /// When true, the leading checkbox picks items for a bulk action (e.g.
  /// "create a new list from these") instead of marking them done.
  final bool selectionMode;
  final bool selected;
  final ValueChanged<bool>? onSelectedChanged;

  /// Long-press on the item text opens the text/note/due-date editor.
  final VoidCallback? onEdit;

  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDismissed,
    this.showRating = false,
    this.onRatingChanged,
    this.isCheckable = true,
    this.showNote = false,
    this.showDueDate = false,
    this.dragIndex,
    this.collaborators = const [],
    this.nicknames = const {},
    this.onAssigneeChanged,
    this.selectionMode = false,
    this.selected = false,
    this.onSelectedChanged,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: selectionMode ? DismissDirection.none : DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: item.isDone ? AppColors.success.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (selectionMode)
              Checkbox(
                value: selected,
                onChanged: (v) => onSelectedChanged?.call(v ?? false),
                activeColor: AppColors.secondary,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
              )
            else if (isCheckable)
              Checkbox(
                value: item.isDone,
                onChanged: (v) {
                  HapticFeedback.mediumImpact();
                  onToggle(v);
                },
                activeColor: AppColors.primary,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
              )
            else
              const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: selectionMode
                        ? () => onSelectedChanged?.call(!selected)
                        : (isCheckable
                            ? () {
                                HapticFeedback.mediumImpact();
                                onToggle(!item.isDone);
                              }
                            : null),
                    onLongPress: selectionMode ? null : onEdit,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.text,
                            style: TextStyle(
                              decoration: item.isDone ? TextDecoration.lineThrough : null,
                              decorationColor: AppColors.textPrimary,
                              decorationThickness: 2.2,
                              color: item.isDone ? AppColors.textSecondary : AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (showNote && item.note != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.note!,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                          if (showDueDate && item.dueDate != null) ...[
                            const SizedBox(height: 4),
                            _DueDateChip(dueDate: item.dueDate!, isDone: item.isDone),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (showRating)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: StarRating(
                        rating: item.rating,
                        size: 18,
                        onChanged: (r) => onRatingChanged?.call(r),
                      ),
                    ),
                ],
              ),
            ),
            if (!selectionMode && onEdit != null)
              IconButton(
                tooltip: 'Düzenle',
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            if (collaborators.isNotEmpty)
              GestureDetector(
                onTap: () => showAssigneePicker(
                  context: context,
                  collaborators: collaborators,
                  current: item.assignedTo,
                  onSelected: (a) => onAssigneeChanged?.call(a),
                  nicknames: nicknames,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: item.assignedTo != null
                      ? InitialsAvatar(
                          name: nicknames[item.assignedTo!] ?? item.assignedTo!,
                          colorKey: item.assignedTo!,
                          radius: 14,
                        )
                      : const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.background,
                          child: Icon(Icons.person_add_alt_1_rounded, size: 14, color: AppColors.textSecondary),
                        ),
                ),
              ),
            if (dragIndex != null)
              ReorderableDragStartListener(
                index: dragIndex!,
                child: const Padding(
                  padding: EdgeInsets.only(left: 4, right: 4),
                  child: Icon(Icons.drag_handle_rounded, color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DueDateChip extends StatelessWidget {
  final DateTime dueDate;
  final bool isDone;

  const _DueDateChip({required this.dueDate, required this.isDone});

  @override
  Widget build(BuildContext context) {
    final isOverdue = !isDone && dueDate.isBefore(DateTime.now());
    final color = isOverdue ? AppColors.danger : AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(formatDueDate(dueDate), style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
