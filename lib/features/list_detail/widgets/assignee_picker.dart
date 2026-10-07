import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/person_label.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../l10n/app_localizations.dart';

Future<void> showAssigneePicker({
  required BuildContext context,
  required List<String> collaborators,
  required String? current,
  required ValueChanged<String?> onSelected,
  Map<String, String> nicknames = const {},
}) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.assignToTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.background,
                child: Icon(Icons.person_off_outlined, color: AppColors.textSecondary),
              ),
              title: Text(l10n.unassignedLabel),
              trailing: current == null ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () {
                onSelected(null);
                Navigator.of(sheetContext).pop();
              },
            ),
            for (final person in collaborators)
              ListTile(
                leading: InitialsAvatar(
                  name: assigneeChipLabel(context, person, nicknames),
                  colorKey: person,
                ),
                title: Text(assigneeChipLabel(context, person, nicknames)),
                trailing: current == person ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                onTap: () {
                  onSelected(person);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
