import 'package:drift/drift.dart';
import 'package:scoreio/common/data/database/database.dart';

class GameRepository {
  final AppDatabase _db;

  GameRepository(this._db);

  Stream<List<Game>> watchAll() {
    return (_db.select(_db.games)
          ..orderBy([(g) => OrderingTerm.desc(g.gameDate)]))
        .watch();
  }

  Future<List<Game>> getAll() {
    return (_db.select(_db.games)
          ..orderBy([(g) => OrderingTerm.desc(g.gameDate)]))
        .get();
  }

  Future<Game?> getById(int id) {
    return (_db.select(_db.games)..where((g) => g.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> create({
    required String name,
    required int gameTypeId,
    required String gameTypeName,
    required List<int> playerIds,
    DateTime? gameDate,
    String? note,
  }) async {
    return _db.transaction(() async {
      final gameId = await _db.into(_db.games).insert(
            GamesCompanion.insert(
              name: name.trim(),
              gameDate: Value(gameDate ?? DateTime.now()),
              gameTypeId: Value(gameTypeId),
              gameTypeNameSnapshot: Value(gameTypeName.trim()),
              note: Value(note?.trim()),
            ),
          );

      for (var i = 0; i < playerIds.length; i++) {
        await _db.into(_db.gamePlayers).insert(
              GamePlayersCompanion.insert(
                gameId: gameId,
                playerId: playerIds[i],
                orderIndex: Value(i),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

      return gameId;
    });
  }

  Future<void> update({
    required int id,
    String? name,
    DateTime? gameDate,
    String? note,
  }) async {
    final companion = GamesCompanion(
      name: name != null ? Value(name.trim()) : const Value.absent(),
      gameDate: gameDate != null ? Value(gameDate) : const Value.absent(),
      note: note != null ? Value(note.trim()) : const Value.absent(),
    );

    await (_db.update(_db.games)..where((g) => g.id.equals(id)))
        .write(companion);
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.games)..where((g) => g.id.equals(id))).go();
  }

  // Get players for a game
  Stream<List<(Player, GamePlayer)>> watchGamePlayers(int gameId) {
    final query = _db.select(_db.gamePlayers).join([
      innerJoin(_db.players, _db.players.id.equalsExp(_db.gamePlayers.playerId)),
    ])
      ..where(_db.gamePlayers.gameId.equals(gameId))
      ..orderBy([OrderingTerm.asc(_db.gamePlayers.orderIndex)]);

    return query.watch().map((rows) {
      return rows.map((r) {
        final player = r.readTable(_db.players);
        final gamePlayer = r.readTable(_db.gamePlayers);
        return (player, gamePlayer);
      }).toList();
    });
  }

  Future<List<(Player, GamePlayer)>> getGamePlayers(int gameId) async {
    final query = _db.select(_db.gamePlayers).join([
      innerJoin(_db.players, _db.players.id.equalsExp(_db.gamePlayers.playerId)),
    ])
      ..where(_db.gamePlayers.gameId.equals(gameId))
      ..orderBy([OrderingTerm.asc(_db.gamePlayers.orderIndex)]);

    final rows = await query.get();
    return rows.map((r) {
      final player = r.readTable(_db.players);
      final gamePlayer = r.readTable(_db.gamePlayers);
      return (player, gamePlayer);
    }).toList();
  }

  Future<int> getPlayerCount(int gameId) async {
    final count = await (_db.select(_db.gamePlayers)
          ..where((gp) => gp.gameId.equals(gameId)))
        .get();
    return count.length;
  }

  Future<GameType?> getGameType(int? gameTypeId) async {
    if (gameTypeId == null) return null;
    return (_db.select(_db.gameTypes)..where((t) => t.id.equals(gameTypeId)))
        .getSingleOrNull();
  }

  /// Reorders players in a game by updating their orderIndex values.
  /// [gamePlayerIds] should be the list of GamePlayer IDs in the new desired order.
  Future<void> reorderPlayers(List<int> gamePlayerIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < gamePlayerIds.length; i++) {
        await (_db.update(_db.gamePlayers)
              ..where((gp) => gp.id.equals(gamePlayerIds[i])))
            .write(GamePlayersCompanion(orderIndex: Value(i)));
      }
    });
  }
}
