import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/di.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_button.dart';
import '../../../../core/ui/app_colors.dart';
import '../../../../core/ui/app_text.dart';
import '../../../../core/ui/app_theme.dart';
import '../../../../core/ui/format_price.dart';
import '../../../../core/ui/snack_bars.dart';
import '../../../../gen/colors.gen.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_history.dart';
import '../widgets/order_widgets.dart';
import 'order_history_cubit.dart';
import 'orders_cubit.dart';
import 'widgets/history_row.dart';

enum _Tab { active, history }

/// The orders tab: «Активні» and «Історія» behind a switch. The history
/// is grouped by month and comes a page at a time.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<OrdersCubit>()..load()),
        BlocProvider(create: (_) => sl<OrderHistoryCubit>()..load()),
      ],
      child: MultiBlocListener(
        // A failed refresh or next page keeps the list: a snack bar says so.
        listeners: [
          BlocListener<OrdersCubit, OrdersState>(
            listenWhen: (previous, current) =>
                current.status == OrdersStatus.loaded &&
                current.failure != null &&
                previous.failure != current.failure,
            listener: (context, state) =>
                showFailureSnackBar(context, state.failure!),
          ),
          BlocListener<OrderHistoryCubit, OrderHistoryState>(
            listenWhen: (previous, current) =>
                current.status == OrderHistoryStatus.loaded &&
                current.failure != null &&
                previous.failure != current.failure,
            listener: (context, state) =>
                showFailureSnackBar(context, state.failure!),
          ),
        ],
        child: const _OrdersView(),
      ),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  /// Null until the user picks a tab: then «Активні» while there are
  /// active orders, otherwise «Історія».
  _Tab? _picked;

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersCubit>().state;
    final tab =
        _picked ??
        (orders.status == OrdersStatus.loaded && orders.active.isEmpty
            ? _Tab.history
            : _Tab.active);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(LocaleKeys.orders_title.tr(), style: AppText.title()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.horizontalPadding,
              0,
              AppDimens.horizontalPadding,
              10,
            ),
            child: _Switch(
              tab: tab,
              activeCount: orders.active.length,
              onChanged: (tab) => setState(() => _picked = tab),
            ),
          ),
        ),
      ),
      body: switch (tab) {
        _Tab.active => _ActiveView(state: orders),
        _Tab.history => const _HistoryView(),
      },
    );
  }
}

/// «Активні (2) | Історія», a segmented switch.
class _Switch extends StatelessWidget {
  const _Switch({
    required this.tab,
    required this.activeCount,
    required this.onChanged,
  });

  final _Tab tab;
  final int activeCount;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget segment(_Tab value, String label, {int count = 0}) {
      final selected = value == tab;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? colors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: colors.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppText.small(
                      color: selected
                          ? colors.textPrimary
                          : colors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorName.primary400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: AppText.small(
                          color: ColorName.black,
                          fontWeight: FontWeight.w600,
                        ).copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          segment(
            _Tab.active,
            LocaleKeys.orders_active.tr(),
            count: activeCount,
          ),
          segment(_Tab.history, LocaleKeys.orders_history.tr()),
        ],
      ),
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.state});

  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      OrdersStatus.loading => const _Loading(),
      OrdersStatus.failure => _Message(
        icon: Icons.cloud_off,
        title: state.failure!.text,
        button: LocaleKeys.common_retry.tr(),
        onPressed: context.read<OrdersCubit>().load,
      ),
      OrdersStatus.loaded when state.active.isEmpty => _Message(
        icon: Icons.receipt_long_outlined,
        title: LocaleKeys.orders_no_active_title.tr(),
        subtitle: LocaleKeys.orders_no_active_text.tr(),
        button: LocaleKeys.common_to_menu.tr(),
        onPressed: () => context.go(Routes.home),
      ),
      OrdersStatus.loaded => RefreshIndicator(
        color: ColorName.primary400,
        onRefresh: context.read<OrdersCubit>().refresh,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppDimens.horizontalPadding,
            8,
            AppDimens.horizontalPadding,
            AppDimens.horizontalPadding + AppDimens.tabBarOverhang,
          ),
          itemCount: state.active.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = state.active[index];
            return OrderCard(
              order: order,
              onTap: () => context.push(Routes.order(order.id)),
            );
          },
        ),
      ),
    };
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderHistoryCubit>().state;
    final cubit = context.read<OrderHistoryCubit>();
    return Column(
      children: [
        _Filters(selected: state.filter, onSelected: cubit.setFilter),
        Expanded(
          child: switch (state.status) {
            OrderHistoryStatus.loading => const _Loading(),
            OrderHistoryStatus.failure => _Message(
              icon: Icons.cloud_off,
              title: state.failure!.text,
              button: LocaleKeys.common_retry.tr(),
              onPressed: cubit.load,
            ),
            OrderHistoryStatus.loaded
                when state.orders.isEmpty && state.filter == null =>
              _Message(
                icon: Icons.receipt_long_outlined,
                title: LocaleKeys.orders_empty_title.tr(),
                subtitle: LocaleKeys.orders_empty_text.tr(),
                button: LocaleKeys.common_to_menu.tr(),
                onPressed: () => context.go(Routes.home),
              ),
            OrderHistoryStatus.loaded when state.orders.isEmpty => _Message(
              icon: Icons.filter_list_rounded,
              title: LocaleKeys.orders_filter_empty.tr(),
              button: LocaleKeys.orders_filter_all.tr(),
              onPressed: () => cubit.setFilter(null),
            ),
            OrderHistoryStatus.loaded => _HistoryList(state: state),
          },
        ),
      ],
    );
  }
}

