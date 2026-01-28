// Used to display where the screenshots are saved
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main(List<String> args) async {
  // Determine output directory based on argument
  // Default to 'ios' if no argument provided
  final platform = args.isNotEmpty && args[0] == 'ipad' ? 'ipad' : 'ios';
  final outputDir = 'screenshots/output/output-$platform';

  // Create output directory if it doesn't exist
  final directory = Directory(outputDir);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  print('📸 Generating screenshots for: $platform');
  print('📂 Output directory: $outputDir');

  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('$outputDir/$name.png');
      await file.writeAsBytes(bytes);
      print('✅ Screenshot saved: ${file.path}');
      return true;
    },
  );
}
