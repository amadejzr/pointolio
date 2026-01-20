import 'package:drift/drift.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/data/tables/game_players_table.dart';
import 'package:scoreio/common/data/tables/games_table.dart';
import 'package:scoreio/common/data/tables/player_table.dart';

part 'game_dao.g.dart';

@DriftAccessor(tables: [Games, GameTypes, Players, GamePlayers])
class GameDao extends DatabaseAccessor<AppDatabase> with _$GameDaoMixin {
  GameDao(super.attachedDatabase);

  Stream<List<Game>> watchAll() {
    return (select(
      games,
    )..orderBy([(g) => OrderingTerm.desc(g.gameDate)])).watch();
  }

  Future<List<Game>> getAll() {
    return (select(
      games,
    )..orderBy([(g) => OrderingTerm.desc(g.gameDate)])).get();
  }

  Future<Game?> getById(int id) {
    return (select(games)..where((g) => g.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertGame(GamesCompanion game) {
    return into(games).insert(game);
  }

  Future<void> updateGame(int id, GamesCompanion companion) {
    return (update(games)..where((g) => g.id.equals(id))).write(companion);
  }

  Future<int> deleteGame(int id) {
    return (delete(games)..where((g) => g.id.equals(id))).go();
  }

  Future<void> insertGamePlayer(GamePlayersCompanion gamePlayer) {
    return into(
      gamePlayers,
    ).insert(gamePlayer, mode: InsertMode.insertOrIgnore);
  }

  Stream<List<(Player, GamePlayer)>> watchGamePlayers(int gameId) {
    final query =
        select(gamePlayers).join([
            innerJoin(players, players.id.equalsExp(gamePlayers.playerId)),
          ])
          ..where(gamePlayers.gameId.equals(gameId))
          ..orderBy([OrderingTerm.asc(gamePlayers.orderIndex)]);

    return query.watch().map((rows) {
      return rows.map((r) {
        return (r.readTable(players), r.readTable(gamePlayers));
      }).toList();
    });
  }

  Future<List<(Player, GamePlayer)>> getGamePlayers(int gameId) async {
    final query =
        select(gamePlayers).join([
            innerJoin(players, players.id.equalsExp(gamePlayers.playerId)),
          ])
          ..where(gamePlayers.gameId.equals(gameId))
          ..orderBy([OrderingTerm.asc(gamePlayers.orderIndex)]);

    final rows = await query.get();
    return rows.map((r) {
      return (r.readTable(players), r.readTable(gamePlayers));
    }).toList();
  }

  Future<int> getPlayerCount(int gameId) async {
    final result = await (select(
      gamePlayers,
    )..where((gp) => gp.gameId.equals(gameId))).get();
    return result.length;
  }

  Future<void> updateGamePlayerOrder(int gamePlayerId, int orderIndex) {
    return (update(gamePlayers)..where((gp) => gp.id.equals(gamePlayerId)))
        .write(GamePlayersCompanion(orderIndex: Value(orderIndex)));
  }

  Future<GameType?> getGameTypeById(int? gameTypeId) async {
    if (gameTypeId == null) return null;
    return (select(
      gameTypes,
    )..where((t) => t.id.equals(gameTypeId))).getSingleOrNull();
  }
}
