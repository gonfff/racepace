import 'package:flutter_test/flutter_test.dart';
import 'package:racepace/application/settings/settings_repository.dart';
import 'package:racepace/application/settings/settings_service.dart';
import 'package:racepace/domain/settings/app_settings.dart';
import 'package:racepace/presentation/features/settings/settings_notifier.dart';

void main() {
  test('SettingsNotifier load updates settings and notifies', () async {
    final repository = _FakeSettingsRepository(
      loadReturn: const AppSettings(
        unit: Unit.miles,
        language: AppLanguage.russian,
        theme: AppThemeMode.dark,
      ),
    );
    final service = SettingsService(repository);
    final notifier = SettingsNotifier(service);

    var notifyCount = 0;
    notifier.addListener(() => notifyCount += 1);

    await notifier.load();

    expect(notifier.settings.unit, Unit.miles);
    expect(notifier.settings.language, AppLanguage.russian);
    expect(notifier.settings.theme, AppThemeMode.dark);
    expect(notifyCount, 1);
    expect(repository.loadCalls, 1);
  });

  test('SettingsNotifier updateUnit ignores same value', () async {
    final repository = _FakeSettingsRepository();
    final service = SettingsService(repository);
    final notifier = SettingsNotifier(service);

    var notifyCount = 0;
    notifier.addListener(() => notifyCount += 1);

    await notifier.updateUnit(AppSettings.defaultUnit);

    expect(notifyCount, 0);
    expect(repository.setUnitCalls, 0);
  });

  test(
    'SettingsNotifier updateLanguage changes settings and notifies',
    () async {
      final repository = _FakeSettingsRepository();
      final service = SettingsService(repository);
      final notifier = SettingsNotifier(service);

      var notifyCount = 0;
      notifier.addListener(() => notifyCount += 1);

      await notifier.updateLanguage(AppLanguage.russian);

      expect(notifier.settings.language, AppLanguage.russian);
      expect(notifyCount, 1);
      expect(repository.setLanguageCalls, 1);
      expect(repository.lastLanguage, AppLanguage.russian);
    },
  );

  test('SettingsNotifier updateTheme changes settings and notifies', () async {
    final repository = _FakeSettingsRepository();
    final service = SettingsService(repository);
    final notifier = SettingsNotifier(service);

    var notifyCount = 0;
    notifier.addListener(() => notifyCount += 1);

    await notifier.updateTheme(AppThemeMode.dark);

    expect(notifier.settings.theme, AppThemeMode.dark);
    expect(notifyCount, 1);
    expect(repository.setThemeCalls, 1);
    expect(repository.lastTheme, AppThemeMode.dark);
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository({
    this.loadReturn = const AppSettings(
      unit: AppSettings.defaultUnit,
      language: AppSettings.defaultLanguage,
      theme: AppSettings.defaultTheme,
    ),
  });

  int loadCalls = 0;
  int setUnitCalls = 0;
  int setLanguageCalls = 0;
  int setThemeCalls = 0;
  Unit? lastUnit;
  AppLanguage? lastLanguage;
  AppThemeMode? lastTheme;

  final AppSettings loadReturn;

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
