/// Calculator expression evaluator and state management.
///
/// Handles parsing and evaluation of arithmetic expressions with + and -.
class CalculatorLogic {
  /// Current expression string (e.g., "50+30-10").
  String expression = '';

  /// Whether the expression is empty.
  bool get isEmpty => expression.isEmpty;

  /// Current evaluated result, or null if expression is invalid/empty.
  int? get result => _evaluate(expression);

  /// Display value for the text field (result as string, or empty).
  String get displayValue {
    final r = result;
    return r?.toString() ?? '';
  }

  /// Reset expression to empty.
  void clear() {
    expression = '';
  }

  /// Append a digit (0-9) to the expression.
  void appendDigit(String digit) {
    expression += digit;
  }

  /// Append an operator (+/-) to the expression.
  /// If expression is empty, starts with "0" prefix.
  /// If last char is already an operator, replaces it.
  void appendOperator(String op) {
    if (expression.isEmpty) {
      expression = '0$op';
    } else {
      final lastChar = expression[expression.length - 1];
      if (lastChar == '+' || lastChar == '-') {
        expression = '${expression.substring(0, expression.length - 1)}$op';
      } else {
        expression += op;
      }
    }
  }

  /// Delete the last character from the expression.
  void backspace() {
    if (expression.isNotEmpty) {
      expression = expression.substring(0, expression.length - 1);
    }
  }

  /// Finalize the expression: evaluate and return the result.
  /// Resets the internal expression after evaluation.
  int? finalize() {
    final r = result;
    expression = '';
    return r;
  }

  /// Parse and evaluate arithmetic expression with + and -.
  int? _evaluate(String expr) {
    if (expr.isEmpty) return null;

    try {
      final cleaned = expr.replaceAll(' ', '');
      if (cleaned.isEmpty) return null;

      var result = 0;
      var currentNum = '';
      var operation = '+';

      for (var i = 0; i < cleaned.length; i++) {
        final char = cleaned[i];

        if (char == '+' || char == '-') {
          if (currentNum.isNotEmpty) {
            final num = int.tryParse(currentNum) ?? 0;
            result = operation == '+' ? result + num : result - num;
          }
          operation = char;
          currentNum = '';
        } else if (RegExp('[0-9]').hasMatch(char)) {
          currentNum += char;
        }
      }

      // Process the last number
      if (currentNum.isNotEmpty) {
        final num = int.tryParse(currentNum) ?? 0;
        result = operation == '+' ? result + num : result - num;
      }

      return result;
    } on Exception {
      return null;
    }
  }
}
