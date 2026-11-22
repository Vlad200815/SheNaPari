import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:shenapari_core/gen/colors.gen.dart';

/// The tick on «Оплачено», played once: the yellow circle pops in, the
/// tick draws itself, a soft ring and a handful of confetti in the logo's
/// colours fly out, and the phone gives one firm tap. With «reduce motion»
/// it is simply there.
///
/// Kept on its own, so a Rive animation can take its place later (same
/// size, same moment).
class PaidCheck extends StatefulWidget {
  const PaidCheck({super.key, this.size = 104});

  /// The circle; the confetti flies a bit beyond it.
  final double size;

  @override
  State<PaidCheck> createState() => _PaidCheckState();
}

class _PaidCheckState extends State<PaidCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    _controller.forward();
    // The tap lands when the tick is drawn, not when the screen opens.
    Future<void>.delayed(const Duration(milliseconds: 560), () {
      if (mounted) HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Decoration: the title under it already says «оплачено». The box holds
    // the confetti too (they fly to ~0.84 × size from the centre), so
    // nothing above or below gets hit by them.
    final box = widget.size * 1.9;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: box,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _PaidCheckPainter(
              progress: _controller,
              circle: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaidCheckPainter extends CustomPainter {
  _PaidCheckPainter({required this.progress, required this.circle})
    : super(repaint: progress);

  final Animation<double> progress;
  final double circle;

  // The logo's yellow, orange and the pink of its tongue.
  static const _confettiColors = [
    ColorName.primary400,
    ColorName.primary500,
    Color(0xFFFF0263),
    ColorName.primary300,
  ];
  static const _confettiCount = 12;

  /// [t] mapped to 0…1 inside [begin, end], eased.
  static double _phase(
    double t,
    double begin,
    double end, [
    Curve curve = Curves.linear,
  ]) => curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    final center = size.center(Offset.zero);
    final radius = circle / 2;

    // 1. A ring that swells out and fades behind the circle.
    final ring = _phase(t, 0.25, 0.85, Curves.easeOut);
    if (ring > 0 && ring < 1) {
      canvas.drawCircle(
        center,
        radius * (1 + 0.6 * ring),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 * (1 - ring) + 1
          ..color = ColorName.primary400.withValues(alpha: 0.45 * (1 - ring)),
      );
    }

    // 2. Confetti: short rounded dashes flying out and fading.
    final burst = _phase(t, 0.32, 1, Curves.easeOutCubic);
    if (burst > 0 && burst < 1) {
      for (var i = 0; i < _confettiCount; i++) {
        final angle =
            (i / _confettiCount) * 2 * math.pi + (i.isEven ? 0.18 : 0);
        final distance = radius * (1.05 + (i.isEven ? 0.62 : 0.42) * burst);
        final direction = Offset(math.cos(angle), math.sin(angle));
        final from = center + direction * distance;
        final to = center + direction * (distance + 7 * (1 - burst) + 3);
        canvas.drawLine(
          from,
          to,
          Paint()
            ..strokeWidth = i.isEven ? 5 : 4
            ..strokeCap = StrokeCap.round
            ..color = _confettiColors[i % _confettiColors.length].withValues(
              alpha: 1 - burst,
            ),
        );
      }
    }

    // 3. The circle pops in with a little overshoot.
    final pop = _phase(t, 0, 0.36, Curves.easeOutBack);
    if (pop > 0) {
      canvas.drawCircle(
        center,
        radius * pop,
        Paint()..color = ColorName.primary400,
      );
    }

    // 4. The tick draws itself from the short arm to the long one.
    final draw = _phase(t, 0.3, 0.58, Curves.easeInOut);
    if (draw > 0) {
      final s = circle;
      final tick = Path()
        ..moveTo(center.dx - s * 0.2, center.dy + s * 0.01)
        ..lineTo(center.dx - s * 0.06, center.dy + s * 0.15)
        ..lineTo(center.dx + s * 0.22, center.dy - s * 0.14);
      final metric = tick.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * draw),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.085
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = ColorName.black,
      );
    }
  }

  @override
  bool shouldRepaint(_PaidCheckPainter old) =>
      old.circle != circle || old.progress != progress;
}