/// «Усі · Отримані · Скасовані · Не забрані», like the menu's chips.
class _Filters extends StatelessWidget {
  const _Filters({required this.selected, required this.onSelected});

  final OrderStatus? selected;
  final ValueChanged<OrderStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = <(OrderStatus?, String)>[
      (null, LocaleKeys.orders_filter_all.tr()),
      (OrderStatus.pickedUp, LocaleKeys.orders_filter_picked_up.tr()),
      (OrderStatus.cancelled, LocaleKeys.orders_filter_cancelled.tr()),
      (OrderStatus.notPickedUp, LocaleKeys.orders_filter_not_picked_up.tr()),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.horizontalPadding,
          2,
          AppDimens.horizontalPadding,
          6,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label) = filters[index];
          final on = filter == selected;
          return Semantics(
            selected: on,
            button: true,
            child: GestureDetector(
              onTap: () => onSelected(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? ColorName.primary400 : context.colors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radius),
                  border: Border.all(color: ColorName.primary400),
                ),
                child: Text(
                  label,
                  style: AppText.small(
                    color: on ? ColorName.black : context.colors.textPrimary,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Month groups with a header that sticks while its month scrolls by;
/// the next page is asked for near the end.
class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.state});

  final OrderHistoryState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrderHistoryCubit>();
    final groups = <(int, int), List<Order>>{};
    for (final order in state.orders) {
      (groups[(order.createdAt.year, order.createdAt.month)] ??= []).add(order);
    }
    return RefreshIndicator(
      color: ColorName.primary400,
      onRefresh: cubit.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 600) cubit.loadMore();
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            for (final MapEntry(key: (year, month), value: orders)
                in groups.entries)
              SliverMainAxisGroup(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _MonthHeader(
                      label: _monthLabel(year, month),
                      summary: _summary(year, month, orders),
                      background: context.colors.background,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.horizontalPadding,
                      0,
                      AppDimens.horizontalPadding,
                      12,
                    ),
                    sliver: SliverList.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) => HistoryRow(
                        order: orders[index],
                        first: index == 0,
                        last: index == orders.length - 1,
                        onTap: () =>
                            context.push(Routes.order(orders[index].id)),
                      ),
                    ),
                  ),
                ],
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 4,
                  bottom: 16 + AppDimens.tabBarOverhang,
                ),
                child: state.hasMore
                    ? _MoreFooter(
                        loading: state.loadingMore || state.failure == null,
                        onRetry: cubit.loadMore,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// `Листопад`, or `Грудень 2025` for another year.
  static String _monthLabel(int year, int month) {
    final name = 'orders.months.$month'.tr();
    return year == DateTime.now().year ? name : '$name $year';
  }

  /// `3 замовлення · 290 ₴` for the whole month (from the server), or
  /// what is loaded if the server did not count it.
  String _summary(int year, int month, List<Order> loaded) {
    OrderMonth? stats;
    for (final m in state.months) {
      if (m.year == year && m.month == month) stats = m;
    }
    final count = stats?.count ?? loaded.length;
    final spent =
        stats?.spentKopecks ??
        loaded
            .where((o) => o.status != OrderStatus.cancelled)
            .fold<int>(0, (sum, o) => sum + o.totalKopecks);
    return LocaleKeys.orders_month_summary.tr(
      namedArgs: {
        'count': LocaleKeys.orders_count.plural(count),
        'sum': formatPrice(spent),
      },
    );
  }
}

class _MonthHeader extends SliverPersistentHeaderDelegate {
  const _MonthHeader({
    required this.label,
    required this.summary,
    required this.background,
  });

  final String label;
  final String summary;
  final Color background;

  static const _height = 40.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalPadding + 4,
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            label,
            style: AppText.small(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            summary,
            style: AppText.small(
              color: context.colors.textSecondary,
            ).copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_MonthHeader old) =>
      old.label != label ||
      old.summary != summary ||
      old.background != background;
}

class _MoreFooter extends StatelessWidget {
  const _MoreFooter({required this.loading, required this.onRetry});

  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: ColorName.primary400,
          ),
        ),
      );
    }
    return Center(
      child: TextButton(
        onPressed: onRetry,
        child: Text(
          '${LocaleKeys.orders_load_more_failed.tr()} · '
          '${LocaleKeys.common_retry.tr()}',
          style: AppText.small(color: context.colors.textSecondary),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: ColorName.primary400),
  );
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.colors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: ColorName.primary500),
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppText.title(), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppText.small(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          AppButton.primary(text: button, onPressed: onPressed),
        ],
      ),
    );
  }
}
