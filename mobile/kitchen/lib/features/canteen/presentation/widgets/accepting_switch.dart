import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/confirm_sheet.dart';

import '../../../../core/l10n/l10n.dart';
import '../canteen_cubit.dart';
import '../canteen_state.dart';

/// «Приймаємо» (green) / «Пауза» (red) in the header. Pausing asks first,
/// since every customer is affected; resuming doesn't.
class AcceptingPill extends StatelessWidget {
  const AcceptingPill({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CanteenCubit>().state;
    if (state.status != CanteenStatus.loaded) return const SizedBox.shrink();
    final colors = context.colors;
    final on = state.accepting;
    final fg = on ? colors.success : colors.danger;
    return Semantics(
      button: true,
      toggled: on,
      child: Material(
        color: on ? colors.successSoft : colors.dangerSoft,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: state.busy
              ? null
              : () => on
                    ? confirmPause(context)
                    : context.read<CanteenCubit>().resume(),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.busy)
                  SizedBox.square(
                    dimension: 10,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                else
                  Icon(
                    on ? Icons.circle : Icons.pause_rounded,
                    size: on ? 10 : 16,
                    color: fg,
                  ),
                const SizedBox(width: 8),
                Text(
                  on
                      ? LocaleKeys.canteen_accepting.tr()
                      : LocaleKeys.canteen_paused.tr(),
                  style: AppText.small(color: fg, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> confirmPause(BuildContext context) async {
  final cubit = context.read<CanteenCubit>();
  final confirmed = await showConfirmSheet(
    context,
    icon: Icons.pause_rounded,
    title: LocaleKeys.canteen_pause_title.tr(),
    text: LocaleKeys.canteen_pause_text.tr(),
    confirm: LocaleKeys.canteen_pause_confirm.tr(),
    keep: LocaleKeys.canteen_keep.tr(),
  );
  if (confirmed) await cubit.pause();
}

/// The red strip under the header while paused, so nobody forgets.
class PausedBanner extends StatelessWidget {
  const PausedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CanteenCubit>().state;
    final paused = state.status == CanteenStatus.loaded && !state.accepting;
    final colors = context.colors;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: !paused
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              color: colors.dangerSoft,
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.pause_circle_rounded,
                    color: colors.danger,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      LocaleKeys.canteen_banner.tr(),
                      style: AppText.small(
                        color: colors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: state.busy
                        ? null
                        : context.read<CanteenCubit>().resume,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(
                      LocaleKeys.canteen_resume.tr(),
                      style: AppText.small(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
