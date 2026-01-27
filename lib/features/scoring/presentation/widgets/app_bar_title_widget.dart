import 'package:flutter/material.dart';
import 'package:pointolio/common/ui/widgets/game_leading_widget.dart';

class AppBarTitleMenu extends StatelessWidget {
  const AppBarTitleMenu({
    required this.title,
    required this.gameTypeName,
    required this.gameTypeColor,
    required this.lowestScoreWins,
    required this.isFinished,
    required this.onToggleFinished,
    required this.onShare,
    required this.onEdit,
    super.key,
  });

  final String title;
  final String? gameTypeName;
  final int? gameTypeColor;
  final bool lowestScoreWins;
  final bool isFinished;

  final VoidCallback onToggleFinished;
  final VoidCallback onShare;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final hasColor = gameTypeColor != null;
    final color = hasColor ? Color(gameTypeColor!) : cs.primaryContainer;

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: PopupMenuButton<_ScoringMenuAction>(
        position: PopupMenuPosition.under,
        tooltip: 'Game menu',
        onSelected: (action) {
          switch (action) {
            case _ScoringMenuAction.toggleFinished:
              onToggleFinished();
            case _ScoringMenuAction.share:
              onShare();
            case _ScoringMenuAction.edit:
              onEdit();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _ScoringMenuAction.toggleFinished,
            child: Row(
              children: [
                Icon(
                  isFinished ? Icons.undo : Icons.check_circle_outline,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(isFinished ? 'Mark as active' : 'Finish party'),
              ],
            ),
          ),

          PopupMenuItem(
            value: _ScoringMenuAction.edit,
            child: Row(
              children: [
                Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                const Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: _ScoringMenuAction.share,
            child: Row(
              children: [
                Icon(Icons.ios_share, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                const Text('Share'),
              ],
            ),
          ),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameLeadingWidget(
              typeColor: color,
              hasColor: hasColor,
              gameTypeName: gameTypeName,
              isFinished: isFinished,
              size: 32,
              radius: 8,
              badgeSize: 16,
              badgeOffset: 4,
            ),
            const SizedBox(width: 12),

            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        lowestScoreWins
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 12,
                        color: lowestScoreWins ? Colors.blue : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          lowestScoreWins ? 'Lowest wins' : 'Highest wins',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: lowestScoreWins
                                    ? Colors.blue
                                    : Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),
            Icon(Icons.expand_more, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

enum _ScoringMenuAction { toggleFinished, edit, share }
