import 'package:flutter/material.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';

class GameTypeTile extends StatelessWidget {
  const GameTypeTile({
    required this.gameType,
    super.key,
  });

  final GameType gameType;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasColor = gameType.color != null;
    final color = hasColor ? Color(gameType.color!) : cs.primary;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: Spacing.card,
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hasColor ? color : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: hasColor
                    ? null
                    : Border.all(color: cs.outlineVariant, width: 2),
              ),
              child: Center(
                child: hasColor
                    ? Text(
                        gameType.name.isNotEmpty
                            ? gameType.name[0].toUpperCase()
                            : '?',
                        style: tt.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : Icon(
                        Icons.category_outlined,
                        color: cs.onSurfaceVariant,
                        size: 20,
                      ),
              ),
            ),
            Spacing.hGap12,

            // Name and badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gameType.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacing.gap4,
                  WinConditionBadge(
                    lowestScoreWins: gameType.lowestScoreWins,
                  ),
                ],
              ),
            ),

            Spacing.hGap8,
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class WinConditionBadge extends StatelessWidget {
  const WinConditionBadge({required this.lowestScoreWins, super.key});

  final bool lowestScoreWins;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final icon = lowestScoreWins ? Icons.arrow_downward : Icons.arrow_upward;
    final label = lowestScoreWins ? 'Lowest wins' : 'Highest wins';
    final color = lowestScoreWins ? Colors.blue : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          Spacing.hGap8,
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
