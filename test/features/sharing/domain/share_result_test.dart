import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/sharing/domain/share_result.dart';

import '../../../utils/fixtures.dart';

/// Builds a [PlayerScore] with a given total, reusing the shared row fixtures.
PlayerScore score(
  int playerId,
  int total, {
  String firstName = 'Player',
  String? lastName,
  int? color,
}) {
  return PlayerScore(
    player: playerRow(
      id: playerId,
      firstName: firstName,
      lastName: lastName,
      color: color,
    ),
    gamePlayer: gamePlayerRow(id: playerId, playerId: playerId),
    roundScores: const {},
    total: total,
  );
}

ScoringData data(
  List<PlayerScore> scores, {
  String gameName = 'Friday Night',
  String gameTypeName = 'Rummy',
  int roundCount = 3,
}) {
  return ScoringData(
    game: gameRow(id: 1, name: gameName),
    gameType: gameTypeRow(id: 1, name: gameTypeName),
    playerScores: scores,
    roundCount: roundCount,
  );
}

void main() {
  group('ShareResult.fromScoringData', () {
    test('ranks highest-first when highest wins', () {
      final result = ShareResult.fromScoringData(
        data([
          score(1, 10, firstName: 'Amy'),
          score(2, 30, firstName: 'Bob'),
          score(3, 20, firstName: 'Cid'),
        ]),
        lowestScoreWins: false,
      );

      expect(result.standings.map((s) => s.firstName), ['Bob', 'Cid', 'Amy']);
      expect(result.standings.map((s) => s.rank), [1, 2, 3]);
      expect(result.winner.firstName, 'Bob');
      expect(result.winner.total, 30);
    });

    test('ranks lowest-first when lowest wins', () {
      final result = ShareResult.fromScoringData(
        data([
          score(1, 10, firstName: 'Amy'),
          score(2, 30, firstName: 'Bob'),
          score(3, 20, firstName: 'Cid'),
        ]),
        lowestScoreWins: true,
      );

      expect(result.standings.map((s) => s.firstName), ['Amy', 'Cid', 'Bob']);
      expect(result.winner.firstName, 'Amy');
      expect(result.winRuleText, 'lowest score wins');
    });

    test('shares a rank on ties and skips to the ordinal position', () {
      final result = ShareResult.fromScoringData(
        data([
          score(1, 30, firstName: 'Amy'),
          score(2, 30, firstName: 'Bob'),
          score(3, 10, firstName: 'Cid'),
        ]),
        lowestScoreWins: false,
      );

      // 30, 30, 10 -> ranks 1, 1, 3.
      expect(result.standings.map((s) => s.rank), [1, 1, 3]);
      expect(result.isTie, isTrue);
      expect(result.topRanked.map((s) => s.firstName), ['Amy', 'Bob']);
      expect(result.runnersUp.map((s) => s.firstName), ['Cid']);
    });

    test('is not a tie when the top score is unique', () {
      final result = ShareResult.fromScoringData(
        data([score(1, 30), score(2, 20)]),
        lowestScoreWins: false,
      );

      expect(result.isTie, isFalse);
      expect(result.runnersUp, hasLength(1));
    });

    test('derives display name, initial and colour hints', () {
      final result = ShareResult.fromScoringData(
        data([
          score(1, 10, firstName: 'Amy', lastName: 'Stone', color: 0xFF112233),
          score(2, 5, firstName: 'bob'),
        ]),
        lowestScoreWins: false,
      );

      final amy = result.standings.first;
      expect(amy.fullName, 'Amy Stone');
      expect(amy.firstName, 'Amy');
      expect(amy.initial, 'A');
      expect(amy.storedColor, 0xFF112233);
      expect(amy.colorIndex, 0);

      final bob = result.standings[1];
      expect(bob.fullName, 'bob');
      expect(bob.initial, 'B'); // upper-cased
      expect(bob.storedColor, isNull);
      expect(bob.colorIndex, 1);
    });

    test('copies party/game/round metadata', () {
      final result = ShareResult.fromScoringData(
        data([score(1, 10)], roundCount: 7),
        lowestScoreWins: false,
      );

      expect(result.partyName, 'Friday Night');
      expect(result.gameName, 'Rummy');
      expect(result.roundCount, 7);
      expect(result.date, DateTime(2025));
    });

    test('falls back to sensible defaults for blank names', () {
      final result = ShareResult.fromScoringData(
        const ScoringData(),
        lowestScoreWins: false,
      );

      expect(result.isEmpty, isTrue);
      expect(result.partyName, 'Party');
      expect(result.gameName, '');
    });

    test('handles an unnamed player gracefully', () {
      final result = ShareResult.fromScoringData(
        data([score(1, 10, firstName: ' ')]),
        lowestScoreWins: false,
      );

      final s = result.standings.single;
      expect(s.firstName, 'Player');
      expect(s.fullName, 'Player');
      expect(s.initial, '?');
    });
  });

  group('toShareText', () {
    test('renders a ranked plain-text summary', () {
      final result = ShareResult.fromScoringData(
        data([
          score(1, 30, firstName: 'Bob'),
          score(2, 20, firstName: 'Amy', lastName: 'Stone'),
        ]),
        lowestScoreWins: false,
      );

      expect(
        result.toShareText(),
        'Friday Night\n'
        'Rummy\n'
        '1. Bob - 30\n'
        '2. Amy Stone - 20\n'
        'via Pointolio',
      );
    });

    test('returns just the party name when empty', () {
      final result = ShareResult.fromScoringData(
        const ScoringData(),
        lowestScoreWins: false,
      );

      expect(result.toShareText(), 'Party');
    });
  });

  group('ShareStyle labels', () {
    test('every style has a label', () {
      expect(ShareStyle.spotlight.label, 'Spotlight');
      expect(ShareStyle.podium.label, 'Podium');
      expect(ShareStyle.ticket.label, 'Scorecard');
      expect(ShareStyle.minimal.label, 'Minimal');
    });
  });
}
