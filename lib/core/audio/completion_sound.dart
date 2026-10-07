import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Plays the item-completion chime — unlike SystemSound.play(), this isn't
/// gated behind the OS's phone-wide "touch sounds" setting.
///
/// Uses a fresh [AudioPlayer] per call rather than one shared/reused
/// instance: a shared player's state machine sometimes got stuck after its
/// first playback on some devices, so checking off several items in a row
/// only played a sound for the first one. A short-lived player per call
/// sidesteps that entirely and also handles rapid back-to-back completions
/// correctly (each gets its own independent playback).
Future<void> playCompletionSound() async {
  final player = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
  unawaited(player.onPlayerComplete.first.then((_) => player.dispose()));
  await player.play(AssetSource('sounds/complete_chime.wav'));
}
