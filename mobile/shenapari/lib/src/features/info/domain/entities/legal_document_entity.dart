import 'package:equatable/equatable.dart';

class LegalDocumentEntity extends Equatable {
  final String? version;
  final String? content;

  const LegalDocumentEntity({required this.version, required this.content});

  Map<String, dynamic> toJson() {
    return {'version': version, 'content': content};
  }

  @override
  List<Object?> get props => [version, content];
}
