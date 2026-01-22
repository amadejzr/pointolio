import 'package:get_it/get_it.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/features/create_game/data/create_game_repository.dart';
import 'package:scoreio/features/home/data/home_repository.dart';
import 'package:scoreio/features/manage/data/game_types_management_repository.dart';
import 'package:scoreio/features/manage/data/players_management_repository.dart';
import 'package:scoreio/features/scoring/data/scoring_repository.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
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
    );
}
