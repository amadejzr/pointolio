import 'package:drift/drift.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/data/tables/games_table.dart';

part 'game_type_dao.g.dart';

@DriftAccessor(tables: [GameTypes])
class GameTypeDao extends DatabaseAccessor<AppDatabase>
    with _$GameTypeDaoMixin {
  GameTypeDao(super.attachedDatabase);

  Future<List<GameType>> getAll() {
    return (select(
      gameTypes,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Future<GameType?> getById(int id) {
    return (select(gameTypes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<GameType?> getByName(String name) {
    return (select(
      gameTypes,
    )..where((t) => t.name.equals(name.trim()))).getSingleOrNull();
  }

  Future<int> add({
    required String name,
    bool lowestScoreWins = false,
    int? color,
  }) {
    return into(gameTypes).insert(
      GameTypesCompanion.insert(
        name: name.trim(),
        lowestScoreWins: Value(lowestScoreWins),
        color: Value(color),
      ),
    );
  }
}
