import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/features/info/domain/entities/legal_document_entity.dart';

abstract interface class InfoRepository {
  Future<Result<LegalDocumentEntity>> fetchTermsOfUse();
  Future<Result<LegalDocumentEntity>> fetchPrivacyPolicy();
}
