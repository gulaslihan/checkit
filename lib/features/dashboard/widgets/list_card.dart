import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/person_label.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/checklist.dart';
import 'category_icon.dart';

class ListCard extends StatelessWidget {
  final Checklist checklist;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const ListCard({super.key, required this.checklist, this.onTap, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final progress = checklist.totalCount == 0 ? 0.0 : checklist.completedCount / checklist.totalCount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(categoryIcon(checklist.category), color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checklist.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(child: _OwnerLabel(checklist: checklist)),
                          if (checklist.isShared) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.people_alt_rounded, size: 14, color: AppColors.textSecondary),
                          ],
                          const Spacer(),
                          Text(
                            checklist.isCheckable
                                ? '${checklist.completedCount}/${checklist.totalCount}'
                                : AppLocalizations.of(context)!.itemCount(checklist.totalCount),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                      if (checklist.isCheckable) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: AppColors.background,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OwnerLabel extends StatelessWidget {
  final Checklist checklist;
  const _OwnerLabel({required this.checklist});

  @override
  Widget build(BuildContext context) {
    final owner = listPersonLabel(context, checklist, checklist.ownerEmail ?? '');
    return Text(
      AppLocalizations.of(context)!.ownerPrefix(owner),
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
      overflow: TextOverflow.ellipsis,
    );
  }
}
