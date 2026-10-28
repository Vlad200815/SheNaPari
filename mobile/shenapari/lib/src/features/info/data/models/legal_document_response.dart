import 'package:json_annotation/json_annotation.dart';
import 'package:shenapari/src/features/info/domain/entities/legal_document_entity.dart';

part "legal_document_response.g.dart";

@JsonSerializable()
class LegalDocumentResponse {
  /// version
  @JsonKey(name: "version")
  final String? version;

  /// content
  @JsonKey(name: "content")
  final String? content;

  const LegalDocumentResponse({required this.version, required this.content});

  /// Deserializer...
  factory LegalDocumentResponse.fromJson(Map<String, dynamic> json) =>
      _$LegalDocumentResponseFromJson(json);

  /// Serializer...
  Map<String, dynamic> toJson() => _$LegalDocumentResponseToJson(this);

  /// To Entity
  LegalDocumentEntity toEntity() =>
      LegalDocumentEntity(version: version, content: content);
}
