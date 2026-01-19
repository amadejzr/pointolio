import 'package:drift/drift.dart';
import 'package:scoreio/common/data/database/database.dart';

class PlayerRepository {
  final AppDatabase _db;

  PlayerRepository(this._db);

  Stream<List<Player>> watchAll({bool includeArchived = false}) {
    final query = _db.select(_db.players);
    if (!includeArchived) {
      query.where((p) => p.isArchived.equals(false));
    }
    query.orderBy([(p) => OrderingTerm.asc(p.firstName)]);
    return query.watch();
  }

  Future<List<Player>> getAll({bool includeArchived = false}) {
    final query = _db.select(_db.players);
    if (!includeArchived) {
      query.where((p) => p.isArchived.equals(false));
    }
    query.orderBy([(p) => OrderingTerm.asc(p.firstName)]);
    return query.get();
  }

  Future<Player?> getById(int id) {
    return (_db.select(_db.players)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Player?> getByName(String firstName, String? lastName) {
    final query = _db.select(_db.players)
      ..where((p) => p.firstName.equals(firstName.trim()));

    if (lastName != null && lastName.trim().isNotEmpty) {
      query.where((p) => p.lastName.equals(lastName.trim()));
    } else {
      query.where((p) => p.lastName.isNull());
    }

    return query.getSingleOrNull();
  }

  Future<int> add({
    required String firstName,
    String? lastName,
  }) async {
    final f = firstName.trim();
    final l = lastName?.trim();
    if (f.isEmpty) throw ArgumentError('First name is empty');

    // Check if already exists
    final existing = await getByName(f, l);
    if (existing != null) return existing.id;

    return _db.into(_db.players).insert(
          PlayersCompanion.insert(
            firstName: f,
            lastName: Value(l?.isEmpty == true ? null : l),
          ),
        );
  }

  Future<void> update({
    required int id,
    String? firstName,
    String? lastName,
  }) async {
    final companion = PlayersCompanion(
      firstName: firstName != null ? Value(firstName.trim()) : const Value.absent(),
      lastName: lastName != null ? Value(lastName.trim()) : const Value.absent(),
    );

    await (_db.update(_db.players)..where((p) => p.id.equals(id)))
        .write(companion);
  }

  Future<void> archive(int id) async {
    await (_db.update(_db.players)..where((p) => p.id.equals(id)))
        .write(const PlayersCompanion(isArchived: Value(true)));
  }

  Future<void> unarchive(int id) async {
    await (_db.update(_db.players)..where((p) => p.id.equals(id)))
        .write(const PlayersCompanion(isArchived: Value(false)));
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.players)..where((p) => p.id.equals(id))).go();
  }
}
