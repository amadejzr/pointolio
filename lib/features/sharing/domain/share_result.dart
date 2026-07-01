import 'package:equatable/equatable.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/features/scoring/domain/models.dart';

/// One player's final standing, ready for a share card.
///
/// Display-ready and framework-free: it carries the resolved name/initial and
/// the colour *hints* (a stored ARGB [storedColor] if the player picked one,
/// otherwise a [colorIndex] the widget layer maps through the theme palette).
/// Keeping it pure means the whole model is trivially unit-testable.
class Standing extends Equatable {
  const Standing({
    required this.firstName,
    required this.fullName,
    required this.initial,
    required this.total,
    required this.rank,
    required this.colorIndex,
    this.storedColor,
  });

  final String firstName;
  final String fullName;
  final String initial;
  final int total;

  /// 1-based rank; tied players share a rank.
  final int rank;

  /// Fallback palette index (position in the sorted list) when [storedColor]
  /// is null.
  final int colorIndex;

  /// The player's chosen colour as an ARGB int, or null to use [colorIndex].
  final int? storedColor;

  @override
  List<Object?> get props => [
    firstName,
    fullName,
    initial,
    total,
    rank,
    colorIndex,
    storedColor,
  ];
}

/// Everything a share card needs, derived once from a finished [ScoringData]
/// so the card widgets stay dumb and purely visual.
class ShareResult extends Equatable {
  const ShareResult({
    required this.partyName,
    required this.gameName,
    required this.lowestScoreWins,
    required this.roundCount,
    required this.standings,
    this.date,
  });

  /// Builds a [ShareResult] from the live scoring state.
  ///
  /// Ranking honours ties: players on the same total share a rank and the next
  /// distinct total jumps to its ordinal position (1, 1, 3, ...).
  factory ShareResult.fromScoringData(
    ScoringData data, {
    required bool lowestScoreWins,
  }) {
    final sorted = List<PlayerScore>.from(data.playerScores)
      ..sort(
        (a, b) => lowestScoreWins
            ? a.total.compareTo(b.total)
            : b.total.compareTo(a.total),
      );

    final standings = <Standing>[];
    var currentRank = 1;
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i].total != sorted[i - 1].total) {
        currentRank = i + 1;
      }
      final player = sorted[i].player;
      standings.add(
        Standing(
          firstName: _displayFirst(player),
          fullName: _displayFull(player),
          initial: _initial(player),
          total: sorted[i].total,
          rank: currentRank,
          colorIndex: i,
          storedColor: player.color,
        ),
      );
    }

    return ShareResult(
      partyName: _clean(data.game?.name, fallback: 'Party'),
      gameName: _clean(data.gameType?.name, fallback: ''),
      lowestScoreWins: lowestScoreWins,
      roundCount: data.roundCount,
      date: data.game?.gameDate,
      standings: standings,
    );
  }

  /// The play-session name (a "party" in Pointolio terms).
  final String partyName;

  /// The game type this party played (e.g. "Rummy"). May be empty.
  final String gameName;

  final bool lowestScoreWins;
  final int roundCount;

  /// Ranked standings, best first.
  final List<Standing> standings;
  final DateTime? date;

  bool get isEmpty => standings.isEmpty;

  /// The best standing. Callers must guard with [isEmpty] first.
  Standing get winner => standings.first;

  /// Everyone except the top rank (skips co-winners on a tie).
  List<Standing> get runnersUp =>
      standings.where((s) => s.rank != 1).toList(growable: false);

  /// The co-winners when the top score is shared, else just the winner.
  List<Standing> get topRanked =>
      standings.where((s) => s.rank == 1).toList(growable: false);

  bool get isTie => topRanked.length > 1;

  String get winRuleText =>
      lowestScoreWins ? 'lowest score wins' : 'highest score wins';

  /// A plain-text summary of the result, for the "Copy result text" action.
  String toShareText() {
    if (isEmpty) return partyName;
    final buffer = StringBuffer()..writeln(partyName);
    if (gameName.isNotEmpty) buffer.writeln(gameName);
    for (final s in standings) {
      buffer.writeln('${s.rank}. ${s.fullName} - ${s.total}');
    }
    buffer.write('via Pointolio');
    return buffer.toString();
  }

  @override
  List<Object?> get props => [
    partyName,
    gameName,
    lowestScoreWins,
    roundCount,
    standings,
    date,
  ];
}

String _displayFirst(Player player) =>
    _clean(player.firstName, fallback: 'Player');

String _displayFull(Player player) {
  final first = _clean(player.firstName, fallback: 'Player');
  final last = _clean(player.lastName, fallback: '');
  return last.isEmpty ? first : '$first $last';
}

String _initial(Player player) {
  final first = _clean(player.firstName, fallback: '');
  return first.isEmpty ? '?' : first[0].toUpperCase();
}

/// Trims, collapses inner whitespace and falls back when blank.
String _clean(String? value, {required String fallback}) {
  final v = (value ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
  return v.isEmpty ? fallback : v;
}

/// The available card designs.
enum ShareStyle { spotlight, podium, ticket, minimal }

extension ShareStyleMeta on ShareStyle {
  String get label => switch (this) {
    ShareStyle.spotlight => 'Spotlight',
    ShareStyle.podium => 'Podium',
    ShareStyle.ticket => 'Scorecard',
    ShareStyle.minimal => 'Minimal',
  };
}
