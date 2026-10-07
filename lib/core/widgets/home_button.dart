import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Jumps straight back to the dashboard from anywhere, without disturbing
/// the normal back button/gesture (which still pops one screen at a time).
class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.homeTooltip,
      icon: const Icon(Icons.home_rounded),
      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );
  }
}
