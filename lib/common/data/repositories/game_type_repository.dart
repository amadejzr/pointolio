import 'package:drift/drift.dart';
import 'package:scoreio/common/data/database/database.dart';

class GameTypeRepository {
  final AppDatabase _db;

  GameTypeRepository(this._db);

  Stream<List<GameType>> watchAll() {
    return (_db.select(_db.gameTypes)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<GameType>> getAll() {
    return (_db.select(_db.gameTypes)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<GameType?> getById(int id) {
    return (_db.select(_db.gameTypes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<GameType?> getByName(String name) {
    return (_db.select(_db.gameTypes)
          ..where((t) => t.name.equals(name.trim())))
        .getSingleOrNull();
  }

  Future<int> add(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Game type name is empty');

    // Check if already exists
    final existing = await getByName(trimmed);
    if (existing != null) return existing.id;

    return _db.into(_db.gameTypes).insert(
          GameTypesCompanion.insert(name: trimmed),
        );
  }

  Future<void> update(int id, String name) async {
    await (_db.update(_db.gameTypes)..where((t) => t.id.equals(id)))
        .write(GameTypesCompanion(name: Value(name.trim())));
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.gameTypes)..where((t) => t.id.equals(id))).go();
  }
}
