import 'package:flutter/material.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';
import 'package:scoreio/common/ui/widgets/game_leading_widget.dart';
import 'package:scoreio/features/home/presentation/cubit/home_state.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    required this.gameWithPlayerCount,
    super.key,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onToggleFinished,
    this.isEditing = false,
    this.isFinished = false,
  });

  final GameWithPlayerCount gameWithPlayerCount;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;

  /// Toggle finished/un-finished (only shown when editing)
  final VoidCallback? onToggleFinished;

  /// Source of truth from DB (e.g. finishedAt != null)
  final bool isFinished;

  final bool isEditing;

  String get _title => gameWithPlayerCount.game.name;
  int get _playerCount => gameWithPlayerCount.playerCount;
  DateTime get _gameDate => gameWithPlayerCount.game.gameDate;
  String? get _gameType => gameWithPlayerCount.game.gameTypeNameSnapshot;
  int? get _gameTypeColor => gameWithPlayerCount.gameType?.color;
  bool get _lowestScoreWins =>
      gameWithPlayerCount.gameType?.lowestScoreWins ?? false;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasColor = _gameTypeColor != null;
    final typeColor = hasColor ? Color(_gameTypeColor!) : cs.primaryContainer;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: isEditing ? null : onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: Spacing.page,
          child: Row(
            children: [
              GameLeadingWidget(
                typeColor: typeColor,
                hasColor: hasColor,
                gameTypeName: _gameType,
                isFinished: isFinished,
              ),

              Spacing.hGap16,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacing.gap4,
                    Row(
                      children: [
                        if (_gameType != null) ...[
                          _WinConditionChip(lowestScoreWins: _lowestScoreWins),
                          Spacing.hGap8,
                        ],
                        Expanded(
                          child: Text(
                            '${_gameType != null ? '$_gameType • ' : ''}'
                            '$_playerCount players • ${_formatDate(_gameDate)}'
                            '${isFinished ? ' • Finished' : ''}',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: isFinished ? FontWeight.w600 : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Spacing.hGap12,

              if (isEditing) ...[
                if (onToggleFinished != null)
                  _EditIconButton(
                    tooltip: isFinished ? 'Mark as active' : 'Finish game',
                    icon: isFinished ? Icons.undo : Icons.check_circle_outline,
                    onPressed: onToggleFinished,
                  ),
                Spacing.hGap8,
                _EditIconButton(
                  tooltip: 'Delete',
                  icon: Icons.delete_outline,
                  onPressed: onDelete,
                  color: cs.error,
                ),
              ] else
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditIconButton extends StatelessWidget {
  const _EditIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.primary;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: c),
          ),
        ),
      ),
    );
  }
}

class _WinConditionChip extends StatelessWidget {
  const _WinConditionChip({required this.lowestScoreWins});

  final bool lowestScoreWins;

  @override
  Widget build(BuildContext context) {
    final icon = lowestScoreWins ? Icons.arrow_downward : Icons.arrow_upward;
    final color = lowestScoreWins ? Colors.blue : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }
}
