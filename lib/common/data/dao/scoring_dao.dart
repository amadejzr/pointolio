import 'package:drift/drift.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/data/tables/game_players_table.dart';
import 'package:pointolio/common/data/tables/games_table.dart';
import 'package:pointolio/common/data/tables/player_table.dart';
import 'package:pointolio/common/data/tables/score_entries_table.dart';

part 'scoring_dao.g.dart';

/// Data class for a player with their scores in a game.
class PlayerWithScores {
  const PlayerWithScores({
    required this.player,
    required this.gamePlayer,
    required this.scores,
  });

  final Player player;
  final GamePlayer gamePlayer;
  final List<ScoreEntry> scores;
}

/// Full scoring data for a game including game info, game type, and all
/// player scores.
class ScoringData {
  const ScoringData({
    required this.playerScores,
    required this.game,
    this.gameType,
  });

  final Game game;
  final GameType? gameType;
  final List<PlayerWithScores> playerScores;
}

@DriftAccessor(tables: [Games, GameTypes, Players, GamePlayers, ScoreEntries])
class ScoringDao extends DatabaseAccessor<AppDatabase> with _$ScoringDaoMixin {
  ScoringDao(super.attachedDatabase);

  /// Fetches complete scoring data for a game in a single query operation.
  /// Returns game, game type, players with their scores.
  Future<ScoringData?> getScoringData(int gameId) async {
    // Get game
    final game = await (select(
      games,
    )..where((g) => g.id.equals(gameId))).getSingleOrNull();
    if (game == null) return null;

    // Get game type
    final gameType = game.gameTypeId != null
        ? await (select(
            gameTypes,
          )..where((t) => t.id.equals(game.gameTypeId!))).getSingleOrNull()
        : null;

    // Get players with scores in one joined query
    final playerScores = await _getPlayersWithScores(gameId);

    return ScoringData(
      game: game,
      gameType: gameType,
      playerScores: playerScores,
    );
  }

  /// Gets all players for a game with their score entries.
  Future<List<PlayerWithScores>> _getPlayersWithScores(int gameId) async {
    // First get players
    final playersQuery =
        select(gamePlayers).join([
            innerJoin(players, players.id.equalsExp(gamePlayers.playerId)),
          ])
          ..where(gamePlayers.gameId.equals(gameId))
          ..orderBy([OrderingTerm.asc(gamePlayers.orderIndex)]);

    final playerRows = await playersQuery.get();

    // Get all scores for this game
    final scoresQuery =
        select(scoreEntries).join([
            innerJoin(
              gamePlayers,
              gamePlayers.id.equalsExp(scoreEntries.gamePlayerId),
            ),
          ])
          ..where(gamePlayers.gameId.equals(gameId))
          ..orderBy([
            OrderingTerm.asc(scoreEntries.roundNumber),
            OrderingTerm.asc(gamePlayers.orderIndex),
          ]);

    final scoreRows = await scoresQuery.get();

    // Group scores by gamePlayerId
    final scoresByGamePlayer = <int, List<ScoreEntry>>{};
    for (final row in scoreRows) {
      final entry = row.readTable(scoreEntries);
      scoresByGamePlayer.putIfAbsent(entry.gamePlayerId, () => []).add(entry);
    }

    // Build result
    return playerRows.map((row) {
      final player = row.readTable(players);
      final gamePlayer = row.readTable(gamePlayers);
      return PlayerWithScores(
        player: player,
        gamePlayer: gamePlayer,
        scores: scoresByGamePlayer[gamePlayer.id] ?? [],
      );
    }).toList();
  }

  /// Watches players for a game (for reactive updates when players change).
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

  /// Watches score entries for a game
  /// (for reactive updates when scores change).
  Stream<List<ScoreEntry>> watchScoreEntries(int gameId) {
    final q =
        select(scoreEntries).join([
            innerJoin(
              gamePlayers,
              gamePlayers.id.equalsExp(scoreEntries.gamePlayerId),
            ),
          ])
          ..where(gamePlayers.gameId.equals(gameId))
          ..orderBy([
            OrderingTerm.asc(scoreEntries.roundNumber),
            OrderingTerm.asc(gamePlayers.orderIndex),
          ]);

    return q.watch().map(
      (rows) => rows.map((r) => r.readTable(scoreEntries)).toList(),
    );
  }

