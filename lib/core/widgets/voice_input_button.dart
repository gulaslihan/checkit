import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../theme/app_colors.dart';

/// Reusable microphone button — tap to start listening, tap again to stop.
/// Recognized text streams back through [onResult] as the user speaks.
class VoiceInputButton extends StatefulWidget {
  final ValueChanged<String> onResult;
  final String localeId;

  const VoiceInputButton({super.key, required this.onResult, this.localeId = 'tr_TR'});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;

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
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        widget.onResult(result.recognizedWords);
        if (result.finalResult && mounted) {
          setState(() => _isListening = false);
        }
      },
      listenOptions: stt.SpeechListenOptions(localeId: widget.localeId),
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
      tooltip: 'Sesli komut',
    );
  }
}
