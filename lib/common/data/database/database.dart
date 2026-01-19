import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scoreio/common/data/tables/game_players_table.dart';
import 'package:scoreio/common/data/tables/games_table.dart';
import 'package:scoreio/common/data/tables/player_table.dart';
import 'package:scoreio/common/data/tables/score_entries_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Games,
    GameTypes,
    Players,
    GamePlayers,
    ScoreEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 3) {
          // Add lowestScoreWins column to game_types table (default false = highest score wins)
          await customStatement(
            'ALTER TABLE game_types ADD COLUMN lowest_score_wins INTEGER NOT NULL DEFAULT 0',
          );
          // Add color column to game_types table (nullable)
          await customStatement(
            'ALTER TABLE game_types ADD COLUMN color INTEGER',
          );
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'score_games.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
