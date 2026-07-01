import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/scoring/presentation/cubit/scoring_cubit.dart';
import 'package:pointolio/features/scoring/presentation/widgets/leaderboard_view.dart';

import '../../../utils/fixtures.dart';

void main() {
  ScoreEntry e(int id, int gp, int round, int points) => ScoreEntry(
    id: id,
    gamePlayerId: gp,
    roundNumber: round,
    points: points,
    createdAt: DateTime(2026),
  );

  // Highest-wins. R1: Amy 10 (win), Bob 8, Cara 4. R2: Amy 5, Bob 13 (win),
  // Cara 8. So Amy 1 win, Bob 1 win, Cara 0 wins.
  ScoringState state() {
    PlayerScore ps(int id, String name, Map<int, ScoreEntry> rounds) {
      final total = rounds.values.fold(0, (sum, x) => sum + x.points);
      return PlayerScore(
        player: playerRow(id: id, firstName: name),
        gamePlayer: gamePlayerRow(id: id, playerId: id, orderIndex: id),
        roundScores: rounds,
        total: total,
      );
    }

    return ScoringState(
      gameId: 1,
      gameType: gameTypeRow(id: 9, name: 'Rummy'),
      status: ScoringStatus.loaded,
      roundCount: 2,
      playerScores: [
        ps(1, 'Amy', {1: e(1, 1, 1, 10), 2: e(2, 1, 2, 5)}),
        ps(2, 'Bob', {1: e(3, 2, 1, 8), 2: e(4, 2, 2, 13)}),
        ps(3, 'Cara', {1: e(5, 3, 1, 4), 2: e(6, 3, 2, 8)}),
      ],
    );
  }

  testWidgets('standings show rounds-won for every player', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [PointolioTheme.light]),
        home: Scaffold(body: LeaderboardView(state: state())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 round won'), findsNWidgets(2)); // Amy + Bob
    expect(find.text('0 rounds won'), findsOneWidget); // Cara
    expect(find.text('pts'), findsNWidgets(3)); // total labelled for everyone
  });

  testWidgets('big totals do not overflow in a narrow card', (tester) async {
    final big = ScoringState(
      gameId: 1,
      status: ScoringStatus.loaded,
      roundCount: 1,
      playerScores: [
        PlayerScore(
          player: playerRow(id: 1, firstName: 'Maximilian', lastName: 'Long'),
          gamePlayer: gamePlayerRow(id: 1),
          roundScores: {1: e(1, 1, 1, 999999)},
          total: 999999,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [PointolioTheme.light]),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 400,
              child: LeaderboardView(state: big),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('999999'), findsOneWidget);
  });
}
