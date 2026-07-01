import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';

/// A single tappable settings row: tinted leading icon, title, optional
/// subtitle, and a trailing affordance (chevron, external-link glyph or a
/// spinner). Set [destructive] for the danger-zone styling.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
    this.subtitle,
    this.trailing,
    this.destructive = false,
    this.semanticHint,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final accent = destructive ? pt.players[3] : pt.accent; // rose vs blue
    final titleColor = destructive ? pt.players[3] : pt.text;

    return Pressable(
      onTap: onTap,
      scale: 0.98,
      isButton: true,
      semanticLabel: title,
      semanticHint: semanticHint,
      excludeChildSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(S.md),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(R.sm),
              ),
              child: Icon(icon, size: 19, color: accent),
            ),
            const SizedBox(width: S.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: PT.bodyStrong(titleColor)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: PT.caption(pt.textMuted)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: S.sm), trailing!],
          ],
        ),
      ),
    );
  }
}
