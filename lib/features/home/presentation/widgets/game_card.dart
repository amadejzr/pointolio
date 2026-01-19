import 'package:flutter/material.dart';
import 'package:scoreio/features/home/presentation/cubit/home_state.dart';

class GameCard extends StatelessWidget {
  final GameWithPlayerCount gameWithPlayerCount;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final bool isEditing;

  const GameCard({
    super.key,
    required this.gameWithPlayerCount,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.isEditing = false,
  });

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

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasColor = _gameTypeColor != null;
    final color = hasColor ? Color(_gameTypeColor!) : cs.primaryContainer;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: isEditing ? null : onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: hasColor
                      ? Text(
                          _gameType?.isNotEmpty == true
                              ? _gameType![0].toUpperCase()
                              : '?',
                          style: tt.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : Icon(
                          Icons.sports_esports_outlined,
                          color: cs.onPrimaryContainer,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (_gameType != null) ...[
                          _WinConditionChip(lowestScoreWins: _lowestScoreWins),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            '${_gameType != null ? '$_gameType • ' : ''}$_playerCount players • ${_formatDate(_gameDate)}',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
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
              if (isEditing)
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: cs.error,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Delete'),
                )
              else
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
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
