import 'package:drift/native.dart';
import 'package:scoreio/common/data/dao/scoring_dao.dart';
import 'package:scoreio/common/data/database/database.dart';
import 'package:scoreio/common/exception/domain_exception.dart';
import 'package:scoreio/common/exception/exception_mapper.dart';
import 'package:scoreio/features/scoring/domain/models.dart';

class ScoringRepository {
  const ScoringRepository(this._db);

  final AppDatabase _db;

  ScoringDao get _dao => _db.scoringDao;

  Future<Game?> getGame(int gameId) async {
    try {
      return await _dao.getGame(gameId);
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'getGame',
        context: {'gameId': gameId},
      );
    }
  }

  Future<GameType?> getGameType(int? gameTypeId) async {
    try {
      return await _dao.getGameType(gameTypeId);
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'getGameType',
        context: {'gameTypeId': gameTypeId},
      );
    }
  }

  Stream<List<(Player, GamePlayer)>> watchGamePlayers(int gameId) {
    return _dao.watchGamePlayers(gameId).handleError(
      (Object e) {
        if (e is SqliteException) {
          throw e.toDomainException(
            operation: 'watchGamePlayers',
            context: {'gameId': gameId},
          );
        }
        throw DomainException(
          DomainErrorCode.storage,
          context: {'op': 'watchGamePlayers', 'gameId': gameId},
          cause: e,
        );
      },
    );
  }

  Stream<List<ScoreEntry>> watchScoreEntries(int gameId) {
    return _dao.watchScoreEntries(gameId).handleError(
      (Object e) {
        if (e is SqliteException) {
          throw e.toDomainException(
            operation: 'watchScoreEntries',
            context: {'gameId': gameId},
          );
        }
        throw DomainException(
          DomainErrorCode.storage,
          context: {'op': 'watchScoreEntries', 'gameId': gameId},
          cause: e,
        );
      },
    );
  }

  Future<List<PlayerScore>> getPlayerScores(int gameId) async {
    try {
      final data = await _dao.getScoringData(gameId);
      if (data == null) return [];

      return data.playerScores.map((pws) {
        final roundScores = <int, ScoreEntry>{};
        var total = 0;

        for (final entry in pws.scores) {
          roundScores[entry.roundNumber] = entry;
          total += entry.points;
        }

        return PlayerScore(
          player: pws.player,
          gamePlayer: pws.gamePlayer,
          roundScores: roundScores,
          total: total,
        );
      }).toList();
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'getPlayerScores',
        context: {'gameId': gameId},
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'getPlayerScores', 'gameId': gameId},
        cause: e,
      );
    }
  }

  Future<void> addRound({
    required int roundNumber,
    required Map<int, int> scores,
  }) async {
    try {
      await _dao.addRound(roundNumber: roundNumber, scores: scores);
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'addRound',
        context: {'roundNumber': roundNumber},
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'addRound', 'roundNumber': roundNumber},
        cause: e,
      );
    }
  }

  Future<void> updateScore({
    required int scoreEntryId,
    required int points,
  }) async {
    try {
      await _dao.updateScore(scoreEntryId: scoreEntryId, points: points);
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'updateScore',
        context: {'scoreEntryId': scoreEntryId, 'points': points},
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'updateScore', 'scoreEntryId': scoreEntryId},
        cause: e,
      );
    }
  }

  Future<void> deleteRound({
    required int gameId,
    required int roundNumber,
  }) async {
    try {
      final deleted = await _dao.deleteRound(
        gameId: gameId,
        roundNumber: roundNumber,
      );
      if (deleted == 0) {
        throw DomainException(
          DomainErrorCode.notFound,
          context: {
            'op': 'deleteRound',
            'gameId': gameId,
            'roundNumber': roundNumber,
          },
        );
      }
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'deleteRound',
        context: {'gameId': gameId, 'roundNumber': roundNumber},
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {
          'op': 'deleteRound',
          'gameId': gameId,
          'roundNumber': roundNumber,
        },
        cause: e,
      );
    }
  }

  Future<void> reorderPlayers(List<int> gamePlayerIds) async {
    try {
      await _dao.reorderPlayers(gamePlayerIds);
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'reorderPlayers',
        context: {'gamePlayerIds': gamePlayerIds},
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'reorderPlayers', 'gamePlayerIds': gamePlayerIds},
        cause: e,
      );
    }
  }

  Future<void> setGameFinished(int gameId, {required bool finished}) async {
    try {
      final updated = await _dao.setGameFinished(gameId, finished: finished);
      if (updated == 0) {
        throw DomainException(
          DomainErrorCode.notFound,
          context: {'op': 'setGameFinished', 'gameId': gameId},
        );
      }
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'setGameFinished',
        context: {'gameId': gameId, 'finished': finished},
      );
    } on DomainException {
      rethrow;
    } on Object catch (e) {
      throw DomainException(
        DomainErrorCode.storage,
        context: {'op': 'setGameFinished', 'gameId': gameId},
        cause: e,
      );
    }
  }
}
