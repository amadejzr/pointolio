import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';

/// A single player disc showing their initial.
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    required this.initial,
    required this.color,
    super.key,
    this.size = 36,
    this.ringColor,
  });

  final String initial;
  final Color color;
  final double size;

  /// Border colour, e.g. the card colour when avatars overlap.
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: ringColor != null
            ? Border.all(color: ringColor!, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: PT.number(pt.onPlayer, size: size * 0.4),
      ),
    );
  }
}

/// Overlapping row of avatars (the "who's playing" cluster). Caps the number
/// of discs shown and appends a "+N" disc for the overflow.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    required this.avatars,
    super.key,
    this.size = 23,
    this.overlap = 7,
    this.max = 5,
  });

  final List<PlayerAvatarData> avatars;
  final double size;
  final double overlap;
  final int max;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    if (avatars.isEmpty) return const SizedBox.shrink();

    final showOverflow = avatars.length > max;
    final visible = showOverflow ? avatars.take(max - 1).toList() : avatars;
    final overflowCount = avatars.length - visible.length;
    final discCount = visible.length + (showOverflow ? 1 : 0);
    final step = size - overlap;

    return SizedBox(
      height: size,
      width: size + (discCount - 1) * step,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * step,
              child: PlayerAvatar(
                initial: visible[i].initial,
                color: visible[i].color,
                size: size,
                ringColor: pt.surface,
              ),
            ),
          if (showOverflow)
            Positioned(
              left: visible.length * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: pt.surfaceMuted,
                  shape: BoxShape.circle,
                  border: Border.all(color: pt.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text('+$overflowCount', style: PT.tab(pt.textMuted)),
              ),
            ),
        ],
      ),
    );
  }
}

/// One avatar's display data (resolved colour + initial).
class PlayerAvatarData {
  const PlayerAvatarData({required this.initial, required this.color});

  final String initial;
  final Color color;
}
