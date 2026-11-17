import 'package:json_annotation/json_annotation.dart';

import '../domain/entities/legal_document.dart';

part 'legal_document_dto.g.dart';

/// `GET /legal/{type}`; also how the last seen copy is cached.
@JsonSerializable()
class LegalDocumentDto {
  const LegalDocumentDto({required this.version, required this.content});

  factory LegalDocumentDto.fromJson(Map<String, dynamic> json) =>
      _$LegalDocumentDtoFromJson(json);

  final String version;
  final String content;

  Map<String, dynamic> toJson() => _$LegalDocumentDtoToJson(this);

  LegalDocument toEntity(LegalDocumentType type) =>
      LegalDocument(type: type, version: version, content: content);
}
