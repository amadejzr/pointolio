import 'package:flutter/material.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';

class WinConditionIndicator extends StatelessWidget {
  const WinConditionIndicator({
    required this.lowestScoreWins,
    this.showLabel = false,
    super.key,
  });

  /// Domain flag (kept as requested)
  final bool lowestScoreWins;

  /// UI flag
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final icon = lowestScoreWins ? Icons.arrow_downward : Icons.arrow_upward;

    final Color color = lowestScoreWins ? Colors.blue : Colors.orange;

    final label = lowestScoreWins ? 'Lowest wins' : 'Highest wins';

    return Container(
      padding: showLabel
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(showLabel ? 8 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: showLabel ? 14 : 12,
            color: color,
          ),
          if (showLabel) ...[
            Spacing.hGap8,
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
