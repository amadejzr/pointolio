import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('screenshots/output/$name.png');
      await file.writeAsBytes(bytes);
      // Used to display where the screenshots are saved
      // ignore: avoid_print
      print('Screenshot saved: ${file.path}');
      return true;
    },
  );
}
