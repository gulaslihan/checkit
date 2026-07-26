import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/person_label.dart';
import '../../../core/widgets/initials_avatar.dart';

Future<void> showAssigneePicker({
  required BuildContext context,
  required List<String> collaborators,
  required String? current,
  required ValueChanged<String?> onSelected,
  Map<String, String> nicknames = const {},
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Kime atansın?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.background,
                child: Icon(Icons.person_off_outlined, color: AppColors.textSecondary),
              ),
              title: const Text('Atanmamış'),
              trailing: current == null ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () {
                onSelected(null);
                Navigator.of(sheetContext).pop();
              },
            ),
            for (final person in collaborators)
              ListTile(
                leading: InitialsAvatar(
                  name: personLabel(person) == 'Siz' ? 'Siz' : (nicknames[person] ?? person),
                  colorKey: person,
                ),
                title: Text(personLabel(person) == 'Siz' ? 'Siz' : (nicknames[person] ?? person)),
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
