import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import 'package:shenapari_core/ui/app_colors.dart';

import '../../../../../core/l10n/l10n.dart';

/// Five stars. With [onChanged] they are buttons: a star shrinks the moment
/// it is pressed, and on release the stars up to it fill in a quick wave
/// (+40 ms each) with a little overshoot, while six sparks in the logo's
/// colours fly off the tapped one. Without [onChanged] it is a plain
/// picture of [value]. «Reduce motion»: just the colour change.
class RatingStars extends StatefulWidget {
  const RatingStars({
    super.key,
    required this.value,
    this.onChanged,
    this.starSize = 44,
    this.spacing = 4,
    this.animateFirstValue = false,
  });

  /// 0–5.
  final int value;
  final ValueChanged<int>? onChanged;
  final double starSize;
  final double spacing;

  /// The sheet opens with the star tapped on the card: play the wave then.
  final bool animateFirstValue;

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars>
    with TickerProviderStateMixin {
  late final List<AnimationController> _pops = [
    for (var i = 0; i < 5; i++)
      AnimationController(vsync: this, duration: _popDuration, value: 1),
  ];
  late final AnimationController _sparks = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 680),
    value: 1,
  );
  int? _pressed;
  int _sparkFrom = 0;
  bool _started = false;

  static const _popDuration = Duration(milliseconds: 420);
  static const _wave = Duration(milliseconds: 40);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.animateFirstValue && widget.value > 0) _play(widget.value);
  }

  @override
  void didUpdateWidget(RatingStars old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && widget.value > 0) _play(widget.value);
  }

  void _play(int value) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    for (var i = 0; i < value; i++) {
      final pop = _pops[i]..value = 0;
      Future<void>.delayed(_wave * i, () {
        if (mounted) pop.forward(from: 0);
      });
    }
    _sparkFrom = value;
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _sparks.forward(from: 0);
    });
  }

  @override
  void dispose() {
    for (final pop in _pops) {
      pop.dispose();
    }
    _sparks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onChanged = widget.onChanged;
    final box = widget.starSize + 14;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++) ...[
          if (i > 1) SizedBox(width: widget.spacing),
          Semantics(
            button: onChanged != null,
            selected: i == widget.value,
            label: onChanged == null
                ? null
                : LocaleKeys.rating_rate_star.tr(namedArgs: {'n': '$i'}),
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: onChanged == null
                  ? null
                  : (_) => setState(() => _pressed = i),
              onTapCancel: () => setState(() => _pressed = null),
              onTap: onChanged == null
                  ? null
                  : () {
                      setState(() => _pressed = null);
                      HapticFeedback.selectionClick();
                      onChanged(i);
                    },
              child: SizedBox.square(
                dimension: box,
                child: AnimatedScale(
                  scale: _pressed == i ? 0.86 : 1,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _StarPainter(
                        pop: _pops[i - 1],
                        sparks: _sparks,
                        filled: i <= widget.value,
                        sparkles: i == _sparkFrom,
                        emptyFill: context.colors.surface,
                        emptyStroke: context.colors.iconMuted,
                        starSize: widget.starSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The star of the logo's family: rounded joins, the brand yellow when
/// filled, a quiet outline when not.
class _StarPainter extends CustomPainter {
  _StarPainter({
    required this.pop,
    required this.sparks,
    required this.filled,
    required this.sparkles,
    required this.emptyFill,
    required this.emptyStroke,
    required this.starSize,
  }) : super(repaint: Listenable.merge([pop, sparks]));

  final Animation<double> pop;
  final Animation<double> sparks;
  final bool filled;
  final bool sparkles;
  final Color emptyFill;
  final Color emptyStroke;
  final double starSize;

  static const _outline = Color(0xFFF0A500);
  static const _sparkColors = [
    ColorName.primary400,
    ColorName.primary500,
    Color(0xFFFF0263),
    ColorName.primary300,
    ColorName.primary500,
    ColorName.primary400,
  ];

  /// .62 → 1.2 → 1: the pop, eased out.
  static final _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.62, end: 1.2), weight: 55),
    TweenSequenceItem(tween: Tween(begin: 1.2, end: 1), weight: 45),
  ]).chain(CurveTween(curve: Curves.easeOutCubic));

  /// The star of a 24×24 icon.
  static final _star = Path()
    ..moveTo(12, 2.8)
    ..lineTo(14.8, 8.5)
    ..lineTo(21.1, 9.4)
    ..lineTo(16.5, 13.8)
    ..lineTo(17.6, 20.1)
    ..lineTo(12, 17.1)
    ..lineTo(6.4, 20.1)
    ..lineTo(7.5, 13.8)
    ..lineTo(2.9, 9.4)
    ..lineTo(9.2, 8.5)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    if (sparkles && filled && sparks.value > 0 && sparks.value < 1) {
      final t = Curves.easeOutCubic.transform(sparks.value);
      for (var k = 0; k < 6; k++) {
        final angle = k / 6 * 2 * math.pi - math.pi / 2 + 0.3;
        final distance = starSize * (0.2 + (0.5 + (k.isOdd ? 0.12 : 0)) * t);
        final at = center + Offset(math.cos(angle), math.sin(angle)) * distance;
        canvas.drawCircle(
          at,
          3.2 * (1 - 0.7 * t),
          Paint()..color = _sparkColors[k].withValues(alpha: 1 - t),
        );
      }
    }

    final scale = filled ? _scale.transform(pop.value) : 1.0;
    final unit = starSize / 24 * scale;
    canvas
      ..save()
      ..translate(center.dx - 12 * unit, center.dy - 12 * unit)
      ..scale(unit);
    canvas
      ..drawPath(
        _star,
        Paint()..color = filled ? ColorName.primary400 : emptyFill,
      )
      ..drawPath(
        _star,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 1.5
          ..color = filled ? _outline : emptyStroke,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.filled != filled ||
      old.sparkles != sparkles ||
      old.emptyFill != emptyFill ||
      old.emptyStroke != emptyStroke ||
      old.starSize != starSize;
}
