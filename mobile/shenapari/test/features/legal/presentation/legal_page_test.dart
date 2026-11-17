import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari/app/di.dart';
import 'package:shenapari/features/legal/domain/entities/legal_document.dart';
import 'package:shenapari/features/legal/domain/legal_repository.dart';
import 'package:shenapari/features/legal/presentation/legal_cubit.dart';
import 'package:shenapari/features/legal/presentation/legal_page.dart';

class _FakeLegalRepository implements LegalRepository {
  @override
  Future<LegalDocument> get(LegalDocumentType type) async => LegalDocument(
    type: type,
    version: '1',
    content: '## 1. Розділ\n\nТекст **документа**.',
  );
}

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerFactoryParam<LegalCubit, LegalDocumentType, void>(
      (type, _) => LegalCubit(_FakeLegalRepository(), type),
    );
  });

  // flutter_markdown_plus comes from the legacy flutter/material world;
  // this makes sure it renders inside our material_ui Scaffold.
  testWidgets('shows the title and the Markdown text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LegalPage(type: LegalDocumentType.privacy)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Політика конфіденційності'), findsOneWidget);
    expect(find.text('1. Розділ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
