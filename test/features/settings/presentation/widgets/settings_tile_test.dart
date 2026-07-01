import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/features/settings/presentation/widgets/settings_tile.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData(extensions: const [PointolioTheme.light]),
    home: Scaffold(body: child),
  );

  testWidgets('renders title and subtitle', (tester) async {
    await tester.pumpWidget(
      wrap(
        SettingsTile(
          icon: Icons.shield_outlined,
          title: 'Privacy Policy',
          subtitle: 'How your data is handled',
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('How your data is handled'), findsOneWidget);
  });

  testWidgets('is a single labelled button exposing its hint', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        SettingsTile(
          icon: Icons.help_outline_rounded,
          title: 'Support',
          subtitle: 'Get help and usage info',
          semanticHint: 'Opens in your browser',
          onTap: () {},
        ),
      ),
    );

    final node = find.bySemanticsLabel('Support');
    expect(node, findsOneWidget);
    final data = tester.getSemantics(node).getSemanticsData();
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hint, 'Opens in your browser');
    // The decorative subtitle is not announced as its own node.
    expect(find.bySemanticsLabel('Get help and usage info'), findsNothing);

    handle.dispose();
  });

  testWidgets('invokes onTap when pressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        SettingsTile(
          icon: Icons.delete_outline_rounded,
          title: 'Delete all data',
          destructive: true,
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.text('Delete all data'));
    expect(taps, 1);
  });

  testWidgets('destructive tile still exposes its label as a button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        SettingsTile(
          icon: Icons.delete_outline_rounded,
          title: 'Delete all data',
          destructive: true,
          onTap: () {},
        ),
      ),
    );

    final node = find.bySemanticsLabel('Delete all data');
    expect(node, findsOneWidget);
    expect(
      tester.getSemantics(node).getSemanticsData().flagsCollection.isButton,
      isTrue,
    );

    handle.dispose();
  });
}
