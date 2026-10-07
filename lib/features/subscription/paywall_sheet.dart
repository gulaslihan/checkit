import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Shown wherever a new-list creation is blocked by the free-tier quota
/// (see subscription_provider.dart) — informational only for now, since
/// there's no real purchase flow yet (Play Billing is a separate, later
/// piece of work). Never blocks access to existing lists.
Future<void> showPaywallSheet(BuildContext context, {required int freeLimit}) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: AppColors.secondary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(l10n.paywallTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(l10n.paywallBody(freeLimit), style: const TextStyle(fontSize: 14, height: 1.4)),
          const SizedBox(height: 12),
          Text(
            l10n.paywallComingSoon,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
              ),
              child: Text(l10n.okButton),
            ),
          ),
        ],
      ),
    ),
  );
}
