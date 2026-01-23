import 'package:flutter/material.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/common/theme/app_theme.dart';
import 'package:pointolio/router/app_router.dart';

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
