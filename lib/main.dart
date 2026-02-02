import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/common/theme/app_theme.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_cubit.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_state.dart';
import 'package:pointolio/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(prefs: locator<SharedPreferences>()),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Pointolio',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.themeMode.toThemeMode(),
            initialRoute: AppRouter.home,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
