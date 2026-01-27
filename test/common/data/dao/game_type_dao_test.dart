// test/common/data/dao/game_type_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/dao/game_type_dao.dart'; // <-- adjust path
import 'package:pointolio/common/data/database/database.dart';

import '../../../utils/db_util.dart'; // for GameTypesCompanion

void main() {
  late AppDatabase db;
  late GameTypeDao dao;

  setUp(() {
    db = createTestDb();
    dao = db.gameTypeDao; // if not exposed, use: dao = GameTypeDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('GameTypeDao.add / getById / getAll', () {
    test('add trims name and stores fields', () async {
      final id = await dao.add(
        name: '  Poker  ',
        lowestScoreWins: true,
        color: 123,
      );

      final gt = await dao.getById(id);
      expect(gt, isNotNull);
      expect(gt!.name, 'Poker');
      expect(gt.lowestScoreWins, true);
      expect(gt.color, 123);
    });

    test('getAll orders by name ascending', () async {
      await dao.add(name: 'Chess');
      await dao.add(name: '  Backgammon ');
      await dao.add(name: 'Poker');

      final all = await dao.getAll();
      expect(all.map((e) => e.name).toList(), ['Backgammon', 'Chess', 'Poker']);
    });
  });

  group('GameTypeDao.getByName', () {
    test('matches by trimmed name', () async {
      final id = await dao.add(name: '  Poker  ');

      final found = await dao.getByName('Poker');
      expect(found, isNotNull);
      expect(found!.id, id);

      final found2 = await dao.getByName('  Poker  ');
      expect(found2, isNotNull);
      expect(found2!.id, id);
    });

    test('returns null when not found', () async {
      final found = await dao.getByName('DoesNotExist');
      expect(found, isNull);
    });
  });

  group('GameTypeDao.updateGameType', () {
    test('updates fields and trims name', () async {
      final id = await dao.add(
        name: 'Poker',
        color: 1,
      );

      final updated = await dao.updateGameType(
        id,
        name: '  Poker Pro ',
        lowestScoreWins: true,
        color: 999,
      );
      expect(updated, 1);

      final gt = await dao.getById(id);
      expect(gt, isNotNull);
      expect(gt!.name, 'Poker Pro');
      expect(gt.lowestScoreWins, true);
      expect(gt.color, 999);
    });

    test('returns 0 when updating non-existent id', () async {
      final updated = await dao.updateGameType(
        999999,
        name: 'X',
        lowestScoreWins: false,
      );
      expect(updated, 0);
    });
  });

  group('GameTypeDao.deleteGameType', () {
    test('deletes existing row and returns 1', () async {
      final id = await dao.add(name: 'Poker');

      final deleted = await dao.deleteGameType(id);
      expect(deleted, 1);

      final gt = await dao.getById(id);
      expect(gt, isNull);
    });

    test('returns 0 when deleting non-existent row', () async {
      final deleted = await dao.deleteGameType(123456);
      expect(deleted, 0);
    });
  });

  group('GameTypeDao.watchAll', () {
    test('emits ordered lists and updates on inserts', () async {
      final events = <List<GameType>>[];
      final sub = dao.watchAll().listen(events.add);

      // wait for initial emission
      await Future<void>.delayed(Duration.zero);

      await dao.add(name: 'Chess');
      await Future<void>.delayed(Duration.zero);

      await dao.add(name: '  Backgammon ');
      await Future<void>.delayed(Duration.zero);

      // Drift may emit multiple times; assert latest snapshot
      final latestNames = events.last.map((e) => e.name).toList();
      expect(latestNames, ['Backgammon', 'Chess']);

      await sub.cancel();
    });
  });
}
