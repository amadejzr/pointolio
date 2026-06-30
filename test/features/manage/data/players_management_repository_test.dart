import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/features/manage/data/players_management_repository.dart';

import '../../../utils/db_util.dart';
import '../../../utils/fixtures.dart';

void main() {
  late AppDatabase db;
  late PlayersManagementRepository repo;

  setUp(() {
    db = createTestDb();
    repo = PlayersManagementRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Matcher throwsDomain(DomainErrorCode code) => throwsA(
        isA<DomainException>().having((e) => e.code, 'code', code),
      );

  group('addPlayer', () {
    test('persists a new player', () async {
      await repo.addPlayer(firstName: 'Amy', lastName: 'Adams');
      final all = await db.playerDao.getAll();
      expect(all.single.firstName, 'Amy');
    });

    test('maps a duplicate name to a conflict DomainException', () async {
      await repo.addPlayer(firstName: 'Amy', lastName: 'Adams');
      expect(
        () => repo.addPlayer(firstName: 'Amy', lastName: 'Adams'),
        throwsDomain(DomainErrorCode.conflict),
      );
    });
  });

  group('updatePlayer', () {
    test('updates an existing player', () async {
      final id = await db.seedPlayer(firstName: 'Amy');
      await repo.updatePlayer(id, firstName: 'Amelia');
      expect((await db.playerDao.getById(id))!.firstName, 'Amelia');
    });

    test('throws notFound for a missing player', () async {
      expect(
        () => repo.updatePlayer(999999, firstName: 'X'),
        throwsDomain(DomainErrorCode.notFound),
      );
    });

    test('maps a name clash to a conflict', () async {
      await db.seedPlayer(firstName: 'Amy', lastName: 'Adams');
      final bob = await db.seedPlayer(firstName: 'Bob', lastName: 'Smith');
      expect(
        () => repo.updatePlayer(bob, firstName: 'Amy', lastName: 'Adams'),
        throwsDomain(DomainErrorCode.conflict),
      );
    });
  });

  group('deletePlayer', () {
    test('deletes an existing player', () async {
      final id = await db.seedPlayer(firstName: 'Amy');
      await repo.deletePlayer(id);
      expect(await db.playerDao.getById(id), isNull);
    });

    test('throws notFound for a missing player', () async {
      expect(
        () => repo.deletePlayer(999999),
        throwsDomain(DomainErrorCode.notFound),
      );
    });
  });

  group('watchAllPlayers', () {
    test('emits players ordered by first name', () async {
      await db.seedPlayer(firstName: 'Bob');
      await db.seedPlayer(firstName: 'Amy');

      final players = await repo.watchAllPlayers().first;
      expect(players.map((p) => p.firstName), ['Amy', 'Bob']);
    });

    test('excludes archived players by default', () async {
      final archived = await db.seedPlayer(firstName: 'Ghost');
      // No DAO archive path yet, so flip the flag directly to exercise filter.
      await (db.update(db.players)..where((p) => p.id.equals(archived)))
          .write(const PlayersCompanion(isArchived: Value(true)));
      await db.seedPlayer(firstName: 'Active');

      final players = await repo.watchAllPlayers().first;
      expect(players.map((p) => p.firstName), ['Active']);
    });
  });
}
