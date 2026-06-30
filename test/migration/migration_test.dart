// Schema / migration tests for [AppDatabase].
//
// These run against the JSON schema snapshots in `drift_schemas/`, generated
// with `dart run drift_dev schema dump`. The companion Dart helpers in
// `generated/` come from `dart run drift_dev schema generate`. See
// test/README.md for the full workflow when bumping `schemaVersion`.
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/data/database/database.dart';

import '../utils/db_util.dart';
import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('schema integrity', () {
    test(
      'runtime schema matches the committed v1 snapshot',
      () async {
        // Boots the database at the v1 reference schema and asserts the live
        // Dart table definitions still match it. If someone edits a table
        // (adds/renames a column, changes a constraint) without dumping a new
        // schema snapshot and bumping `schemaVersion`, this fails - which is
        // the guard rail: schema drift can corrupt real users' data.
        final connection = await verifier.startAt(1);
        final db = AppDatabase(connection);
        addTearDown(db.close);

        await verifier.migrateAndValidate(db, 1);
      },
    );

    test('schemaVersion is the latest dumped schema', () async {
      // Keeps `schemaVersion` and the dumped snapshots in lock-step. When you
      // add `drift_schema_v2.json`, bump `schemaVersion` to 2 and this
      // assertion follows automatically.
      final db = createTestDb();
      addTearDown(db.close);

      expect(db.schemaVersion, GeneratedHelper.versions.last);
    });
  });

  // When you introduce schemaVersion 2, add a test like:
  //
  //   test('migrates v1 -> v2', () async {
  //     final connection = await verifier.startAt(1);
  //     final db = AppDatabase(connection);
  //     addTearDown(db.close);
  //     await verifier.migrateAndValidate(db, 2);
  //   });
  //
  // and, when the migration backfills/transforms data, also seed rows at v1
  // and assert on them after the migration. See test/README.md.
}
