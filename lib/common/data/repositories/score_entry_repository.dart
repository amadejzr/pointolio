import 'package:drift/drift.dart';
import 'package:scoreio/common/data/database/database.dart';

class ScoreEntryRepository {
  final AppDatabase _db;

  ScoreEntryRepository(this._db);

  Stream<List<ScoreEntry>> watchByGameId(int gameId) {
    final query = _db.select(_db.scoreEntries).join([
      innerJoin(
        _db.gamePlayers,
        _db.gamePlayers.id.equalsExp(_db.scoreEntries.gamePlayerId),
      ),
    ])
      ..where(_db.gamePlayers.gameId.equals(gameId))
      ..orderBy([
        OrderingTerm.asc(_db.scoreEntries.roundNumber),
        OrderingTerm.asc(_db.gamePlayers.orderIndex),
      ]);

    return query.watch().map((rows) {
      return rows.map((r) => r.readTable(_db.scoreEntries)).toList();
    });
  }

  Future<List<ScoreEntry>> getByGameId(int gameId) async {
    final query = _db.select(_db.scoreEntries).join([
      innerJoin(
        _db.gamePlayers,
        _db.gamePlayers.id.equalsExp(_db.scoreEntries.gamePlayerId),
      ),
    ])
      ..where(_db.gamePlayers.gameId.equals(gameId))
      ..orderBy([
        OrderingTerm.asc(_db.scoreEntries.roundNumber),
        OrderingTerm.asc(_db.gamePlayers.orderIndex),
      ]);

    final rows = await query.get();
    return rows.map((r) => r.readTable(_db.scoreEntries)).toList();
  }

  Future<int> add({
    required int gamePlayerId,
    required int roundNumber,
    required int points,
  }) {
    return _db.into(_db.scoreEntries).insert(
          ScoreEntriesCompanion.insert(
            gamePlayerId: gamePlayerId,
            roundNumber: roundNumber,
            points: points,
          ),
        );
  }

  Future<void> update({
    required int id,
    required int points,
  }) async {
    await (_db.update(_db.scoreEntries)..where((e) => e.id.equals(id))).write(
      ScoreEntriesCompanion(points: Value(points)),
    );
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.scoreEntries)..where((e) => e.id.equals(id))).go();
  }

  Future<void> deleteRound(int gameId, int roundNumber) async {
    final gamePlayerIds = await (_db.select(_db.gamePlayers)
          ..where((gp) => gp.gameId.equals(gameId)))
        .get()
        .then((list) => list.map((gp) => gp.id).toList());

    await (_db.delete(_db.scoreEntries)
          ..where((e) =>
              e.gamePlayerId.isIn(gamePlayerIds) &
              e.roundNumber.equals(roundNumber)))
        .go();
  }

  Future<int> getMaxRound(int gameId) async {
    final gamePlayerIds = await (_db.select(_db.gamePlayers)
          ..where((gp) => gp.gameId.equals(gameId)))
        .get()
        .then((list) => list.map((gp) => gp.id).toList());

    if (gamePlayerIds.isEmpty) return 0;

    final result = await (_db.select(_db.scoreEntries)
          ..where((e) => e.gamePlayerId.isIn(gamePlayerIds))
          ..orderBy([(e) => OrderingTerm.desc(e.roundNumber)])
          ..limit(1))
        .getSingleOrNull();

    return result?.roundNumber ?? 0;
  }
}
