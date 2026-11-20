import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'package:shenapari_core/ui/app_text.dart';
import '../../domain/entities/break_slot.dart';
import '../../domain/entities/canteen.dart';
import '../home/break_countdown.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import '../../../../core/l10n/l10n.dart';

/// The orange card under the greeting: when the next break is, how long
/// until it and which canteen. Also tells when the kitchen is paused or no
/// break is scheduled.
class BreakCard extends StatefulWidget {
  const BreakCard({
    super.key,
    required this.canteen,
    required this.nextBreak,
    required this.onBreakStarted,
  });

  final Canteen canteen;
  final BreakSlot? nextBreak;

  /// Called once when the shown break starts, to load the next one.
  final VoidCallback onBreakStarted;

  @override
  State<BreakCard> createState() => _BreakCardState();
}

class _BreakCardState extends State<BreakCard> {
  Timer? _ticker;
  bool _reportedStart = false;

  @override
  void initState() {
    super.initState();
    // Minutes are the smallest unit on the card; 15 s keeps it accurate.
    _ticker = Timer.periodic(const Duration(seconds: 15), (_) => _tick());
  }

  @override
  void didUpdateWidget(BreakCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nextBreak != widget.nextBreak) _reportedStart = false;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.nextBreak;
    final countdown = slot == null
        ? null
        : BreakCountdown(slot, DateTime.now());
    if (countdown != null && countdown.hasStarted && !_reportedStart) {
      _reportedStart = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onBreakStarted(),
      );
    }

    final paused = !widget.canteen.isAcceptingOrders;
    final (icon, title, subtitle) = switch ((paused, countdown)) {
      (true, _) => (
        Icons.pause_circle_outline,
        LocaleKeys.break_card_paused_title.tr(),
        LocaleKeys.break_card_paused_text.tr(),
      ),
      (false, null) => (
        Icons.event_busy_outlined,
        LocaleKeys.break_card_none_title.tr(),
        LocaleKeys.break_card_none_text.tr(),
      ),
      (false, final countdown?) => (
        Icons.schedule_rounded,
        countdown.title,
        LocaleKeys.break_card_order_now.tr(),
      ),
    };

    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // The same solid yellow as the selected filter chip, with black
          // text on it (white on yellow would be unreadable).
          color: ColorName.primary400,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ColorName.primary400.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              const Positioned(right: -40, top: -50, child: _Bubble(160)),
              const Positioned(right: -20, bottom: -45, child: _Bubble(100)),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _IconCircle(icon: icon),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppText.title(color: ColorName.black)
                                    .copyWith(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                subtitle,
                                style: AppText.small(
                                  color: ColorName.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!paused && countdown != null) ...[
                      const SizedBox(height: 16),
                      _ProgressBar(value: countdown.progress),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (!paused && countdown != null)
                          _Chip.solid(text: countdown.timeLeft),
                        _Chip.glass(
                          icon: Icons.location_on_outlined,
                          text: widget.canteen.name,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A decorative circle in the corner.
class _Bubble extends StatelessWidget {
  const _Bubble(this.size);

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorName.white.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorName.white.withValues(alpha: 0.5),
      ),
      child: Icon(icon, color: ColorName.black, size: 24),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: LocaleKeys.break_card_time_left.tr(),
      value: '${(value * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: ColorName.black.withValues(alpha: 0.12)),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: const ColoredBox(color: ColorName.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip.solid({required this.text}) : icon = null, _glass = false;

  const _Chip.glass({required this.text, required this.icon}) : _glass = true;

  final String text;
  final IconData? icon;
  final bool _glass;

  @override
  Widget build(BuildContext context) {
    const color = ColorName.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _glass
            ? ColorName.white.withValues(alpha: 0.5)
            : ColorName.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              style: AppText.small(color: color, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
