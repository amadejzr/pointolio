import 'package:get_it/get_it.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/data/repositories/game_repository.dart';
import 'package:scoreio/common/data/repositories/game_type_repository.dart';
import 'package:scoreio/common/data/repositories/player_repository.dart';
import 'package:scoreio/common/data/repositories/score_entry_repository.dart';
import 'package:scoreio/features/create_game/data/create_game_repository.dart';
import 'package:scoreio/features/home/data/home_repository.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Database
  locator
    ..registerLazySingleton<AppDatabase>(AppDatabase.new)
    // Repositories
    ..registerLazySingleton<GameTypeRepository>(
      () => GameTypeRepository(locator<AppDatabase>()),
    )
    ..registerLazySingleton<PlayerRepository>(
      () => PlayerRepository(locator<AppDatabase>()),
    )
    ..registerLazySingleton<GameRepository>(
      () => GameRepository(locator<AppDatabase>()),
    )
    ..registerLazySingleton<ScoreEntryRepository>(
      () => ScoreEntryRepository(locator<AppDatabase>()),
    )
    ///
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepository(locator<AppDatabase>()),
    )
    ..registerLazySingleton<CreateGameRepository>(
      () => CreateGameRepository(locator<AppDatabase>()),
    );
}
