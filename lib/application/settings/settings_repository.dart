import 'package:pacenote/domain/settings/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> loadSettings();
  Future<void> setUnit(Unit unit);
  Future<void> setLanguage(AppLanguage language);
  Future<void> setTheme(AppThemeMode theme);
}
