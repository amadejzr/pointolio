import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/features/manage/presentation/player_form_page.dart';

import '../../../utils/fixtures.dart';

void main() {
  // Drives the page through a real GoRouter (as the Players screen does) and
  // exposes the popped result through the returned holder.
  Future<List<PlayerFormResult?>> openPage(
    WidgetTester tester, {
    Player? initial,
  }) async {
    final holder = <PlayerFormResult?>[];
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  holder.add(
                    await context.push<PlayerFormResult>(
                      '/form',
                      extra: initial,
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/form',
          builder: (context, state) =>
              PlayerFormPage(initial: state.extra as Player?),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(extensions: const [PointolioTheme.light]),
        routerConfig: router,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return holder;
  }

  testWidgets('create mode shows "New player" and gates save until a name is '
      'entered', (tester) async {
    await openPage(tester);

    expect(find.text('New player'), findsOneWidget);

    // The save CTA is present but gated - tapping it leaves us on the form.
    await tester.tap(find.text('Add player'));
    await tester.pumpAndSettle();
    expect(find.text('New player'), findsOneWidget);
  });

  testWidgets('saving returns the entered names and a resolved colour', (
    tester,
  ) async {
    final holder = await openPage(tester);

    // First-name field is first in the form, last-name second.
    await tester.enterText(find.byType(TextField).at(0), 'Amy');
    await tester.enterText(find.byType(TextField).at(1), 'Stone');
    await tester.pump();

    await tester.tap(find.text('Add player'));
    await tester.pumpAndSettle();

    expect(holder, hasLength(1));
    final result = holder.single;
    expect(result, isNotNull);
    expect(result!.firstName, 'Amy');
    expect(result.lastName, 'Stone');
    // Colour resolves to the first palette swatch by default.
    expect(result.color, PointolioTheme.light.playerColor(0).toARGB32());
  });

  testWidgets('edit mode prefills the fields and preserves the stored colour', (
    tester,
  ) async {
    final storedColor = PointolioTheme.light.playerColor(2).toARGB32();

    final holder = await openPage(
      tester,
      initial: playerRow(
        id: 1,
        firstName: 'Bob',
        lastName: 'Ray',
        color: storedColor,
      ),
    );

    expect(find.text('Edit player'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Bob'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Ray'), findsOneWidget);

    // Saving without touching the colour keeps the stored swatch.
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(holder.single?.color, storedColor);
  });
}
