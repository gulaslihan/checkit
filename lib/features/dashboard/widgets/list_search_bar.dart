import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/voice_input_button.dart';
import '../../../l10n/app_localizations.dart';

class ListSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? hintText;

  const ListSearchBar({super.key, required this.onChanged, this.hintText});

  @override
  State<ListSearchBar> createState() => _ListSearchBarState();
}

class _ListSearchBarState extends State<ListSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText ?? AppLocalizations.of(context)!.searchListsHint,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          suffixIcon: VoiceInputButton(controller: _controller, onChanged: widget.onChanged),
        ),
      ),
    );
  }
}
