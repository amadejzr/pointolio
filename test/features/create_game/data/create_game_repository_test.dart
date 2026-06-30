import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/features/create_game/data/create_game_repository.dart';

import '../../../utils/db_util.dart';
import '../../../utils/fixtures.dart';

void main() {
  late AppDatabase db;
  late CreateGameRepository repo;

  setUp(() {
    db = createTestDb();
    repo = CreateGameRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('addGameType', () {
    test('inserts a new type and returns its id', () async {
      final id = await repo.addGameType(name: 'Poker');
      final stored = await repo.getGameTypeById(id);
      expect(stored, isNotNull);
      expect(stored!.name, 'Poker');
    });

    test('returns the existing id instead of creating a duplicate', () async {
      final first = await repo.addGameType(name: 'Poker');
      final second = await repo.addGameType(name: 'Poker');

      expect(second, first);
      final all = await repo.getAllGameTypes();
      expect(all.where((t) => t.name == 'Poker'), hasLength(1));
    });
  });

  group('addPlayer', () {
    test('inserts a new player', () async {
      final id = await repo.addPlayer(firstName: 'Amy');
      final stored = await repo.getPlayerById(id);
      expect(stored!.firstName, 'Amy');
    });

    test('is idempotent for the same first/last name', () async {
      final first = await repo.addPlayer(firstName: 'Amy', lastName: 'Adams');
      final second = await repo.addPlayer(firstName: 'Amy', lastName: 'Adams');
      expect(second, first);
    });
  });

  group('getAllPlayers', () {
    test('excludes archived players by default', () async {
      final activeId = await db.seedPlayer(firstName: 'Active');
      final archivedId = await db.seedPlayer(firstName: 'Archived');
      // No DAO archive path yet, so flip the flag directly to exercise filter.
      await (db.update(db.players)..where((p) => p.id.equals(archivedId)))
          .write(const PlayersCompanion(isArchived: Value(true)));

      final visible = await repo.getAllPlayers();
      expect(visible.map((p) => p.id), [activeId]);

      final all = await repo.getAllPlayers(includeArchived: true);
      expect(all.map((p) => p.id), containsAll([activeId, archivedId]));
    });
  });

  group('createGame', () {
    test('creates a game wired to its type and players', () async {
      final typeId = await repo.addGameType(name: 'Poker');
      final amy = await repo.addPlayer(firstName: 'Amy');
      final bob = await repo.addPlayer(firstName: 'Bob');

      final gameId = await repo.createGame(
        name: 'Friday',
        gameTypeId: typeId,
        gameTypeName: 'Poker',
        playerIds: [amy, bob],
        gameDate: DateTime(2025, 1, 2),
      );

      final game = await db.gameDao.getById(gameId);
      expect(game!.name, 'Friday');
      expect(game.gameTypeId, typeId);

      final players = await db.gameDao.getGamePlayers(gameId);
      expect(players.map((t) => t.$1.id), [amy, bob]);
    });
  });
}
