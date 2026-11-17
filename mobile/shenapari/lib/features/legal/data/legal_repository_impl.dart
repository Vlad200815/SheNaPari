import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_call.dart';
import '../../../core/result/result.dart';
import '../domain/entities/legal_document.dart';
import '../domain/legal_repository.dart';
import 'legal_api.dart';
import 'legal_document_dto.dart';

/// Reads a bundled asset; `rootBundle.loadString` in the app.
typedef AssetLoader = Future<String> Function(String path);

class LegalRepositoryImpl implements LegalRepository {
  LegalRepositoryImpl(this._api, this._prefs, {required AssetLoader loadAsset})
    : _loadAsset = loadAsset;

  final LegalApi _api;
  final SharedPreferences _prefs;
  final AssetLoader _loadAsset;

  @override
  Future<LegalDocument> get(LegalDocumentType type) async {
    switch (await apiCall(() => _api.get(type.name), (dto) => dto)) {
      case Ok(value: final dto):
        await _prefs.setString(_cacheKey(type), jsonEncode(dto.toJson()));
        return dto.toEntity(type);
      case Err():
        return _cached(type) ?? await _bundled(type);
    }
  }

  LegalDocument? _cached(LegalDocumentType type) {
    final json = _prefs.getString(_cacheKey(type));
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return LegalDocumentDto.fromJson(map).toEntity(type);
    } on Object {
      return null; // A broken cache entry is as good as none.
    }
  }

  Future<LegalDocument> _bundled(LegalDocumentType type) async => LegalDocument(
    type: type,
    version: null,
    content: await _loadAsset('assets/legal/${type.name}.md'),
  );

  static String _cacheKey(LegalDocumentType type) => 'legal_${type.name}';
}
