import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/features/sharing/presentation/widgets/glass_panel.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 100, height: 100, child: child),
    ),
  );

  testWidgets('GlassPanel tints its fill by the opacity', (tester) async {
    await tester.pumpWidget(
      wrap(const GlassPanel(opacity: 0.5, child: SizedBox())),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(GlassPanel),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color!.a, closeTo(0.5, 0.001));
  });
}
