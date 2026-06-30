# Testing guide

This suite is the regression net for Pointolio's logic, data, and state layers.
It deliberately does **not** cover widgets - the focus is business logic,
database behaviour, and schema migrations, so that adding a feature can't
silently break an existing one.

## Running

```sh
flutter test                              # whole suite
flutter test test/common/data/dao         # one folder
flutter test --name "reorder"             # tests matching a name
```

CI (`.github/workflows/test.yml`) runs `build_runner`, `flutter analyze`, and
`flutter test` on every PR to `main`. The `build_runner` step is required, not
optional: drift's `*.g.dart` output is gitignored, so a clean checkout has no
generated DAO code and won't compile until it runs. (Locally, run
`dart run build_runner build --delete-conflicting-outputs` after a fresh clone
or whenever you change a table/DAO.)

## Layout

```
test/
  utils/
    db_util.dart        # in-memory AppDatabase factory (FK-aware)
    fixtures.dart       # data builders: seedGame(), playerRow(), gameTypeRow()...
  common/data/dao/      # DAO integration tests against a real in-memory SQLite
  common/exception/     # exception_mapper unit tests
  features/<feature>/   # cubit (bloc_test) + repository + pure-logic tests
  migration/
    generated/          # drift_dev-generated schema snapshots (do not edit)
    migration_test.dart # schema-integrity / migration tests
```

## The three testing styles used here

1. **DAO / repository integration** - run against a genuine in-memory SQLite
   database via `createTestDb()`. No mocking of the database; assertions are on
   real query results, ordering, and cascade behaviour. See
   `test/common/data/dao/`.
2. **Cubit tests** - `bloc_test` with a `mocktail` mock of the repository, so
   state transitions are verified in isolation. Because some initial states use
   `DateTime.now()`, prefer `isA<State>().having(...)` matchers over full-state
   equality where a timestamp is involved. See `test/features/*/cubit/`.
3. **Pure unit tests** - no database, no Flutter bindings (e.g.
   `CalculatorLogic`, `exception_mapper`). Fast and exhaustive on edge cases.

## Fixtures

`test/utils/fixtures.dart` keeps tests focused on behaviour:

- `seedGame(db, playerNames: [...])` - inserts a game type, players, the game,
  and the join rows, returning the ids (including `gamePlayerIds`, which score
  entries reference).
- `db.seedGameType(...)` / `db.seedPlayer(...)` - single-row helpers.
- `playerRow(...)`, `gameTypeRow(...)`, `gameRow(...)`, `gamePlayerRow(...)` -
  build in-memory row objects for cubit tests that mock the repository.

## Foreign keys

SQLite leaves `PRAGMA foreign_keys` **off** by default, so cascade/restrict
rules declared on the tables aren't enforced unless turned on. `createTestDb()`
enables them by default so tests exercise the schema as designed.

> Note: production (`AppDatabase._openConnection`) does **not** currently enable
> foreign keys, so cascade deletes are not enforced on real devices. Worth
> aligning - either enable them in production or stop relying on cascade
> semantics. Tracked separately from this test work.

## Schema migrations

Schema snapshots live in `drift_schemas/`, and the Dart helpers used by the
migration tests live in `test/migration/generated/`. Both are generated - never
hand-edit them.

When you change a table (add/rename a column, change a constraint):

1. Bump `schemaVersion` in `lib/common/data/database/database.dart`.
2. Add the `MigrationStrategy` step that performs the upgrade.
3. Dump the new schema and regenerate the helpers:

   ```sh
   dart run drift_dev schema dump \
     lib/common/data/database/database.dart drift_schemas/
   dart run drift_dev schema generate \
     drift_schemas/ test/migration/generated/
   ```

4. Add a migration test in `test/migration/migration_test.dart`:

   ```dart
   test('migrates v1 -> v2', () async {
     final connection = await verifier.startAt(1);
     final db = AppDatabase(connection);
     addTearDown(db.close);
     await verifier.migrateAndValidate(db, 2);
   });
   ```

   When the migration backfills or transforms data, seed rows at the old version
   first and assert on them after `migrateAndValidate` to prove no data is lost.

`migration_test.dart` already guards against accidental drift: if a table
changes without a matching schema dump + `schemaVersion` bump, the
"runtime schema matches the committed v1 snapshot" test fails.

## Conventions

- One behaviour per `test`; group by method/feature.
- Always `await db.close()` (or `addTearDown(db.close)`) and cancel stream
  subscriptions to avoid cross-test leakage.
- State and domain models use `Equatable`, so prefer value equality / `having`
  matchers over poking at individual getters.
