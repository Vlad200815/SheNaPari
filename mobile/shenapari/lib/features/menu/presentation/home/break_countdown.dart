import '../../domain/entities/break_slot.dart';

/// Orders for a break are usually placed during the class before it,
/// so the progress bar fills over this window.
const orderWindow = Duration(minutes: 90);

/// What the break card shows at [now]. Pure, so it is tested without
/// widgets or timers.
class BreakCountdown {
  BreakCountdown(this.slot, this.now) : left = slot.startsAt.difference(now);

  final BreakSlot slot;
  final DateTime now;

  /// Time until the break starts; zero or negative once it has started.
  final Duration left;

  bool get hasStarted => left <= Duration.zero;

  /// 0 at the start of [orderWindow], 1 when the break starts.
  double get progress {
    final share = left.inSeconds / orderWindow.inSeconds;
    return (1 - share).clamp(0.0, 1.0);
  }

  /// `Наступна перерва · 11:40`, `Завтра · 08:30` or `21.11 · 08:30`.
  String get title {
    final time = formatClock(slot.startsAt);
    final days = _dayOf(slot.startsAt).difference(_dayOf(now)).inDays;
    return switch (days) {
      <= 0 => 'Наступна перерва · $time',
      1 => 'Завтра · $time',
      _ => '${_two(slot.startsAt.day)}.${_two(slot.startsAt.month)} · $time',
    };
  }

  /// `ще 25 хв`, `ще 1 год 05 хв`, `менше хвилини`.
  String get timeLeft {
    if (left < const Duration(minutes: 1)) return 'менше хвилини';
    final hours = left.inHours;
    final minutes = left.inMinutes % 60;
    if (hours == 0) return 'ще $minutes хв';
    return 'ще $hours год ${_two(minutes)} хв';
  }

  /// UTC midnight of the local date: a day across a DST switch is still
  /// 24 hours, so `inDays` counts calendar days correctly.
  static DateTime _dayOf(DateTime time) =>
      DateTime.utc(time.year, time.month, time.day);
}

/// `11:40`.
String formatClock(DateTime time) => '${_two(time.hour)}:${_two(time.minute)}';

String _two(int value) => value.toString().padLeft(2, '0');
