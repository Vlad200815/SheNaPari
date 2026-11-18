import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari/app/di.dart';
import 'package:shenapari/features/legal/domain/entities/legal_document.dart';
import 'package:shenapari/features/legal/domain/legal_repository.dart';
import 'package:shenapari/features/legal/presentation/legal_cubit.dart';
import 'package:shenapari/features/legal/presentation/legal_page.dart';
import 'package:shenapari/gen/colors.gen.dart';
import 'package:shenapari/core/ui/app_theme.dart';

class _FakeLegalRepository implements LegalRepository {
  _FakeLegalRepository(this.content);

  final String content;

  @override
  Future<LegalDocument> get(LegalDocumentType type) async =>
      LegalDocument(type: type, version: '1', content: content);
}

String _content = '';

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerFactoryParam<LegalCubit, LegalDocumentType, void>(
      (type, _) => LegalCubit(_FakeLegalRepository(_content), type),
    );
  });

  // flutter_markdown_plus comes from the legacy flutter/material world;
  // this makes sure it renders inside our material_ui Scaffold.
  testWidgets('shows the title and the Markdown text', (tester) async {
    _content = '## 1. Розділ\n\nТекст **документа**.';
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const LegalPage(type: LegalDocumentType.privacy),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Політика конфіденційності'), findsOneWidget);
    expect(find.text('1. Розділ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('refund terms: own title and hint', (tester) async {
    _content = 'Текст.';
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const LegalPage(type: LegalDocumentType.refund),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Умови повернення коштів'), findsOneWidget);
    expect(
      find.text('Коли і як повертаються кошти за замовлення'),
      findsOneWidget,
    );
  });

  testWidgets('a mail link that cannot open is copied instead', (tester) async {
    _content = '[support@example.com](mailto:support@example.com)';
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );

    final launched = <Object?>[];
    // The phone has no app for the link: url_launcher answers "not opened".
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (call) async {
        launched.add(call.arguments);
        return false;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const LegalPage(type: LegalDocumentType.terms),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('support@example.com'));
    await tester.pumpAndSettle();

    expect(launched, isNotEmpty, reason: 'the link was tapped');
    expect(copied, 'support@example.com');
    expect(find.textContaining('скопіювали'), findsOneWidget);
  });

  testWidgets('links in the text are brand yellow', (tester) async {
    _content = 'Пишіть на [support@example.com](mailto:support@example.com).';

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const LegalPage(type: LegalDocumentType.terms),
      ),
    );
    await tester.pumpAndSettle();

    final spans = <TextSpan>[];
    for (final text in tester.widgetList<RichText>(find.byType(RichText))) {
      text.text.visitChildren((span) {
        if (span is TextSpan) spans.add(span);
        return true;
      });
    }
    final link = spans.singleWhere((s) => s.text == 'support@example.com');
    final plain = spans.singleWhere((s) => s.text == 'Пишіть на ');

    expect(link.style?.color, ColorName.primary400);
    expect(plain.style?.color, isNot(ColorName.primary400));
  });
}
