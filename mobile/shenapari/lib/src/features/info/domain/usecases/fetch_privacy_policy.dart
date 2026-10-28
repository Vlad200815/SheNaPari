import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/core/others/usecase.dart';
import 'package:shenapari/src/features/info/domain/entities/legal_document_entity.dart';
import 'package:shenapari/src/features/info/domain/repositories/info_repository.dart';

class FetchPrivacyPolicyUseCase extends Functions<Result<LegalDocumentEntity>> {
  final InfoRepository _legalRepository;

  FetchPrivacyPolicyUseCase({required InfoRepository legalRepository})
    : _legalRepository = legalRepository;

  @override
  Future<Result<LegalDocumentEntity>> perform() async {
    return await _legalRepository.fetchPrivacyPolicy();
  }
}
