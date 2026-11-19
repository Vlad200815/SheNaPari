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
import '../../../cart/presentation/cart_cubit.dart';
import '../../../notifications/presentation/notifications_cubit.dart';
import '../widgets/break_card.dart';
import '../widgets/dish_card.dart';
import '../widgets/filter_chips.dart';
import '../widgets/home_header.dart';
import 'home_cubit.dart';
import 'home_state.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/language_listener.dart';

/// The menu: canteen name, filters and the grid of dishes.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeCubit>()..load()),
        BlocProvider(create: (_) => sl<UnreadNotificationsCubit>()..load()),
      ],
      child: BlocListener<HomeCubit, HomeState>(
        // A failed refresh keeps the old menu; tell the user with a snack bar.
        listenWhen: (previous, current) =>
            current.status == HomeStatus.loaded &&
            current.failure != null &&
            previous.failure != current.failure,
        listener: (context, state) =>
            showFailureSnackBar(context, state.failure!),
        // Category names come from the server in the request's language.
        child: LanguageListener(
          onChanged: (context) => context.read<HomeCubit>().refresh(),
          child: Scaffold(
            backgroundColor: ColorName.secondary100,
            body: SafeArea(
              bottom: false,
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) => switch (state.status) {
                  HomeStatus.loading => const _HomeSkeleton(),
                  HomeStatus.failure => _LoadError(
                    message: state.failure!.text,
                    onRetry: context.read<HomeCubit>().load,
                  ),
                  HomeStatus.loaded => _MenuView(state: state),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuView extends StatelessWidget {
  const _MenuView({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final menu = state.menu!;
    final dishes = state.visibleDishes;
    return RefreshIndicator(
      color: ColorName.primary400,
      onRefresh: cubit.refresh,
      child: CustomScrollView(
        // Pull-to-refresh must work even when the list is short.
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header(state: state)),
          SliverToBoxAdapter(
            child: FilterChips(
              menu: menu,
              selected: state.filter,
              onSelected: cubit.selectFilter,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (dishes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  LocaleKeys.home_menu_empty.tr(),
                  style: AppText.regular(color: ColorName.typography500),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.horizontalPadding,
                0,
                AppDimens.horizontalPadding,
                24,
              ),
              sliver: SliverGrid.builder(
                gridDelegate: _gridDelegate,
                itemCount: dishes.length,
                itemBuilder: (context, index) {
                  final dish = dishes[index];
                  return DishCard(
                    dish: dish,
                    onTap: () =>
                        context.push(Routes.dish(dish.id), extra: dish),
                    onAdd: () => context.read<CartCubit>().add(dish),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  childAspectRatio: 0.68,
);

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final menu = state.menu!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.horizontalPadding,
        16,
        AppDimens.horizontalPadding,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(
            firstName: state.firstName,
            hasUnread: context.watch<UnreadNotificationsCubit>().state,
            onNotifications: () {
              // Opening the list reads everything.
              context.read<UnreadNotificationsCubit>().markSeen();
              context.push(Routes.notifications);
            },
          ),
          const SizedBox(height: 20),
          BreakCard(
            canteen: menu.canteen,
            nextBreak: menu.nextBreak,
            onBreakStarted: context.read<HomeCubit>().refresh,
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.horizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: ColorName.secondary400),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppText.regular(color: ColorName.typography500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton.primary(
            text: LocaleKeys.common_retry.tr(),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// Grey boxes in the shape of the menu while it loads.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.horizontalPadding,
            16,
            AppDimens.horizontalPadding,
            16,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 100, height: 16),
                SizedBox(height: 8),
                _Bone(width: 220, height: 30),
                SizedBox(height: 20),
                _Bone(height: 150),
                SizedBox(height: 20),
                Row(
                  children: [
                    _Bone(width: 60, height: 40),
                    SizedBox(width: 8),
                    _Bone(width: 100, height: 40),
                    SizedBox(width: 8),
                    _Bone(width: 90, height: 40),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.horizontalPadding,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: _gridDelegate,
            itemCount: 6,
            itemBuilder: (_, _) => const _Bone(),
          ),
        ),
      ],
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ColorName.secondary50,
        borderRadius: BorderRadius.circular(AppDimens.radius),
      ),
    );
  }
}
