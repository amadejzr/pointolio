import 'package:flutter/material.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/scoring/presentation/cubit/scoring_cubit.dart';

class TotalsBar extends StatelessWidget {
  const TotalsBar({required this.state, required this.onShowTotals, super.key});

  final ScoringState state;
  final VoidCallback onShowTotals;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final leader = _leaderInfo(state);

    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        MediaQuery.paddingOf(context).bottom + Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          // Chips row (same style as the landscape appbar chips)
          Expanded(
            child: Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                Tooltip(
                  message: 'Players',
                  waitDuration: const Duration(milliseconds: 350),
                  child: _MiniChip(
                    icon: Icons.people_outline,
                    label: '${state.playerScores.length}',
                  ),
                ),
                Tooltip(
                  message: 'Rounds',
                  waitDuration: const Duration(milliseconds: 350),
                  child: _MiniChip(
                    icon: Icons.grid_view_rounded,
                    label: '${state.roundCount}',
                  ),
                ),
                Tooltip(
                  message: state.lowestScoreWins
                      ? 'Leader (lowest total)'
                      : 'Leader (highest total)',
                  waitDuration: const Duration(milliseconds: 350),
                  child: _MiniChip(
                    icon: Icons.emoji_events_outlined,
                    label: leader.label, // "Tie" or "Maj A."
                    onTap: onShowTotals, // quick open totals
                  ),
                ),
              ],
            ),
          ),

          Spacing.hGap12,

          // Totals CTA (keep as a pill button like before)
          _TotalsPillButton(onPressed: onShowTotals),
        ],
      ),
    );
  }

  _LeaderInfo _leaderInfo(ScoringState state) {
    if (state.playerScores.isEmpty) {
      return const _LeaderInfo(label: '—');
    }

    var best = state.playerScores.first;
    for (final ps in state.playerScores.skip(1)) {
      final isBetter = state.lowestScoreWins
          ? ps.total < best.total
          : ps.total > best.total;
      if (isBetter) best = ps;
    }

    final bestTotal = best.total;
    final tied = state.playerScores
        .where((ps) => ps.total == bestTotal)
        .toList();
    if (tied.length > 1) return const _LeaderInfo(label: 'Tie');

    // Compact name label, similar to appbar chip style.
    final full = _fullName(best);
    final parts = full.split(' ').where((e) => e.trim().isNotEmpty).toList();
    if (parts.length == 1) return _LeaderInfo(label: parts.first);
    return _LeaderInfo(label: '${parts.first} ${parts[1][0].toUpperCase()}.');
  }

  static String _fullName(PlayerScore ps) {
    final fn = ps.player.firstName.trim();
    final ln = (ps.player.lastName ?? '').trim();
    return ln.isEmpty ? fn : '$fn $ln';
  }
}

class _LeaderInfo {
  const _LeaderInfo({required this.label});
  final String label;
}

/// Small pill chip — matches the chips used in the landscape AppBar.
class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// Totals action — kept as a primary pill button (same vibe as before).
class _TotalsPillButton extends StatelessWidget {
  const _TotalsPillButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.primary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.summarize_outlined, size: 18, color: cs.onPrimary),
              const SizedBox(width: 8),
              Text(
                'Totals',
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TotalsSheet extends StatelessWidget {
  const TotalsSheet({required this.state, super.key});

  final ScoringState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final sorted = [...state.playerScores]
      ..sort(
        (a, b) => state.lowestScoreWins
            ? a.total.compareTo(b.total)
            : b.total.compareTo(a.total),
      );

    final top = sorted.isEmpty ? null : sorted.first.total;
    final ranks = _computeRanks(sorted);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
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
                  style: text.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List
          Expanded(
            child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final ps = sorted[index];
                final name = _fullName(ps);
                final isLeader = top != null && ps.total == top;
                final rank = ranks[index];

                return DecoratedBox(
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
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  /// Computes ranks for sorted players, handling ties.
  /// Players with the same score get the same rank.
  /// Example: [100, 90, 90, 80] -> ranks [1, 2, 2, 4]
  static List<int> _computeRanks(List<PlayerScore> sorted) {
    if (sorted.isEmpty) return [];

    final ranks = <int>[];
    var currentRank = 1;

    for (var i = 0; i < sorted.length; i++) {
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
