import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/scoring/presentation/cubit/scoring_cubit.dart';
import 'package:pointolio/features/scoring/presentation/widgets/score_table.dart';

import '../../../utils/fixtures.dart';

void main() {
  ScoreEntry entry(int id, int gamePlayerId, int round, int points) =>
      ScoreEntry(
        id: id,
        gamePlayerId: gamePlayerId,
        roundNumber: round,
        points: points,
        createdAt: DateTime(2026),
      );

  // Three players, two rounds. Totals: Amy 15, Bob 21, Cara 12.
  ScoringState buildState({bool lowestWins = false}) {
    PlayerScore ps(int id, String name, Map<int, ScoreEntry> rounds) {
      final total = rounds.values.fold(0, (sum, e) => sum + e.points);
      return PlayerScore(
        player: playerRow(id: id, firstName: name),
        gamePlayer: gamePlayerRow(id: id, playerId: id, orderIndex: id),
        roundScores: rounds,
        total: total,
      );
    }

    return ScoringState(
      gameId: 1,
      game: gameRow(id: 1, name: 'Friday Rummy', gameTypeId: 9),
      gameType: gameTypeRow(id: 9, name: 'Rummy', lowestScoreWins: lowestWins),
      status: ScoringStatus.loaded,
      roundCount: 2,
      playerScores: [
        ps(1, 'Amy', {1: entry(1, 1, 1, 10), 2: entry(2, 1, 2, 5)}),
        ps(2, 'Bob', {1: entry(3, 2, 1, 8), 2: entry(4, 2, 2, 13)}),
        ps(3, 'Cara', {1: entry(5, 3, 1, 4), 2: entry(6, 3, 2, 8)}),
      ],
    );
  }

  Widget wrap(Widget child, {required Size size}) {
    return MaterialApp(
      theme: ThemeData(extensions: const [PointolioTheme.light]),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('portrait ledger renders totals without layout errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(ScoreTable(state: buildState()), size: const Size(400, 800)),
    );

    expect(tester.takeException(), isNull);
    // Pinned totals are always visible.
    expect(find.text('15'), findsOneWidget);
    expect(find.text('21'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    // Round labels present.
    expect(find.text('R1'), findsOneWidget);
    expect(find.text('R2'), findsOneWidget);
  });

  testWidgets('landscape grid renders totals without layout errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(ScoreTable(state: buildState()), size: const Size(800, 400)),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('21'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  // The reported "too much empty space" case: a small game must still render
  // as a centered, overflow-free card in both orientations.
  ScoringState twoPlayers() {
    PlayerScore ps(int id, String name, int points) => PlayerScore(
      player: playerRow(id: id, firstName: name),
      gamePlayer: gamePlayerRow(id: id, playerId: id, orderIndex: id),
      roundScores: {1: entry(id, id, 1, points)},
      total: points,
    );

    return ScoringState(
      gameId: 1,
      game: gameRow(id: 1, name: 'Quick Duel', gameTypeId: 9),
      gameType: gameTypeRow(id: 9, name: 'Rummy'),
      status: ScoringStatus.loaded,
      roundCount: 1,
      playerScores: [ps(1, 'Amy', 7), ps(2, 'Bob', 4)],
    );
  }

  testWidgets('two players / one round render without overflow', (tester) async {
    for (final size in const [Size(400, 800), Size(800, 400)]) {
      await tester.pumpWidget(
        wrap(ScoreTable(state: twoPlayers()), size: size),
      );
      expect(tester.takeException(), isNull, reason: 'size=$size');
      expect(find.text('7'), findsWidgets);
      expect(find.text('4'), findsWidgets);
    }
  });

  testWidgets('tapping a round label triggers delete (no long-press)', (
    tester,
  ) async {
    int? deleted;
    await tester.pumpWidget(
      wrap(
        ScoreTable(
          state: twoPlayers(),
          onDeleteRound: (round) => deleted = round,
        ),
        size: const Size(400, 800),
      ),
    );

    await tester.tap(find.text('R1'));
    await tester.pump();
    expect(deleted, 1);
  });

  testWidgets('read-only mode (finished party) still renders', (tester) async {
    await tester.pumpWidget(
      wrap(
        // No callbacks -> read-only, no reorder handles.
        ScoreTable(state: buildState(lowestWins: true)),
        size: const Size(400, 800),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('15'), findsOneWidget);
  });
}
