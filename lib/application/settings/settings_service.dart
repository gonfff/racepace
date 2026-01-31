import 'package:racepace/application/settings/settings_repository.dart';
import 'package:racepace/domain/settings/app_settings.dart';

class SettingsService {
  SettingsService(this._repository);

  final SettingsRepository _repository;

  Future<AppSettings> load() => _repository.loadSettings();

  Future<void> updateUnit(Unit unit) => _repository.setUnit(unit);

  Future<void> updateLanguage(AppLanguage language) =>
      _repository.setLanguage(language);

  Future<void> updateTheme(AppThemeMode theme) => _repository.setTheme(theme);
}
