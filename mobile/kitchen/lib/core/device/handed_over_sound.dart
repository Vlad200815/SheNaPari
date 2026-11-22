import 'package:audioplayers/audioplayers.dart';

/// «М'який дзинь угору» when an order is handed over (a valid QR, or
/// «Видати» after a number): the same success sound as the customers'
/// «Оплачено» (assets/sounds/success.wav, from the customer app's
/// tool/render_success_sound.py).
abstract interface class HandedOverSound {
  Future<void> play();
}

class AudioHandedOverSound implements HandedOverSound {
  late final _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  @override
  Future<void> play() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/success.wav'));
    } on Object {
      // No sound: the green card and the haptic still say it.
    }
  }
}
