import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const ThemeState()) {
    _loadTheme();
  }

  final SharedPreferences _prefs;
  static const _themeKey = 'app_theme_mode';

  void _loadTheme() {
    final savedTheme = _prefs.getString(_themeKey);
    final themeMode = AppThemeModeX.fromString(savedTheme);
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> setTheme(AppThemeMode themeMode) async {
    await _prefs.setString(_themeKey, themeMode.name);
    emit(state.copyWith(themeMode: themeMode));
  }
}
