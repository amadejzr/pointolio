import 'package:drift/native.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/exception_mapper.dart';

class CreateGameRepository {
  const CreateGameRepository(this._db);
  final AppDatabase _db;

  // Game
  Future<int> createGame({
    required String name,
    required int gameTypeId,
    required String gameTypeName,
    required List<int> playerIds,
    DateTime? gameDate,
    String? note,
  }) async {
    try {
      return await _db.gameDao.createGame(
        name: name,
        gameTypeId: gameTypeId,
        gameTypeName: gameTypeName,
        playerIds: playerIds,
        gameDate: gameDate,
        note: note,
      );
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'createGame',
        context: {'name': name, 'gameTypeId': gameTypeId},
      );
    }
  }

  // Game Types
  Future<List<GameType>> getAllGameTypes() async {
    try {
      return await _db.gameTypeDao.getAll();
    } on SqliteException catch (e) {
      throw e.toDomainException(operation: 'getAllGameTypes');
    }
  }

  Future<GameType?> getGameTypeById(int id) async {
    try {
      return await _db.gameTypeDao.getById(id);
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'getGameTypeById',
        context: {'id': id},
      );
    }
  }

  Future<int> addGameType({
    required String name,
    bool lowestScoreWins = false,
    int? color,
  }) async {
    try {
      final existing = await _db.gameTypeDao.getByName(name);
      if (existing != null) return existing.id;
      return await _db.gameTypeDao.add(
        name: name,
        lowestScoreWins: lowestScoreWins,
        color: color,
      );
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'addGameType',
        context: {'name': name},
      );
    }
  }

  // Players
  Future<List<Player>> getAllPlayers({bool includeArchived = false}) async {
    try {
      return await _db.playerDao.getAll(includeArchived: includeArchived);
    } on SqliteException catch (e) {
      throw e.toDomainException(operation: 'getAllPlayers');
    }
  }

  Future<Player?> getPlayerById(int id) async {
    try {
      return await _db.playerDao.getById(id);
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'getPlayerById',
        context: {'id': id},
      );
    }
  }

  Future<int> addPlayer({
    required String firstName,
    String? lastName,
    int? color,
  }) async {
    try {
      final existing = await _db.playerDao.getByName(firstName, lastName);
      if (existing != null) return existing.id;
      return await _db.playerDao.add(
        firstName: firstName,
        lastName: lastName,
        color: color,
      );
    } on SqliteException catch (e) {
      throw e.toDomainException(
        operation: 'addPlayer',
        context: {'firstName': firstName},
      );
    }
  }
}
