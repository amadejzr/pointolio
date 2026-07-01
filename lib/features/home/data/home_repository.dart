import 'package:drift/native.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/common/exception/exception_mapper.dart';
import 'package:pointolio/features/home/presentation/cubit/home_state.dart';

class HomeRepository {
  const HomeRepository(this._db);
  final AppDatabase _db;

  Future<void> deleteGame(int id) async {
    try {
      final deleted = await _db.gameDao.deleteGame(id);
      if (deleted == 0) {
        throw DomainException(
          DomainErrorCode.notFound,
          context: {'op': 'deleteGame', 'gameId': id},
        );
      }
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'deleteGame',
        context: {'gameId': id},
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'deleteGame', 'gameId': id},
        cause: e,
      );
    }
  }

  Stream<List<Game>> watchAllGames() {
    return _db.gameDao.watchAll().handleError(
      (Object e) {
        if (e is SqliteException) {
          throw e.toDomainException(
            operation: 'watchAllGames',
          );
        }
        throw DomainException(
          DomainErrorCode.storage,
          context: {'op': 'watchAllGames'},
          cause: e,
        );
      },
    );
  }

  Future<int> getPlayerCount(int gameId) async {
    try {
      return await _db.gameDao.getPlayerCount(gameId);
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'getPlayerCount',
        context: {'gameId': gameId},
      );
    }
  }

  Future<GameType?> getGameType(int? gameTypeId) async {
    try {
      return await _db.gameDao.getGameTypeById(gameTypeId);
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'getGameType',
        context: {'gameTypeId': gameTypeId},
      );
    }
  }

  Stream<List<GameWithPlayerCount>> watchGamesWithMetadata() {
    return _db.gameDao
        .watchGamesWithDetails()
        .map((rows) {
          return rows.map((r) {
            final (game, gameType, roster, roundCount) = r;
            return GameWithPlayerCount(
              game: game,
              playerCount: roster.length,
              gameType: gameType,
              players: roster.map((e) => e.$1).toList(),
              roundCount: roundCount,
              winnerName: _winnerName(game, gameType, roster, roundCount),
            );
          }).toList();
        })
        .handleError(
          (Object e) {
            if (e is SqliteException) {
              throw e.toDomainException(operation: 'watchGamesWithMetadata');
            }
            throw DomainException(
              DomainErrorCode.storage,
              context: {'op': 'watchGamesWithMetadata'},
              cause: e,
            );
          },
        );
  }

  /// The winning player's first name for a finished party, or null while it is
  /// still active or has no scores yet. Uses the game type's win rule.
  String? _winnerName(
    Game game,
    GameType? gameType,
    List<(Player, int)> roster,
    int roundCount,
  ) {
    if (game.finishedAt == null || roster.isEmpty || roundCount == 0) {
      return null;
    }
    final lowestWins = gameType?.lowestScoreWins ?? false;
    var best = roster.first;
    for (final entry in roster.skip(1)) {
      final betterScore = lowestWins
          ? entry.$2 < best.$2
          : entry.$2 > best.$2;
      if (betterScore) best = entry;
    }
    return best.$1.firstName;
  }

  Future<void> setGameFinished(int id, {required bool finished}) async {
    try {
      final updated = await _db.gameDao.setGameFinished(id, finished: finished);

      if (updated == 0) {
        throw DomainException(
          DomainErrorCode.notFound,
          context: {
            'op': 'setGameFinished',
            'gameId': id,
            'finished': finished,
          },
        );
      }
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'setGameFinished',
        context: {'gameId': id, 'finished': finished},
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'setGameFinished', 'gameId': id, 'finished': finished},
        cause: e,
      );
    }
  }
}
