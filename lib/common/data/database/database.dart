import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointolio/common/data/dao/game_dao.dart';
import 'package:pointolio/common/data/dao/game_type_dao.dart';
import 'package:pointolio/common/data/dao/player_dao.dart';
import 'package:pointolio/common/data/dao/score_entry_dao.dart';
import 'package:pointolio/common/data/dao/scoring_dao.dart';
import 'package:pointolio/common/data/tables/game_players_table.dart';
import 'package:pointolio/common/data/tables/games_table.dart';
import 'package:pointolio/common/data/tables/player_table.dart';
import 'package:pointolio/common/data/tables/score_entries_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Games,
    GameTypes,
    Players,
    GamePlayers,
    ScoreEntries,
  ],
  daos: [
    GameDao,
    GameTypeDao,
    PlayerDao,
    ScoreEntryDao,
    ScoringDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'database',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}
