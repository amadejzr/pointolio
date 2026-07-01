import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/features/scoring/presentation/widgets/calculator_keyboard/calculator_keyboard_exports.dart';

/// Guards the landscape fix: the keyboard must be sized off the shortest side
/// (real tablet detection) and shrink on short viewports, so a landscape phone
/// no longer gets a keyboard taller than the screen.
void main() {
  Future<double> keyboardHeight(WidgetTester tester, Size size) async {
    late double height;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: Builder(
          builder: (context) {
            height = getCalculatorKeyboardHeight(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return height;
  }

  testWidgets('landscape phone keyboard fits and is shorter than portrait', (
    tester,
  ) async {
    final portrait = await keyboardHeight(tester, const Size(400, 800));
    final landscape = await keyboardHeight(tester, const Size(800, 390));

    // The compact landscape keyboard is shorter...
    expect(landscape, lessThan(portrait));
    // ...and crucially fits within the landscape screen height.
    expect(landscape, lessThan(390));
  });

  testWidgets('a real tablet still gets the roomy keyboard', (tester) async {
    final phone = await keyboardHeight(tester, const Size(400, 800));
    final tablet = await keyboardHeight(tester, const Size(834, 1112));

    expect(tablet, greaterThan(phone));
  });
}
