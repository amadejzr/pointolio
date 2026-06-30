import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/features/manage/data/game_types_management_repository.dart';

import '../../../utils/db_util.dart';
import '../../../utils/fixtures.dart';

void main() {
  late AppDatabase db;
  late GameTypesManagementRepository repo;

  setUp(() {
    db = createTestDb();
    repo = GameTypesManagementRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Matcher throwsDomain(DomainErrorCode code) => throwsA(
        isA<DomainException>().having((e) => e.code, 'code', code),
      );

  group('addGameType', () {
    test('persists a new type', () async {
      await repo.addGameType(name: 'Poker', lowestScoreWins: false);
      final all = await db.gameTypeDao.getAll();
      expect(all.single.name, 'Poker');
    });

    test('maps a duplicate name to a conflict', () async {
      await repo.addGameType(name: 'Poker', lowestScoreWins: false);
      expect(
        () => repo.addGameType(name: 'Poker', lowestScoreWins: false),
        throwsDomain(DomainErrorCode.conflict),
      );
    });
  });

  group('updateGameType', () {
    test('updates an existing type', () async {
      final id = await db.seedGameType();
      await repo.updateGameType(id, name: 'Holdem', lowestScoreWins: true);

      final stored = await db.gameTypeDao.getById(id);
      expect(stored!.name, 'Holdem');
      expect(stored.lowestScoreWins, isTrue);
    });

    test('throws notFound for a missing type', () async {
      expect(
        () => repo.updateGameType(999999, name: 'X', lowestScoreWins: false),
        throwsDomain(DomainErrorCode.notFound),
      );
    });

    test('maps a name clash to a conflict', () async {
      await db.seedGameType();
      final chess = await db.seedGameType(name: 'Chess');
      expect(
        () => repo.updateGameType(chess, name: 'Poker', lowestScoreWins: false),
        throwsDomain(DomainErrorCode.conflict),
      );
    });
  });

  group('deleteGameType', () {
    test('deletes an existing type', () async {
      final id = await db.seedGameType();
      await repo.deleteGameType(id);
      expect(await db.gameTypeDao.getById(id), isNull);
    });

    test('throws notFound for a missing type', () async {
      expect(
        () => repo.deleteGameType(999999),
        throwsDomain(DomainErrorCode.notFound),
      );
    });
  });

  group('watchAllGameTypes', () {
    test('emits the current types', () async {
      await db.seedGameType();
      await db.seedGameType(name: 'Chess');

      final types = await repo.watchAllGameTypes().first;
      expect(types.map((t) => t.name), containsAll(['Poker', 'Chess']));
    });
  });
}
