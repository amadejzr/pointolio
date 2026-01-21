import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/features/scoring/domain/models.dart';

class ShareScoreCardTransparent extends StatelessWidget {
  const ShareScoreCardTransparent({
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

    return Container(
      width: width,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, accent),
            _buildWinnerSection(context, sortedScores, ranks, accent),
            _buildScoresList(context, sortedScores, ranks),
            if (showBranding) _buildFooter(context),
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

  Widget _buildHeader(BuildContext context, Color accent) {
    final gameName = _clean(scoringData.game?.name, fallback: 'Game', max: 48);

    final date = scoringData.game?.gameDate;
    final formattedDate = date != null
        ? DateFormat.yMMMd(
            Localizations.localeOf(context).toString(),
          ).format(date)
        : null;

    final gameTypeName = _clean(
      scoringData.gameType?.name,
      fallback: '',
      max: 18,
    );

    final roundCount = scoringData.roundCount;

    final dateText = formattedDate ?? '';
    final roundsText = roundCount > 0
        ? Intl.plural(
            roundCount,
            one: '$roundCount round',
            other: '$roundCount rounds',
          )
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top line: pill (left) + date (right)
          Row(
            children: [
              if (gameTypeName.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_esports, size: 15, color: accent),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          gameTypeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.95),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              if (dateText.isNotEmpty)
                Text(
                  dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.60),
                    fontSize: 12.5,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            gameName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1.05,
            ),
          ),

          // Second line: rounds (and you can add more later)
          if (roundsText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              roundsText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.60),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWinnerSection(
    BuildContext context,
    List<PlayerScore> sortedScores,
    List<int> ranks,
    Color accent,
  ) {
    if (sortedScores.isEmpty) return const SizedBox.shrink();

    final winner = sortedScores.first;
    final isTie = ranks.where((r) => r == 1).length > 1;

    final winnerName = isTie
        ? _clean(
            _getTiedPlayersNames(sortedScores, ranks),
            fallback: '',
            max: 64,
          )
        : _clean(_playerDisplayName(winner.player), fallback: '', max: 40);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.45)),
            ),
            child: Icon(
              isTie ? Icons.handshake : Icons.emoji_events,
              size: 32,
              color: accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isTie ? 'TIE!' : 'WINNER',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.70),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            winnerName,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${winner.total} points',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.70),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresList(
    BuildContext context,
    List<PlayerScore> sortedScores,
    List<int> ranks,
  ) {
    final rows = <Widget>[];
    var rowIndex = 0;

    for (var i = 0; i < sortedScores.length; i++) {
      if (ranks[i] == 1) continue;

      rows.add(
        Padding(
          padding: EdgeInsets.only(top: rowIndex == 0 ? 0 : 7),
          child: _buildScoreRow(context, sortedScores[i], ranks[i]),
        ),
      );
      rowIndex++;
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Column(children: rows),
    );
  }

  Widget _buildScoreRow(
    BuildContext context,
    PlayerScore playerScore,
    int rank,
  ) {
    final name = _clean(
      _playerDisplayName(playerScore.player),
      fallback: '',
      max: 32,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _buildRankBadge(rank),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.92),
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${playerScore.total}',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.92),
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    final (icon, color) = switch (rank) {
      1 => (Icons.emoji_events, const Color(0xFFFFD700)),
      2 => (Icons.workspace_premium, const Color(0xFFA8A8A8)),
      3 => (Icons.military_tech, const Color(0xFFCD7F32)),
      _ => (Icons.tag, Colors.white.withValues(alpha: 0.45)),
    };

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: rank <= 3
            ? Icon(icon, size: 16, color: color)
            : Text(
                '$rank',
                style: TextStyle(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
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
            'Scoreio',
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
    );
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
