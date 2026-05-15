import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const _prefKey = 'app_theme_mode';

  AppThemeMode _mode;

  ThemeProvider(this._mode) {
    AppColors.applyMode(_mode);
  }

  AppThemeMode get mode => _mode;

  ThemeData get themeData => AppTheme.themeFor(_mode);

  static Future<ThemeProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    final mode = AppThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => AppThemeMode.dark,
    );
    return ThemeProvider(mode);
  }

  Future<void> setMode(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    AppColors.applyMode(mode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }

  String get modeName {
    switch (_mode) {
      case AppThemeMode.dark:  return 'Dark';
      case AppThemeMode.gray:  return 'Gray';
      case AppThemeMode.light: return 'Light';
    }
  }
}
