import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../core/ui/snack_bars.dart';
import '../../../../gen/colors.gen.dart';
import '../../domain/entities/order.dart';
import '../widgets/order_widgets.dart';
import 'orders_cubit.dart';

/// The orders tab: active ones on top, then the history.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..load(),
      child: BlocConsumer<OrdersCubit, OrdersState>(
        listenWhen: (previous, current) =>
            current.status == OrdersStatus.loaded &&
            current.failure != null &&
            previous.failure != current.failure,
        listener: (context, state) =>
            showFailureSnackBar(context, state.failure!),
        builder: (context, state) => Scaffold(
          backgroundColor: ColorName.secondary100,
          appBar: AppBar(
            backgroundColor: ColorName.secondary100,
            title: Text('Замовлення', style: AppText.title()),
          ),
          body: switch (state.status) {
            OrdersStatus.loading => const Center(
              child: CircularProgressIndicator(color: ColorName.primary400),
            ),
            OrdersStatus.failure => _Message(
              icon: Icons.cloud_off,
              title: state.failure!.message,
              button: 'Спробувати ще раз',
              onPressed: context.read<OrdersCubit>().load,
            ),
            OrdersStatus.loaded when state.orders.isEmpty => _Message(
              icon: Icons.receipt_long_outlined,
              title: 'Замовлень ще немає',
              subtitle: 'Оберіть страви в меню — і заберете їх на перерві',
              button: 'До меню',
              onPressed: () => context.go(Routes.home),
            ),
            OrdersStatus.loaded => _OrderList(state: state),
          },
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.state});

  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    Widget card(Order order) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OrderCard(
        order: order,
        onTap: () => context.push(Routes.order(order.id)),
      ),
    );
    return RefreshIndicator(
      color: ColorName.primary400,
      onRefresh: context.read<OrdersCubit>().refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimens.horizontalPadding),
        children: [
          if (state.active.isNotEmpty) ...[
            const _Header('Активні'),
            ...state.active.map(card),
          ],
          if (state.past.isNotEmpty) ...[
            if (state.active.isNotEmpty) const SizedBox(height: 12),
            const _Header('Історія'),
            ...state.past.map(card),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: AppText.medium().copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Empty list or a load error: icon, text, one button.
class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.button,
    required this.onPressed,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
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
              child: Icon(icon, size: 44, color: ColorName.primary500),
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppText.title(), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: AppText.small(), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          AppButton.primary(text: button, onPressed: onPressed),
        ],
      ),
    );
  }
}
