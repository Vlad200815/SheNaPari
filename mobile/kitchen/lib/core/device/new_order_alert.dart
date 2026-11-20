import 'package:audioplayers/audioplayers.dart';

/// The chime for a new order: the kitchen hears it across the room.
abstract interface class NewOrderAlert {
  Future<void> play();
}

class SoundNewOrderAlert implements NewOrderAlert {
  final _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  @override
  Future<void> play() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/new_order.wav'));
    } on Object {
      // No sound (muted device, no audio focus): the toast still shows.
    }
  }
}
