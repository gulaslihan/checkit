import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/voice_input_button.dart';

class ListSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const ListSearchBar({super.key, required this.onChanged});

  @override
  State<ListSearchBar> createState() => _ListSearchBarState();
}

class _ListSearchBarState extends State<ListSearchBar> {
  final _controller = TextEditingController();

  void _setText(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
    widget.onChanged(text);
  }

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
        boxShadow: AppTheme.softShadow,
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'Listelerde ara...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          suffixIcon: VoiceInputButton(onResult: _setText),
        ),
      ),
    );
  }
}
