import 'package:drift/drift.dart';

class GameTypes extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Dropdown items come from here. When user types a new one, insert it here.
  TextColumn get name => text().withLength(min: 1, max: 60)();

  // If true, lowest score wins. If false, highest score wins.
  BoolColumn get lowestScoreWins =>
      boolean().withDefault(const Constant(false))();

  // Color for the game type (stored as hex integer, e.g. 0xFF42A5F5)
  IntColumn get color => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {name},
  ];
}

class Games extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Game name (e.g. "Friday Night #1")
  TextColumn get name => text().withLength(min: 1, max: 100)();

  // "Creation" timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // "Game date" (when you played) — default to now, but user can set it
  DateTimeColumn get gameDate => dateTime().withDefault(currentDateAndTime)();

  // Link to dropdown game type
  IntColumn get gameTypeId => integer().nullable().references(
    GameTypes,
    #id,
    onDelete: KeyAction.setNull,
  )();

  // Optional: store a snapshot name too (so if user renames a type later,
  //this game still shows original)
  TextColumn get gameTypeNameSnapshot =>
      text().nullable().withLength(min: 1, max: 60)();

  // Optional: notes
  TextColumn get note => text().nullable()();

  // ✅ NEW: when the game was finished
  // null = active game
  // non-null = finished game
  DateTimeColumn get finishedAt => dateTime().nullable()();
}
