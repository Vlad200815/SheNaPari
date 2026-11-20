import 'package:material_ui/material_ui.dart';

import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import 'profile_ui.dart';

/// A settings row with a choice («Мова», «Тема»): the current [badge] and an
/// arrow down; a tap drops a menu right under the row with every value, the
/// current one highlighted and ticked.
class ChoiceMenuRow<T> extends StatefulWidget {
  const ChoiceMenuRow({
    super.key,
    required this.icon,
    required this.tint,
    required this.title,
    required this.values,
    required this.current,
    required this.nameOf,
    required this.badge,
    required this.onPicked,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final List<T> values;
  final T current;
  final String Function(T value) nameOf;

  /// A small picture of a value, inside a square of the given size.
  final Widget Function(T value, double size) badge;
  final ValueChanged<T> onPicked;

  @override
  State<ChoiceMenuRow<T>> createState() => _ChoiceMenuRowState<T>();
}

class _ChoiceMenuRowState<T> extends State<ChoiceMenuRow<T>> {
  final _menu = MenuController();

  static const _menuWidth = 240.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        controller: _menu,
        // Right edge of the menu under the right edge of the row, where the
        // badge and the arrow are.
        alignmentOffset: Offset(constraints.maxWidth - _menuWidth - 12, 4),
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(context.colors.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(8),
          shadowColor: WidgetStatePropertyAll(
            ColorName.black.withValues(alpha: 0.25),
          ),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              // On a dark screen a shadow alone does not show the edge.
              side: BorderSide(color: context.colors.border),
            ),
          ),
        ),
        menuChildren: [
          for (final value in widget.values)
            _Option(
              name: widget.nameOf(value),
              badge: widget.badge(value, 28),
              selected: value == widget.current,
              width: _menuWidth - 12,
              onPressed: () => widget.onPicked(value),
            ),
        ],
        builder: (context, controller, _) => MenuRow(
          icon: widget.icon,
          tint: widget.tint,
          title: widget.title,
          subtitle: widget.nameOf(widget.current),
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          trailing: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.badge(widget.current, 24),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: controller.isOpen ? 0.5 : 0,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: context.colors.iconMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.name,
    required this.badge,
    required this.selected,
    required this.width,
    required this.onPressed,
  });

  final String name;
  final Widget badge;
  final bool selected;
  final double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: MenuItemButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(width, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: WidgetStatePropertyAll(
            selected
                ? ColorName.primary400.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
          overlayColor: WidgetStatePropertyAll(
            ColorName.primary400.withValues(alpha: 0.12),
          ),
        ),
        leadingIcon: badge,
        trailingIcon: selected
            ? Icon(
                Icons.check_rounded,
                color: context.colors.textPrimary,
                size: 20,
              )
            : null,
        child: Text(
          name,
          style: AppText.medium().copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// An icon in a circle the size of a flag badge, e.g. «Як у системі».
class CircleBadge extends StatelessWidget {
  const CircleBadge(this.icon, {super.key, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.fill,
          border: Border.all(color: context.colors.hairline),
        ),
        child: Icon(icon, size: size * 0.6, color: context.colors.textPrimary),
      ),
    );
  }
}
