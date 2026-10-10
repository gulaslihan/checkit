import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/voice_input_button.dart';
import '../../../data/ai_list_generator.dart';
import '../../../l10n/app_localizations.dart';

Future<AiGeneratedList?> showAiPromptSheet(BuildContext context, {String? initialPrompt}) {
  return showModalBottomSheet<AiGeneratedList>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _AiPromptSheet(initialPrompt: initialPrompt),
  );
}

class _AiPromptSheet extends StatefulWidget {
  final String? initialPrompt;

  const _AiPromptSheet({this.initialPrompt});

  @override
  State<_AiPromptSheet> createState() => _AiPromptSheetState();
}

class _AiPromptSheetState extends State<_AiPromptSheet> {
  late final TextEditingController _controller;
  bool _isGenerating = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPrompt);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _isGenerating) return;
    setState(() {
      _isGenerating = true;
      _errorText = null;
    });
    try {
      final result = await generateListWithAI(prompt);
      if (mounted) Navigator.of(context).pop(result);
    } on AiGenerationException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isGenerating = false;
        _errorText = switch (e.kind) {
          AiGenerationErrorKind.dailyLimitReached => l10n.aiDailyLimitReached,
          AiGenerationErrorKind.freeLimitReached => l10n.aiFreeLimitReached,
          AiGenerationErrorKind.generic => l10n.aiGenerationFailed,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.aiPromptSheetTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            maxLength: 500,
            enabled: !_isGenerating,
            decoration: InputDecoration(
              hintText: l10n.aiPromptHint,
              suffixIcon: VoiceInputButton(controller: _controller),
            ),
            onSubmitted: (_) => _generate(),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 4),
            Text(_errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generate,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
              ),
              child: _isGenerating
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(l10n.aiGenerating),
                      ],
                    )
                  : Text(l10n.createAction),
            ),
          ),
        ],
      ),
    );
  }
}
