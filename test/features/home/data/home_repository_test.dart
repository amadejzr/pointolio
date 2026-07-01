import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/features/home/data/home_repository.dart';

import '../../../utils/db_util.dart';
import '../../../utils/fixtures.dart';

void main() {
  late AppDatabase db;
  late HomeRepository repo;

  setUp(() {
    db = createTestDb();
    repo = HomeRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Matcher throwsDomain(DomainErrorCode code) => throwsA(
        isA<DomainException>().having((e) => e.code, 'code', code),
      );

  group('deleteGame', () {
    test('deletes an existing game', () async {
      final seeded = await seedGame(db);
      await repo.deleteGame(seeded.gameId);
      expect(await db.gameDao.getById(seeded.gameId), isNull);
    });

    test('throws notFound for a missing game', () async {
      expect(
        () => repo.deleteGame(999999),
        throwsDomain(DomainErrorCode.notFound),
      );
    });
  });

  group('getPlayerCount / getGameType', () {
    test('getPlayerCount counts the roster', () async {
      final seeded = await seedGame(
        db,
        playerNames: const ['Amy', 'Bob', 'Cy'],
      );
      expect(await repo.getPlayerCount(seeded.gameId), 3);
    });

    test('getGameType returns null for a null id and the type otherwise',
        () async {
      final seeded = await seedGame(db);
      expect(await repo.getGameType(null), isNull);
      expect(
        (await repo.getGameType(seeded.gameTypeId))!.id,
        seeded.gameTypeId,
      );
    });
  });

  group('setGameFinished', () {
    test('toggles finished state', () async {
      final seeded = await seedGame(db);
      await repo.setGameFinished(seeded.gameId, finished: true);
      expect((await db.gameDao.getById(seeded.gameId))!.finishedAt, isNotNull);
    });

    test('throws notFound for a missing game', () async {
      expect(
        () => repo.setGameFinished(999999, finished: true),
        throwsDomain(DomainErrorCode.notFound),
      );
    });
  });

  group('watchGamesWithMetadata', () {
    test('maps rows to GameWithPlayerCount with player counts', () async {
      final seeded = await seedGame(db); // defaults to Amy + Bob

      final first = await repo.watchGamesWithMetadata().first;
      final entry = first.firstWhere((g) => g.game.id == seeded.gameId);

      expect(entry.playerCount, 2);
      expect(entry.gameType?.id, seeded.gameTypeId);
      expect(entry.players.map((p) => p.firstName), ['Amy', 'Bob']);
      expect(entry.roundCount, 0);
      expect(entry.winnerName, isNull);
    });

    test('reports the highest round number', () async {
      final seeded = await seedGame(db);
      await db.scoringDao.addRound(
        roundNumber: 1,
        scores: {seeded.gamePlayerIds[0]: 5, seeded.gamePlayerIds[1]: 3},
      );
      await db.scoringDao.addRound(
        roundNumber: 2,
        scores: {seeded.gamePlayerIds[0]: 5, seeded.gamePlayerIds[1]: 3},
      );

      final entry = (await repo.watchGamesWithMetadata().first)
          .firstWhere((g) => g.game.id == seeded.gameId);

      expect(entry.roundCount, 2);
      expect(entry.winnerName, isNull); // still active
    });

    test('names the winner once finished (highest score wins)', () async {
      final seeded = await seedGame(db); // lowestScoreWins defaults to false
      await db.scoringDao.addRound(
        roundNumber: 1,
        scores: {seeded.gamePlayerIds[0]: 10, seeded.gamePlayerIds[1]: 4},
      );
      await repo.setGameFinished(seeded.gameId, finished: true);

      final entry = (await repo.watchGamesWithMetadata().first)
          .firstWhere((g) => g.game.id == seeded.gameId);

      expect(entry.winnerName, 'Amy');
    });

    test('respects lowest-score-wins when naming the winner', () async {
      final seeded = await seedGame(db, lowestScoreWins: true);
      await db.scoringDao.addRound(
        roundNumber: 1,
        scores: {seeded.gamePlayerIds[0]: 10, seeded.gamePlayerIds[1]: 4},
      );
      await repo.setGameFinished(seeded.gameId, finished: true);

      final entry = (await repo.watchGamesWithMetadata().first)
          .firstWhere((g) => g.game.id == seeded.gameId);

      expect(entry.winnerName, 'Bob');
    });
  });

  group('watchAllGames', () {
    test('emits games ordered by the DAO', () async {
      await seedGame(db, name: 'A');
      final games = await repo.watchAllGames().first;
      expect(games.map((g) => g.name), contains('A'));
    });
  });
}
