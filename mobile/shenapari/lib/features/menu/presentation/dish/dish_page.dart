import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/dish_marks.dart';
import 'widgets/nutrition_card.dart';
import '../../../../app/di.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../core/ui/format_price.dart';
import '../../../../core/ui/quantity_stepper.dart';
import '../../../../core/ui/snack_bars.dart';
import '../../../../gen/colors.gen.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/presentation/cart_cubit.dart';
import '../../domain/entities/break_slot.dart';
import '../../domain/entities/dish.dart';
import '../home/break_countdown.dart';
import '../widgets/dish_card.dart';
import 'dish_cubit.dart';
import 'dish_state.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_colors.dart';

/// A dish: big photo on top, details on a white sheet, and a bottom bar
/// with the portion stepper and «Додати · 170 ₴».
class DishPage extends StatelessWidget {
  const DishPage({super.key, required this.dishId, this.initial});

  final int dishId;

  /// The dish the menu already has, to skip the loader.
  final Dish? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = sl<DishCubit>(param1: dishId, param2: initial);
        // Already in the cart: the stepper shows that amount, not 1.
        final inCart = context.read<CartCubit>().state.quantityOf(dishId);
        if (inCart > 0) cubit.setQuantity(inCart);
        return cubit..load();
      },
      child: BlocBuilder<DishCubit, DishState>(
        builder: (context, state) => Scaffold(
          backgroundColor: context.colors.surface,
          body: switch (state.status) {
            DishStatus.loading => const Center(
              child: CircularProgressIndicator(color: ColorName.primary400),
            ),
            DishStatus.failure => _LoadError(message: state.failure!.text),
            DishStatus.loaded => _DishView(state: state),
          },
          bottomNavigationBar: state.status == DishStatus.loaded
              ? _AddToCartBar(state: state)
              : null,
        ),
      ),
    );
  }
}

class _DishView extends StatelessWidget {
  const _DishView({required this.state});

  final DishState state;

  static const _heroHeight = 340.0;

  @override
  Widget build(BuildContext context) {
    final dish = state.dish!;
    final topInset = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        // Pale yellow backdrop with a decorative circle behind the photo.
        Container(
          height: _heroHeight + topInset,
          color: context.colors.accentSoft,
        ),
        Positioned(
          top: topInset - 40,
          right: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.accentDecor,
            ),
          ),
        ),
        ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: _heroHeight + topInset,
              child: Padding(
                padding: EdgeInsets.fromLTRB(40, topInset + 56, 40, 40),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DishImage(url: dish.imageUrl, radius: 24),
                    // Spicy / vegan on the photo: seen before the name.
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: DishMarks(dish: dish),
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: _Sheet(dish: dish, nextBreak: state.nextBreak),
            ),
          ],
        ),
        Positioned(
          top: topInset + 8,
          left: AppDimens.horizontalPadding,
          child: _RoundButton(
            icon: Icons.arrow_back_rounded,
            label: LocaleKeys.common_back.tr(),
            onTap: () => _back(context),
          ),
        ),
      ],
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.dish, required this.nextBreak});

  final Dish dish;
  final BreakSlot? nextBreak;

  @override
  Widget build(BuildContext context) {
    final nextBreak = this.nextBreak;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.horizontalPadding,
        24,
        AppDimens.horizontalPadding,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  dish.name,
                  style: AppText.title().copyWith(fontSize: 24, height: 1.25),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                formatPrice(dish.priceKopecks),
                style: AppText.title().copyWith(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (dish.isPopular)
                _MetaPill(
                  icon: Icons.local_fire_department_rounded,
                  text: LocaleKeys.home_hit.tr(),
                  highlighted: true,
                ),
              _MetaPill(
                icon: Icons.scale_outlined,
                text: LocaleKeys.home_weight.tr(
                  namedArgs: {'grams': '${dish.weightG}'},
                ),
              ),
              // With the macros the calories go into the card below.
              if (!dish.hasMacros)
                _MetaPill(
                  icon: Icons.bolt_rounded,
                  text: LocaleKeys.home_kcal.tr(
                    namedArgs: {'kcal': '${dish.kcal}'},
                  ),
                ),
            ],
          ),
          if (dish.hasMacros) ...[
            const SizedBox(height: 16),
            NutritionCard(dish: dish),
          ],
          if (nextBreak != null) ...[
            const SizedBox(height: 20),
            _PickupHint(slot: nextBreak),
          ],
          if (dish.description case final description?) ...[
            const SizedBox(height: 20),
            Text(
              LocaleKeys.dish_composition.tr(),
              style: AppText.medium().copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: AppText.regular(color: context.colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.text,
    this.highlighted = false,
  });

  final IconData icon;
  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: highlighted ? ColorName.primary400 : context.colors.fill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: highlighted ? ColorName.black : context.colors.textPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppText.small(
              color: highlighted ? ColorName.black : context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// «Забереш на перерві о 11:40» — the main promise of the app.
class _PickupHint extends StatelessWidget {
  const _PickupHint({required this.slot});

  final BreakSlot slot;

  @override
  Widget build(BuildContext context) {
    final countdown = BreakCountdown(slot, DateTime.now());
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.accentSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: ColorName.primary400,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: ColorName.black,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.dish_pickup_hint.tr(),
                  style: AppText.medium().copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${countdown.title} · ${countdown.timeLeft}',
                  style: AppText.small(color: context.colors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.state});

  final DishState state;

  /// Sets exactly the chosen amount: for a dish already in the cart the
  /// stepper started from its amount, so «Оновити» does not add on top.
  void _save(BuildContext context, {required bool inCart}) {
    context.read<CartCubit>().setQuantity(state.dish!, state.quantity);
    showInfoSnackBar(
      context,
      inCart ? LocaleKeys.dish_cart_updated.tr() : LocaleKeys.dish_added.tr(),
    );
    _back(context);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DishCubit>();
    final inCart = context.select<CartCubit, bool>(
      (cart) => cart.state.quantityOf(state.dish!.id) > 0,
    );
    final total = formatPrice(state.totalKopecks);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.horizontalPadding,
            12,
            AppDimens.horizontalPadding,
            12,
          ),
          child: Row(
            children: [
              QuantityStepper(
                value: state.quantity,
                max: Cart.maxQuantity,
                onChanged: cubit.setQuantity,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton.primary(
                  text: inCart
                      ? LocaleKeys.dish_update.tr(namedArgs: {'total': total})
                      : LocaleKeys.dish_add.tr(namedArgs: {'total': total}),
                  onPressed: () => _save(context, inCart: inCart),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.colors.surface,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: ColorName.black.withValues(alpha: 0.2),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 44,
            child: Icon(icon, color: context.colors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.no_food_outlined,
              size: 48,
              color: context.colors.iconMuted,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppText.regular(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton.outlined(
              text: LocaleKeys.common_back.tr(),
              onPressed: () => _back(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Back to wherever the dish was opened from; to the menu when it was the
/// first screen (e.g. restored after a restart).
void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(Routes.home);
