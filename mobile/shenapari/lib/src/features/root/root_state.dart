import 'package:collection/collection.dart' as ScrollDirection;
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/gen/assets.gen.dart';
import 'package:shenapari/gen/colors.gen.dart';
import 'package:shenapari/src/core/base/back_button_interceptor.dart';
import 'package:shenapari/src/features/root/root_page.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../core/widgets/widgets.dart';

class RootState extends State<RootPage> {
  final _bottomMenuInitialIndex = 0;

  RouteInformationProvider? _routeInformationProvider;

  @override
  void initState() {
    super.initState();
    // GoRouter.maybeOf(
    //   context,
    // )?.routeInformationProvider.addListener(_onChangeRouteDispatcher);
    // BackButtonInterceptor.add(_onBackInvokedDispatcher);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Safely look up GoRouter here while the widget is active
    final newProvider = GoRouter.maybeOf(context)?.routeInformationProvider;

    // Only update if the provider has actually changed
    if (_routeInformationProvider != newProvider) {
      // Remove listener from the old provider if it existed
      _routeInformationProvider?.removeListener(_onChangeRouteDispatcher);

      // Update to the new provider and attach the listener
      _routeInformationProvider = newProvider;
      _routeInformationProvider?.addListener(_onChangeRouteDispatcher);
    }
  }

  @override
  void dispose() {
    _routeInformationProvider?.removeListener(_onChangeRouteDispatcher);
    _routeInformationProvider = null;

    // GoRouter.maybeOf(
    //   context,
    // )?.routeInformationProvider.removeListener(_onChangeRouteDispatcher);

    // If you decide to re-enable BackButtonInterceptor later:
    // BackButtonInterceptor.remove(_onBackInvokedDispatcher);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.white,
      body: widget.navigationShell,
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  Widget _bottomNavigationBar(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 14,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.maxFinite,
        decoration: const BoxDecoration(color: ColorName.white),
        child: BottomNavigationBar(
          backgroundColor: ColorName.secondary500,
          selectedFontSize: 12,
          unselectedItemColor: ColorName.white,
          selectedItemColor: ColorName.primary400,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            _menuItem(
              Assets.images.bottomNav.icHome,
              LocaleKeys.app_bottom_bar_home.tr(),
            ),

            _menuItem(
              Assets.images.bottomNav.icSearch,
              LocaleKeys.app_bottom_bar_browser.tr(),
            ),
            _menuItem(
              Assets.images.bottomNav.icOrders,
              LocaleKeys.app_bottom_bar_discover.tr(),
            ),
            //TODO: change this to more icon
            _menuItem(
              Assets.images.bottomNav.icProfile,
              LocaleKeys.app_bottom_bar_profile.tr(),
            ),
          ],
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  BottomNavigationBarItem _menuItem(SvgGenImage icon, String label) {
    return BottomNavigationBarItem(
      label: label,

      activeIcon: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),

        child: ImageView(url: icon.path, iconColor: ColorName.primary400),
      ),
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SvgPicture.asset(
          icon.path,
          colorFilter: const ColorFilter.mode(ColorName.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    });
  }

  ///
  /// On back pressed button dispatcher
  ///
  bool _onBackInvokedDispatcher(bool stopDefaultButtonEvent, RouteInfo info) {
    final page = info.currentRoute(context);
    page?.isCurrent == false;
    final isEnable = _isNeedRefreshNavBarIndex(
      context,
      _bottomMenuInitialIndex,
    );
    if (isEnable) {
      //widget.navigationShell.goBranch(_bottomMenuInitialIndex);
      return false;
    } else {
      return false;
    }
  }

  ///
  /// On change route dispatcher
  ///
  void _onChangeRouteDispatcher() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_isNeedRefreshNavBarIndex(
        context,
        widget.navigationShell.currentIndex,
      )) {
        setState(() {
          debugPrint("Refresh bottom menu selected index.");
        });
      }
    });
  }

  ///
  /// Find root page and index
  ///
  bool _isNeedRefreshNavBarIndex(BuildContext context, int currentIndex) {
    final current = GoRouter.of(context).routeInformationProvider.value;
    final list = widget.navigationShell.route.branches.toList();
    return list.firstWhereIndexedOrNull(
          (index, element) =>
              ((element.routes.first as GoRoute).path == current.uri.path &&
              currentIndex != index),
        ) !=
        null;
  }
}
