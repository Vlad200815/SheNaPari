import 'package:flutter/material.dart';

/// SheNaPari branded dual-circle pulse loader.
///
/// Usage:
///   Loader()
///   Loader(size: 60, color: Color(0xFFFFD614))
class Loader extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const Loader({
    super.key,
    this.size = 48,
    this.color = const Color(0xFFFFD614), // SheNaPari yellow accent
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Circle 1: pulse 0° → 180°  (first half of the loop)
  late Animation<double> _scale1;

  // Circle 2: pulse 180° → 360° (second half — perfectly offset)
  late Animation<double> _scale2;

  // Opacity dims when a circle is at its smallest
  late Animation<double> _opacity1;
  late Animation<double> _opacity2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();

    // ── Circle 1: grows in first half, shrinks in second half ──
    _scale1 = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.5,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    // ── Circle 2: opposite phase ──
    _scale2 = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.5,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Opacity: dims when small, full when large
    _opacity1 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.35), weight: 50),
    ]).animate(_controller);

    _opacity2 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCircle({
    required Animation<double> scale,
    required Animation<double> opacity,
  }) {
    final double circleSize = widget.size * 0.42;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: opacity.value,
          child: Transform.scale(
            scale: scale.value,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Outlined circle (matches the screenshot style)
                border: Border.all(
                  color: widget.color,
                  width: circleSize * 0.10,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gap = widget.size * 0.18;

    return SizedBox(
      width: widget.size,
      height: widget.size * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCircle(scale: _scale1, opacity: _opacity1),
          SizedBox(width: gap),
          _buildCircle(scale: _scale2, opacity: _opacity2),
        ],
      ),
    );
  }
}
