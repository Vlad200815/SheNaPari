import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/confirm_sheet.dart';
import 'package:shenapari_core/ui/snack_bars.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/kitchen_order.dart';
import '../queue_cubit.dart';
import '../queue_state.dart';
import 'order_details.dart';
import 'order_ticket.dart';
import 'queue_colors.dart';

/// The queue tab: the filter chips, then three columns on a tablet or one
/// status at a time on a phone; a yellow banner and a chime for each new
/// order.
class QueueBoard extends StatefulWidget {
  const QueueBoard({super.key, required this.tablet});

  final bool tablet;

  @override
  State<QueueBoard> createState() => _QueueBoardState();
}

class _QueueBoardState extends State<QueueBoard> {
  var _phoneColumn = QueueColumn.fresh;
  String? _banner;
  Timer? _bannerTimer;

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _showBanner(List<int> numbers) {
    HapticFeedback.heavyImpact();
    setState(() {
      _banner = numbers.length == 1
          ? LocaleKeys.queue_new_order.tr(
              namedArgs: {'number': '${numbers.single}'},
            )
          : LocaleKeys.queue_new_orders.tr(
              namedArgs: {'numbers': numbers.map((n) => '№$n').join(', ')},
            );
    });
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _banner = null);
    });
  }

  Future<void> _handOver(KitchenOrder order) async {
    final cubit = context.read<QueueCubit>();
    final name = order.customerName;
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.how_to_reg_rounded,
      title: LocaleKeys.queue_hand_over_title.tr(
        namedArgs: {'number': '${order.number}'},
      ),
      text: name == null || name.isEmpty
          ? LocaleKeys.queue_hand_over_text_noname.tr()
          : LocaleKeys.queue_hand_over_text.tr(namedArgs: {'name': name}),
      confirm: LocaleKeys.queue_hand_over_confirm.tr(),
      keep: LocaleKeys.queue_keep.tr(),
    );
    if (confirmed) await cubit.handOver(order.id);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<QueueCubit, QueueState>(
          listenWhen: (a, b) => a.arrivals != b.arrivals,
          listener: (_, state) => _showBanner(state.arrived),
        ),
        BlocListener<QueueCubit, QueueState>(
          listenWhen: (a, b) =>
              b.status == QueueStatus.loaded &&
              b.failure != null &&
              a.failure != b.failure,
          listener: (context, state) =>
              showFailureSnackBar(context, state.failure!),
        ),
      ],
      child: BlocBuilder<QueueCubit, QueueState>(
        builder: (context, state) {
          final body = switch (state.status) {
            QueueStatus.loading => const Center(
              child: CircularProgressIndicator(color: ColorName.primary400),
            ),
            QueueStatus.failure => _LoadError(
              message: state.failure!.text,
              onRetry: context.read<QueueCubit>().load,
            ),
            QueueStatus.loaded when state.orders.isEmpty => const _Empty(),
            QueueStatus.loaded => Column(
              children: [
                _Filters(state: state),
                Expanded(
                  child: widget.tablet
                      ? _Columns(state: state, ticket: _ticket)
                      : _PhoneList(
                          state: state,
                          column: _phoneColumn,
                          onColumn: (c) => setState(() => _phoneColumn = c),
                          ticket: _ticket,
                        ),
                ),
              ],
            ),
          };
          return Stack(
            children: [
              Positioned.fill(child: body),
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _banner == null
                        ? const SizedBox.shrink()
                        : Center(
                            key: ValueKey(_banner),
                            child: _Banner(text: _banner!),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ticket(BuildContext context, QueueState state, KitchenOrder order) {
    final cubit = context.read<QueueCubit>();
    return OrderTicket(
      key: ValueKey(order.id),
      order: order,
      now: state.now,
      busy: state.busy.contains(order.id),
      onAccept: (minutes) => cubit.accept(order.id, minutes: minutes),
      onReady: () => cubit.markReady(order.id),
      onHandOver: () => _handOver(order),
      onOpen: () => showOrderDetails(context, order, tablet: widget.tablet),
    );
  }
}

typedef _TicketBuilder =
    Widget Function(BuildContext, QueueState, KitchenOrder);

class _Filters extends StatelessWidget {
  const _Filters({required this.state});

  final QueueState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QueueCubit>();
    final chips = <(QueueFilter, String, int, IconData?)>[
      (
        const AllOrders(),
        LocaleKeys.queue_filter_all.tr(),
        state.orders.length,
        null,
      ),
      if (state.asapCount > 0)
        (
          const AsapOrders(),
          LocaleKeys.queue_asap.tr(),
          state.asapCount,
          Icons.bolt_rounded,
        ),
      for (final (start, count) in state.breaks)
        (
          BreakOrders(start),
          LocaleKeys.queue_break_at.tr(namedArgs: {'time': clock(start)}),
          count,
          null,
        ),
    ];
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (filter, label, count, icon) = chips[i];
          final on = filter == state.filter;
          final colors = context.colors;
          final fg = on ? colors.background : colors.textSecondary;
          return Semantics(
            selected: on,
            button: true,
            child: GestureDetector(
              onTap: () => cubit.selectFilter(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? colors.textPrimary : Colors.transparent,
                  border: Border.all(
                    color: on ? colors.textPrimary : colors.border,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 14, color: fg),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      label,
                      style: AppText.small(color: fg).copyWith(fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$count',
                      style: AppText.small(
                        color: on ? colors.background : colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Columns extends StatelessWidget {
  const _Columns({required this.state, required this.ticket});

  final QueueState state;
  final _TicketBuilder ticket;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, column) in QueueColumn.values.indexed) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: _Column(
                column: column,
                count: state.count(column),
                orders: state.column(column),
                ticket: (o) => ticket(context, state, o),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.column,
    required this.count,
    required this.orders,
    required this.ticket,
  });

  final QueueColumn column;
  final int count;
  final List<KitchenOrder> orders;
  final Widget Function(KitchenOrder) ticket;

  @override
  Widget build(BuildContext context) {
    final look = ColumnLook.of(column);
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: look.band,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(look.icon, size: 18, color: look.onBand),
                const SizedBox(width: 8),
                Text(
                  columnTitle(column),
                  style: AppText.medium(
                    color: look.onBand,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$count',
                    style: AppText.small(
                      color: look.onBand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Text(
                      LocaleKeys.queue_column_empty.tr(),
                      style: AppText.small(color: context.colors.textTertiary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => ticket(orders[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PhoneList extends StatelessWidget {
  const _PhoneList({
    required this.state,
    required this.column,
    required this.onColumn,
    required this.ticket,
  });

  final QueueState state;
  final QueueColumn column;
  final ValueChanged<QueueColumn> onColumn;
  final _TicketBuilder ticket;

  @override
  Widget build(BuildContext context) {
    final orders = state.column(column);
    final colors = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                for (final c in QueueColumn.values)
                  Expanded(
                    child: Semantics(
                      selected: c == column,
                      button: true,
                      child: GestureDetector(
                        onTap: () => onColumn(c),
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: c == column
                                ? ColumnLook.of(c).band
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '${columnTitle(c)} · ${state.count(c)}',
                            style: AppText.small(
                              color: c == column
                                  ? ColumnLook.of(c).onBand
                                  : colors.textSecondary,
                              fontWeight: c == column
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Text(
                    LocaleKeys.queue_column_empty.tr(),
                    style: AppText.small(color: colors.textTertiary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      ticket(context, state, orders[i]),
                ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: ColorName.primary400,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_active_rounded,
            color: ColorName.black,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: AppText.medium(
              color: ColorName.black,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// «Поки тихо»: nothing in the queue.
class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.fill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 46,
                color: ColorName.primary400,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              LocaleKeys.queue_empty_title.tr(),
              style: AppText.title().copyWith(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              LocaleKeys.queue_empty_text.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: context.colors.iconMuted,
          ),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center, style: AppText.regular()),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(LocaleKeys.queue_retry.tr()),
          ),
        ],
      ),
    ),
  );
}
