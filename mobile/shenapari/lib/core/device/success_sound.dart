import 'package:audioplayers/audioplayers.dart';
import 'package:shenapari_core/storage/app_prefs.dart';

/// «М'який дзинь угору» with the yellow tick (Оплачено, Дякуємо!). Off with
/// «Звуки в застосунку»; the phone's silent mode mutes it too.
abstract interface class SuccessSound {
  Future<void> play();
}

class AudioSuccessSound implements SuccessSound {
  AudioSuccessSound(this._prefs);

  final AppPrefs _prefs;
  late final _player = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop)
    ..setAudioContext(
      AudioContext(
        // A short UI sound: follows the ringer/silent switch, never pauses
        // the music someone is listening to.
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
        android: const AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.none,
        ),
      ),
    );

  @override
  Future<void> play() async {
    if (!_prefs.sounds) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/success.wav'));
    } on Object {
      // No sound is fine: the tick and the haptic already say it.
    }
  }
}