  /// Adds a round of scores for multiple players in a batch.
  Future<void> addRound({
    required int roundNumber,
    required Map<int, int> scores, // gamePlayerId -> points
  }) {
    return batch((b) {
      for (final entry in scores.entries) {
        b.insert(
          scoreEntries,
          ScoreEntriesCompanion.insert(
            gamePlayerId: entry.key,
            roundNumber: roundNumber,
            points: entry.value,
          ),
        );
      }
    });
  }

  /// Updates a score entry's points.
  Future<void> updateScore({required int scoreEntryId, required int points}) {
    return (update(scoreEntries)..where((e) => e.id.equals(scoreEntryId)))
        .write(ScoreEntriesCompanion(points: Value(points)));
  }

  /// Deletes all scores for a specific round in a game.
  Future<int> deleteRound({required int gameId, required int roundNumber}) {
    final gpIds = selectOnly(gamePlayers)
      ..addColumns([gamePlayers.id])
      ..where(gamePlayers.gameId.equals(gameId));

    return (delete(scoreEntries)..where(
          (e) =>
              e.roundNumber.equals(roundNumber) &
              e.gamePlayerId.isInQuery(gpIds),
        ))
        .go();
  }

  /// Reorders players in a game by updating their orderIndex values.
  Future<void> reorderPlayers(List<int> gamePlayerIds) {
    return batch((b) {
      for (var i = 0; i < gamePlayerIds.length; i++) {
        b.update(
          gamePlayers,
          GamePlayersCompanion(orderIndex: Value(i)),
          where: (gp) => gp.id.equals(gamePlayerIds[i]),
        );
      }
    });
  }

  /// Gets game by ID.
  Future<Game?> getGame(int gameId) {
    return (select(games)..where((g) => g.id.equals(gameId))).getSingleOrNull();
  }

  /// Gets game type by ID.
  Future<GameType?> getGameType(int? gameTypeId) {
    if (gameTypeId == null) return Future.value();
    return (select(
      gameTypes,
    )..where((t) => t.id.equals(gameTypeId))).getSingleOrNull();
  }

  /// Sets the game as finished or restores it to active.
  /// Returns the number of rows updated (0 if game not found).
  Future<int> setGameFinished(int gameId, {required bool finished}) {
    return (update(games)..where((g) => g.id.equals(gameId))).write(
      GamesCompanion(
        finishedAt: Value(finished ? DateTime.now() : null),
      ),
    );
  }

  /// Updates a game's name and player list in a single transaction.
  ///
  /// - Updates the game name
  /// - Removes players that are no longer in the list
  /// - Adds new players that weren't in the list before
  /// - Reorders existing players to match the new order
  Future<void> updateGameParty({
    required int gameId,
    required String name,
    required List<int> playerIds,
  }) {
    return transaction(() async {
      // Update game name
      await (update(games)..where((g) => g.id.equals(gameId))).write(
        GamesCompanion(name: Value(name.trim())),
      );

      // Get current game players
      final currentGamePlayers = await (select(gamePlayers)
            ..where((gp) => gp.gameId.equals(gameId)))
          .get();

      final currentPlayerIds =
          currentGamePlayers.map((gp) => gp.playerId).toSet();
      final newPlayerIds = playerIds.toSet();

      // Remove players that are no longer in the list
      final toRemove = currentPlayerIds.difference(newPlayerIds);
      if (toRemove.isNotEmpty) {
        await (delete(gamePlayers)
              ..where(
                (gp) =>
                    gp.gameId.equals(gameId) & gp.playerId.isIn(toRemove),
              ))
            .go();
      }

      // Add new players
      final toAdd = newPlayerIds.difference(currentPlayerIds);
      for (final playerId in toAdd) {
        await into(gamePlayers).insert(
          GamePlayersCompanion.insert(
            gameId: gameId,
            playerId: playerId,
            orderIndex: const Value(999), // Will be fixed by reorder below
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }

      // Reorder all players to match the new order
      for (var i = 0; i < playerIds.length; i++) {
        await (update(gamePlayers)
              ..where(
                (gp) =>
                    gp.gameId.equals(gameId) &
                    gp.playerId.equals(playerIds[i]),
              ))
            .write(GamePlayersCompanion(orderIndex: Value(i)));
      }
    });
  }
}
