import 'package:flutter/material.dart';

/// The translucent card the result is drawn on. [opacity] (0.35..1.0) drives
/// the dark fill; the card is always exported over a transparent canvas, so the
/// user drops it straight onto a story or shares it as a standalone PNG.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    this.opacity = 0.72,
    this.tint = const Color(0xFF10131A),
    this.padding = const EdgeInsets.all(24),
    this.radius = 20,
    super.key,
  });

  final double opacity;
  final Color tint;
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: child,
    );
  }
}
