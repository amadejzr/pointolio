import 'package:flutter/material.dart';

/// Extracted: 48x48 colored tile + initial/icon + optional finished badge outside
class GameLeadingWidget extends StatelessWidget {
  const GameLeadingWidget({
    required this.typeColor,
    required this.hasColor,
    required this.gameTypeName,
    required this.isFinished,

    this.size = 48,
    this.radius = 12,
    this.badgeSize = 22,
    this.badgeOffset = 6,
    super.key,
  });

  final Color typeColor;
  final bool hasColor;
  final String? gameTypeName;
  final bool isFinished;

  final double size;
  final double radius;

  final double badgeSize;
  final double badgeOffset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final label = (gameTypeName?.isNotEmpty ?? false)
        ? gameTypeName![0].toUpperCase()
        : '?';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Center(
              child: hasColor
                  ? Text(
                      label,
                      style: tt.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Icon(
                      Icons.sports_esports_outlined,
                      color: cs.onPrimaryContainer,
                    ),
            ),
          ),

          if (isFinished)
            Positioned(
              right: -badgeOffset,
              bottom: -badgeOffset,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 2),
                ),
                child: Icon(
                  Icons.check,
                  size: badgeSize * 0.64,
                  color: cs.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
