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

/// The cart tab: dishes with steppers, the total and «Оформити замовлення».
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, Cart>(
      builder: (context, cart) => Scaffold(
        backgroundColor: ColorName.secondary100,
        appBar: AppBar(
          backgroundColor: ColorName.secondary100,
          title: Text('Кошик', style: AppText.title()),
          actions: [
            if (!cart.isEmpty)
              TextButton(
                onPressed: context.read<CartCubit>().clear,
                child: Text(
                  'Очистити',
                  style: AppText.small(
                    color: ColorName.typography500,
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
              color: ColorName.redLight,
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
      color: ColorName.white,
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
                        color: ColorName.typography900,
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
        color: ColorName.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: ColorName.black.withValues(alpha: 0.06),
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
                  'Разом · ${cart.count} ${_portions(cart.count)}',
                  style: AppText.regular(color: ColorName.typography500),
                ),
                const Spacer(),
                Text(formatPrice(cart.totalKopecks), style: AppText.title()),
              ],
            ),
            const SizedBox(height: 12),
            AppButton.primary(
              text: 'Оформити замовлення',
              onPressed: () => context.push(Routes.checkout),
            ),
          ],
        ),
      ),
    );
  }

  /// 1 порція, 2 порції, 5 порцій, 11 порцій, 21 порція.
  static String _portions(int count) {
    final lastTwo = count % 100;
    final last = count % 10;
    if (lastTwo >= 11 && lastTwo <= 14) return 'порцій';
    if (last == 1) return 'порція';
    if (last >= 2 && last <= 4) return 'порції';
    return 'порцій';
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
              decoration: const BoxDecoration(
                color: ColorName.primary100,
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
            'Кошик порожній',
            style: AppText.title(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Додайте страви з меню, і ми приготуємо їх до перерви',
            style: AppText.small(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton.primary(
            text: 'До меню',
            onPressed: () => context.go(Routes.home),
          ),
        ],
      ),
    );
  }
}
