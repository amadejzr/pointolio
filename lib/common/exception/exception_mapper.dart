import 'package:drift/native.dart';
import 'package:scoreio/common/exception/domain_exception.dart';

extension SqliteExceptionDomainX on SqliteException {
  DomainException toDomainException({
    required String operation,
    Map<String, Object?>? context,
  }) {
    return DomainException(
      _mapCode(),
      // leave message null -> UI decides user-facing text
      context: {
        'op': operation,
        ...?context,
        'sqliteCode': resultCode,
        'sqliteExtendedCode': extendedResultCode,
      },
      cause: this,
    );
  }

  DomainErrorCode _mapCode() {
    if (resultCode == 19) {
      // SQLITE_CONSTRAINT
      return switch (extendedResultCode) {
        2067 || 1555 => DomainErrorCode.conflict, // UNIQUE / PRIMARY KEY
        787 => DomainErrorCode.conflict, // FOREIGN KEY
        1299 || 275 => DomainErrorCode.validation, // NOT NULL / CHECK
        _ => DomainErrorCode.conflict,
      };
    }
    if (resultCode == 23) return DomainErrorCode.unauthorized; // SQLITE_AUTH
    return DomainErrorCode.storage;
  }
}
