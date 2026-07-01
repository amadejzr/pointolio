import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:pointolio/common/data/database/database.dart';

/// Creates an in-memory [AppDatabase] for DAO / repository tests.
///
/// `closeStreamsSynchronously: true` avoids async stream disposal issues that
/// otherwise leak between tests (a pending `watch()` subscription firing after
/// the test that created it has already completed).
///
/// [foreignKeys] enables `PRAGMA foreign_keys = ON` so the referential
/// integrity declared on the tables (cascade / restrict / set null) is actually
/// enforced. SQLite leaves foreign keys OFF by default, so a test that asserts
/// on cascade deletes or FK violations must run with them ON. We default to ON
/// here so tests exercise the schema as designed; see test/README.md for the
/// note about production not enabling this yet.
AppDatabase createTestDb({bool foreignKeys = true}) {
  final native = NativeDatabase.memory(
    setup: (db) {
      if (foreignKeys) {
        db.execute('PRAGMA foreign_keys = ON;');
      }
    },
  );

  return AppDatabase(
    DatabaseConnection(
      native,
      closeStreamsSynchronously: true,
    ),
  );
}
