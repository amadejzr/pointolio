import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_cubit.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const themeKey = 'app_theme_mode';

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('initial load', () {
    test('defaults to system when nothing is stored', () async {
      final prefs = await prefsWith({});
      final cubit = ThemeCubit(prefs: prefs);

      expect(cubit.state.themeMode, AppThemeMode.system);
      await cubit.close();
    });

    test('restores a previously saved theme', () async {
      final prefs = await prefsWith({themeKey: 'dark'});
      final cubit = ThemeCubit(prefs: prefs);

      expect(cubit.state.themeMode, AppThemeMode.dark);
      await cubit.close();
    });

    test('falls back to system for an unrecognised value', () async {
      final prefs = await prefsWith({themeKey: 'banana'});
      final cubit = ThemeCubit(prefs: prefs);

      expect(cubit.state.themeMode, AppThemeMode.system);
      await cubit.close();
    });
  });

  group('setTheme', () {
    test('emits the new mode and persists it', () async {
      final prefs = await prefsWith({});
      final cubit = ThemeCubit(prefs: prefs);

      await cubit.setTheme(AppThemeMode.light);

      expect(cubit.state.themeMode, AppThemeMode.light);
      expect(prefs.getString(themeKey), 'light');
      await cubit.close();
    });
  });

  group('AppThemeModeX', () {
    test('fromString maps known values and defaults to system', () {
      expect(AppThemeModeX.fromString('light'), AppThemeMode.light);
      expect(AppThemeModeX.fromString('dark'), AppThemeMode.dark);
      expect(AppThemeModeX.fromString(null), AppThemeMode.system);
      expect(AppThemeModeX.fromString('whatever'), AppThemeMode.system);
    });
  });
}
