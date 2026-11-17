import 'entities/legal_document.dart';

abstract interface class LegalRepository {
  /// The newest text available: from the server, else the last one seen,
  /// else the copy bundled with the app. Never fails: a legal document must
  /// open even without a connection.
  Future<LegalDocument> get(LegalDocumentType type);
}
