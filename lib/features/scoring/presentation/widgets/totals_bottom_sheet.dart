import 'package:flutter/material.dart';
import 'package:scoreio/features/scoring/presentation/cubit/scoring_state.dart';

class TotalsBar extends StatelessWidget {
  const TotalsBar({super.key, required this.state, required this.onShowTotals});

  final ScoringState state;
  final VoidCallback onShowTotals;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final players = state.playerScores;
    final totals = players.map((e) => e.total).toList();
    final int? maxTotal = totals.isEmpty
        ? null
        : totals.reduce((a, b) => a > b ? a : b);
    final int? minTotal = totals.isEmpty
        ? null
        : totals.reduce((a, b) => a < b ? a : b);

    // Determine winning score based on game type
    final int? winningScore = state.lowestScoreWins ? minTotal : maxTotal;

    final leaders = winningScore == null
        ? <PlayerScore>[]
        : players.where((p) => p.total == winningScore).toList();

    final leaderLabel = leaders.isEmpty
        ? '—'
        : leaders.length == 1
        ? _initials(_fullName(leaders.first))
        : 'Tie';

    final leaderScore = winningScore?.toString() ?? '—';
    final spread = (maxTotal != null && minTotal != null)
        ? (maxTotal - minTotal)
        : null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: Row(
          children: [
            // Left: meta
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.playerScores.length} players • ${state.roundCount} rounds',
                    style: text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spread == null ? 'Spread: —' : 'Spread: $spread',
                    style: text.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Center: leader pill
            _LeaderPill(label: leaderLabel, score: leaderScore),

            const SizedBox(width: 10),

            // Right: totals button
            FilledButton.tonal(
              onPressed: onShowTotals,
              child: const Text('Totals'),
            ),
          ],
        ),
      ),
    );
  }

  static String _fullName(PlayerScore ps) {
    final fn = ps.player.firstName.trim();
    final ln = (ps.player.lastName ?? '').trim();
    return ln.isEmpty ? fn : '$fn $ln';
  }

  static String _initials(String name) {
    final parts = name.split(' ').where((p) => p.trim().isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

class _LeaderPill extends StatelessWidget {
  const _LeaderPill({required this.label, required this.score});

  final String label;
  final String score;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: cs.primaryContainer,
            foregroundColor: cs.onPrimaryContainer,
            child: Text(
              label,
              style: text.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            score,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class TotalsSheet extends StatelessWidget {
  const TotalsSheet({super.key, required this.state});

  final ScoringState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Sort based on win condition: lowest wins = ascending, highest wins = descending
    final sorted = [...state.playerScores]
      ..sort((a, b) => state.lowestScoreWins
          ? a.total.compareTo(b.total)
          : b.total.compareTo(a.total));

    final top = sorted.isEmpty ? null : sorted.first.total;

    // Compute ranks with ties (players with same score share the same rank)
    final ranks = _computeRanks(sorted);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Totals',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(
                    '${sorted.length} players',
                    style: text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final ps = sorted[index];
                  final name = _fullName(ps);
                  final isLeader = top != null && ps.total == top;
                  final rank = ranks[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: isLeader ? cs.primaryContainer : cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      leading: _RankBadge(rank: rank),
                      title: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isLeader ? cs.onPrimaryContainer : null,
                        ),
                      ),
                      subtitle: Text(
                        _subtitleForRank(rank),
                        style: text.labelMedium?.copyWith(
                          color: isLeader
                              ? cs.onPrimaryContainer.withValues(alpha: 0.85)
                              : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isLeader
                              ? cs.onPrimaryContainer.withValues(alpha: 0.12)
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Text(
                          ps.total.toString(),
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isLeader ? cs.onPrimaryContainer : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Computes ranks for sorted players, handling ties.
  /// Players with the same score get the same rank.
  /// Example: [100, 90, 90, 80] -> ranks [1, 2, 2, 4]
  static List<int> _computeRanks(List<PlayerScore> sorted) {
    if (sorted.isEmpty) return [];

    final ranks = <int>[];
    int currentRank = 1;

    for (int i = 0; i < sorted.length; i++) {
      if (i == 0) {
        ranks.add(currentRank);
      } else if (sorted[i].total == sorted[i - 1].total) {
        // Same score as previous player, same rank
        ranks.add(ranks[i - 1]);
      } else {
        // Different score, rank is position + 1
        currentRank = i + 1;
        ranks.add(currentRank);
      }
    }

    return ranks;
  }

  static String _fullName(PlayerScore ps) {
    final fn = ps.player.firstName.trim();
    final ln = (ps.player.lastName ?? '').trim();
    return ln.isEmpty ? fn : '$fn $ln';
  }

  static String _subtitleForRank(int rank) {
    if (rank == 1) return 'Leader';
    if (rank == 2) return '2nd';
    if (rank == 3) return '3rd';
    return 'Rank $rank';
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final icon = switch (rank) {
      1 => Icons.emoji_events,
      2 => Icons.workspace_premium,
      3 => Icons.military_tech,
      _ => Icons.tag,
    };

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          Positioned(
            bottom: 4,
            right: 6,
            child: Text(
              '$rank',
              style: text.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
