import "package:flutter/material.dart";
import "package:shenapari/gen/colors.gen.dart";
import "package:shenapari/src/core/resource/theme_dimen.dart";
import "package:shenapari/src/core/resource/theme_text.dart";

class TabsItemView extends StatefulWidget {
  final List<String> categories;
  final void Function(String category) onCategorySelected;
  final int initialIndex;
  final bool isLoading;

  const TabsItemView({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    this.initialIndex = 0,
    required this.isLoading,
  });

  @override
  State<TabsItemView> createState() => _TabsItemViewState();
}

class _TabsItemViewState extends State<TabsItemView> {
  late int _selectedIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return widget.isLoading
        ? _TabsSkeleton()
        : SizedBox(
            height: 43,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: widget.categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final title = widget.categories[index];
                final isSelected = index == _selectedIndex;

                return GestureDetector(
                  onTap: () => _onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ColorName.primary400
                          : ColorName.white,
                      borderRadius: BorderRadius.circular(Dimen.CORNER_RADIUS),
                      border: Border.all(
                        color: ColorName.primary400,
                        width: Dimen.DEFAULT_BORDER_WIDTH,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        title,
                        style: ThemeText.poppinsRegular(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? ColorName.white
                              : ColorName.typography900,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    debugPrint("Selected Category: ${widget.categories[index]}");
    widget.onCategorySelected(widget.categories[index]);
  }
}

class _TabsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimen.DEFAULT_HORIZONTAL_PADDING,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) => Container(
          width: 80,
          decoration: BoxDecoration(
            color: ColorName.secondary50,
            borderRadius: BorderRadius.circular(Dimen.CORNER_RADIUS),
          ),
        ),
      ),
    );
  }
}
