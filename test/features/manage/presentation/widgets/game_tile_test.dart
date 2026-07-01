import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/features/manage/presentation/widgets/game_tile.dart';

import '../../../../utils/fixtures.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData(extensions: const [PointolioTheme.light]),
    home: Scaffold(body: child),
  );

  testWidgets('game is one button summarising it, plus a menu button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        GameTile(
          gameType: gameTypeRow(id: 9, name: 'Rummy', lowestScoreWins: true),
        ),
      ),
    );

    final tile = find.bySemanticsLabel(RegExp('Rummy.*Lowest score wins'));
    expect(tile, findsOneWidget);
    expect(
      tester.getSemantics(tile).getSemanticsData().flagsCollection.isButton,
      isTrue,
    );

    final menu = find.bySemanticsLabel('Game options');
    expect(menu, findsOneWidget);
    expect(
      tester.getSemantics(menu).getSemanticsData().flagsCollection.isButton,
      isTrue,
    );

    handle.dispose();
  });

  testWidgets('highest-score game announces its win rule', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(GameTile(gameType: gameTypeRow(id: 1, name: 'Yahtzee'))),
    );

    expect(
      find.bySemanticsLabel(RegExp('Yahtzee.*Highest score wins')),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('the menu button opens the actions menu with edit and delete', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(GameTile(gameType: gameTypeRow(id: 3, name: 'Hearts'))),
    );

    await tester.tap(find.bySemanticsLabel('Game options'));
    await tester.pumpAndSettle();

    expect(find.text('Edit game'), findsOneWidget);
    expect(find.text('Delete game'), findsOneWidget);

    handle.dispose();
  });
}
