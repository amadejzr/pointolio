import 'package:flutter/material.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/features/manage/presentation/widgets/game_menu.dart';

/// A saved game in the Games library, in the Notebook/Slate style. A colour bar
/// carries the game's hue; the "⋯" button opens the actions menu (edit /
/// delete). Tapping the card opens the editor.
class GameTile extends StatelessWidget {
  const GameTile({
    required this.gameType,
    super.key,
    this.onEdit,
    this.onDelete,
  });

  final GameType gameType;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    final typeColor = gameType.color;
    final barColor = typeColor != null ? Color(typeColor) : pt.accent;
    final rule = gameType.lowestScoreWins
        ? 'Lowest score wins'
        : 'Highest score wins';
    final summary = '${gameType.name}, $rule';

    return Pressable(
      onTap: onEdit,
      isButton: true,
      semanticLabel: summary,
      semanticHint: 'Edit game',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: pt.surface,
          borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: pt.border),
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 12,
                height: 38,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      gameType.name,
                      style: PT.cardTitle(pt.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(rule, style: PT.caption(pt.textMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: S.sm),
            _MenuButton(onEdit: onEdit, onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onEdit, required this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  Future<void> _open(BuildContext context) async {
    final action = await showGameMenu(context);
    switch (action) {
      case GameAction.edit:
        onEdit?.call();
      case GameAction.delete:
        onDelete?.call();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    // 44x44 hit target around a 34px visible disc.
    return Pressable(
      onTap: () => _open(context),
      scale: 0.88,
      isButton: true,
      semanticLabel: 'Game options',
      excludeChildSemantics: true,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: pt.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: pt.border),
            ),
            child: Icon(
              Icons.more_horiz_rounded,
              size: 20,
              color: pt.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
