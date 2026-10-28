import 'package:shenapari/src/core/base/base_view_state.dart';

final class LegalState extends ViewState {
  final String? documentContent;

  LegalState({this.documentContent});

  LegalState copyWith({String? documentContent}) {
    return LegalState(documentContent: documentContent ?? this.documentContent);
  }

  @override
  List<Object?> get props => [documentContent];
}
