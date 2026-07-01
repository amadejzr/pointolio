import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';

enum SmallActionVariant {
  primary,
  destructive,
}

class SmallActionButton extends StatelessWidget {
  const SmallActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.variant = SmallActionVariant.primary,
    this.colorOverride,
    super.key,
  });

  /// Semantic preset
  const SmallActionButton.delete({
    required VoidCallback? onPressed,
    Color? colorOverride,
    Key? key,
  }) : this(
         key: key,
         icon: Icons.delete_outline,
         tooltip: 'Delete',
         onPressed: onPressed,
         variant: SmallActionVariant.destructive,
         colorOverride: colorOverride,
       );

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final SmallActionVariant variant;

  /// Optional explicit color (wins over variant)
  final Color? colorOverride;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    final baseColor =
        colorOverride ??
        switch (variant) {
          SmallActionVariant.primary => pt.accent,
          SmallActionVariant.destructive => pt.players[3],
        };

    return Tooltip(
      message: tooltip,
      child: Material(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: baseColor),
          ),
        ),
      ),
    );
  }
}
