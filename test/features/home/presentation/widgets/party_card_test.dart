import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/features/home/presentation/cubit/home_state.dart';
import 'package:pointolio/features/home/presentation/widgets/party_card.dart';

import '../../../../utils/fixtures.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData(extensions: const [PointolioTheme.light]),
    home: Scaffold(body: child),
  );

  GameWithPlayerCount sample({bool finished = false, String? winner}) {
    return GameWithPlayerCount(
      game: gameRow(
        id: 1,
        name: 'Friday Rummy',
        gameTypeId: 9,
        finishedAt: finished ? DateTime(2025) : null,
      ),
      playerCount: 2,
      gameType: gameTypeRow(id: 9, name: 'Rummy'),
      players: [
        playerRow(id: 1, firstName: 'Amy'),
        playerRow(id: 2, firstName: 'Bob'),
      ],
      roundCount: 3,
      winnerName: winner,
    );
  }

  testWidgets('active party is one button summarising it, plus a menu button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(PartyCard(gameWithPlayerCount: sample())));

    final card = find.bySemanticsLabel(
      RegExp('Friday Rummy.*2 players.*Round 3'),
    );
    expect(card, findsOneWidget);
    expect(
      tester.getSemantics(card).getSemanticsData().flagsCollection.isButton,
      isTrue,
    );

    final menu = find.bySemanticsLabel('Party options');
    expect(menu, findsOneWidget);
    expect(
      tester.getSemantics(menu).getSemanticsData().flagsCollection.isButton,
      isTrue,
    );

    handle.dispose();
  });

  testWidgets('finished party announces the winner in its label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        PartyCard(
          gameWithPlayerCount: sample(finished: true, winner: 'Amy'),
          isFinished: true,
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(RegExp('Friday Rummy.*Finished, Amy won')),
      findsOneWidget,
    );

    handle.dispose();
  });
}
