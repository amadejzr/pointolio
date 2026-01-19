import 'package:get_it/get_it.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/data/repositories/game_repository.dart';
import 'package:scoreio/common/data/repositories/game_type_repository.dart';
import 'package:scoreio/common/data/repositories/player_repository.dart';
import 'package:scoreio/common/data/repositories/score_entry_repository.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Database
  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Repositories
  locator.registerLazySingleton<GameTypeRepository>(
    () => GameTypeRepository(locator<AppDatabase>()),
  );
  locator.registerLazySingleton<PlayerRepository>(
    () => PlayerRepository(locator<AppDatabase>()),
  );
  locator.registerLazySingleton<GameRepository>(
    () => GameRepository(locator<AppDatabase>()),
  );
  locator.registerLazySingleton<ScoreEntryRepository>(
    () => ScoreEntryRepository(locator<AppDatabase>()),
  );
}
