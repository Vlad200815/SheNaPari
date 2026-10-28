import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenapari/gen/colors.gen.dart';
import 'package:shenapari/src/app/config.dart';
import 'package:shenapari/src/core/base/base_page.dart';
import 'package:shenapari/src/core/di/di.dart';
import 'package:shenapari/src/core/others/extension/extensions.dart';
import 'package:shenapari/src/core/resource/theme_dimen.dart';
import 'package:shenapari/src/features/info/presentation/notifications/notifications_page.dart';
import 'package:shenapari/src/features/menu/presentation/home/home_action.dart';
import 'package:shenapari/src/features/menu/presentation/home/home_event.dart';
import 'package:shenapari/src/features/menu/presentation/home/home_state.dart';
import 'package:shenapari/src/features/menu/presentation/home/home_view_model.dart';
import 'package:shenapari/src/features/menu/presentation/product_details/product_details_page.dart';

import '../../../../app/navigation.dart';
import '../widgets/widgets.dart';

class HomePage
    extends BasePage<HomeViewModel, HomeState, HomeEvent, HomeAction> {
  @override
  viewModelProvider(
    Uri uri,
    Map<String, String> pathParameters,
    Object? extra,
  ) {
    return HomeViewModel(
      fetchProductsUseCase: di.get(),
      fetchPostersUseCase: di.get(),
    );
  }

  @override
  void handleEvent(BuildContext context, event) {
    switch (event) {
      case OpenNotificationsPageEvent _:
        NotificationsPage.open(context);
      case OpenProductDetailsPageEvent event:
        ProductDetailsPage.open(context, id: event.id, section: event.section);
    }
  }

  @override
  Widget createView(BuildContext context, state) {
    final bool isSkeletonLoading = state.isSkeletonLoading.orFalse();
    final products = isSkeletonLoading
        ? List.filled(6, null) // Fake list for skeletonizer
        : state.products.orEmpty();

    return Scaffold(
      backgroundColor: ColorName.secondary100,

      /// Debug button
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     // final String accessToken = await AppSecureStorage.getAccessToken();
      //     // final String refreshToken = await AppSecureStorage.getRefreshToken();
      //     // debugPrint("Access token: $accessToken");
      //     // debugPrint("Refresh token: $refreshToken");
      //
      //     // await ProfileRepositoryImpl(apiService: di.get()).test();
      //     final dpr = MediaQuery.devicePixelRatioOf(context);
      //     debugPrint("devicePixelRatioOf: $dpr");
      //   },
      //   child: Text("TEST: JWT token"),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (!state.posters.isNullOrEmpty()) ...[
                  PosterView(posters: state.posters.orEmpty()),
                  const SizedBox(height: 24),
                ],

                TabsItemView(
                  categories: const ["Burger", "Pizza", "Hot Dog", "Panini"],
                  onCategorySelected: (category) => postAction(
                    context,
                    OnCategoryChangedAction(category: category),
                  ),
                  isLoading: isSkeletonLoading,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          SliverPadding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
            ),
            sliver: SliverGrid.builder(
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return ProductCardItem(
                  onTap: () => postAction(
                    context,
                    OnProductTilePressedAction(id: (product?.id).orEmpty()),
                  ),
                  product: product,
                  section: Config.HOME_SECTION,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //
  // Navigation
  //
  static String path = "/home";
  static String name = "Home";

  HomePage({super.key});

  static GoRoute route() {
    return Navigation.getRoute(name, path, (state) {
      return HomePage();
    });
  }

  static void open(BuildContext context) {
    return context.go(Uri(path: path).toString());
  }
}
