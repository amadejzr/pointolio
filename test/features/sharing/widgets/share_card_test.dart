import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/sharing/domain/share_result.dart';
import 'package:pointolio/features/sharing/presentation/widgets/share_card.dart';

import '../../../utils/fixtures.dart';

void main() {
  PlayerScore score(int id, int total, String name) => PlayerScore(
    player: playerRow(id: id, firstName: name),
    gamePlayer: gamePlayerRow(id: id, playerId: id),
    roundScores: const {},
    total: total,
  );

  ShareResult sample({List<PlayerScore>? scores}) {
    return ShareResult.fromScoringData(
      ScoringData(
        game: gameRow(id: 1, name: 'Friday Night'),
        gameType: gameTypeRow(id: 1, name: 'Rummy'),
        playerScores:
            scores ??
            [
              score(1, 30, 'Amy'),
              score(2, 20, 'Bob'),
              score(3, 10, 'Cid'),
            ],
        roundCount: 3,
      ),
      lowestScoreWins: false,
    );
  }

  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData(extensions: const [PointolioTheme.light]),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: kShareCardWidth, child: child),
      ),
    ),
  );

  Widget card(ShareStyle style, ShareResult result) => ShareCard(
    result: result,
    style: style,
    opacity: 0.72,
    accent: const Color(0xFF4F86FF),
    colorFor: (_) => const Color(0xFF4F86FF),
  );

  for (final style in ShareStyle.values) {
    testWidgets('renders ${style.label} without overflow', (tester) async {
      await tester.pumpWidget(wrap(card(style, sample())));
      await tester.pump();

      expect(tester.takeException(), isNull);
      // The Pointolio watermark is on every card.
      expect(find.text('Pointolio'), findsOneWidget);
    });
  }

  testWidgets('spotlight shows the winner name and total', (tester) async {
    await tester.pumpWidget(wrap(card(ShareStyle.spotlight, sample())));

    expect(find.text('Amy'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('WINNER'), findsOneWidget);
  });

  testWidgets('scorecard lists every player', (tester) async {
    await tester.pumpWidget(wrap(card(ShareStyle.ticket, sample())));

    expect(find.text('Amy'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Cid'), findsOneWidget);
  });

  testWidgets('announces a tie on the winner card', (tester) async {
    final tied = sample(
      scores: [score(1, 30, 'Amy'), score(2, 30, 'Bob')],
    );
    await tester.pumpWidget(wrap(card(ShareStyle.spotlight, tied)));

    expect(find.text('TIE'), findsOneWidget);
  });

  testWidgets('spotlight keeps a co-winner in the list on a tie', (
    tester,
  ) async {
    final tied = sample(
      scores: [score(1, 30, 'Amy'), score(2, 30, 'Bob'), score(3, 10, 'Cid')],
    );
    await tester.pumpWidget(wrap(card(ShareStyle.spotlight, tied)));

    // Amy is the hero; the co-winner Bob (and Cid) are still listed.
    expect(find.text('Amy'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Cid'), findsOneWidget);
  });

  testWidgets('minimal lists the other players below the winner', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(card(ShareStyle.minimal, sample())));

    expect(find.text('Amy'), findsOneWidget); // winner
    expect(find.text('Bob'), findsOneWidget); // runner-up
    expect(find.text('Cid'), findsOneWidget); // runner-up
  });

  testWidgets('podium shows every co-champion on a draw', (tester) async {
    final tied = sample(
      scores: [score(1, 30, 'Amy'), score(2, 30, 'Bob'), score(3, 30, 'Cid')],
    );
    await tester.pumpWidget(wrap(card(ShareStyle.podium, tied)));

    expect(find.text('Amy'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Cid'), findsOneWidget);
  });

  testWidgets('podium shows only the top three without a draw', (tester) async {
    final four = sample(
      scores: [
        score(1, 40, 'Amy'),
        score(2, 30, 'Bob'),
        score(3, 20, 'Cid'),
        score(4, 10, 'Dan'),
      ],
    );
    await tester.pumpWidget(wrap(card(ShareStyle.podium, four)));

    expect(find.text('Amy'), findsOneWidget);
    expect(find.text('Dan'), findsNothing);
  });

  testWidgets('renders an empty result without crashing', (tester) async {
    final empty = ShareResult.fromScoringData(
      const ScoringData(),
      lowestScoreWins: false,
    );
    await tester.pumpWidget(wrap(card(ShareStyle.spotlight, empty)));

    expect(tester.takeException(), isNull);
    expect(find.text('Party'), findsOneWidget);
  });
}
