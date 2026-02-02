import 'package:flutter/foundation.dart';
import 'package:racepace/application/settings/settings_service.dart';
import 'package:racepace/domain/settings/app_settings.dart';

class SettingsNotifier extends ChangeNotifier {
  SettingsNotifier(this._service);

  final SettingsService _service;
  AppSettings _settings = const AppSettings(
    unit: AppSettings.defaultUnit,
    language: AppSettings.defaultLanguage,
    theme: AppSettings.defaultTheme,
  );

  AppSettings get settings => _settings;

  Future<void> load() async {
    _settings = await _service.load();
    notifyListeners();
  }

  Future<void> updateUnit(Unit unit) async {
    if (unit == _settings.unit) return;
    _settings = _settings.copyWith(unit: unit);
    notifyListeners();
    await _service.updateUnit(unit);
  }

  Future<void> updateLanguage(AppLanguage language) async {
    if (language == _settings.language) return;
    _settings = _settings.copyWith(language: language);
    notifyListeners();
    await _service.updateLanguage(language);
  }

  Future<void> updateTheme(AppThemeMode theme) async {
    if (theme == _settings.theme) return;
    _settings = _settings.copyWith(theme: theme);
    notifyListeners();
    await _service.updateTheme(theme);
  }
}
