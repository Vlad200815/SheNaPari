import 'package:flutter/foundation.dart';
import 'package:shenapari/src/core/network/result.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/features/info/domain/entities/legal_document_entity.dart';

mixin LegalContentLoaderMixin {
  Future<Result<LegalDocumentEntity>?> loadLegalDocument({
    required String acceptedVersion,
    required Future<Result<LegalDocumentEntity>> Function() fetchFromApi,
    required Future<LegalDocumentEntity?> Function() fetchFromCache,
    required Future<void> Function(LegalDocumentEntity) saveToCache,
    required String assetPath,
    required String documentType,
    required ValueChanged<bool> onLoading,
    required ValueChanged<Object> onErrorCaught,
  }) async {
    onLoading(true);

    try {
      try {
        final result = await fetchFromApi();
        final apiData = result.data;

        if (result.succeeded.orFalse() && apiData != null) {
          if (apiData.version != acceptedVersion) {
            // New version available — notify the caller before returning the content
            debugPrint(
              "$documentType update detected: server=${apiData.version}, accepted=$acceptedVersion",
            );
            return result;
          } else {
            await saveToCache(apiData);
            debugPrint("$documentType loaded from API successfully.");
            return result;
          }
        }
      } catch (apiError) {
        debugPrint("$documentType API error: $apiError");
        onErrorCaught(apiError);
      }

      try {
        final cachedEntity = await fetchFromCache();

        if (cachedEntity != null) {
          debugPrint("$documentType loaded from Cache successfully.");
          return Result<LegalDocumentEntity>(
            succeeded: true,
            message: "$documentType loaded from Cache successfully.",
            data: cachedEntity,
          );
        }
      } catch (cacheError) {
        debugPrint("Cache Error: $cacheError");
        onErrorCaught(cacheError);
      }
    } finally {
      onLoading(false);
    }
    return null;
  }
}
