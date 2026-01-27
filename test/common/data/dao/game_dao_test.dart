// test/common/data/dao/game_dao_test.dart
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/dao/game_dao.dart'; // <-- adjust path
import 'package:pointolio/common/data/database/database.dart';

import '../../../utils/db_util.dart';

// <-- your createTestDb()

void main() {
  late AppDatabase db;
  late GameDao dao;

  setUp(() {
    db = createTestDb();
    dao = db.gameDao; // if not exposed: dao = GameDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insertGameType({
    required String name,
    bool lowestScoreWins = false,
    int? color,
  }) {
    return db.gameTypeDao.add(
      name: name,
      lowestScoreWins: lowestScoreWins,
      color: color,
    );
    // If you don't expose db.gameTypeDao, do:
    // return GameTypeDao(db).add(...)
  }

  Future<int> insertPlayer({required String firstName, String? lastName}) {
    return db.playerDao.add(firstName: firstName, lastName: lastName);
    // If not exposed: return PlayerDao(db).add(...)
  }

  group('getAll / watchAll', () {
    test('getAll orders by gameDate desc', () async {
      final typeId = await insertGameType(name: 'Poker');

      final idOld = await dao.insertGame(
        GamesCompanion.insert(
          name: 'Old',
          gameDate: Value(DateTime(2024)),
          gameTypeId: Value(typeId),
          gameTypeNameSnapshot: const Value('Poker'),
        ),
      );

      final idNew = await dao.insertGame(
        GamesCompanion.insert(
          name: 'New',
          gameDate: Value(DateTime(2025)),
          gameTypeId: Value(typeId),
          gameTypeNameSnapshot: const Value('Poker'),
        ),
      );

      final all = await dao.getAll();
      expect(all.map((g) => g.id).toList(), [idNew, idOld]);
    });

    test('watchAll emits ordered list and updates on insert', () async {
      final typeId = await insertGameType(name: 'Poker');

      final events = <List<Game>>[];
      final sub = dao.watchAll().listen(events.add);

      await Future<void>.delayed(Duration.zero);

      await dao.insertGame(
        GamesCompanion.insert(
          name: 'A',
          gameDate: Value(DateTime(2024)),
          gameTypeId: Value(typeId),
          gameTypeNameSnapshot: const Value('Poker'),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      await dao.insertGame(
        GamesCompanion.insert(
          name: 'B',
          gameDate: Value(DateTime(2025)),
          gameTypeId: Value(typeId),
          gameTypeNameSnapshot: const Value('Poker'),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final latest = events.last;
      expect(latest.map((g) => g.name).toList(), ['B', 'A']);

      await sub.cancel();
    });
  });

  group('getById / insertGame / updateGame / deleteGame', () {
    test('getById returns inserted game', () async {
      final typeId = await insertGameType(name: 'Chess');

      final id = await dao.insertGame(
        GamesCompanion.insert(
          name: 'My Game',
          gameDate: Value(DateTime(2025, 2, 2)),
          gameTypeId: Value(typeId),
          gameTypeNameSnapshot: const Value('Chess'),
        ),
      );

      final g = await dao.getById(id);
      expect(g, isNotNull);
      expect(g!.id, id);
      expect(
        g.name,
        'My Game',
      ); // Drift insert doesn't trim; your createGame trims.
    });

    test('updateGame updates fields', () async {
      final typeId = await insertGameType(name: 'Poker');

      final id = await dao.insertGame(
        GamesCompanion.insert(
          name: 'Game',
          gameDate: Value(DateTime(2025)),
          gameTypeId: Value(typeId),
          gameTypeNameSnapshot: const Value('Poker'),
        ),
      );

      await dao.updateGame(
        id,
        const GamesCompanion(
          note: Value('hello'),
        ),
      );

      final g = await dao.getById(id);
      expect(g!.note, 'hello');
    });

    test(
      'deleteGame deletes and returns 1; subsequent getById is null',
      () async {
        final typeId = await insertGameType(name: 'Poker');

        final id = await dao.insertGame(
          GamesCompanion.insert(
            name: 'Game',
            gameDate: Value(DateTime(2025)),
            gameTypeId: Value(typeId),
            gameTypeNameSnapshot: const Value('Poker'),
          ),
        );

        final deleted = await dao.deleteGame(id);
        expect(deleted, 1);

        final g = await dao.getById(id);
        expect(g, isNull);
      },
    );

    test('deleteGame returns 0 for non-existent id', () async {
      final deleted = await dao.deleteGame(999999);
      expect(deleted, 0);
    });
  });

  group('createGame', () {
    test('creates a game and gamePlayers with orderIndex', () async {
      final typeId = await insertGameType(name: 'Poker');
      final p1 = await insertPlayer(firstName: 'Amy');
      final p2 = await insertPlayer(firstName: 'Bob');
      final p3 = await insertPlayer(firstName: 'Cory');

      final gameId = await dao.createGame(
        name: '  Friday Night  ',
        gameTypeId: typeId,
        gameTypeName: 'Poker',
        playerIds: [p2, p1, p3],
        gameDate: DateTime(2025, 1, 10),
        note: '  note  ',
      );

      final game = await dao.getById(gameId);
      expect(game, isNotNull);
      expect(game!.name, 'Friday Night');
      expect(game.note, 'note');
      expect(game.gameTypeId, typeId);
      expect(game.gameTypeNameSnapshot, 'Poker');
      expect(game.gameDate, DateTime(2025, 1, 10));

      final players = await dao.getGamePlayers(gameId);
      expect(players.map((t) => t.$1.id).toList(), [
        p2,
        p1,
        p3,
      ]); // ordered by orderIndex
      expect(players.map((t) => t.$2.orderIndex).toList(), [0, 1, 2]);
    });

    test(
      'uses insertOrIgnore for duplicate playerIds (no duplicates inserted)',
      () async {
        final typeId = await insertGameType(name: 'Poker');
        final p1 = await insertPlayer(firstName: 'Amy');

        final gameId = await dao.createGame(
          name: 'Game',
          gameTypeId: typeId,
          gameTypeName: 'Poker',
          playerIds: [p1, p1, p1],
          gameDate: DateTime(2025),
        );

        final rows = await (db.select(
          db.gamePlayers,
        )..where((gp) => gp.gameId.equals(gameId))).get();

        expect(rows.length, 1);
        expect(rows.single.playerId, p1);
        expect(rows.single.orderIndex, 0);
      },
    );
  });

  group('game players (watch/get/count/order/insert)', () {
    test('insertGamePlayer insertOrIgnore prevents duplicates', () async {
      final typeId = await insertGameType(name: 'Poker');
      final playerId = await insertPlayer(firstName: 'Amy');

      final gameId = await dao.insertGame(
        GamesCompanion.insert(
          name: 'Game',
          gameDate: Value(DateTime(2025)),
          gameTypeId: Value(typeId),
          gameTypeNameSnapshot: const Value('Poker'),
        ),
      );

      await dao.insertGamePlayer(
        GamePlayersCompanion.insert(
          gameId: gameId,
          playerId: playerId,
          orderIndex: const Value(0),
        ),
      );

      // duplicate
      await dao.insertGamePlayer(
        GamePlayersCompanion.insert(
          gameId: gameId,
          playerId: playerId,
          orderIndex: const Value(0),
        ),
      );

      final rows = await (db.select(
        db.gamePlayers,
      )..where((gp) => gp.gameId.equals(gameId))).get();

      expect(rows.length, 1);
    });

    test(
      'getPlayerCount returns number of gamePlayers rows for game',
      () async {
        final typeId = await insertGameType(name: 'Poker');
        final p1 = await insertPlayer(firstName: 'Amy');
        final p2 = await insertPlayer(firstName: 'Bob');

        final gameId = await dao.createGame(
          name: 'Game',
          gameTypeId: typeId,
          gameTypeName: 'Poker',
          playerIds: [p1, p2],
          gameDate: DateTime(2025),
        );

        final count = await dao.getPlayerCount(gameId);
        expect(count, 2);
      },
    );

    test(
      'getGamePlayers returns joined (Player, GamePlayer) '
      'ordered by orderIndex',
      () async {
        final typeId = await insertGameType(name: 'Poker');
        final p1 = await insertPlayer(firstName: 'Amy');
        final p2 = await insertPlayer(firstName: 'Bob');

        final gameId = await dao.createGame(
          name: 'Game',
          gameTypeId: typeId,
          gameTypeName: 'Poker',
          playerIds: [p2, p1],
          gameDate: DateTime(2025),
        );

        final res = await dao.getGamePlayers(gameId);
        expect(res.map((t) => t.$1.firstName).toList(), ['Bob', 'Amy']);
        expect(res.map((t) => t.$2.orderIndex).toList(), [0, 1]);
      },
    );

    test('watchGamePlayers emits joined rows and updates', () async {
      final typeId = await insertGameType(name: 'Poker');
      final p1 = await insertPlayer(firstName: 'Amy');
      final p2 = await insertPlayer(firstName: 'Bob');

      final gameId = await dao.createGame(
        name: 'Game',
        gameTypeId: typeId,
        gameTypeName: 'Poker',
        playerIds: [p1],
        gameDate: DateTime(2025),
      );

      final events = <List<(Player, GamePlayer)>>[];
      final sub = dao.watchGamePlayers(gameId).listen(events.add);

      await Future<void>.delayed(Duration.zero);

      await dao.insertGamePlayer(
        GamePlayersCompanion.insert(
          gameId: gameId,
          playerId: p2,
          orderIndex: const Value(1),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final latest = events.last;
      expect(latest.map((t) => t.$1.id).toList(), [p1, p2]);

      await sub.cancel();
    });

    test('updateGamePlayerOrder updates orderIndex', () async {
      final typeId = await insertGameType(name: 'Poker');
      final p1 = await insertPlayer(firstName: 'Amy');
      final p2 = await insertPlayer(firstName: 'Bob');

      final gameId = await dao.createGame(
        name: 'Game',
        gameTypeId: typeId,
        gameTypeName: 'Poker',
        playerIds: [p1, p2],
        gameDate: DateTime(2025),
      );

      final before = await dao.getGamePlayers(gameId);
      final gpBob = before
          .firstWhere((t) => t.$1.id == p1)
          .$2; // p1 order 0 initially
      await dao.updateGamePlayerOrder(gpBob.id, 5);

      final after = await dao.getGamePlayers(gameId);
      final updated = after.firstWhere((t) => t.$2.id == gpBob.id).$2;
      expect(updated.orderIndex, 5);
    });
  });

  group('getGameTypeById', () {
    test('returns null if gameTypeId is null', () async {
      final gt = await dao.getGameTypeById(null);
      expect(gt, isNull);
    });

    test('returns GameType for id', () async {
      final id = await insertGameType(name: 'Chess');
      final gt = await dao.getGameTypeById(id);
      expect(gt, isNotNull);
      expect(gt!.id, id);
      expect(gt.name, 'Chess');
    });
  });

  group('setGameFinished', () {
    test('sets finishedAt to non-null when finished=true', () async {
      final typeId = await insertGameType(name: 'Poker');

      final gameId = await dao.insertGame(
        GamesCompanion.insert(
          name: 'Game',
          gameDate: Value(DateTime(2025)),
          gameTypeId: Value(typeId),
          gameTypeNameSnapshot: const Value('Poker'),
        ),
      );

      final updated = await dao.setGameFinished(gameId, finished: true);
      expect(updated, 1);

      final g = await dao.getById(gameId);
      expect(g!.finishedAt, isNotNull);
    });

    test('sets finishedAt to null when finished=false', () async {
      final typeId = await insertGameType(name: 'Poker');

      final gameId = await dao.insertGame(
        GamesCompanion.insert(
          name: 'Game',
          gameDate: Value(DateTime(2025)),
          gameTypeId: Value(typeId),
          gameTypeNameSnapshot: const Value('Poker'),
        ),
      );

      await dao.setGameFinished(gameId, finished: true);
      final updated = await dao.setGameFinished(gameId, finished: false);
      expect(updated, 1);

      final g = await dao.getById(gameId);
      expect(g!.finishedAt, isNull);
    });

    test('returns 0 for non-existent id', () async {
      final updated = await dao.setGameFinished(999999, finished: true);
      expect(updated, 0);
    });
  });

  group('watchGamesWithMetadata', () {
    test(
      'returns tuples (Game, playerCount, GameType?) with correct counts',
      () async {
        final typeId = await insertGameType(name: 'Poker');
        final p1 = await insertPlayer(firstName: 'Amy');
        final p2 = await insertPlayer(firstName: 'Bob');

        final gameId = await dao.createGame(
          name: 'Game',
          gameTypeId: typeId,
          gameTypeName: 'Poker',
          playerIds: [p1, p2],
          gameDate: DateTime(2025),
        );

        final events = <List<(Game, int, GameType?)>>[];
        final sub = dao.watchGamesWithMetadata().listen(events.add);

        await Future<void>.delayed(Duration.zero);

        // Ensure we see at least one emission containing our game
        final latest = events.last;
        final tuple = latest.firstWhere((t) => t.$1.id == gameId);

        expect(tuple.$2, 2); // playerCount
        expect(tuple.$3, isNotNull);
        expect(tuple.$3!.id, typeId);
        expect(tuple.$3!.name, 'Poker');

        await sub.cancel();
      },
    );

    test('playerCount is 0 when no players exist', () async {
      final typeId = await insertGameType(name: 'Poker');

      final gameId = await dao.insertGame(
        GamesCompanion.insert(
          name: 'Game',
          gameDate: Value(DateTime(2025)),
          gameTypeId: Value(typeId),
          gameTypeNameSnapshot: const Value('Poker'),
        ),
      );

      final events = <List<(Game, int, GameType?)>>[];
      final sub = dao.watchGamesWithMetadata().listen(events.add);

      await Future<void>.delayed(Duration.zero);

      final tuple = events.last.firstWhere((t) => t.$1.id == gameId);
      expect(tuple.$2, 0);

      await sub.cancel();
    });
  });
}
