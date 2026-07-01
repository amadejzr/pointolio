import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/features/settings/presentation/widgets/settings_section.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData(extensions: const [PointolioTheme.light]),
    home: Scaffold(body: child),
  );

  testWidgets('renders an uppercased header title and its children', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        const SettingsSection(
          title: 'About',
          children: [Text('Row A'), Text('Row B')],
        ),
      ),
    );

    final header = find.text('ABOUT');
    expect(header, findsOneWidget);
    expect(
      tester.getSemantics(header).getSemanticsData().flagsCollection.isHeader,
      isTrue,
    );
    expect(find.text('Row A'), findsOneWidget);
    expect(find.text('Row B'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('places a divider between rows only', (tester) async {
    await tester.pumpWidget(
      wrap(
        const SettingsSection(
          children: [Text('Row A'), Text('Row B'), Text('Row C')],
        ),
      ),
    );

    // Three rows -> two separators between them.
    expect(find.byType(Divider), findsNWidgets(2));
  });
}
