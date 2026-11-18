import '../../../core/l10n/l10n.dart';
import '../domain/entities/legal_document.dart';

extension LegalDocumentTypeText on LegalDocumentType {
  /// Shown as the page title and in the lists that lead to it.
  String get title => switch (this) {
    LegalDocumentType.terms => LocaleKeys.legal_terms.tr(),
    LegalDocumentType.privacy => LocaleKeys.legal_privacy.tr(),
    LegalDocumentType.refund => LocaleKeys.legal_refund.tr(),
  };
}
