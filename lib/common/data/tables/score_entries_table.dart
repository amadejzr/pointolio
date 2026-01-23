import 'package:drift/drift.dart';
import 'package:pointolio/common/data/tables/game_players_table.dart';

class ScoreEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get gamePlayerId =>
      integer().references(GamePlayers, #id, onDelete: KeyAction.cascade)();

  // Round number (1, 2, 3, ...)
  IntColumn get roundNumber => integer()();

  // Points scored in this round (can be negative for some games)
  IntColumn get points => integer()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Prevent duplicate entries for same player in same round
  @override
  List<Set<Column>> get uniqueKeys => [
    {gamePlayerId, roundNumber},
  ];
}
