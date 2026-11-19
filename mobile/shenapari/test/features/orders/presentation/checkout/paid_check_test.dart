import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari/features/orders/presentation/checkout/widgets/paid_check.dart';

void main() {
  late List<String> haptics;

  setUp(() {
    haptics = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments as String);
          }
          return null;
        });
  });

  Future<void> pump(WidgetTester tester, {bool reduceMotion = false}) =>
      tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: const Center(child: PaidCheck()),
        ),
      );

  testWidgets('plays once and taps when the tick is drawn', (tester) async {
    await pump(tester);
    expect(haptics, isEmpty);

    await tester.pump(const Duration(milliseconds: 600));
    expect(haptics, ['HapticFeedbackType.mediumImpact']);

    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('with «reduce motion» it is simply there', (tester) async {
    await pump(tester, reduceMotion: true);

    expect(tester.hasRunningAnimations, isFalse);
    await tester.pump(const Duration(seconds: 1));
    expect(haptics, isEmpty);
  });
}
