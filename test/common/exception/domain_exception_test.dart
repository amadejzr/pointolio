import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/exception/domain_exception.dart';

void main() {
  group('DomainException', () {
    test('stores its code, message, context and cause', () {
      final cause = Exception('underlying');
      const context = {'op': 'deleteGame', 'gameId': 7};
      final ex = DomainException(
        DomainErrorCode.notFound,
        message: 'nope',
        context: context,
        cause: cause,
      );

      expect(ex.code, DomainErrorCode.notFound);
      expect(ex.message, 'nope');
      expect(ex.context, context);
      expect(ex.cause, cause);
      expect(ex, isA<Exception>());
    });

    test('defaults message, context and cause to null', () {
      const ex = DomainException(DomainErrorCode.storage);
      expect(ex.message, isNull);
      expect(ex.context, isNull);
      expect(ex.cause, isNull);
    });

    test('toString includes the code and fields', () {
      const ex = DomainException(
        DomainErrorCode.conflict,
        message: 'dup',
        context: {'op': 'addPlayer'},
      );

      final text = ex.toString();
      expect(text, startsWith('DomainException('));
      expect(text, contains('DomainErrorCode.conflict'));
      expect(text, contains('dup'));
      expect(text, contains('op'));
    });

    test('exposes every error code', () {
      expect(DomainErrorCode.values, [
        DomainErrorCode.notFound,
        DomainErrorCode.storage,
        DomainErrorCode.conflict,
        DomainErrorCode.validation,
        DomainErrorCode.unauthorized,
      ]);
    });
  });
}
