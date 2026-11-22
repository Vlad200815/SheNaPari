import 'package:audioplayers/audioplayers.dart';

/// The sound of a new order: «гам», the same as the customers' order
/// pushes (assets/sounds/gam.wav, made by the customer app's
/// tool/make_gam_sound.py from Vlad's recording).
abstract interface class NewOrderAlert {
  Future<void> play();
}

class SoundNewOrderAlert implements NewOrderAlert {
  final _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  @override
  Future<void> play() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/gam.wav'));
    } on Object {
      // No sound (muted device, no audio focus): the toast still shows.
    }
  }
}
