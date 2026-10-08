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

  /// Bumped whenever a listening session starts or ends, so results that
  /// arrive late from an already-ended session are ignored. iOS keeps the
  /// recognizer running well after the user stops talking and can deliver
  /// a final result after the field was submitted and cleared — without
  /// this, that late result wrote the previous item back into the field.
  int _session = 0;

  /// The text this button last wrote into the controller. If the
  /// controller's text differs from it while listening, someone else
  /// changed the field (item submitted and cleared, or the user typed), so
  /// the session is cancelled instead of overwriting their change.
  String? _lastWritten;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _speech.initialize(onStatus: _onStatus).then((available) {
      if (mounted) setState(() => _isAvailable = available);
    });
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (_isListening && widget.controller.text != _lastWritten) {
      _endSession(cancel: true);
    }
  }

  void _onStatus(String status) {
    // iOS doesn't always deliver a finalResult; 'done'/'notListening' is
    // the reliable signal that the recognizer has stopped.
    if ((status == stt.SpeechToText.doneStatus || status == stt.SpeechToText.notListeningStatus) && _isListening) {
      _endSession();
    }
  }

  void _endSession({bool cancel = false}) {
    _session++;
    _lastWritten = null;
    if (cancel) _speech.cancel();
    if (mounted && _isListening) setState(() => _isListening = false);
  }

  Future<void> _toggleListening() async {
    if (!_isAvailable) return;
    if (_isListening) {
      await _speech.stop();
      _endSession();
      return;
    }
    final session = ++_session;
    _baseText = widget.controller.text.trim();
    _lastWritten = widget.controller.text;
    final locale = Localizations.localeOf(context);
    final effectiveLocaleId = widget.localeId ?? (locale.languageCode == 'tr' ? 'tr_TR' : 'en_US');
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        if (session != _session) return;
        final spoken = result.recognizedWords;
        final combined = _baseText.isEmpty
            ? spoken
            : (spoken.isEmpty ? _baseText : '$_baseText $spoken');
        _lastWritten = combined;
        widget.controller.text = combined;
        widget.controller.selection = TextSelection.collapsed(offset: combined.length);
        widget.onChanged?.call(combined);
        if (result.finalResult) _endSession();
      },
      listenOptions: stt.SpeechListenOptions(localeId: effectiveLocaleId),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
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
