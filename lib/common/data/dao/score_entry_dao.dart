import 'package:drift/drift.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/data/tables/game_players_table.dart';
import 'package:pointolio/common/data/tables/score_entries_table.dart';

part 'score_entry_dao.g.dart';

@DriftAccessor(tables: [ScoreEntries, GamePlayers])
class ScoreEntryDao extends DatabaseAccessor<AppDatabase>
    with _$ScoreEntryDaoMixin {
  ScoreEntryDao(super.attachedDatabase);

  Stream<List<ScoreEntry>> watchByGameId(int gameId) {
    final q =
        select(scoreEntries).join([
            innerJoin(
              gamePlayers,
              gamePlayers.id.equalsExp(scoreEntries.gamePlayerId),
            ),
          ])
          ..where(gamePlayers.gameId.equals(gameId))
          ..orderBy([
            OrderingTerm.asc(scoreEntries.roundNumber),
            OrderingTerm.asc(gamePlayers.orderIndex),
          ]);

    return q.watch().map(
      (rows) => rows.map((r) => r.readTable(scoreEntries)).toList(),
    );
  }

  Future<List<ScoreEntry>> getByGameId(int gameId) async {
    final q =
        select(scoreEntries).join([
            innerJoin(
              gamePlayers,
              gamePlayers.id.equalsExp(scoreEntries.gamePlayerId),
            ),
          ])
          ..where(gamePlayers.gameId.equals(gameId))
          ..orderBy([
            OrderingTerm.asc(scoreEntries.roundNumber),
            OrderingTerm.asc(gamePlayers.orderIndex),
          ]);

    final rows = await q.get();
    return rows.map((r) => r.readTable(scoreEntries)).toList();
  }

  Future<int> insertEntry({
    required int gamePlayerId,
    required int roundNumber,
    required int points,
  }) {
    return into(scoreEntries).insert(
      ScoreEntriesCompanion.insert(
        gamePlayerId: gamePlayerId,
        roundNumber: roundNumber,
        points: points,
      ),
    );
  }

  Future<void> updatePoints({required int id, required int points}) {
    return (update(scoreEntries)..where((e) => e.id.equals(id))).write(
      ScoreEntriesCompanion(points: Value(points)),
    );
  }

  Future<int> deleteEntry(int id) {
    return (delete(scoreEntries)..where((e) => e.id.equals(id))).go();
  }

  Future<int> deleteRoundForGame({
    required int gameId,
    required int roundNumber,
  }) {
    // single DELETE with subquery (better than fetching ids first)
    final gpIds = selectOnly(gamePlayers)
      ..addColumns([gamePlayers.id])
      ..where(gamePlayers.gameId.equals(gameId));

    return (delete(scoreEntries)..where(
          (e) =>
              e.roundNumber.equals(roundNumber) &
              e.gamePlayerId.isInQuery(gpIds),
        ))
        .go();
  }
}
