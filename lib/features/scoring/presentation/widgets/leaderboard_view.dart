import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/scoring/presentation/cubit/scoring_cubit.dart';
import 'package:pointolio/features/scoring/presentation/widgets/score_table.dart';

/// Ranked standings for the scoring screen. Compact cards - rank, avatar,
/// name, rounds-won, and the total - sorted by the win rule with ties sharing
/// a rank. Reads everything from `context.pt`.
class LeaderboardView extends StatelessWidget {
  const LeaderboardView({required this.state, super.key});

  final ScoringState state;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    final sorted = [...state.playerScores]
      ..sort(
        (a, b) => state.lowestScoreWins
            ? a.total.compareTo(b.total)
            : b.total.compareTo(a.total),
      );

    if (sorted.isEmpty) {
      return Center(
        child: Text('No players in this party.', style: PT.body(pt.textMuted)),
      );
    }

    final ranks = _computeRanks(sorted);
    final roundsWon = _roundsWonByGamePlayer(state);
    final topTotal = sorted.first.total;

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        S.lg,
        S.xs,
        S.lg,
        MediaQuery.paddingOf(context).bottom + S.sm,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        final ps = sorted[i];
        return AnimatedEntrance(
          delay: Duration(milliseconds: 40 * i),
          child: Padding(
            padding: const EdgeInsets.only(bottom: S.sm),
            child: _LeaderCard(
              playerScore: ps,
              rank: ranks[i],
              colorIndex: i,
              roundsWon: roundsWon[ps.gamePlayer.id] ?? 0,
              isLeader: ps.total == topTotal,
            ),
          ),
        );
      },
    );
  }

  /// Ranks for sorted players; ties share a rank. [100, 90, 90, 80] -> 1,2,2,4.
  static List<int> _computeRanks(List<PlayerScore> sorted) {
    final ranks = <int>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i].total == sorted[i - 1].total) {
        ranks.add(ranks[i - 1]);
      } else {
        ranks.add(i + 1);
      }
    }
    return ranks;
  }

  /// How many rounds each player won (best that round, per the win rule).
  static Map<int, int> _roundsWonByGamePlayer(ScoringState state) {
    final best = <int, int>{};
    for (final ps in state.playerScores) {
      ps.roundScores.forEach((round, entry) {
        final current = best[round];
        best[round] = current == null
            ? entry.points
            : state.lowestScoreWins
            ? math.min(current, entry.points)
            : math.max(current, entry.points);
      });
    }
    final won = <int, int>{};
    for (final ps in state.playerScores) {
      var count = 0;
      ps.roundScores.forEach((round, entry) {
        if (entry.points == best[round]) count++;
      });
      won[ps.gamePlayer.id] = count;
    }
    return won;
  }
}

class _LeaderCard extends StatelessWidget {
  const _LeaderCard({
    required this.playerScore,
    required this.rank,
    required this.colorIndex,
    required this.roundsWon,
    required this.isLeader,
  });

  final PlayerScore playerScore;
  final int rank;
  final int colorIndex;
  final int roundsWon;
  final bool isLeader;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final stored = playerScore.player.color;
    final color = stored != null ? Color(stored) : pt.playerColor(colorIndex);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
      decoration: BoxDecoration(
        color: isLeader ? pt.accentTint : pt.surface,
        borderRadius: BorderRadius.circular(R.md),
        border: Border.all(color: isLeader ? pt.accentBorder : pt.border),
        boxShadow: isLeader ? pt.shadowCard : null,
      ),
      child: Row(
        children: [
          _RankGlyph(rank: rank),
          const SizedBox(width: S.md),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              ScoreTable.initials(playerScore.player),
              style: PT.number(pt.onPlayer, size: 14),
            ),
          ),
          const SizedBox(width: S.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ScoreTable.fullName(playerScore.player),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PT.bodyStrong(pt.text).copyWith(fontSize: 14.5),
                ),
                const SizedBox(height: 1),
                Text(
                  roundsWon == 0
                      ? (isLeader ? 'Leader' : '-')
                      : '$roundsWon ${roundsWon == 1 ? 'round' : 'rounds'} won',
                  style: PT.caption(
                    isLeader ? pt.accentDeep : pt.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: S.sm),
          Text(
            playerScore.total.toString(),
            style: PT.number(
              isLeader ? pt.accentDeep : pt.text,
              size: 22,
              weight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankGlyph extends StatelessWidget {
  const _RankGlyph({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    // Medal tints for the podium, plain chip otherwise.
    final (bg, fg) = switch (rank) {
      1 => (pt.accent, pt.accentText),
      2 => (pt.surfaceMuted, pt.text2),
      3 => (pt.surfaceMuted, pt.text2),
      _ => (pt.surfaceMuted, pt.textMuted),
    };

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(R.sm),
      ),
      alignment: Alignment.center,
      child: Text('$rank', style: PT.number(fg, size: 14)),
    );
  }
}
