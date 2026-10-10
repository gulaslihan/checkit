import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Shown after an invite / connection request to someone who doesn't have a
/// CheckIt account yet. It stays until dismissed on purpose: the invite itself
/// went through fine, but nothing will reach that person until they sign up
/// with the same email, and a passing snackbar is too easy to miss.
Future<void> showNoAccountDialog(BuildContext context, {required String title, required String body}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.okButton, style: const TextStyle(color: AppColors.primary)),
        ),
      ],
    ),
  );
}
