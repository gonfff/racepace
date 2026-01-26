import 'package:pacenote/application/settings/settings_repository.dart';
import 'package:pacenote/domain/settings/app_settings.dart';
import 'package:pacenote/infrastructure/database/app_database.dart';

class _SettingsStorageKeys {
  static const String unit = 'unit';
  static const String language = 'language';
  static const String theme = 'theme';
}

class SettingsRepositoryLocal implements SettingsRepository {
  SettingsRepositoryLocal(this._database);

  final AppDatabase _database;

  @override
  Future<AppSettings> loadSettings() async {
    final unit = await _database.getSetting(_SettingsStorageKeys.unit);
    final language = await _database.getSetting(_SettingsStorageKeys.language);
    final theme = await _database.getSetting(_SettingsStorageKeys.theme);

    return AppSettings(
      unit: unit == null ? AppSettings.defaultUnit : UnitStorage.fromCode(unit),
      language: language == null
          ? AppSettings.defaultLanguage
          : AppLanguageStorage.fromCode(language),
      theme: theme == null
          ? AppSettings.defaultTheme
          : AppThemeModeStorage.fromCode(theme),
    );
  }

  @override
  Future<void> setUnit(Unit unit) =>
      _database.setSetting(_SettingsStorageKeys.unit, unit.code);

  @override
  Future<void> setLanguage(AppLanguage language) =>
      _database.setSetting(_SettingsStorageKeys.language, language.code);

  @override
  Future<void> setTheme(AppThemeMode theme) =>
      _database.setSetting(_SettingsStorageKeys.theme, theme.code);
}
