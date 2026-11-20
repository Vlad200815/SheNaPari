import 'package:material_ui/material_ui.dart';
import 'package:shenapari_core/gen/colors.gen.dart';
import 'package:shenapari_core/ui/app_colors.dart';
import 'package:shenapari_core/ui/app_logo.dart';
import 'package:shenapari_core/ui/app_text.dart';
import 'package:shenapari_core/ui/confirm_sheet.dart';

import '../../../core/l10n/l10n.dart';

enum KitchenTab { queue, pickup, stopList }

/// The kitchen's frame: on a tablet a top bar with the logo, the three tabs
/// and the employee button; on a phone a header and a bottom bar. For now
/// only the empty queue is there — the columns come next.
class QueuePage extends StatefulWidget {
  const QueuePage({super.key, required this.onSignOut});

  final Future<void> Function() onSignOut;

  static const tabletWidth = 720.0;

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  var _tab = KitchenTab.queue;

  Future<void> _signOut() async {
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.logout_rounded,
      title: LocaleKeys.queue_sign_out_title.tr(),
      text: LocaleKeys.queue_sign_out_text.tr(),
      confirm: LocaleKeys.queue_sign_out.tr(),
      keep: LocaleKeys.queue_stay.tr(),
    );
    if (confirmed) await widget.onSignOut();
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_tab) {
      KitchenTab.queue => const _Empty(),
      KitchenTab.pickup || KitchenTab.stopList => const _Soon(),
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final tablet = constraints.maxWidth >= QueuePage.tabletWidth;
        return Scaffold(
          body: SafeArea(
            bottom: tablet,
            child: Column(
              children: [
                tablet
                    ? _TopBar(
                        tab: _tab,
                        onTab: (tab) => setState(() => _tab = tab),
                        onSignOut: _signOut,
                      )
                    : _PhoneHeader(tab: _tab, onSignOut: _signOut),
                Expanded(child: body),
              ],
            ),
          ),
          bottomNavigationBar: tablet
              ? null
              : _BottomBar(
                  tab: _tab,
                  onTab: (tab) => setState(() => _tab = tab),
                ),
        );
      },
    );
  }
}

String _label(KitchenTab tab) => switch (tab) {
  KitchenTab.queue => LocaleKeys.queue_tab_queue.tr(),
  KitchenTab.pickup => LocaleKeys.queue_tab_pickup.tr(),
  KitchenTab.stopList => LocaleKeys.queue_tab_stop.tr(),
};

IconData _icon(KitchenTab tab) => switch (tab) {
  KitchenTab.queue => Icons.view_column_rounded,
  KitchenTab.pickup => Icons.qr_code_scanner_rounded,
  KitchenTab.stopList => Icons.block_rounded,
};

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.tab,
    required this.onTab,
    required this.onSignOut,
  });

  final KitchenTab tab;
  final ValueChanged<KitchenTab> onTab;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          const AppLogo(width: 48),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: 1,
            height: 24,
            color: colors.border,
          ),
          Text(
            LocaleKeys.kitchen.tr(),
            style: AppText.medium().copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                for (final t in KitchenTab.values)
                  _TabChip(
                    label: _label(t),
                    selected: t == tab,
                    onTap: () => onTab(t),
                  ),
              ],
            ),
          ),
          const Spacer(),
          _AccountButton(onSignOut: onSignOut),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.fill : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: AppText.small(
              color: selected ? colors.textPrimary : colors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: LocaleKeys.queue_sign_out.tr(),
      onPressed: onSignOut,
      style: IconButton.styleFrom(
        backgroundColor: context.colors.fill,
        minimumSize: const Size(44, 44),
      ),
      icon: Icon(Icons.logout_rounded, color: context.colors.textPrimary),
    );
  }
}

class _PhoneHeader extends StatelessWidget {
  const _PhoneHeader({required this.tab, required this.onSignOut});

  final KitchenTab tab;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          const AppLogo(width: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _label(tab),
              style: AppText.title().copyWith(fontSize: 20),
            ),
          ),
          _AccountButton(onSignOut: onSignOut),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.tab, required this.onTab});

  final KitchenTab tab;
  final ValueChanged<KitchenTab> onTab;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (final t in KitchenTab.values)
                Expanded(
                  child: Semantics(
                    selected: t == tab,
                    button: true,
                    child: InkResponse(
                      onTap: () => onTab(t),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _icon(t),
                            color: t == tab
                                ? ColorName.primary400
                                : colors.iconMuted,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _label(t),
                            style: AppText.small(
                              color: t == tab
                                  ? ColorName.primary400
                                  : colors.textSecondary,
                              fontWeight: t == tab
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// «Поки тихо»: nothing in the queue.
class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.fill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 46,
                color: ColorName.primary400,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              LocaleKeys.queue_empty_title.tr(),
              style: AppText.title().copyWith(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              LocaleKeys.queue_empty_text.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _Soon extends StatelessWidget {
  const _Soon();

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      LocaleKeys.queue_soon.tr(),
      style: AppText.regular(color: context.colors.textSecondary),
    ),
  );
}
