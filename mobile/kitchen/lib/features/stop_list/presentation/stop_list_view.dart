import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/snack_bars.dart';

import '../../../app/di.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/entities/stop_list_dish.dart';
import 'stop_list_cubit.dart';
import 'stop_list_state.dart';

/// «Стоп-лист»: every dish with a switch, by category. On a tablet three
/// dishes a row, on a phone one.
class StopListView extends StatelessWidget {
  const StopListView({super.key, required this.tablet});

  final bool tablet;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StopListCubit>()..load(),
      child: BlocConsumer<StopListCubit, StopListState>(
        listenWhen: (a, b) =>
            b.status == StopListStatus.loaded &&
            b.failure != null &&
            a.failure != b.failure,
        listener: (context, state) =>
            showFailureSnackBar(context, state.failure!),
        builder: (context, state) => switch (state.status) {
          StopListStatus.loading => const Center(
            child: CircularProgressIndicator(color: ColorName.primary400),
          ),
          StopListStatus.failure => _LoadError(
            message: state.failure!.text,
            onRetry: context.read<StopListCubit>().load,
          ),
          StopListStatus.loaded when state.sections.isEmpty => _Message(
            LocaleKeys.stop_list_empty.tr(),
          ),
          StopListStatus.loaded => Column(
            children: [
              _Toolbar(state: state, tablet: tablet),
              Expanded(
                child: state.visible.isEmpty
                    ? _Message(LocaleKeys.stop_list_nothing_found.tr())
                    : _Sections(state: state, tablet: tablet),
              ),
            ],
          ),
        },
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.state, required this.tablet});

  final StopListState state;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StopListCubit>();
    final colors = context.colors;
    final search = TextField(
      key: const ValueKey('stop-search'),
      onChanged: cubit.search,
      textInputAction: TextInputAction.search,
      style: AppText.regular(),
      decoration: InputDecoration(
        hintText: LocaleKeys.stop_list_search.tr(),
        prefixIcon: Icon(Icons.search_rounded, color: colors.iconMuted),
        isDense: true,
      ),
    );
    final off = state.offCount;
    final summary = [
      if (off > 0) ...[
        Text(
          LocaleKeys.stop_list_off_count.tr(namedArgs: {'n': '$off'}),
          style: AppText.small(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        _EnableAllButton(
          busy: state.busy.isNotEmpty,
          onPressed: cubit.enableAll,
        ),
      ],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: tablet
          ? Row(
              children: [
                SizedBox(width: 320, child: search),
                const Spacer(),
                ...summary,
              ],
            )
          : Column(
              children: [
                search,
                if (off > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: summary,
                  ),
                ],
              ],
            ),
    );
  }
}

class _EnableAllButton extends StatelessWidget {
  const _EnableAllButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: ColorName.primary400,
          foregroundColor: ColorName.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.restart_alt_rounded, size: 20),
        label: Text(
          LocaleKeys.stop_list_enable_all.tr(),
          style: AppText.small(
            color: ColorName.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections({required this.state, required this.tablet});

  final StopListState state;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    final columns = tablet ? 3 : 1;
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        for (final section in state.visible) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                (section.title ?? LocaleKeys.stop_list_uncategorized.tr())
                    .toUpperCase(),
                style: AppText.small(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ).copyWith(letterSpacing: 0.8),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _DishTile(
                  key: ValueKey(section.dishes[i].id),
                  dish: section.dishes[i],
                  busy: state.busy.contains(section.dishes[i].id),
                ),
                childCount: section.dishes.length,
              ),
            ),
          ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

/// The whole tile is the switch: a big target for wet hands. Off reads as
/// struck-through grey text and «закінчилось», not only as a grey switch.
class _DishTile extends StatelessWidget {
  const _DishTile({super.key, required this.dish, required this.busy});

  final StopListDish dish;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final on = dish.isAvailable;
    void toggle() => context.read<StopListCubit>().toggle(dish.id);
    return MergeSemantics(
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: busy ? null : toggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppText.medium(
                              color: on
                                  ? colors.textPrimary
                                  : colors.textSecondary,
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: on
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                      ),
                      Text(
                        on
                            ? LocaleKeys.stop_list_on.tr()
                            : LocaleKeys.stop_list_off.tr(),
                        style: AppText.small(
                          color: on ? colors.textSecondary : colors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: on,
                  onChanged: busy ? null : (_) => toggle(),
                  activeTrackColor: colors.success,
                  activeThumbColor: Colors.white,
                  // Off must read as a switch too, not a dark blot.
                  inactiveThumbColor: colors.textSecondary,
                  inactiveTrackColor: colors.fill,
                  trackOutlineColor: WidgetStatePropertyAll(colors.border),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppText.regular(color: context.colors.textSecondary),
      ),
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Message(message),
        TextButton(
          onPressed: onRetry,
          child: Text(
            LocaleKeys.queue_retry.tr(),
            style: AppText.medium(color: ColorName.primary400),
          ),
        ),
      ],
    ),
  );
}
