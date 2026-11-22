import 'package:audioplayers/audioplayers.dart';

/// The sound of a new order: «Дзинь на видачу», the customer app's success
/// sound (assets/sounds/success.wav, rendered by its
/// tool/render_success_sound.py).
abstract interface class NewOrderAlert {
  Future<void> play();
}

class SoundNewOrderAlert implements NewOrderAlert {
  final _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  @override
  Future<void> play() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/success.wav'));
    } on Object {
      // No sound (muted device, no audio focus): the toast still shows.
    }
  }
}
