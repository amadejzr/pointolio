import 'package:flutter/material.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';
import 'package:scoreio/common/ui/widgets/small_action_buttons.dart';
import 'package:scoreio/common/ui/widgets/win_condition_widgets.dart';

class GameTypeItem extends StatelessWidget {
  const GameTypeItem({
    required this.gameType,
    this.onTap,
    this.onDelete,
    this.showDelete = false,
    this.showChevron = false,
    this.padding,
    super.key,
  });

  final GameType gameType;
  final VoidCallback? onTap;

  final VoidCallback? onDelete;
  final bool showDelete;
  final bool showChevron;

  /// Optional override if you want different density per screen
  final EdgeInsets? padding;

  String get _initial =>
      gameType.name.isNotEmpty ? gameType.name[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasColor = gameType.color != null;
    final typeColor = hasColor ? Color(gameType.color!) : cs.primaryContainer;

    final resolvedPadding = padding ?? Spacing.card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: resolvedPadding,
        child: Row(
          children: [
            _LeadingTypeIcon(
              hasColor: hasColor,
              color: typeColor,
              initial: _initial,
            ),
            Spacing.hGap12,

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + (optional small indicator on same row)
                  Text(
                    gameType.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  Spacing.gap4,
                  WinConditionIndicator(
                    lowestScoreWins: gameType.lowestScoreWins,
                    showLabel: true,
                  ),
                ],
              ),
            ),

            // Trailing actions
            if (showDelete) ...[
              Spacing.hGap12,
              // Your SmallActionButton already handles theming
              SmallActionButton.delete(onPressed: onDelete),
            ] else if (showChevron) ...[
              Spacing.hGap8,
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ],
        ),
      ),
    );
  }
}

class _LeadingTypeIcon extends StatelessWidget {
  const _LeadingTypeIcon({
    required this.hasColor,
    required this.color,
    required this.initial,
  });

  final bool hasColor;
  final Color color;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
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
                initial,
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
    );
  }
}
