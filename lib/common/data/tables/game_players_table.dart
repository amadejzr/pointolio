import 'package:drift/drift.dart';
import 'package:scoreio/common/data/tables/games_table.dart';
import 'package:scoreio/common/data/tables/player_table.dart';

class GamePlayers extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();

  IntColumn get playerId =>
      integer().references(Players, #id, onDelete: KeyAction.restrict)();

  // Keeps stable ordering on UI
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {gameId, playerId}, // same player cannot be added twice to same game
  ];
}
