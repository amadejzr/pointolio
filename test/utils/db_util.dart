import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:pointolio/common/data/database/database.dart';

/// Creates an in-memory AppDatabase for DAO tests.
///
/// `closeStreamsSynchronously: true` helps in widget tests and generally avoids
/// async stream disposal issues in tests.
AppDatabase createTestDb() {
  return AppDatabase(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
}
