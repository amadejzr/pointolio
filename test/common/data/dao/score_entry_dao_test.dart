import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/dao/score_entry_dao.dart';
import 'package:pointolio/common/data/database/database.dart';

import '../../../utils/db_util.dart';
import '../../../utils/fixtures.dart';

void main() {
  late AppDatabase db;
  late ScoreEntryDao dao;
  late SeededGame seeded;

  // GamePlayers join-row ids for the two seeded players (Amy=0, Bob=1).
  late int amyGp;
  late int bobGp;

  setUp(() async {
    db = createTestDb();
    dao = db.scoreEntryDao;
    // A game with two players (Amy=orderIndex 0, Bob=orderIndex 1).
    seeded = await seedGame(db);
    amyGp = seeded.gamePlayerIds[0];
    bobGp = seeded.gamePlayerIds[1];
  });

  tearDown(() async {
    await db.close();
  });

  group('insertEntry / getByGameId', () {
    test('inserts and reads back an entry', () async {
      final id = await dao.insertEntry(
        gamePlayerId: amyGp,
        roundNumber: 1,
        points: 50,
      );

      final entries = await dao.getByGameId(seeded.gameId);
      expect(entries, hasLength(1));
      expect(entries.single.id, id);
      expect(entries.single.points, 50);
      expect(entries.single.roundNumber, 1);
    });

    test('points can be negative', () async {
      await dao.insertEntry(gamePlayerId: amyGp, roundNumber: 1, points: -30);
      final entries = await dao.getByGameId(seeded.gameId);
      expect(entries.single.points, -30);
    });

    test(
      'orders by roundNumber asc then player orderIndex asc',
      () async {
        // Insert deliberately out of order.
        await dao.insertEntry(gamePlayerId: bobGp, roundNumber: 2, points: 1);
        await dao.insertEntry(gamePlayerId: amyGp, roundNumber: 2, points: 2);
        await dao.insertEntry(gamePlayerId: bobGp, roundNumber: 1, points: 3);
        await dao.insertEntry(gamePlayerId: amyGp, roundNumber: 1, points: 4);

        final entries = await dao.getByGameId(seeded.gameId);
        // Round 1 (Amy then Bob), then round 2 (Amy then Bob).
        expect(
          entries.map((e) => (e.roundNumber, e.gamePlayerId)).toList(),
          [(1, amyGp), (1, bobGp), (2, amyGp), (2, bobGp)],
        );
      },
    );

    test('only returns entries belonging to the requested game', () async {
      final other = await seedGame(
        db,
        name: 'Other',
        gameTypeName: 'Chess',
        playerNames: const ['Cory', 'Dana'],
      );
      await dao.insertEntry(gamePlayerId: amyGp, roundNumber: 1, points: 10);
      await dao.insertEntry(
        gamePlayerId: other.gamePlayerIds[0],
        roundNumber: 1,
        points: 99,
      );

      final entries = await dao.getByGameId(seeded.gameId);
      expect(entries, hasLength(1));
      expect(entries.single.points, 10);
    });

    test('duplicate (gamePlayer, round) violates unique key', () async {
      await dao.insertEntry(gamePlayerId: amyGp, roundNumber: 1, points: 10);
      expect(
        () => dao.insertEntry(gamePlayerId: amyGp, roundNumber: 1, points: 20),
        throwsA(anything),
      );
    });
  });

  group('updatePoints', () {
    test('updates the points of an existing entry', () async {
      final id = await dao.insertEntry(
        gamePlayerId: amyGp,
        roundNumber: 1,
        points: 10,
      );

      await dao.updatePoints(id: id, points: 75);

      final entries = await dao.getByGameId(seeded.gameId);
      expect(entries.single.points, 75);
    });

    test('no-op for a non-existent id', () async {
      await dao.updatePoints(id: 999999, points: 1);
      final entries = await dao.getByGameId(seeded.gameId);
      expect(entries, isEmpty);
    });
  });

  group('deleteEntry', () {
    test('deletes and returns 1', () async {
      final id = await dao.insertEntry(
        gamePlayerId: amyGp,
        roundNumber: 1,
        points: 10,
      );

      final deleted = await dao.deleteEntry(id);
      expect(deleted, 1);
      expect(await dao.getByGameId(seeded.gameId), isEmpty);
    });

    test('returns 0 for a non-existent id', () async {
      expect(await dao.deleteEntry(999999), 0);
    });
  });

  group('deleteRoundForGame', () {
    test('deletes all entries for a round across players', () async {
      await dao.insertEntry(gamePlayerId: amyGp, roundNumber: 1, points: 1);
      await dao.insertEntry(gamePlayerId: bobGp, roundNumber: 1, points: 2);
      await dao.insertEntry(gamePlayerId: amyGp, roundNumber: 2, points: 3);
      await dao.insertEntry(gamePlayerId: bobGp, roundNumber: 2, points: 4);

      final deleted = await dao.deleteRoundForGame(
        gameId: seeded.gameId,
        roundNumber: 1,
      );

      expect(deleted, 2);
      final remaining = await dao.getByGameId(seeded.gameId);
      expect(remaining.map((e) => e.roundNumber).toSet(), {2});
    });

    test('does not touch other games', () async {
      final other = await seedGame(
        db,
        name: 'Other',
        gameTypeName: 'Chess',
        playerNames: const ['Cory', 'Dana'],
      );
      await dao.insertEntry(gamePlayerId: amyGp, roundNumber: 1, points: 1);
      await dao.insertEntry(
        gamePlayerId: other.gamePlayerIds[0],
        roundNumber: 1,
        points: 99,
      );

      await dao.deleteRoundForGame(gameId: seeded.gameId, roundNumber: 1);

      expect(await dao.getByGameId(seeded.gameId), isEmpty);
      expect(await dao.getByGameId(other.gameId), hasLength(1));
    });

    test('returns 0 when the round has no entries', () async {
      expect(
        await dao.deleteRoundForGame(gameId: seeded.gameId, roundNumber: 5),
        0,
      );
    });
  });

  group('watchByGameId', () {
    test('emits updated list as entries are inserted', () async {
      final events = <List<ScoreEntry>>[];
      final sub = dao.watchByGameId(seeded.gameId).listen(events.add);
      await Future<void>.delayed(Duration.zero);

      await dao.insertEntry(gamePlayerId: amyGp, roundNumber: 1, points: 10);
      await Future<void>.delayed(Duration.zero);

      await dao.insertEntry(gamePlayerId: bobGp, roundNumber: 1, points: 20);
      await Future<void>.delayed(Duration.zero);

      expect(events.last.map((e) => e.points).toList(), [10, 20]);

      await sub.cancel();
    });
  });

  group('cascade behaviour', () {
    test('deleting the game removes its score entries', () async {
      await dao.insertEntry(gamePlayerId: amyGp, roundNumber: 1, points: 10);
      expect(await dao.getByGameId(seeded.gameId), hasLength(1));

      // GamePlayers cascade from Games; ScoreEntries cascade from GamePlayers.
      await db.gameDao.deleteGame(seeded.gameId);

      expect(await dao.getByGameId(seeded.gameId), isEmpty);
    });
  });
}
