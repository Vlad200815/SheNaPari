import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_text.dart';
import '../../../../gen/colors.gen.dart';

/// `+380681234567` → `+38 (068) 123-45-67`.
String formatProfilePhone(String phone) {
  final m = RegExp(r'^\+38(\d{3})(\d{3})(\d{2})(\d{2})$').firstMatch(phone);
  if (m == null) return phone;
  return '+38 (${m[1]}) ${m[2]}-${m[3]}-${m[4]}';
}

/// A white rounded card holding rows, with thin dividers between them.
class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorName.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: 68,
                color: ColorName.secondary200,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A row with a tinted icon tile, a title, an optional hint and a chevron.
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.icon,
    required this.tint,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;

  /// The tile colour; the icon on it stays black for contrast.
  final Color tint;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 21, color: ColorName.black),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.medium().copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(subtitle, style: AppText.small()),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ColorName.secondary400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round avatar with the first letter of the name on brand yellow.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 72});

  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = (name?.trim().isNotEmpty ?? false)
        ? name!.trim().characters.first.toUpperCase()
        : null;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: ColorName.primary400,
          shape: BoxShape.circle,
        ),
        child: letter == null
            ? Icon(
                Icons.person_rounded,
                size: size * 0.5,
                color: ColorName.black,
              )
            : Text(
                letter,
                style: AppText.heading(
                  color: ColorName.black,
                ).copyWith(fontSize: size * 0.42),
              ),
      ),
    );
  }
}
