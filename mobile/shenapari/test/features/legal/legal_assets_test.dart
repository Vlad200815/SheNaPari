import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/features/legal/domain/entities/legal_document.dart';

/// The app bundles offline copies of the texts the backend serves; this
/// fails as soon as one side is edited without the other.
void main() {
  for (final type in LegalDocumentType.values) {
    test('assets/legal/${type.name}.md matches the backend', () {
      final bundled = File('assets/legal/${type.name}.md');
      final server = File(
        '../../backend/src/ShenaPari.Api/Legal/${type.name}.md',
      );

      expect(bundled.readAsStringSync(), server.readAsStringSync());
    });
  }
}
