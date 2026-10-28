import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shenapari/src/app/config.dart';
import 'package:shenapari/src/core/base/base_view_model.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/preference/app_preference.dart';
import 'package:shenapari/src/core/servies/legal_content_loader_mixin.dart';
import 'package:shenapari/src/core/servies/url_handler_mixin.dart';
import 'package:shenapari/src/features/info/domain/usecases/fetch_privacy_policy.dart';
import 'package:shenapari/src/features/info/domain/usecases/fetch_terms_of_use.dart';

import 'legal_action.dart';
import 'legal_event.dart';
import 'legal_state.dart';

class LegalViewModel extends BaseViewModel<LegalState, LegalEvent, LegalAction>
    with LegalContentLoaderMixin, UrlHandlerMixin {
  final FetchPrivacyPolicyUseCase _fetchPrivacyPolicyUseCase;
  final FetchTermsOfUseUseCase _fetchTermsOfUseUseCase;

  final DocumentType? _documentType;

  String? _documentContent;

  LegalViewModel({
    required FetchPrivacyPolicyUseCase fetchPrivacyPolicyUseCase,
    required FetchTermsOfUseUseCase fetchTermsOfUseUseCase,
    required DocumentType? documentType,
  }) : _documentType = documentType,
       _fetchPrivacyPolicyUseCase = fetchPrivacyPolicyUseCase,
       _fetchTermsOfUseUseCase = fetchTermsOfUseUseCase,
       super(LegalState());

  @override
  Future<void> onViewCreate(
    Emitter<LegalState> emitter,
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) async {
    await _fetchDocumentContent(emitter, _documentType);
  }

  @override
  Future<void> onViewAction(
    LegalAction action,
    Emitter<LegalState> emitter,
  ) async {
    switch (action) {
      case OnLinkPressedAction action:
        await _handleOnLinkPressedAction(action, emitter);
    }
  }

  ///
  /// Handle [OnLinkPressedAction]
  ///
  Future<void> _handleOnLinkPressedAction(
    OnLinkPressedAction action,
    Emitter<LegalState> emitter,
  ) async {
    loading(true);
    try {
      bool isSuccess = await launchLink(action.href.orEmpty());
      if (!isSuccess) {
        //TODO: add this to localization!
        message("Something went wrong");
      }
    } catch (e) {
      setThrowable(e);
    } finally {
      loading(false);
    }
  }

  /// Fetch Document Content
  Future<void> _fetchDocumentContent(
    Emitter<LegalState> emitter,
    DocumentType? documentType,
  ) async {
    switch (documentType) {
      case null:
        //TODO: replace this with a valid text
        setThrowable("Something went wrong");
      case DocumentType.termsOfUse:
        await _fetchTermsOfUse(emitter);
      case DocumentType.privacyPolicy:
        await _fetchPrivacyPolicy(emitter);
      case DocumentType.removalConditions:
        //TODO: add removal conditions
        debugPrint("Add removal conditions");
    }
  }

  /// Fetch Terms Of Use
  Future<void> _fetchTermsOfUse(Emitter<LegalState> emitter) async {
    final language = await AppPreference.language;
    final acceptedVersion = await AppPreference.acceptedTermsOfUseVersion;

    final result = await loadLegalDocument(
      acceptedVersion: acceptedVersion,
      fetchFromApi: () => _fetchTermsOfUseUseCase.perform(),
      fetchFromCache: () => AppPreference.termsOfUse,
      saveToCache: (entity) => AppPreference.setTermsOfUse(entity),
      assetPath: language == Config.UK
          ? Config.TERMS_OF_USE_UK_PATH
          : Config.TERMS_OF_USE_EN_PATH,
      documentType: "Terms of Use",
      onLoading: (isLoading) => loading(isLoading),
      onErrorCaught: (error) => setThrowable(error),
    );

    if (result?.data?.content != null) {
      _documentContent = result!.data!.content.orEmpty();
      _updateState(emitter);
    }
  }

  /// Fetch Privacy Policy
  Future<void> _fetchPrivacyPolicy(Emitter<LegalState> emitter) async {
    final language = await AppPreference.language;
    final acceptedVersion = await AppPreference.acceptedPrivacyPolicyVersion;

    final result = await loadLegalDocument(
      acceptedVersion: acceptedVersion,
      fetchFromApi: () => _fetchPrivacyPolicyUseCase.perform(),
      fetchFromCache: () => AppPreference.privacyPolicy,
      saveToCache: (entity) => AppPreference.setPrivacyPolicy(entity),
      assetPath: language == Config.UK
          ? Config.PRIVACY_POLICY_UK_PATH
          : Config.PRIVACY_POLICY_EN_PATH,
      documentType: "Privacy Policy",
      onLoading: (isLoading) => loading(isLoading),
      onErrorCaught: (error) => setThrowable(error),
    );

    if (result?.data?.content != null) {
      _documentContent = result?.data?.content.orEmpty();
      _updateState(emitter);
    }
  }

  /// Update State
  void _updateState(Emitter<LegalState> emitter) {
    emitter(state.copyWith(documentContent: _documentContent));
  }
}
