import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/features/menu/domain/entities/break_slot.dart';
import 'package:shenapari/features/menu/presentation/home/break_countdown.dart';

final _slot = BreakSlot(
  id: 1,
  startsAt: DateTime(2026, 11, 17, 11, 40),
  endsAt: DateTime(2026, 11, 17, 12, 0),
);

BreakCountdown _at(int hour, int minute, {int day = 17, int second = 0}) =>
    BreakCountdown(_slot, DateTime(2026, 11, day, hour, minute, second));

void main() {
  group('title', () {
    test('a break today', () {
      expect(_at(11, 15).title, 'Наступна перерва · 11:40');
    });

    test('a break tomorrow', () {
      expect(_at(20, 0, day: 16).title, 'Завтра · 11:40');
    });

    test('a break later shows the date', () {
      expect(_at(20, 0, day: 14).title, '17.11 · 11:40');
    });
  });

  group('time left', () {
    test('minutes', () {
      expect(_at(11, 15).timeLeft, 'ще 25 хв');
    });

    test('hours and minutes', () {
      expect(_at(10, 35).timeLeft, 'ще 1 год 05 хв');
    });

    test('the last minute', () {
      expect(_at(11, 39, second: 30).timeLeft, 'менше хвилини');
    });
  });

  group('progress', () {
    test('empty before the order window', () {
      expect(_at(9, 0).progress, 0);
    });

    test('fills during the window', () {
      // 45 of 90 minutes left.
      expect(_at(10, 55).progress, closeTo(0.5, 0.001));
    });

    test('full when the break starts', () {
      expect(_at(11, 40).progress, 1);
      expect(_at(11, 40).hasStarted, isTrue);
      expect(_at(11, 39).hasStarted, isFalse);
    });
  });

  test('clock is always two digits', () {
    expect(formatClock(DateTime(2026, 1, 1, 8, 5)), '08:05');
  });
}
