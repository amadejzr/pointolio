import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/features/scoring/domain/models.dart';

class ShareScoreCardTransparentAlt extends StatelessWidget {
  const ShareScoreCardTransparentAlt({
    required this.scoringData,
    required this.lowestScoreWins,
    super.key,
    this.width = 400,
    this.showBranding = true,
    this.primaryColor,
    this.textColor = Colors.white,
  });

  final ScoringData scoringData;
  final bool lowestScoreWins;
  final double width;
  final bool showBranding;
  final Color? primaryColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final sortedScores = _sortedPlayerScores();
    final ranks = _computeRanks(sortedScores);
    final accent = _resolveAccentColor(cs);

    final winnerCount = ranks.where((r) => r == 1).length;
    final isTie = winnerCount > 1;
    final winner = sortedScores.isEmpty ? null : sortedScores.first;

    final gameName = _clean(scoringData.game?.name, fallback: 'Game', max: 48);
    final gameTypeName = _clean(
      scoringData.gameType?.name,
      fallback: '',
      max: 18,
    );

    final date = scoringData.game?.gameDate;
    final locale = Localizations.localeOf(context).toLanguageTag();

    // You can pick yMMMd or yMd depending on your taste.
    // yMMMd -> "Jan 21, 2026" / "21. jan. 2026"
    // yMd   -> "1/21/2026" / "21. 1. 2026"
    final dateText = date != null ? DateFormat.yMMMd(locale).format(date) : '—';

    final roundCount = scoringData.roundCount;
    final roundsText = Intl.plural(
      roundCount,
      zero: '0 rounds',
      one: '1 round',
      other: '$roundCount rounds',
    );

    final meta = '$dateText • $roundsText';

    final winnersLabel = isTie ? 'TIE' : 'WINNER';
    final winnersNames = isTie
        ? _clean(
            _getTiedPlayersNames(sortedScores, ranks),
            fallback: '',
            max: 64,
          )
        : _clean(
            winner != null ? _playerDisplayName(winner.player) : '',
            fallback: '',
            max: 40,
          );
    final winnersScore = winner?.total ?? 0;

    return Container(
      width: width,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gameName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            isTie ? Icons.handshake : Icons.emoji_events,
                            size: 20,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (gameTypeName.isNotEmpty)
                        Flexible(
                          child: Text(
                            gameTypeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.80),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      if (gameTypeName.isNotEmpty && meta.isNotEmpty) ...[
                        Text(
                          '  •  ',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.35),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (meta.isNotEmpty)
                        Flexible(
                          child: Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.55),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 54,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            winnersLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.70),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            winnersNames.isEmpty ? '-' : winnersNames,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Text(
                        '$winnersScore',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.95),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Column(
                children: [
                  for (var i = 0; i < sortedScores.length; i++)
                    if (ranks[i] != 1)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                        child: _RowAltNoScale(
                          textColor: textColor,
                          accent: accent,
                          rank: ranks[i],
                          name: _clean(
                            _playerDisplayName(sortedScores[i].player),
                            fallback: '',
                            max: 32,
                          ),
                          score: sortedScores[i].total,
                        ),
                      ),
                ],
              ),
            ),
            if (showBranding)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo/logo_transparent.png',
                      height: 24,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pointolio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.35),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _resolveAccentColor(ColorScheme cs) {
    if (primaryColor != null) return primaryColor!;
    final raw = scoringData.gameType?.color;
    if (raw != null) {
      final normalized = (raw & 0xFF000000) == 0 ? (0xFF000000 | raw) : raw;
      return Color(normalized);
    }
    return cs.primary;
  }

  List<PlayerScore> _sortedPlayerScores() {
    final scores = List<PlayerScore>.from(scoringData.playerScores)
      ..sort((a, b) {
        if (lowestScoreWins) return a.total.compareTo(b.total);
        return b.total.compareTo(a.total);
      });
    return scores;
  }

  List<int> _computeRanks(List<PlayerScore> sorted) {
    final ranks = <int>[];
    var currentRank = 1;

    for (var i = 0; i < sorted.length; i++) {
      if (i == 0) {
        ranks.add(currentRank);
      } else if (sorted[i].total == sorted[i - 1].total) {
        ranks.add(ranks[i - 1]);
      } else {
        currentRank = i + 1;
        ranks.add(currentRank);
      }
    }

    return ranks;
  }

  String _playerDisplayName(Player player) {
    final firstName = _clean(player.firstName, fallback: '', max: 20);
    final lastName = _clean(player.lastName, fallback: '', max: 20);
    if (lastName.isEmpty) return firstName;
    return '$firstName $lastName';
  }

  String _getTiedPlayersNames(List<PlayerScore> sortedScores, List<int> ranks) {
    final tiedPlayers = <String>[];
    for (var i = 0; i < sortedScores.length; i++) {
      if (ranks[i] == 1) {
        tiedPlayers.add(_playerDisplayName(sortedScores[i].player));
      }
    }
    if (tiedPlayers.length == 2) return '${tiedPlayers[0]} & ${tiedPlayers[1]}';
    return tiedPlayers.join(', ');
  }

  String _clean(String? value, {required String fallback, required int max}) {
    final v = (value ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
    if (v.isEmpty) return fallback;
    if (v.length <= max) return v;
    return v.substring(0, max).trim();
  }
}

class _RowAltNoScale extends StatelessWidget {
  const _RowAltNoScale({
    required this.textColor,
    required this.accent,
    required this.rank,
    required this.name,
    required this.score,
  });

  final Color textColor;
  final Color accent;
  final int rank;
  final String name;
  final int score;

  @override
  Widget build(BuildContext context) {
    final rankColor = _rankColor(rank);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rankColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name.isEmpty ? '-' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.92),
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$score',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.92),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFA8A8A8),
      3 => const Color(0xFFCD7F32),
      _ => accent.withValues(alpha: 0.85),
    };
  }
}
