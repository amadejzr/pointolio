// App Store screenshot harness.
//
// Instead of rendering individual pages in a bare MaterialApp (which drops the
// notebook background and floating navbar that the shell provides), this drives
// the *real* go_router app against a seeded in-memory database. Every shot is
// therefore pixel-accurate with production: real Notebook/Slate theme, real
// bundled fonts, real navbar, real backgrounds.
//
// Run:
//   flutter drive --driver=screenshots/driver.dart \
//     --target=screenshots/screenshot_test.dart
//
// Output: screenshots/output/output-ios/<name>.png

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/features/create_game/data/create_game_repository.dart';
import 'package:pointolio/features/create_game/presentation/cubit/create_game_cubit.dart';
import 'package:pointolio/features/home/data/home_repository.dart';
import 'package:pointolio/features/manage/data/game_types_management_repository.dart';
import 'package:pointolio/features/manage/data/players_management_repository.dart';
import 'package:pointolio/features/scoring/data/scoring_repository.dart';
import 'package:pointolio/features/settings/data/settings_repository.dart';
import 'package:pointolio/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screenshot_seed_data.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ScreenshotSeed seed;
  final locator = GetIt.instance;

  setUp(() async {
    await locator.reset();
    db = AppDatabase(NativeDatabase.memory());

    // This driver target runs under the integration_test binding (a test
    // context), so seeding empty prefs via the test-only API is intended.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    // Mirror lib/common/di/locator.dart, but with the in-memory DB + prefs.
    locator
      ..registerSingleton<AppDatabase>(db)
      ..registerSingleton<SharedPreferences>(prefs)
      ..registerLazySingleton<ScoringRepository>(
        () => ScoringRepository(locator<AppDatabase>()),
      )
      ..registerLazySingleton<HomeRepository>(
        () => HomeRepository(locator<AppDatabase>()),
      )
      ..registerLazySingleton<CreateGameRepository>(
        () => CreateGameRepository(locator<AppDatabase>()),
      )
      ..registerLazySingleton<PlayersManagementRepository>(
        () => PlayersManagementRepository(locator<AppDatabase>()),
      )
      ..registerLazySingleton<GameTypesManagementRepository>(
        () => GameTypesManagementRepository(locator<AppDatabase>()),
      )
      ..registerLazySingleton<SettingsRepository>(
        () => SettingsRepository(locator<AppDatabase>()),
      );

    seed = await seedScreenshotData(db);
  });

  tearDown(() async {
    await db.close();
    await locator.reset();
  });

  /// Pumps the full app and returns its router so tests can navigate the map.
  Future<GoRouter> pumpApp(WidgetTester tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(_ScreenshotApp(router: router));
    await tester.pumpAndSettle();
    return router;
  }

  group('App Store Screenshots', () {
    testWidgets('01 - Parties (home)', (tester) async {
      await pumpApp(tester);
      // Starts on the Parties tab. Expand "Completed" so the hero shot shows a
      // full screen (active + finished parties) instead of empty paper.
      await tester.tap(find.bySemanticsLabel('2 completed parties'));
      await settle(tester);
      await binding.takeScreenshot('01_parties');
    });

    testWidgets('02 - Scoring table', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRouter.scoringPath(seed.rummyGameId));
      await settle(tester);
      await binding.takeScreenshot('02_scoring_table');
    });

    testWidgets('03 - Standings', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRouter.scoringPath(seed.rummyGameId));
      await settle(tester);

      await tester.tap(find.bySemanticsLabel('Standings'));
      await settle(tester);
      await binding.takeScreenshot('03_standings');
    });

    testWidgets('04 - Share result', (tester) async {
      final router = await pumpApp(tester);
      // A finished party shows a "Share result" primary button.
      router.go(AppRouter.scoringPath(seed.pokerGameId));
      await settle(tester);

      await tester.tap(find.bySemanticsLabel('Share result'));
      await settle(tester);
      await binding.takeScreenshot('04_share');
    });

    testWidgets('05 - New party', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRouter.createGame);
      await settle(tester);

      // Populate the form so the shot shows a realistic, valid party.
      final ctx = tester.element(find.byType(EditableText));
      final cubit = ctx.read<CreateGameCubit>();
      final state = cubit.state;
      cubit.setGameType(
        state.availableGameTypes.firstWhere((g) => g.name == 'Rummy'),
      );
      state.availablePlayers.take(4).forEach(cubit.addPlayer);
      await tester.enterText(find.byType(EditableText).first, 'Sunday Rummy');
      FocusManager.instance.primaryFocus?.unfocus();
      await settle(tester);
      await binding.takeScreenshot('05_new_party');
    });

    testWidgets('06 - Players', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRouter.players);
      await settle(tester);
      await binding.takeScreenshot('06_players');
    });

    testWidgets('07 - Games', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRouter.games);
      await settle(tester);
      await binding.takeScreenshot('07_games');
    });
  });
}

/// Settles the tree and lets entrance animations / shadows finish painting.
Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

/// The production app wired to a caller-provided router, pinned to light mode.
class _ScreenshotApp extends StatelessWidget {
  const _ScreenshotApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Pointolio',
      theme: PointolioTheme.themeData(Brightness.light),
      darkTheme: PointolioTheme.themeData(Brightness.dark),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
