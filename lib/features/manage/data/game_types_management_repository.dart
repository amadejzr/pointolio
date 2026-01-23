import 'package:drift/native.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/common/exception/exception_mapper.dart';

class GameTypesManagementRepository {
  const GameTypesManagementRepository(this._db);
  final AppDatabase _db;

  Stream<List<GameType>> watchAllGameTypes() {
    return _db.gameTypeDao.watchAll().handleError(
      (Object e) {
        if (e is SqliteException) {
          throw e.toDomainException(operation: 'watchAllGameTypes');
        }
        throw DomainException(
          DomainErrorCode.storage,
          context: {'op': 'watchAllGameTypes'},
          cause: e,
        );
      },
    );
  }

  Future<void> addGameType({
    required String name,
    required bool lowestScoreWins,
    int? color,
  }) async {
    try {
      await _db.gameTypeDao.add(
        name: name,
        lowestScoreWins: lowestScoreWins,
        color: color,
      );
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'addGameType',
        context: {
          'name': name,
          'lowestScoreWins': lowestScoreWins,
          'color': color,
        },
      );
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {
          'op': 'addGameType',
          'name': name,
          'lowestScoreWins': lowestScoreWins,
          'color': color,
        },
        cause: e,
      );
    }
  }

  Future<void> updateGameType(
    int id, {
    required String name,
    required bool lowestScoreWins,
    int? color,
  }) async {
    try {
      final updated = await _db.gameTypeDao.updateGameType(
        id,
        name: name,
        lowestScoreWins: lowestScoreWins,
        color: color,
      );
      if (updated == 0) {
        throw DomainException(
          DomainErrorCode.notFound,
          context: {'op': 'updateGameType', 'gameTypeId': id},
        );
      }
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'updateGameType',
        context: {
          'gameTypeId': id,
          'name': name,
          'lowestScoreWins': lowestScoreWins,
          'color': color,
        },
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'updateGameType', 'gameTypeId': id},
        cause: e,
      );
    }
  }

  Future<void> deleteGameType(int id) async {
    try {
      final deleted = await _db.gameTypeDao.deleteGameType(id);
      if (deleted == 0) {
        throw DomainException(
          DomainErrorCode.notFound,
          context: {'op': 'deleteGameType', 'gameTypeId': id},
        );
      }
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'deleteGameType',
        context: {'gameTypeId': id},
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'deleteGameType', 'gameTypeId': id},
        cause: e,
      );
    }
  }
}
