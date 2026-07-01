import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/features/scoring/data/scoring_repository.dart';

import '../../../utils/db_util.dart';
import '../../../utils/fixtures.dart';

void main() {
  late AppDatabase db;
  late ScoringRepository repo;
  late SeededGame seeded;
  late int amyGp;
  late int bobGp;

  setUp(() async {
    db = createTestDb();
    repo = ScoringRepository(db);
    seeded = await seedGame(db, lowestScoreWins: true);
    amyGp = seeded.gamePlayerIds[0];
    bobGp = seeded.gamePlayerIds[1];
  });

  tearDown(() async {
    await db.close();
  });

  Matcher throwsDomain(DomainErrorCode code) => throwsA(
        isA<DomainException>().having((e) => e.code, 'code', code),
      );

  group('getGame / getGameType', () {
    test('getGame returns the game, or null when missing', () async {
      expect((await repo.getGame(seeded.gameId))!.id, seeded.gameId);
      expect(await repo.getGame(999999), isNull);
    });

    test('getGameType returns null for a null id', () async {
      expect(await repo.getGameType(null), isNull);
      expect((await repo.getGameType(seeded.gameTypeId))!.lowestScoreWins,
          isTrue);
    });
  });

  group('getPlayerScores', () {
    test('aggregates totals and indexes entries by round', () async {
      await repo.addRound(roundNumber: 1, scores: {amyGp: 10, bobGp: 5});
      await repo.addRound(roundNumber: 2, scores: {amyGp: 3, bobGp: 7});

      final scores = await repo.getPlayerScores(seeded.gameId);
      final amy = scores.firstWhere((s) => s.player.firstName == 'Amy');

      expect(amy.total, 13);
      expect(amy.getScoreForRound(1), 10);
      expect(amy.getScoreForRound(2), 3);
      expect(amy.getScoreForRound(99), isNull);
      expect(amy.roundScores[1]!.points, 10);
    });

    test('returns an empty list for a non-existent game', () async {
      expect(await repo.getPlayerScores(999999), isEmpty);
    });
  });

  group('addRound / updateScore', () {
    test('addRound then updateScore are reflected in totals', () async {
      await repo.addRound(roundNumber: 1, scores: {amyGp: 10});
      final entry = (await repo.getPlayerScores(seeded.gameId))
          .firstWhere((s) => s.gamePlayer.id == amyGp)
          .roundScores[1]!;

      await repo.updateScore(scoreEntryId: entry.id, points: 50);

      final updated = (await repo.getPlayerScores(seeded.gameId))
          .firstWhere((s) => s.gamePlayer.id == amyGp);
      expect(updated.total, 50);
    });
  });

  group('deleteRound', () {
    test('removes the round', () async {
      await repo.addRound(roundNumber: 1, scores: {amyGp: 1, bobGp: 2});
      await repo.deleteRound(gameId: seeded.gameId, roundNumber: 1);

      final scores = await repo.getPlayerScores(seeded.gameId);
      expect(scores.every((s) => s.total == 0), isTrue);
    });

    test('throws notFound when the round has no entries', () async {
      expect(
        () => repo.deleteRound(gameId: seeded.gameId, roundNumber: 9),
        throwsDomain(DomainErrorCode.notFound),
      );
    });
  });

  group('setGameFinished', () {
    test('marks finished and restores', () async {
      await repo.setGameFinished(seeded.gameId, finished: true);
      expect((await repo.getGame(seeded.gameId))!.finishedAt, isNotNull);

      await repo.setGameFinished(seeded.gameId, finished: false);
      expect((await repo.getGame(seeded.gameId))!.finishedAt, isNull);
    });

    test('throws notFound for a missing game', () async {
      expect(
        () => repo.setGameFinished(999999, finished: true),
        throwsDomain(DomainErrorCode.notFound),
      );
    });
  });

  group('reorderPlayers / getAllPlayers / updateGameParty', () {
    test('reorderPlayers changes the order returned by getPlayerScores',
        () async {
      await repo.reorderPlayers([bobGp, amyGp]);
      final scores = await repo.getPlayerScores(seeded.gameId);
      expect(scores.map((s) => s.player.firstName), ['Bob', 'Amy']);
    });

    test('getAllPlayers returns every seeded player', () async {
      final players = await repo.getAllPlayers();
      expect(players.map((p) => p.firstName), containsAll(['Amy', 'Bob']));
    });

    test('updateGameParty renames and swaps the roster', () async {
      final cory = await db.seedPlayer(firstName: 'Cory');
      await repo.updateGameParty(
        gameId: seeded.gameId,
        name: 'Renamed',
        playerIds: [seeded.playerIds[0], cory],
      );

      expect((await repo.getGame(seeded.gameId))!.name, 'Renamed');
      final scores = await repo.getPlayerScores(seeded.gameId);
      expect(scores.map((s) => s.player.firstName), ['Amy', 'Cory']);
    });
  });

  group('streams', () {
    test('watchGamePlayers emits the current roster', () async {
      final first = await repo.watchGamePlayers(seeded.gameId).first;
      expect(first.map((t) => t.$1.firstName), ['Amy', 'Bob']);
    });

    test('watchScoreEntries emits entries after a round is added', () async {
      final events = <List<ScoreEntry>>[];
      final sub = repo.watchScoreEntries(seeded.gameId).listen(events.add);
      await Future<void>.delayed(Duration.zero);

      await repo.addRound(roundNumber: 1, scores: {amyGp: 10, bobGp: 20});
      await Future<void>.delayed(Duration.zero);

      expect(events.last.map((e) => e.points), [10, 20]);
      await sub.cancel();
    });
  });
}
