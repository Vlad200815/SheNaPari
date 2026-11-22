import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rive/rive.dart' as rive;

import '../../../../../core/device/rive_support.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../gen/assets.gen.dart';
import 'rating_stars.dart';

/// The sheet's stars: «Rating animation» by JcToon (Rive, CC BY 4.0), fed
/// the rating through its `rating` input; the taps are ours, five equal
/// zones over the stars. While the file loads, if it fails, and with
/// «reduce motion» the drawn [RatingStars] stand in.
class RiveRatingStars extends StatefulWidget {
  const RiveRatingStars({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<RiveRatingStars> createState() => _RiveRatingStarsState();
}

class _RiveRatingStarsState extends State<RiveRatingStars> {
  final _factory = RiveSupport.factory;
  late final _loader = _factory == null
      ? null
      : rive.FileLoader.fromAsset(
          Assets.rive.ratingStars,
          riveFactory: _factory,
        );
  rive.NumberInput? _rating;

  @override
  void didUpdateWidget(RiveRatingStars old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _rating?.value = widget.value.toDouble();
  }

  @override
  void dispose() {
    _rating?.dispose();
    _loader?.dispose();
    super.dispose();
  }

  void _loaded(rive.RiveLoaded state) {
    // The file predates data binding: its only control is this input.
    // ignore: deprecated_member_use
    _rating = state.controller.stateMachine.number('rating')
      ?..value = widget.value.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = RatingStars(
      value: widget.value,
      onChanged: widget.onChanged,
      animateFirstValue: true,
    );
    final loader = _loader;
    if (loader == null || MediaQuery.disableAnimationsOf(context)) {
      return fallback;
    }
    return SizedBox(
      height: _Stars.maxHeight,
      child: rive.RiveWidgetBuilder(
        fileLoader: loader,
        artboardSelector: rive.ArtboardSelector.byName('New Artboard'),
        stateMachineSelector: rive.StateMachineSelector.byName(
          'State Machine 1',
        ),
        onLoaded: _loaded,
        builder: (context, state) => switch (state) {
          rive.RiveLoaded(:final controller) => _Stars(
            value: widget.value,
            onChanged: widget.onChanged,
            child: rive.RiveWidget(
              controller: controller,
              fit: rive.Fit.contain,
              hitTestBehavior: rive.RiveHitTestBehavior.none,
            ),
          ),
          _ => Center(child: fallback),
        },
      ),
    );
  }
}

/// The file's artboard is a big square with the five stars small in its
/// middle (34 % of the width, measured): show that strip only, enlarged so
/// the stars span [_fill] of the width, with the tap zones over them.
class _Stars extends StatelessWidget {
  const _Stars({
    required this.value,
    required this.onChanged,
    required this.child,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final Widget child;

  /// The stars' share of the artboard's width and of what is shown.
  static const _starsInArtboard = 0.343;
  static const _fill = 0.92;
  static const _maxWidth = 300.0;

  /// Tall enough for the pop and the fifth star's sparks.
  static const maxHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(0.0, _maxWidth);
        final artboard = width * _fill / _starsInArtboard;
        final inset = width * (1 - _fill) / 2;
        return Center(
          child: SizedBox(
            width: width,
            height: maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: OverflowBox(
                    minWidth: artboard,
                    maxWidth: artboard,
                    minHeight: artboard,
                    maxHeight: artboard,
                    child: child,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: inset),
                  child: Row(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        Expanded(
                          child: Semantics(
                            button: true,
                            selected: i == value,
                            label: LocaleKeys.rating_rate_star.tr(
                              namedArgs: {'n': '$i'},
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                onChanged(i);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
