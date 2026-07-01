import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/common/ui/widgets/player_avatar.dart';
import 'package:pointolio/features/home/presentation/cubit/home_state.dart';
import 'package:pointolio/features/home/presentation/widgets/party_menu.dart';

/// A party in the Parties list, in the Notebook/Slate style. Live parties get
/// a white card + soft shadow; finished ones sit on a muted surface. The "⋯"
/// button opens the actions sheet (finish / delete).
class PartyCard extends StatelessWidget {
  const PartyCard({
    required this.gameWithPlayerCount,
    super.key,
    this.onTap,
    this.onDelete,
    this.onToggleFinished,
    this.isFinished = false,
  });

  final GameWithPlayerCount gameWithPlayerCount;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFinished;
  final bool isFinished;

  String? get _typeName =>
      gameWithPlayerCount.gameType?.name ??
      gameWithPlayerCount.game.gameTypeNameSnapshot;

  String get _meta {
    final parts = <String>[];
    final type = _typeName;
    if (type != null) parts.add(type);
    if (gameWithPlayerCount.gameType != null) {
      parts.add(
        gameWithPlayerCount.gameType!.lowestScoreWins
            ? 'Lowest wins'
            : 'Highest wins',
      );
    }
    return parts.join(' · ');
  }

  static String _initial(String name) =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final game = gameWithPlayerCount.game;
    final roundCount = gameWithPlayerCount.roundCount;
    final winnerName = gameWithPlayerCount.winnerName;

    final typeColor = gameWithPlayerCount.gameType?.color;
    final dotColor = typeColor != null ? Color(typeColor) : pt.accent;
    final meta = _meta;

    final roster = [
      for (var i = 0; i < gameWithPlayerCount.players.length; i++)
        PlayerAvatarData(
          initial: _initial(gameWithPlayerCount.players[i].firstName),
          color: gameWithPlayerCount.players[i].color != null
              ? Color(gameWithPlayerCount.players[i].color!)
              : pt.playerColor(i),
        ),
    ];

    final count = gameWithPlayerCount.playerCount;
    final status = isFinished
        ? (winnerName != null ? 'Finished, $winnerName won' : 'Finished')
        : (roundCount > 0 ? 'Round $roundCount' : 'Not started');
    final summary = [
      game.name,
      if (meta.isNotEmpty) meta,
      '$count ${count == 1 ? 'player' : 'players'}',
      status,
    ].join(', ');

    return Pressable(
      onTap: onTap,
      isButton: true,
      semanticLabel: summary,
      semanticHint: isFinished ? 'Opens the score sheet' : 'Opens the scores',
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isFinished ? pt.surfaceMuted : pt.surface,
          borderRadius: BorderRadius.circular(R.lg),
          border: Border.all(color: pt.border),
          boxShadow: isFinished ? null : pt.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                game.name,
                                style: PT.cardTitle(pt.text),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (meta.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(meta, style: PT.caption(pt.textMuted)),
                        ],
                      ],
                    ),
                  ),
                ),
                _MenuButton(
                  background: isFinished ? pt.surface : pt.surfaceMuted,
                  isFinished: isFinished,
                  onToggleFinished: onToggleFinished,
                  onDelete: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 13),
            ExcludeSemantics(
              child: isFinished
                  ? _Chip(
                      label: winnerName != null
                          ? '🏆 $winnerName won'
                          : 'Finished',
                      color: pt.textMuted,
                      bg: pt.surface,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AvatarStack(avatars: roster),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          label: roundCount > 0
                              ? 'Round $roundCount'
                              : 'Not started',
                          color: pt.accent,
                          bg: pt.accentTint,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.background,
    required this.isFinished,
    required this.onToggleFinished,
    required this.onDelete,
  });

  final Color background;
  final bool isFinished;
  final VoidCallback? onToggleFinished;
  final VoidCallback? onDelete;

  Future<void> _open(BuildContext context) async {
    final action = await showPartyMenu(context, isFinished: isFinished);
    switch (action) {
      case PartyAction.toggleFinished:
        onToggleFinished?.call();
      case PartyAction.delete:
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
      semanticLabel: 'Party options',
      excludeChildSemantics: true,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: background,
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, required this.bg});

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(R.pill),
      ),
      child: Text(label, style: PT.chip(color)),
    );
  }
}
