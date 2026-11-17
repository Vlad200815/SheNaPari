import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/di.dart';
import '../../../core/ui/app_text.dart';
import '../../../core/ui/app_theme.dart';
import '../../../gen/colors.gen.dart';
import '../domain/entities/legal_document.dart';
import 'legal_cubit.dart';

/// Terms of use or privacy policy: a title, a hint and the Markdown text in
/// a framed box with a always-visible scrollbar, so it is clear how long
/// the document is.
class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.type});

  final LegalDocumentType type;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LegalCubit>(param1: type)..load(),
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.horizontalPadding,
              0,
              AppDimens.horizontalPadding,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  type.title,
                  style: AppText.heading().copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  switch (type) {
                    LegalDocumentType.terms =>
                      'Будь ласка, уважно прочитайте Умови використання',
                    LegalDocumentType.privacy =>
                      'Будь ласка, уважно прочитайте Політику конфіденційності',
                  },
                  style: AppText.small(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimens.radius),
                      border: Border.all(color: ColorName.secondary200),
                    ),
                    child: BlocBuilder<LegalCubit, LegalDocument?>(
                      builder: (context, document) => document == null
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: ColorName.primary400,
                              ),
                            )
                          : _DocumentText(markdown: document.content),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentText extends StatefulWidget {
  const _DocumentText({required this.markdown});

  final String markdown;

  @override
  State<_DocumentText> createState() => _DocumentTextState();
}

class _DocumentTextState extends State<_DocumentText> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _openLink(String? href) async {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final body = AppText.small(color: ColorName.typography900);
    return RawScrollbar(
      controller: _scroll,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      thickness: 6,
      radius: const Radius.circular(6),
      trackRadius: const Radius.circular(6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      thumbColor: ColorName.secondary400,
      trackColor: ColorName.secondary100,
      trackBorderColor: Colors.transparent,
      child: Markdown(
        controller: _scroll,
        data: widget.markdown,
        // Room on the right so the text never runs under the scrollbar.
        padding: const EdgeInsets.fromLTRB(16, 16, 28, 16),
        onTapLink: (_, href, _) => _openLink(href),
        styleSheet: MarkdownStyleSheet(
          h2: AppText.medium().copyWith(fontWeight: FontWeight.w700),
          h2Padding: const EdgeInsets.only(top: 8),
          h3: body.copyWith(fontWeight: FontWeight.w700),
          p: body,
          pPadding: const EdgeInsets.only(bottom: 4),
          listBullet: body,
          strong: body.copyWith(fontWeight: FontWeight.w700),
          a: body.copyWith(
            color: ColorName.primary600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
