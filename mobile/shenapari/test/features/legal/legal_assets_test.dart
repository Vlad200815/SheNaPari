import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shenapari/features/legal/data/legal_repository_impl.dart';
import 'package:shenapari/features/legal/domain/entities/legal_document.dart';

/// The app bundles offline copies of the texts the backend serves; this
/// fails as soon as one side is edited without the other.
void main() {
  for (final type in LegalDocumentType.values) {
    for (final language in ['uk', 'en']) {
      final bundled = bundledLegalPath(type, language);
      test('$bundled matches the backend', () {
        final name = bundled.split('/').last;
        final server = File('../../backend/src/ShenaPari.Api/Legal/$name');

        expect(File(bundled).readAsStringSync(), server.readAsStringSync());
      });
    }
  }
}
