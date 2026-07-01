import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/features/scoring/presentation/widgets/calculator_keyboard/calculator_logic.dart';

void main() {
  late CalculatorLogic calc;

  setUp(() {
    calc = CalculatorLogic();
  });

  group('initial state', () {
    test('starts empty with null result', () {
      expect(calc.isEmpty, isTrue);
      expect(calc.expression, '');
      expect(calc.result, isNull);
      expect(calc.displayValue, '');
    });
  });

  group('appendDigit', () {
    test('builds a multi-digit number', () {
      calc
        ..appendDigit('1')
        ..appendDigit('2')
        ..appendDigit('3');
      expect(calc.expression, '123');
      expect(calc.result, 123);
      expect(calc.displayValue, '123');
      expect(calc.isEmpty, isFalse);
    });
  });

  group('appendOperator', () {
    test('prefixes 0 when starting with an operator', () {
      calc.appendOperator('-');
      expect(calc.expression, '0-');
      // Trailing operator: only the leading 0 has been consumed.
      expect(calc.result, 0);
    });

    test('replaces a trailing operator instead of stacking', () {
      calc
        ..appendDigit('5')
        ..appendOperator('+')
        ..appendOperator('-');
      expect(calc.expression, '5-');
    });

    test('appends an operator after a number', () {
      calc
        ..appendDigit('5')
        ..appendOperator('+');
      expect(calc.expression, '5+');
    });
  });

  group('evaluation', () {
    test('adds and subtracts left to right', () {
      calc
        ..appendDigit('5')
        ..appendDigit('0')
        ..appendOperator('+')
        ..appendDigit('3')
        ..appendDigit('0')
        ..appendOperator('-')
        ..appendDigit('1')
        ..appendDigit('0');
      // 50 + 30 - 10
      expect(calc.expression, '50+30-10');
      expect(calc.result, 70);
    });

    test('supports a negative net result', () {
      calc
        ..appendOperator('-')
        ..appendDigit('5');
      // 0 - 5
      expect(calc.result, -5);
    });

    test('ignores a trailing operator when evaluating', () {
      calc
        ..appendDigit('9')
        ..appendOperator('+');
      expect(calc.result, 9);
    });
  });

  group('backspace', () {
    test('removes the last character', () {
      calc
        ..appendDigit('1')
        ..appendDigit('2')
        ..backspace();
      expect(calc.expression, '1');
      expect(calc.result, 1);
    });

    test('is a no-op on an empty expression', () {
      calc.backspace();
      expect(calc.expression, '');
    });
  });

  group('clear', () {
    test('resets the expression', () {
      calc
        ..appendDigit('4')
        ..appendDigit('2')
        ..clear();
      expect(calc.isEmpty, isTrue);
      expect(calc.result, isNull);
    });
  });

  group('finalize', () {
    test('returns the result and resets the expression', () {
      calc
        ..appendDigit('1')
        ..appendDigit('0')
        ..appendOperator('+')
        ..appendDigit('5');
      final result = calc.finalize();
      expect(result, 15);
      expect(calc.expression, '');
      expect(calc.isEmpty, isTrue);
    });

    test('returns null when nothing was entered', () {
      expect(calc.finalize(), isNull);
    });
  });
}
