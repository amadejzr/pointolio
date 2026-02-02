import 'package:get_it/get_it.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/features/create_game/data/create_game_repository.dart';
import 'package:pointolio/features/home/data/home_repository.dart';
import 'package:pointolio/features/manage/data/game_types_management_repository.dart';
import 'package:pointolio/features/manage/data/players_management_repository.dart';
import 'package:pointolio/features/scoring/data/scoring_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();
  // Database
  locator
    ..registerLazySingleton<AppDatabase>(AppDatabase.new)
    // Repositories
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
    ..registerLazySingleton<SharedPreferences>(
      () => prefs,
    );
}
