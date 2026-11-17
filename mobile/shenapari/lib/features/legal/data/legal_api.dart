import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/network/api_envelope.dart';
import 'legal_document_dto.dart';

part 'legal_api.g.dart';

@RestApi()
abstract class LegalApi {
  factory LegalApi(Dio dio) = _LegalApi;

  /// [type] is `terms` or `privacy`. Works without a token.
  @GET('/legal/{type}')
  Future<ApiEnvelope<LegalDocumentDto>> get(@Path('type') String type);
}
