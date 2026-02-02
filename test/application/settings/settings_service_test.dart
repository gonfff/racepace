import 'package:flutter_test/flutter_test.dart';
import 'package:racepace/application/settings/settings_repository.dart';
import 'package:racepace/application/settings/settings_service.dart';
import 'package:racepace/domain/settings/app_settings.dart';

void main() {
  test('SettingsService delegates to repository', () async {
    final repository = _FakeSettingsRepository();
    final service = SettingsService(repository);

    final loaded = await service.load();
    expect(loaded, repository.loadReturn);
    expect(repository.loadCalls, 1);

    await service.updateUnit(Unit.miles);
    expect(repository.setUnitCalls, 1);
    expect(repository.lastUnit, Unit.miles);

    await service.updateLanguage(AppLanguage.russian);
    expect(repository.setLanguageCalls, 1);
    expect(repository.lastLanguage, AppLanguage.russian);

    await service.updateTheme(AppThemeMode.dark);
    expect(repository.setThemeCalls, 1);
    expect(repository.lastTheme, AppThemeMode.dark);
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  int loadCalls = 0;
  int setUnitCalls = 0;
  int setLanguageCalls = 0;
  int setThemeCalls = 0;
  Unit? lastUnit;
  AppLanguage? lastLanguage;
  AppThemeMode? lastTheme;

  final loadReturn = const AppSettings(
    unit: Unit.kilometers,
    language: AppLanguage.english,
    theme: AppThemeMode.light,
  );

  @override
  Future<AppSettings> loadSettings() async {
    loadCalls += 1;
    return loadReturn;
  }

  @override
  Future<void> setUnit(Unit unit) async {
    setUnitCalls += 1;
    lastUnit = unit;
  }

  @override
  Future<void> setLanguage(AppLanguage language) async {
    setLanguageCalls += 1;
    lastLanguage = language;
  }

  @override
  Future<void> setTheme(AppThemeMode theme) async {
    setThemeCalls += 1;
    lastTheme = theme;
  }
}
