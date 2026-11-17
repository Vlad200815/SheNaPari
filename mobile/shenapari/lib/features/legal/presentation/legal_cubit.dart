import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/legal_document.dart';
import '../domain/legal_repository.dart';

/// Null while loading. The repository never fails (it falls back to the
/// cache or the bundled copy), so there is no failure state.
class LegalCubit extends Cubit<LegalDocument?> {
  LegalCubit(this._legal, this._type) : super(null);

  final LegalRepository _legal;
  final LegalDocumentType _type;

  Future<void> load() async => emit(await _legal.get(_type));
}
