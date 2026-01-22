import 'package:drift/drift.dart';

class Players extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get firstName => text().withLength(min: 1, max: 40)();
  TextColumn get lastName => text().nullable().withLength(min: 1, max: 60)();

  // For future features (stats, sorting, etc.)
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Useful later (soft delete / hide)
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  IntColumn get color => integer().nullable()();

  // Prevent duplicates (basic). If you want “John Smith” twice, remove this.
  @override
  List<Set<Column>> get uniqueKeys => [
    {firstName, lastName},
  ];
}
