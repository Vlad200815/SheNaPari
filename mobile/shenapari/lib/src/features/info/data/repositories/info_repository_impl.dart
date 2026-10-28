import 'package:shenapari/src/app/config.dart';
import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/features/info/domain/entities/legal_document_entity.dart';
import 'package:shenapari/src/features/info/domain/repositories/info_repository.dart';

class InfoRepositoryImpl implements InfoRepository {
  // Mock version simulates a server-pushed update.
  // When backend is ready, replace with a real HTTP call that reads
  // X-Legal-Update-Required and X-Legal-Required-Version response headers.
  static const _mockVersion = '1.0.1';

  @override
  Future<Result<LegalDocumentEntity>> fetchPrivacyPolicy() async {
    return Result<LegalDocumentEntity>(
      succeeded: true,
      message: 'ok',
      data: LegalDocumentEntity(
        version: _mockVersion,
        content: Config.PRIVACY_POLICY_UK_FALLBACK,
      ),
    );
  }

  @override
  Future<Result<LegalDocumentEntity>> fetchTermsOfUse() async {
    return Result<LegalDocumentEntity>(
      succeeded: true,
      message: 'ok',
      data: LegalDocumentEntity(
        version: _mockVersion,
        content: Config.TERMS_OF_USE_UK_FALLBACK,
      ),
    );
  }
}
