import 'package:equatable/equatable.dart';

enum LegalDocumentType {
  terms('Умови використання'),
  privacy('Політика конфіденційності');

  const LegalDocumentType(this.title);

  /// Shown as the page title.
  final String title;
}

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
