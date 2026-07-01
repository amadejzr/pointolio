import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/ui/widgets/page_app_bar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData(extensions: const [PointolioTheme.light]),
    home: Scaffold(body: child),
  );

  testWidgets('shows the title as a header', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(const PageAppBar(title: 'Settings', onBack: _noop)),
    );

    final title = find.bySemanticsLabel('Settings');
    expect(title, findsOneWidget);
    expect(
      tester.getSemantics(title).getSemanticsData().flagsCollection.isHeader,
      isTrue,
    );

    handle.dispose();
  });

  testWidgets('back button is a labelled button that fires onBack', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var backs = 0;
    await tester.pumpWidget(
      wrap(PageAppBar(title: 'Settings', onBack: () => backs++)),
    );

    final back = find.bySemanticsLabel('Back');
    expect(back, findsOneWidget);
    expect(
      tester.getSemantics(back).getSemanticsData().flagsCollection.isButton,
      isTrue,
    );

    await tester.tap(back);
    expect(backs, 1);

    handle.dispose();
  });

  testWidgets('renders a trailing action when provided', (tester) async {
    await tester.pumpWidget(
      wrap(
        const PageAppBar(
          title: 'Settings',
          onBack: _noop,
          action: Icon(Icons.more_horiz),
        ),
      ),
    );

    expect(find.byIcon(Icons.more_horiz), findsOneWidget);
  });
}

void _noop() {}
