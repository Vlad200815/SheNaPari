import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenapari/core/network/api_envelope.dart';
import 'package:shenapari/features/legal/data/legal_api.dart';
import 'package:shenapari/features/legal/data/legal_document_dto.dart';
import 'package:shenapari/features/legal/data/legal_repository_impl.dart';
import 'package:shenapari/features/legal/domain/entities/legal_document.dart';

/// Answers with [document], or fails like a dropped connection when null.
class _FakeLegalApi implements LegalApi {
  LegalDocumentDto? document;
  final requested = <String>[];

  @override
  Future<ApiEnvelope<LegalDocumentDto>> get(String type) async {
    requested.add(type);
    final document = this.document;
    if (document == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/legal/$type'),
        type: DioExceptionType.connectionError,
      );
    }
    return ApiEnvelope(succeeded: true, data: document);
  }
}

const _fresh = LegalDocumentDto(version: 'v2', content: '## Нова редакція');

void main() {
  late _FakeLegalApi api;
  late SharedPreferences prefs;
  late LegalRepositoryImpl repository;
  var language = 'uk';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    language = 'uk';
    prefs = await SharedPreferences.getInstance();
    api = _FakeLegalApi();
    repository = LegalRepositoryImpl(
      api,
      prefs,
      loadAsset: (path) async => 'bundled $path',
      languageCode: () => language,
    );
  });

  test('English: its own bundled copy and its own cache', () async {
    // Ukrainian seen once and cached…
    api.document = _fresh;
    await repository.get(LegalDocumentType.terms);

    // …then offline in English: not the Ukrainian cache, the English copy.
    language = 'en';
    api.document = null;
    final document = await repository.get(LegalDocumentType.terms);

    expect(document.content, 'bundled assets/legal/terms.en.md');
  });

  test('takes the document from the server', () async {
    api.document = _fresh;

    final document = await repository.get(LegalDocumentType.privacy);

    expect(api.requested, ['privacy']);
    expect(
      document,
      const LegalDocument(
        type: LegalDocumentType.privacy,
        version: 'v2',
        content: '## Нова редакція',
      ),
    );
  });

  test('offline it shows the last copy from the server', () async {
    api.document = _fresh;
    await repository.get(LegalDocumentType.terms);

    api.document = null;
    final document = await repository.get(LegalDocumentType.terms);

    expect(document.version, 'v2');
    expect(document.content, '## Нова редакція');
  });

  test('offline and never loaded: the copy bundled with the app', () async {
    final document = await repository.get(LegalDocumentType.terms);

    expect(document.version, isNull);
    expect(document.content, 'bundled assets/legal/terms.md');
  });

  test('a broken cache entry falls back to the bundled copy', () async {
    await prefs.setString('legal_terms', '{not json');

    final document = await repository.get(LegalDocumentType.terms);

    expect(document.content, 'bundled assets/legal/terms.md');
  });

  test('each document has its own cache', () async {
    api.document = _fresh;
    await repository.get(LegalDocumentType.terms);

    api.document = null;
    final privacy = await repository.get(LegalDocumentType.privacy);

    expect(privacy.content, 'bundled assets/legal/privacy.md');
  });
}
