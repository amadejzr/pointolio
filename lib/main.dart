import 'package:flutter/material.dart';
import 'package:scoreio/common/di/locator.dart';
import 'package:scoreio/common/theme/app_theme.dart';
import 'package:scoreio/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pointolio',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
