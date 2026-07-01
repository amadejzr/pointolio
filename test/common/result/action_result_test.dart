import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/result/action_result.dart';

void main() {
  // `showToast` is UI glue (needs a BuildContext / SnackBar) and is exercised by
  // widget-level tests; here we pin down the data semantics the cubits rely on.
  group('ActionResult', () {
    test('ActionSuccess carries an optional message', () {
      const withMessage = ActionSuccess('Player added successfully');
      const withoutMessage = ActionSuccess();

      expect(withMessage, isA<ActionResult>());
      expect(withMessage.message, 'Player added successfully');
      expect(withoutMessage.message, isNull);
    });

    test('ActionFailure always carries a message', () {
      const failure = ActionFailure('Failed to add player');
      expect(failure, isA<ActionResult>());
      expect(failure.message, 'Failed to add player');
    });

    test('success and failure are distinct branches of the sealed type', () {
      const ActionResult success = ActionSuccess('ok');
      const ActionResult failure = ActionFailure('bad');

      expect(success, isA<ActionSuccess>());
      expect(success, isNot(isA<ActionFailure>()));
      expect(failure, isA<ActionFailure>());
      expect(failure, isNot(isA<ActionSuccess>()));
    });
  });
}
