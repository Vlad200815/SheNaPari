import "dart:async";

import "package:flutter/material.dart";
import "package:shenapari/gen/colors.gen.dart";
import "package:shenapari/src/core/others/extension/extensions.dart";
import "package:shenapari/src/features/menu/domain/entities/entities.dart";

import "../../../../core/widgets/widgets.dart";

class PosterView extends StatefulWidget {
  final List<PosterEntity> posters;

  const PosterView({super.key, required this.posters});

  @override
  State<PosterView> createState() => PosterViewState();
}

class PosterViewState extends State<PosterView> {
  final _pageController = PageController();
  int _selectedIndex = 0;
  Timer? _timer;

  ///Start the scroll animation on init
  @override
  void initState() {
    super.initState();
    _startScrollPosterAnimation();
  }

  ///Dispose controllers
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.posters;
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: changeIndex,
            // For repeating logic you don't need to use itemCount
            itemBuilder: (context, index) {
              final realIndex = index % data.length;
              final item = data[realIndex];
              return ImageView(
                url: item.posterImage.orEmpty(),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              );
            },
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 25,
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(data.length, (index) {
                return _Dot(cardIndex: index, currentIndex: _selectedIndex);
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Scroll Animation
  void _startScrollPosterAnimation() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!_pageController.hasClients) return;

      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  /// Change poster's index
  void changeIndex(int index) {
    setState(() {
      final realIndex = index % widget.posters.length;
      _selectedIndex = realIndex;
    });
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.currentIndex, required this.cardIndex});

  final int currentIndex;
  final int cardIndex;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      height: 8,
      width: currentIndex == cardIndex ? 24 : 8,
      decoration: BoxDecoration(
        color: currentIndex == cardIndex
            ? ColorName.white
            : ColorName.secondary500,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
