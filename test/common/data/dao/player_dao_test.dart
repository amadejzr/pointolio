import 'dart:async';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/dao/player_dao.dart';
import 'package:pointolio/common/data/database/database.dart';

import '../../../utils/db_util.dart';

void main() {
  late AppDatabase db;
  late PlayerDao dao;

  setUp(() {
    db = createTestDb();
    dao = db.playerDao; // assumes you expose it on AppDatabase (common pattern)
  });

  tearDown(() async {
    await db.close();
  });

  group('PlayerDao.add / getById / getAll', () {
    test(
      'add trims firstName and stores null for empty lastName',
      () async {
        final id = await dao.add(
          firstName: '  John  ',
          lastName: '   ',
          color: 123,
        );

        final p = await dao.getById(id);
        expect(p, isNotNull);
        expect(p!.firstName, 'John');
        expect(p.lastName, isNull);
        expect(p.color, 123);
        expect(p.isArchived, false);
      },
    );

    test('getAll excludes archived by default', () async {
      final id1 = await dao.add(firstName: 'Zed');
      final id2 = await dao.add(firstName: 'Amy');

      // archive one
      await (db.update(db.players)..where((p) => p.id.equals(id1))).write(
        const PlayersCompanion(isArchived: Value(true)),
      );

      final all = await dao.getAll(); // default includeArchived=false
      expect(all.map((e) => e.id), [id2]); // only Amy

      final allIncl = await dao.getAll(includeArchived: true);
      expect(allIncl.map((e) => e.id).toSet(), {id1, id2});
    });

    test('getAll orders by firstName ascending', () async {
      await dao.add(firstName: 'Charlie');
      await dao.add(firstName: 'Alice');
      await dao.add(firstName: 'Bob');

      final all = await dao.getAll(includeArchived: true);
      expect(all.map((e) => e.firstName).toList(), [
        'Alice',
        'Bob',
        'Charlie',
      ]);
    });
  });

  group('PlayerDao.getByName', () {
    test(
      'matches by trimmed firstName + lastName when lastName provided',
      () async {
        final id = await dao.add(firstName: '  John ', lastName: '  Smith ');
        final found = await dao.getByName(' John', 'Smith  ');

        expect(found, isNotNull);
        expect(found!.id, id);
        expect(found.firstName, 'John');
        expect(found.lastName, 'Smith');
      },
    );

    test(
      'when lastName is null/empty, matches only rows with NULL lastName',
      () async {
        final idNull = await dao.add(firstName: 'John');
        await dao.add(firstName: 'John', lastName: 'Smith'); // should not match

        final found1 = await dao.getByName(' John ', null);
        expect(found1?.id, idNull);

        final found2 = await dao.getByName(' John ', '   ');
        expect(found2?.id, idNull);
      },
    );
  });

  group('PlayerDao.updatePlayer', () {
    test(
      'updates fields and trims input; empty lastName becomes null',
      () async {
        final id = await dao.add(
          firstName: 'John',
          lastName: 'Smith',
          color: 1,
        );

        final updated = await dao.updatePlayer(
          id,
          firstName: '  Johnny ',
          lastName: '   ',
          color: 999,
        );
        expect(updated, 1);

        final p = await dao.getById(id);
        expect(p!.firstName, 'Johnny');
        expect(p.lastName, isNull);
        expect(p.color, 999);
      },
    );

    test('returns 0 when updating a non-existent id', () async {
      final updated = await dao.updatePlayer(
        999999,
        firstName: 'X',
      );
      expect(updated, 0);
    });
  });

  group('PlayerDao.deletePlayer', () {
    test('deletes existing row and returns 1', () async {
      final id = await dao.add(firstName: 'John');

      final deleted = await dao.deletePlayer(id);
      expect(deleted, 1);

      final p = await dao.getById(id);
      expect(p, isNull);
    });

    test('returns 0 when deleting non-existent row', () async {
      final deleted = await dao.deletePlayer(123456);
      expect(deleted, 0);
    });
  });

  group('PlayerDao.watchAll', () {
    test(
      'emits only non-archived by default and updates on changes',
      () async {
        final events = <List<Player>>[];
        final sub = dao.watchAll().listen(events.add);

        // initial emission
        await Future<void>.delayed(Duration.zero);

        final idA = await dao.add(firstName: 'Amy');
        await Future<void>.delayed(Duration.zero);

        final idZ = await dao.add(firstName: 'Zed');
        await Future<void>.delayed(Duration.zero);

        // archive Zed -> should disappear from watchAll default
        await (db.update(db.players)..where((p) => p.id.equals(idZ))).write(
          const PlayersCompanion(isArchived: Value(true)),
        );
        await Future<void>.delayed(Duration.zero);

        // We don't assert exact emission count (Drift can emit multiple times),
        // just assert the latest state.
        final last = events.last.map((p) => p.id).toList();
        expect(last, [idA]);

        await sub.cancel();
      },
    );

    test('includeArchived=true includes archived rows', () async {
      final events = <List<Player>>[];
      final sub = dao.watchAll(includeArchived: true).listen(events.add);

      await Future<void>.delayed(Duration.zero);

      final idA = await dao.add(firstName: 'Amy');
      final idZ = await dao.add(firstName: 'Zed');

      await (db.update(db.players)..where((p) => p.id.equals(idZ))).write(
        const PlayersCompanion(isArchived: Value(true)),
      );

      await Future<void>.delayed(Duration.zero);

      final ids = events.last.map((p) => p.id).toSet();
      expect(ids, {idA, idZ});

      await sub.cancel();
    });

    test('watchAll orders by firstName ascending', () async {
      final events = <List<Player>>[];
      final sub = dao.watchAll(includeArchived: true).listen(events.add);

      await Future<void>.delayed(Duration.zero);

      await dao.add(firstName: 'Charlie');
      await dao.add(firstName: 'Alice');
      await dao.add(firstName: 'Bob');

      await Future<void>.delayed(Duration.zero);

      final names = events.last.map((p) => p.firstName).toList();
      expect(names, ['Alice', 'Bob', 'Charlie']);

      await sub.cancel();
    });
  });
}
