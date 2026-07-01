import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/sharing/domain/share_result.dart';
import 'package:pointolio/features/sharing/presentation/cubit/share_editor_cubit.dart';
import 'package:pointolio/features/sharing/presentation/share_page.dart';
import 'package:pointolio/features/sharing/presentation/widgets/share_card.dart';

import '../../utils/fixtures.dart';
import 'cubit/share_editor_cubit_test.dart' show FakeShareLauncher;

void main() {
  PlayerScore score(int id, int total, String name) => PlayerScore(
    player: playerRow(id: id, firstName: name),
    gamePlayer: gamePlayerRow(id: id, playerId: id),
    roundScores: const {},
    total: total,
  );

  ShareResult sample() => ShareResult.fromScoringData(
    ScoringData(
      game: gameRow(id: 1, name: 'Friday Night'),
      gameType: gameTypeRow(id: 1, name: 'Rummy'),
      playerScores: [
        score(1, 30, 'Amy'),
        score(2, 20, 'Bob'),
      ],
      roundCount: 3,
    ),
    lowestScoreWins: false,
  );

  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData(extensions: const [PointolioTheme.light]),
    home: child,
  );

  testWidgets('starts on the Spotlight style', (tester) async {
    await tester.pumpWidget(wrap(SharePage(result: sample())));

    expect(find.text('WINNER'), findsOneWidget);
    expect(find.text('Amy'), findsWidgets);
  });

  testWidgets('switching style updates the live preview', (tester) async {
    await tester.pumpWidget(wrap(SharePage(result: sample())));

    // 'pts' only appears on the Minimal card, so it is a clean style probe.
    expect(find.text('pts'), findsNothing);

    await tester.tap(find.text('Minimal'));
    await tester.pumpAndSettle();

    expect(find.text('pts'), findsOneWidget);
  });

  testWidgets('the card is captured tightly at a fixed width', (tester) async {
    await tester.pumpWidget(wrap(SharePage(result: sample())));

    // The capture boundary is the nearest RepaintBoundary above the card.
    final captureBoundary = find
        .ancestor(
          of: find.byType(ShareCard),
          matching: find.byType(RepaintBoundary),
        )
        .first;

    // The boundary wraps only the fixed-width card - a tight export.
    expect(
      find.descendant(of: captureBoundary, matching: find.byType(ShareCard)),
      findsOneWidget,
    );
    final sized = tester.widget<SizedBox>(
      find
          .descendant(of: captureBoundary, matching: find.byType(SizedBox))
          .first,
    );
    expect(sized.width, kShareCardWidth);
  });

  testWidgets('copy text writes the summary to the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(wrap(SharePage(result: sample())));
    await tester.tap(find.byKey(const Key('copy_text_button')));
    await tester.pump(); // toast fade-in

    expect(copied, contains('Friday Night'));
    expect(copied, contains('1. Amy - 30'));
    expect(find.text('Result copied'), findsOneWidget);

    // Let the toast auto-dismiss so no timers dangle past the test.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('sharing captures the card and forwards it to the launcher', (
    tester,
  ) async {
    final launcher = FakeShareLauncher();

    await tester.runAsync(() async {
      await tester.pumpWidget(
        wrap(SharePage(result: sample(), launcher: launcher)),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('share_button')));

      // Let the capture retries + the fake share complete.
      for (var i = 0; i < 10 && launcher.calls == 0; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });

    expect(launcher.calls, 1);
    expect(launcher.lastBytes, isNotNull);
    expect(launcher.lastText, contains('via Pointolio'));
  });

  testWidgets('shows an error toast when the share backend fails', (
    tester,
  ) async {
    final launcher = FakeShareLauncher(result: ShareActionResult.failed);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        wrap(SharePage(result: sample(), launcher: launcher)),
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('share_button')));
      for (var i = 0; i < 10 && launcher.calls == 0; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pump(); // toast fade-in

    expect(find.text('Sharing failed, please try again'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
