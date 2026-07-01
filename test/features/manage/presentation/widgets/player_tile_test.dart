import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/features/manage/presentation/widgets/player_tile.dart';

import '../../../../utils/fixtures.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData(extensions: const [PointolioTheme.light]),
    home: Scaffold(body: child),
  );

  testWidgets('is a labelled button with an edit hint', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        PlayerTile(
          player: playerRow(id: 1, firstName: 'Amy', lastName: 'Stone'),
          colorIndex: 0,
        ),
      ),
    );

    final tile = find.bySemanticsLabel('Amy Stone');
    expect(tile, findsOneWidget);

    final data = tester.getSemantics(tile).getSemanticsData();
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hint, 'Edit player');

    handle.dispose();
  });

  testWidgets('exposes a separate, focusable "Player options" button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        PlayerTile(
          player: playerRow(id: 1, firstName: 'Amy', lastName: 'Stone'),
          colorIndex: 0,
        ),
      ),
    );

    final menu = find.bySemanticsLabel('Player options');
    expect(menu, findsOneWidget);
    expect(
      tester.getSemantics(menu).getSemanticsData().flagsCollection.isButton,
      isTrue,
    );

    handle.dispose();
  });

  testWidgets('uses only the first name when there is no last name', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        PlayerTile(player: playerRow(id: 2, firstName: 'Bob'), colorIndex: 1),
      ),
    );

    expect(find.bySemanticsLabel('Bob'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('tapping the body invokes onEdit', (tester) async {
    var edits = 0;
    await tester.pumpWidget(
      wrap(
        PlayerTile(
          player: playerRow(id: 1, firstName: 'Amy', lastName: 'Stone'),
          colorIndex: 0,
          onEdit: () => edits++,
        ),
      ),
    );

    // Tap the name area (not the trailing menu button).
    await tester.tap(find.text('Amy'));
    expect(edits, 1);
  });

  testWidgets('the menu offers Edit and Delete and routes each action', (
    tester,
  ) async {
    var edits = 0;
    var deletes = 0;
    await tester.pumpWidget(
      wrap(
        PlayerTile(
          player: playerRow(id: 1, firstName: 'Amy', lastName: 'Stone'),
          colorIndex: 0,
          onEdit: () => edits++,
          onDelete: () => deletes++,
        ),
      ),
    );

    // Open menu -> Delete.
    await tester.tap(find.bySemanticsLabel('Player options'));
    await tester.pumpAndSettle();
    expect(find.text('Edit player'), findsOneWidget);
    expect(find.text('Delete player'), findsOneWidget);
    await tester.tap(find.text('Delete player'));
    await tester.pumpAndSettle();
    expect(deletes, 1);
    expect(edits, 0);

    // Open menu -> Edit.
    await tester.tap(find.bySemanticsLabel('Player options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit player'));
    await tester.pumpAndSettle();
    expect(edits, 1);
    expect(deletes, 1);
  });

  testWidgets('meets tap-target and labelled-target accessibility guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        PlayerTile(
          player: playerRow(id: 1, firstName: 'Amy', lastName: 'Stone'),
          colorIndex: 0,
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });
}
