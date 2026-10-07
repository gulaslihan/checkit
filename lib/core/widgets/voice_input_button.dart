import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Reusable microphone button — tap to start listening, tap again to stop.
/// Writes recognized text directly into [controller], continuing from
/// whatever text is already there (so pressing the mic again after the
/// platform recognizer times out mid-sentence resumes instead of
/// overwriting what was already captured).
class VoiceInputButton extends StatefulWidget {
  final TextEditingController controller;

  /// Fired with the combined text every time it updates — for callers that
  /// need to react (e.g. a search bar re-filtering as you speak), not just
  /// display it via [controller].
  final ValueChanged<String>? onChanged;

  /// Speech-to-text locale (e.g. 'tr_TR'). Defaults to the app's current
  /// language when not given, instead of always listening in Turkish.
  final String? localeId;

  const VoiceInputButton({super.key, required this.controller, this.onChanged, this.localeId});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _baseText = '';

  @override
  void initState() {
    super.initState();
    _speech.initialize().then((available) {
      if (mounted) setState(() => _isAvailable = available);
    });
  }

  Future<void> _toggleListening() async {
    if (!_isAvailable) return;
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    _baseText = widget.controller.text.trim();
    final locale = Localizations.localeOf(context);
    final effectiveLocaleId = widget.localeId ?? (locale.languageCode == 'tr' ? 'tr_TR' : 'en_US');
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        final spoken = result.recognizedWords;
        final combined = _baseText.isEmpty
            ? spoken
            : (spoken.isEmpty ? _baseText : '$_baseText $spoken');
        widget.controller.text = combined;
        widget.controller.selection = TextSelection.collapsed(offset: combined.length);
        widget.onChanged?.call(combined);
        if (result.finalResult && mounted) {
          setState(() => _isListening = false);
        }
      },
      listenOptions: stt.SpeechListenOptions(localeId: effectiveLocaleId),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isAvailable ? _toggleListening : null,
      icon: Icon(
        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
        color: _isListening ? AppColors.danger : AppColors.textSecondary,
      ),
      tooltip: AppLocalizations.of(context)!.voiceInputTooltip,
    );
  }
}
