import 'package:drift/native.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/exception/domain_exception.dart';
import 'package:scoreio/common/exception/exception_mapper.dart';
import 'package:scoreio/features/home/presentation/cubit/home_state.dart';

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
        .watchGamesWithMetadata()
        .map((rows) {
          return rows
              .map(
                (r) => GameWithPlayerCount(
                  game: r.$1,
                  playerCount: r.$2,
                  gameType: r.$3,
                ),
              )
              .toList();
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
