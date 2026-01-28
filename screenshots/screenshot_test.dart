import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/app_theme.dart';
import 'package:pointolio/features/create_game/data/create_game_repository.dart';
import 'package:pointolio/features/create_game/presentation/create_game_page.dart';
import 'package:pointolio/features/home/data/home_repository.dart';
import 'package:pointolio/features/home/presentation/home_page.dart';
import 'package:pointolio/features/manage/data/game_types_management_repository.dart';
import 'package:pointolio/features/manage/data/players_management_repository.dart';
import 'package:pointolio/features/scoring/data/scoring_repository.dart';
import 'package:pointolio/features/scoring/presentation/scoring_page.dart';

import 'screenshot_seed_data.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  final locator = GetIt.instance;

  setUp(() async {
    await locator.reset();
    db = AppDatabase(NativeDatabase.memory());

    locator
      ..registerSingleton<AppDatabase>(db)
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
      );

    await seedScreenshotData(db);
  });

  tearDown(() async {
    await db.close();
    await locator.reset();
  });

  group('App Store Screenshots', () {
    testWidgets('Home screen - light', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Completed'));

      await Future<void>.delayed(Durations.medium1);

      await tester.pumpAndSettle();

      await binding.takeScreenshot('1');
    });

    testWidgets('Create party', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const CreateGamePage(),
        ),
      );

      await tester.pumpAndSettle();

      await binding.takeScreenshot('2');
    });

    testWidgets('Scoring view', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const ScoringPage(
            gameId: 1,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(-1200, 0),
      );
      await tester.pumpAndSettle();

      await binding.takeScreenshot('3');

      await tester.tap(find.byKey(const Key('add_round_button')));

      await tester.pumpAndSettle();

      await Future<void>.delayed(Durations.medium1);

      await binding.takeScreenshot('4');
    });

    testWidgets('Scoring view', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const ScoringPage(
            gameId: 1,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(-1200, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('appbar_title_menu')));

      await tester.pumpAndSettle();

      await Future<void>.delayed(Durations.medium3);

      await tester.tap(find.text('Share'));

      await tester.pumpAndSettle();

      await Future<void>.delayed(Durations.medium3);

      await binding.takeScreenshot('5');
    });
  });
}
