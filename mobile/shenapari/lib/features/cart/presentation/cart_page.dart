import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/routes.dart';
import '../../../core/ui/app_button.dart';
import '../../../core/ui/app_text.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/format_price.dart';
import '../../../core/ui/quantity_stepper.dart';
import '../../../gen/colors.gen.dart';
import '../../menu/presentation/widgets/dish_card.dart';
import '../domain/entities/cart.dart';
import 'cart_cubit.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_colors.dart';

/// The cart tab: dishes with steppers, the total and «Оформити замовлення».
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, Cart>(
      builder: (context, cart) => Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.background,
          title: Text(LocaleKeys.cart_title.tr(), style: AppText.title()),
          actions: [
            if (!cart.isEmpty)
              TextButton(
                onPressed: context.read<CartCubit>().clear,
                child: Text(
                  LocaleKeys.common_clear.tr(),
                  style: AppText.small(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: cart.isEmpty ? const _EmptyCart() : _CartList(cart: cart),
        bottomNavigationBar: cart.isEmpty ? null : _CheckoutBar(cart: cart),
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  const _CartList({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.horizontalPadding),
      itemCount: cart.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        // Swipe left to remove, like in mail apps.
        return Dismissible(
          key: ValueKey(item.dish.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => context.read<CartCubit>().remove(item.dish.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: context.colors.dangerSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: ColorName.red,
            ),
          ),
          child: _CartRow(item: item),
        );
      },
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final dish = item.dish;
    final cart = context.read<CartCubit>();
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.dish(dish.id), extra: dish),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 72,
                child: DishImage(url: dish.imageUrl, radius: 12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatPrice(item.totalKopecks),
                      style: AppText.medium().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              QuantityStepper(
                compact: true,
                value: item.quantity,
                // Going below 1 removes the dish.
                min: 0,
                max: Cart.maxQuantity,
                onChanged: (quantity) => cart.setQuantity(dish, quantity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.horizontalPadding,
          16,
          AppDimens.horizontalPadding,
          16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  LocaleKeys.cart_total.tr(
                    namedArgs: {
                      'count': '${cart.count}',
                      'portions': LocaleKeys.cart_portions.plural(cart.count),
                    },
                  ),
                  style: AppText.regular(color: context.colors.textSecondary),
                ),
                const Spacer(),
                Text(formatPrice(cart.totalKopecks), style: AppText.title()),
              ],
            ),
            const SizedBox(height: 12),
            AppButton.primary(
              text: LocaleKeys.cart_checkout.tr(),
              onPressed: () => context.push(Routes.checkout),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.colors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 44,
                color: ColorName.primary500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            LocaleKeys.cart_empty_title.tr(),
            style: AppText.title(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.cart_empty_text.tr(),
            style: AppText.small(color: context.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton.primary(
            text: LocaleKeys.common_to_menu.tr(),
            onPressed: () => context.go(Routes.home),
          ),
        ],
      ),
    );
  }
}
