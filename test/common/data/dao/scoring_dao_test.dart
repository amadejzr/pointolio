import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/dao/scoring_dao.dart';
import 'package:pointolio/common/data/database/database.dart';

import '../../../utils/db_util.dart';
import '../../../utils/fixtures.dart';

void main() {
  late AppDatabase db;
  late ScoringDao dao;
  late SeededGame seeded;

  // GamePlayers join-row ids for the two seeded players (Amy=0, Bob=1).
  late int amyGp;
  late int bobGp;

  setUp(() async {
    db = createTestDb();
    dao = db.scoringDao;
    seeded = await seedGame(db, lowestScoreWins: true);
    amyGp = seeded.gamePlayerIds[0];
    bobGp = seeded.gamePlayerIds[1];
  });

  tearDown(() async {
    await db.close();
  });

  group('getScoringData', () {
    test('returns null for a non-existent game', () async {
      expect(await dao.getScoringData(999999), isNull);
    });

    test('returns game, game type and players (ordered) with scores', () async {
      await dao.addRound(roundNumber: 1, scores: {amyGp: 10, bobGp: 20});
      await dao.addRound(roundNumber: 2, scores: {amyGp: 5, bobGp: 7});

      final data = await dao.getScoringData(seeded.gameId);

      expect(data, isNotNull);
      expect(data!.game.id, seeded.gameId);
      expect(data.gameType, isNotNull);
      expect(data.gameType!.lowestScoreWins, isTrue);

      // Players preserve orderIndex (Amy before Bob).
      expect(
        data.playerScores.map((p) => p.player.firstName).toList(),
        ['Amy', 'Bob'],
      );

      final amy = data.playerScores.first;
      expect(amy.scores.map((s) => s.points).toList(), [10, 5]);
    });

    test('game type is null when the game has none', () async {
      final gameId = await db.gameDao.insertGame(
        GamesCompanion.insert(name: 'No type'),
      );
      final data = await dao.getScoringData(gameId);
      expect(data, isNotNull);
      expect(data!.gameType, isNull);
      expect(data.playerScores, isEmpty);
    });
  });

  group('addRound', () {
    test('inserts one score entry per player in a batch', () async {
      await dao.addRound(roundNumber: 1, scores: {amyGp: 11, bobGp: 22});

      final data = await dao.getScoringData(seeded.gameId);
      final byName = {
        for (final p in data!.playerScores) p.player.firstName: p,
      };
      expect(byName['Amy']!.scores.single.points, 11);
      expect(byName['Bob']!.scores.single.points, 22);
    });
  });

  group('updateScore', () {
    Future<ScoreEntry> onlyEntry() async {
      final data = await dao.getScoringData(seeded.gameId);
      return data!.playerScores.first.scores.single;
    }

    test('changes the points of an entry', () async {
      await dao.addRound(roundNumber: 1, scores: {amyGp: 10});
      final entry = await onlyEntry();

      await dao.updateScore(scoreEntryId: entry.id, points: 99);

      expect((await onlyEntry()).points, 99);
    });
  });

  group('deleteRound', () {
    test('removes every entry of a round and returns the count', () async {
      await dao.addRound(roundNumber: 1, scores: {amyGp: 1, bobGp: 2});
      await dao.addRound(roundNumber: 2, scores: {amyGp: 3, bobGp: 4});

      final deleted =
          await dao.deleteRound(gameId: seeded.gameId, roundNumber: 1);
      expect(deleted, 2);

      final data = await dao.getScoringData(seeded.gameId);
      for (final ps in data!.playerScores) {
        expect(ps.scores.map((s) => s.roundNumber), everyElement(2));
      }
    });
  });

  group('reorderPlayers', () {
    test('rewrites orderIndex to match the given order', () async {
      // Initially Amy(0), Bob(1). Swap them.
      await dao.reorderPlayers([bobGp, amyGp]);

      final data = await dao.getScoringData(seeded.gameId);
      expect(
        data!.playerScores.map((p) => p.player.firstName).toList(),
        ['Bob', 'Amy'],
      );
    });
  });

  group('setGameFinished', () {
    test('toggles finishedAt on and off', () async {
      expect(await dao.setGameFinished(seeded.gameId, finished: true), 1);
      expect((await dao.getGame(seeded.gameId))!.finishedAt, isNotNull);

      expect(await dao.setGameFinished(seeded.gameId, finished: false), 1);
      expect((await dao.getGame(seeded.gameId))!.finishedAt, isNull);
    });

    test('returns 0 for a non-existent game', () async {
      expect(await dao.setGameFinished(999999, finished: true), 0);
    });
  });

  group('getGameType', () {
    test('returns null for a null id without querying', () async {
      expect(await dao.getGameType(null), isNull);
    });

    test('returns the matching game type', () async {
      final gt = await dao.getGameType(seeded.gameTypeId);
      expect(gt, isNotNull);
      expect(gt!.id, seeded.gameTypeId);
    });
  });

  group('updateGameParty', () {
    test('renames the game and trims whitespace', () async {
      await dao.updateGameParty(
        gameId: seeded.gameId,
        name: '  Renamed  ',
        playerIds: seeded.playerIds,
      );
      expect((await dao.getGame(seeded.gameId))!.name, 'Renamed');
    });

    test('adds a new player and removes a dropped one', () async {
      final cory = await db.seedPlayer(firstName: 'Cory');

      // Drop Bob (playerIds[1]), keep Amy, add Cory.
      await dao.updateGameParty(
        gameId: seeded.gameId,
        name: 'Game',
        playerIds: [seeded.playerIds[0], cory],
      );

      final players = await db.gameDao.getGamePlayers(seeded.gameId);
      expect(
        players.map((t) => t.$1.firstName).toList(),
        ['Amy', 'Cory'],
      );
      expect(players.map((t) => t.$2.orderIndex).toList(), [0, 1]);
    });

    test('reorders existing players to the requested order', () async {
      await dao.updateGameParty(
        gameId: seeded.gameId,
        name: 'Game',
        playerIds: [seeded.playerIds[1], seeded.playerIds[0]],
      );

      final players = await db.gameDao.getGamePlayers(seeded.gameId);
      expect(players.map((t) => t.$1.firstName).toList(), ['Bob', 'Amy']);
    });

    test('removing a player cascades their score entries', () async {
      await dao.addRound(roundNumber: 1, scores: {amyGp: 1, bobGp: 2});

      // Drop Bob.
      await dao.updateGameParty(
        gameId: seeded.gameId,
        name: 'Game',
        playerIds: [seeded.playerIds[0]],
      );

      final entries = await db.scoreEntryDao.getByGameId(seeded.gameId);
      expect(entries, hasLength(1));
      expect(entries.single.gamePlayerId, amyGp);
    });
  });

  group('watchScoreEntries', () {
    test('emits ordered entries and reacts to inserts', () async {
      final events = <List<ScoreEntry>>[];
      final sub = dao.watchScoreEntries(seeded.gameId).listen(events.add);
      await Future<void>.delayed(Duration.zero);

      await dao.addRound(roundNumber: 1, scores: {amyGp: 10, bobGp: 20});
      await Future<void>.delayed(Duration.zero);

      expect(events.last.map((e) => e.points).toList(), [10, 20]);
      await sub.cancel();
    });
  });
}
