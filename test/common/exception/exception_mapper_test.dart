import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/common/exception/exception_mapper.dart';

import '../../utils/db_util.dart';
import '../../utils/fixtures.dart';

void main() {
  // `resultCode` is `extendedResultCode & 0xFF`, so each extended code below
  // also encodes the SQLITE_CONSTRAINT (19) / SQLITE_AUTH (23) primary code.
  SqliteException ex(int extendedCode) =>
      SqliteException(extendedResultCode: extendedCode, message: 'boom');

  group('toDomainException code mapping', () {
    test('UNIQUE / PRIMARY KEY constraint -> conflict', () {
      expect(ex(2067).toDomainException(operation: 'x').code,
          DomainErrorCode.conflict);
      expect(ex(1555).toDomainException(operation: 'x').code,
          DomainErrorCode.conflict);
    });

    test('FOREIGN KEY constraint -> conflict', () {
      expect(ex(787).toDomainException(operation: 'x').code,
          DomainErrorCode.conflict);
    });

    test('NOT NULL / CHECK constraint -> validation', () {
      expect(ex(1299).toDomainException(operation: 'x').code,
          DomainErrorCode.validation);
      expect(ex(275).toDomainException(operation: 'x').code,
          DomainErrorCode.validation);
    });

    test('unknown constraint subtype -> conflict', () {
      // resultCode 19 with an unmapped extended code falls through to conflict.
      expect(ex(19).toDomainException(operation: 'x').code,
          DomainErrorCode.conflict);
    });

    test('SQLITE_AUTH (23) -> unauthorized', () {
      expect(ex(23).toDomainException(operation: 'x').code,
          DomainErrorCode.unauthorized);
    });

    test('any other error -> storage', () {
      // SQLITE_ERROR (1) and SQLITE_BUSY (5) are generic storage failures.
      expect(ex(1).toDomainException(operation: 'x').code,
          DomainErrorCode.storage);
      expect(ex(5).toDomainException(operation: 'x').code,
          DomainErrorCode.storage);
    });
  });

  group('toDomainException context', () {
    test('records operation, sqlite codes and merges extra context', () {
      final domain = ex(2067).toDomainException(
        operation: 'addPlayer',
        context: {'firstName': 'Amy'},
      );

      expect(domain.message, isNull); // UI decides the user-facing text
      expect(domain.cause, isA<SqliteException>());
      expect(domain.context, {
        'op': 'addPlayer',
        'firstName': 'Amy',
        'sqliteCode': 19,
        'sqliteExtendedCode': 2067,
      });
    });
  });

  group('against a real SQLite constraint', () {
    test('a genuine UNIQUE violation maps to conflict', () async {
      final db = createTestDb();
      addTearDown(db.close);

      await db.seedGameType(name: 'Bridge');

      // Game type names are unique -> inserting a duplicate throws.
      SqliteException? caught;
      try {
        await db.seedGameType(name: 'Bridge');
      } on SqliteException catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(
        caught!.toDomainException(operation: 'addGameType').code,
        DomainErrorCode.conflict,
      );
    });
  });
}
