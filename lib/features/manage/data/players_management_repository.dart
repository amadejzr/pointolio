import 'package:drift/native.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/common/exception/exception_mapper.dart';

class PlayersManagementRepository {
  const PlayersManagementRepository(this._db);
  final AppDatabase _db;

  Stream<List<Player>> watchAllPlayers({bool includeArchived = false}) {
    return _db.playerDao.watchAll(includeArchived: includeArchived).handleError(
      (Object e) {
        if (e is SqliteException) {
          throw e.toDomainException(operation: 'watchAllPlayers');
        }
        throw DomainException(
          DomainErrorCode.storage,
          context: {'op': 'watchAllPlayers'},
          cause: e,
        );
      },
    );
  }

  Future<void> addPlayer({
    required String firstName,
    String? lastName,
    int? color,
  }) async {
    try {
      await _db.playerDao.add(
        firstName: firstName,
        lastName: lastName,
        color: color,
      );
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'addPlayer',
        context: {'firstName': firstName, 'lastName': lastName, 'color': color},
      );
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {
          'op': 'addPlayer',
          'firstName': firstName,
          'lastName': lastName,
          'color': color,
        },
        cause: e,
      );
    }
  }

  Future<void> updatePlayer(
    int id, {
    required String firstName,
    String? lastName,
    int? color,
  }) async {
    try {
      final updated = await _db.playerDao.updatePlayer(
        id,
        firstName: firstName,
        lastName: lastName,
        color: color,
      );
      if (updated == 0) {
        throw DomainException(
          DomainErrorCode.notFound,
          context: {'op': 'updatePlayer', 'playerId': id},
        );
      }
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'updatePlayer',
        context: {
          'playerId': id,
          'firstName': firstName,
          'lastName': lastName,
          'color': color,
        },
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'updatePlayer', 'playerId': id},
        cause: e,
      );
    }
  }

  Future<void> deletePlayer(int id) async {
    try {
      final deleted = await _db.playerDao.deletePlayer(id);
      if (deleted == 0) {
        throw DomainException(
          DomainErrorCode.notFound,
          context: {'op': 'deletePlayer', 'playerId': id},
        );
      }
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'deletePlayer',
        context: {'playerId': id},
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'deletePlayer', 'playerId': id},
        cause: e,
      );
    }
  }
}
