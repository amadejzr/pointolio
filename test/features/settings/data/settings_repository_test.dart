import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/features/settings/data/settings_repository.dart';

import '../../../utils/db_util.dart';
import '../../../utils/fixtures.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = createTestDb();
    repo = SettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('clearAllData', () {
    test('wipes every table (games, players, types, joins, scores)', () async {
      final seeded = await seedGame(db);
      await db.scoreEntryDao.insertEntry(
        gamePlayerId: seeded.gamePlayerIds.first,
        roundNumber: 1,
        points: 10,
      );

      await repo.clearAllData();

      expect(await db.select(db.scoreEntries).get(), isEmpty);
      expect(await db.select(db.gamePlayers).get(), isEmpty);
      expect(await db.select(db.games).get(), isEmpty);
      expect(await db.select(db.players).get(), isEmpty);
      expect(await db.select(db.gameTypes).get(), isEmpty);
    });

    test('is a no-op on an already empty database', () async {
      await repo.clearAllData();
      expect(await db.select(db.games).get(), isEmpty);
    });
  });
}
