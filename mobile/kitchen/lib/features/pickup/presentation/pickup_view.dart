import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';

import '../../../app/di.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/kitchen_button.dart';
import '../../queue/domain/entities/kitchen_order.dart';
import '../../queue/presentation/widgets/queue_colors.dart';
import 'pickup_cubit.dart';
import 'pickup_state.dart';

/// «Видача»: the camera looks for the customer's QR all the time; next to it
/// the result and a keypad for the number when there is no code. Tablet:
/// side by side; phone: one under the other.
class PickupView extends StatelessWidget {
  const PickupView({super.key, required this.tablet});

  final bool tablet;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PickupCubit>(),
      child: BlocListener<PickupCubit, PickupState>(
        listenWhen: (a, b) =>
            a.handedOver != b.handedOver ||
            (b.status == PickupStatus.failed && a.status != b.status),
        listener: (_, state) => state.status == PickupStatus.done
            ? HapticFeedback.mediumImpact()
            : HapticFeedback.vibrate(),
        child: tablet
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 11, child: _Scanner()),
                    SizedBox(width: 14),
                    Expanded(
                      flex: 10,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _Result(),
                            SizedBox(height: 12),
                            _Keypad(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SingleChildScrollView(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    SizedBox(height: 260, child: _Scanner()),
                    SizedBox(height: 12),
                    _Result(),
                    SizedBox(height: 12),
                    _Keypad(),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Scanner extends StatelessWidget {
  const _Scanner();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PickupCubit>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              onDetect: (capture) {
                for (final code in capture.barcodes) {
                  final raw = code.rawValue;
                  if (raw != null) cubit.scanned(raw);
                }
              },
              errorBuilder: (context, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.no_photography_outlined,
                        size: 40,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        LocaleKeys.pickup_no_camera.tr(),
                        textAlign: TextAlign.center,
                        style: AppText.regular(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Where to hold the code.
            IgnorePointer(
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: ColorName.primary400, width: 4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Text(
                LocaleKeys.pickup_scan_hint.tr(),
                textAlign: TextAlign.center,
                style: AppText.small(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PickupCubit>().state;
    final colors = context.colors;
    final ready = ColumnLook.of(QueueColumn.ready);
    final order = state.order;
    final (
      Color? border,
      IconData? icon,
      Color? tint,
      String title,
    ) = switch (state.status) {
      PickupStatus.done => (
        ready.band,
        Icons.check_rounded,
        ready.band,
        LocaleKeys.pickup_done.tr(namedArgs: {'number': '${order?.number}'}),
      ),
      PickupStatus.found => (
        ColorName.primary400,
        Icons.inventory_2_outlined,
        ColorName.primary400,
        '№${order?.number}',
      ),
      PickupStatus.failed => (
        ColumnLook.late,
        Icons.close_rounded,
        ColumnLook.late,
        _problemText(state),
      ),
      PickupStatus.idle || PickupStatus.working => (
        null,
        null,
        null,
        LocaleKeys.pickup_waiting.tr(),
      ),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border ?? colors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (state.status == PickupStatus.working)
                const SizedBox.square(
                  dimension: 40,
                  child: Padding(
                    padding: EdgeInsets.all(9),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: ColorName.primary400,
                    ),
                  ),
                )
              else if (icon != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tint!.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: tint, size: 22),
                ),
              if (icon != null || state.status == PickupStatus.working)
                const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: icon == null
                      ? AppText.regular(color: colors.textSecondary)
                      : AppText.title().copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          // The order, to match with the person at the counter.
          if (order != null &&
              (state.status == PickupStatus.done ||
                  state.status == PickupStatus.found)) ...[
            const SizedBox(height: 10),
            if (order.customerName case final name?)
              Text(
                // «Готове · Влад» while it waits; just the name once given.
                state.status == PickupStatus.found
                    ? LocaleKeys.pickup_ready_for.tr(namedArgs: {'name': name})
                    : name,
                style: AppText.medium().copyWith(fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 4),
            for (final item in order.items)
              Text(
                '${item.quantity}×  ${item.name}',
                style: AppText.regular(color: colors.textPrimary),
              ),
          ],
          if (state.status == PickupStatus.found && order != null) ...[
            const SizedBox(height: 12),
            KitchenButton(
              text: LocaleKeys.pickup_hand_over.tr(
                namedArgs: {'number': '${order.number}'},
              ),
              onPressed: context.read<PickupCubit>().handOverFound,
            ),
          ],
        ],
      ),
    );
  }

  static String _problemText(PickupState state) {
    final failure = state.failure;
    if (failure != null) return failure.text;
    return switch (state.problem) {
      PickupProblem.notOurCode => LocaleKeys.pickup_problems_not_our_code.tr(),
      PickupProblem.noSuchNumber =>
        LocaleKeys.pickup_problems_no_such_number.tr(),
      PickupProblem.notReadyYet => LocaleKeys.pickup_problems_not_ready.tr(
        namedArgs: {'number': '${state.order?.number}'},
      ),
      null => '',
    };
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PickupCubit>();
    final number = context.select<PickupCubit, String>((c) => c.state.number);
    final colors = context.colors;
    Widget key(
      Widget child,
      VoidCallback? onTap, {
      Color? color,
      String? label,
    }) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Semantics(
          button: true,
          label: label,
          child: Material(
            color: color ?? colors.fill,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: SizedBox(height: 56, child: Center(child: child)),
            ),
          ),
        ),
      ),
    );
    Widget digit(int d) => key(
      Text('$d', style: AppText.title().copyWith(fontSize: 22)),
      () => cubit.digit(d),
    );
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            LocaleKeys.pickup_manual.tr(),
            style: AppText.small(color: colors.textSecondary),
          ),
          SizedBox(
            height: 52,
            child: Center(
              child: Text(
                number.isEmpty ? '—' : '№$number',
                style: AppText.title().copyWith(
                  fontSize: 32,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          for (final row in const [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
          ])
            Row(children: [for (final d in row) digit(d)]),
          Row(
            children: [
              key(
                Icon(Icons.backspace_outlined, color: colors.textPrimary),
                cubit.backspace,
                label: '⌫',
              ),
              digit(0),
              key(
                Text(
                  LocaleKeys.pickup_ok.tr(),
                  style: AppText.button(
                    color: number.isEmpty
                        ? colors.textTertiary
                        : ColorName.black,
                  ),
                ),
                number.isEmpty ? null : cubit.lookUp,
                color: number.isEmpty ? colors.fill : ColorName.primary400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
