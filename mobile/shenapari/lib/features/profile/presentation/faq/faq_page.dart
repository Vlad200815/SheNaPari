import 'package:material_ui/material_ui.dart';

import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/app_theme.dart';
import '../../../../core/l10n/l10n.dart';
import 'package:shenapari_core/ui/app_colors.dart';

/// Short answers to what customers ask most. The rules quoted here are the
/// backend's: 30 minutes to pick up, cancel until cooking, simulated pay.
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static List<(String, String)> get items => [
    (LocaleKeys.faq_how_order_q.tr(), LocaleKeys.faq_how_order_a.tr()),
    (LocaleKeys.faq_when_q.tr(), LocaleKeys.faq_when_a.tr()),
    (LocaleKeys.faq_pickup_q.tr(), LocaleKeys.faq_pickup_a.tr()),
    (LocaleKeys.faq_late_q.tr(), LocaleKeys.faq_late_a.tr()),
    (LocaleKeys.faq_cancel_q.tr(), LocaleKeys.faq_cancel_a.tr()),
    (LocaleKeys.faq_payment_q.tr(), LocaleKeys.faq_payment_a.tr()),
    (LocaleKeys.faq_cant_order_q.tr(), LocaleKeys.faq_cant_order_a.tr()),
    (LocaleKeys.faq_name_q.tr(), LocaleKeys.faq_name_a.tr()),
    (LocaleKeys.faq_delete_q.tr(), LocaleKeys.faq_delete_a.tr()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        title: Text(LocaleKeys.faq_title.tr(), style: AppText.title()),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimens.horizontalPadding),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) =>
            _Question(question: items[i].$1, answer: items[i].$2),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // No divider lines around the expanded tile.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: context.colors.textPrimary,
          collapsedIconColor: context.colors.iconMuted,
          title: Text(
            question,
            style: AppText.medium().copyWith(fontWeight: FontWeight.w600),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(answer, style: AppText.regular()),
            ),
          ],
        ),
      ),
    );
  }
}
