import 'package:equatable/equatable.dart';

/// Its title for the screen is in `legal_texts.dart` (presentation).
enum LegalDocumentType { terms, privacy, refund }

class LegalDocument extends Equatable {
  const LegalDocument({
    required this.type,
    required this.version,
    required this.content,
  });

  final LegalDocumentType type;

  /// Changes whenever the text changes; null for the copy bundled with the
  /// app, which has no server version.
  final String? version;

  /// Markdown.
  final String content;

  @override
  List<Object?> get props => [type, version, content];
}
