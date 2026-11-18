import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../gen/colors.gen.dart';

/// Short answers to what customers ask most. The rules quoted here are the
/// backend's: 30 minutes to pick up, cancel until cooking, simulated pay.
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const items = [
    (
      'Як зробити замовлення?',
      'Додайте страви в кошик, натисніть «Оформити замовлення», оберіть '
          'перерву або «Якнайшвидше» і оплатіть.',
    ),
    (
      'Коли можна забрати?',
      'На перерві, яку ви обрали. Коли кухня позначить замовлення готовим, '
          'прийде сповіщення, а кнопка з QR у центрі почне світитися.',
    ),
    (
      'Як забрати замовлення?',
      'Натисніть кнопку з QR у центрі нижньої панелі й покажіть код на '
          'видачі. Номер замовлення теж є на екрані.',
    ),
    (
      'Що буде, якщо я не встигну?',
      'Готове замовлення чекає 30 хвилин. Після цього воно закривається як '
          '«не забрано».',
    ),
    (
      'Чи можна скасувати замовлення?',
      'Так, доки кухня не почала готувати: відкрийте замовлення і натисніть '
          '«Скасувати замовлення». Гроші буде повернуто.',
    ),
    (
      'Як працює оплата?',
      'У цій версії оплата через Apple Pay чи Google Pay імітується — гроші '
          'не списуються.',
    ),
    (
      'Чому не вдається оформити замовлення?',
      'Кухня могла тимчасово призупинити прийом — про це скаже банер на '
          'головній. Меню переглядати можна, замовити — трохи згодом.',
    ),
    (
      'Як змінити ім’я?',
      'Більше → Мій профіль. Номер телефону змінити не можна: це ваш логін.',
    ),
    (
      'Як видалити акаунт?',
      'Більше → Мій профіль → Налаштування → «Видалити акаунт». Спершу '
          'заберіть або скасуйте активні замовлення.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.secondary100,
      appBar: AppBar(
        backgroundColor: ColorName.secondary100,
        title: Text('Питання та відповіді', style: AppText.title()),
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
      color: ColorName.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // No divider lines around the expanded tile.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: ColorName.black,
          collapsedIconColor: ColorName.secondary400,
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
