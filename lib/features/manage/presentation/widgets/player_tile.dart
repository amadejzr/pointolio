import 'package:flutter/material.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/common/ui/widgets/player_avatar.dart';
import 'package:pointolio/features/manage/presentation/widgets/player_menu.dart';

/// A person in the Players library, in the Notebook/Slate style.
/// Avatar + name on a bordered surface; tapping edits the player, and the "⋯"
/// button opens the actions menu (edit / delete).
class PlayerTile extends StatelessWidget {
  const PlayerTile({
    required this.player,
    required this.colorIndex,
    super.key,
    this.onEdit,
    this.onDelete,
  });

  final Player player;

  /// Fallback index into the theme's player palette when the player has no
  /// stored colour.
  final int colorIndex;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  bool get _hasLastName =>
      player.lastName != null && player.lastName!.isNotEmpty;

  String get _displayName => _hasLastName
      ? '${player.firstName} ${player.lastName}'
      : player.firstName;

  String get _initial =>
      player.firstName.isNotEmpty ? player.firstName[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final avatarColor = player.color != null
        ? Color(player.color!)
        : pt.playerColor(colorIndex);

    return Pressable(
      onTap: onEdit,
      isButton: true,
      semanticLabel: _displayName,
      semanticHint: 'Edit player',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: pt.surface,
          borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: pt.border),
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Row(
                children: [
                  PlayerAvatar(initial: _initial, color: avatarColor),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.firstName,
                      style: PT.bodyStrong(pt.text).copyWith(fontSize: 14.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_hasLastName)
                      Text(
                        player.lastName!,
                        style: PT.caption(pt.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
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
    final action = await showPlayerMenu(context);
    switch (action) {
      case PlayerAction.edit:
        onEdit?.call();
      case PlayerAction.delete:
        onDelete?.call();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    // 48x48 hit target around a 34px visible disc.
    return Pressable(
      onTap: () => _open(context),
      scale: 0.88,
      isButton: true,
      semanticLabel: 'Player options',
      excludeChildSemantics: true,
      child: SizedBox(
        width: 48,
        height: 48,
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
