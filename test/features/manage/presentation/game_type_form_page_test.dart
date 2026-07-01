import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/ui/widgets/game_type_bottom_sheet/game_type_result.dart';
import 'package:pointolio/features/manage/presentation/game_type_form_page.dart';

import '../../../utils/fixtures.dart';

void main() {
  // Harness: a launcher route pushes the form so `context.pop(result)` lands
  // back here and we can capture what the page returned.
  late GameTypeResult? captured;
  late bool returned;

  Widget harness({GameType? initial}) {
    captured = null;
    returned = false;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  captured =
                      await context.push<GameTypeResult>('/form');
                  returned = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/form',
          builder: (context, state) => GameTypeFormPage(initial: initial),
        ),
      ],
    );
    return MaterialApp.router(
      theme: ThemeData(extensions: const [PointolioTheme.light]),
      routerConfig: router,
    );
  }

  Future<void> openForm(WidgetTester tester, {GameType? initial}) async {
    await tester.pumpWidget(harness(initial: initial));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  bool isButton(WidgetTester tester, Finder f) =>
      tester.getSemantics(f).getSemanticsData().flagsCollection.isButton;

  bool isSelected(WidgetTester tester, Finder f) =>
      tester.getSemantics(f).getSemanticsData().flagsCollection.isSelected ==
      Tristate.isTrue;

  testWidgets('new game form exposes labelled, accessible controls', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await openForm(tester);

    // Header reflects create mode.
    expect(find.text('New game'), findsOneWidget);

    // Name field is a labelled text field (the section label folds into it,
    // so the accessible name reads "GAME NAME / Game name").
    final name = find.bySemanticsLabel(RegExp('Game name'));
    expect(name, findsOneWidget);
    expect(
      tester.getSemantics(name).getSemanticsData().flagsCollection.isTextField,
      isTrue,
    );

    // Colour swatches are labelled buttons.
    expect(isButton(tester, find.bySemanticsLabel('Colour 1')), isTrue);

    // Win-rule options are labelled buttons; Highest wins is the default.
    expect(isButton(tester, find.bySemanticsLabel('Highest wins')), isTrue);
    expect(isButton(tester, find.bySemanticsLabel('Lowest wins')), isTrue);
    expect(isSelected(tester, find.bySemanticsLabel('Highest wins')), isTrue);
    expect(isSelected(tester, find.bySemanticsLabel('Lowest wins')), isFalse);

    // The primary CTA is a labelled button.
    expect(isButton(tester, find.bySemanticsLabel('Add game')), isTrue);

    handle.dispose();
  });

  testWidgets('the CTA stays disabled until a name is entered', (tester) async {
    await openForm(tester);

    // Empty name -> tapping does nothing, we stay on the form.
    await tester.tap(find.bySemanticsLabel('Add game'));
    await tester.pumpAndSettle();
    expect(returned, isFalse);
    expect(find.text('New game'), findsOneWidget);
  });

  testWidgets('saving returns the entered game type', (tester) async {
    await openForm(tester);

    await tester.enterText(find.byType(TextField), 'Chess');
    await tester.tap(find.bySemanticsLabel('Lowest wins'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Add game'));
    await tester.pumpAndSettle();

    expect(returned, isTrue);
    expect(captured, isNotNull);
    expect(captured!.name, 'Chess');
    expect(captured!.lowestScoreWins, isTrue);
  });

  testWidgets('edit mode pre-fills the game and its win rule', (tester) async {
    final handle = tester.ensureSemantics();
    await openForm(
      tester,
      initial: gameTypeRow(id: 7, name: 'Rummy', lowestScoreWins: true),
    );

    expect(find.text('Edit game'), findsOneWidget);
    expect(find.text('Rummy'), findsOneWidget);
    expect(isSelected(tester, find.bySemanticsLabel('Lowest wins')), isTrue);
    // Edit uses "Save game" as its CTA.
    expect(isButton(tester, find.bySemanticsLabel('Save game')), isTrue);

    handle.dispose();
  });
}
