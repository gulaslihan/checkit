import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/voice_input_button.dart';
import '../../../l10n/app_localizations.dart';

class AddItemBar extends StatefulWidget {
  final ValueChanged<String> onAdd;

  const AddItemBar({super.key, required this.onAdd});

  @override
  State<AddItemBar> createState() => _AddItemBarState();
}

class _AddItemBarState extends State<AddItemBar> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 200,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.addItemHint,
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              VoiceInputButton(controller: _controller),
              IconButton(
                onPressed: _submit,
                icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
