import 'package:flutter_test/flutter_test.dart';
import 'package:racepace/domain/settings/app_settings.dart';

void main() {
  test('AppSettings defaults are defined', () {
    expect(AppSettings.defaultUnit, Unit.kilometers);
    expect(AppSettings.defaultLanguage, AppLanguage.system);
    expect(AppSettings.defaultTheme, AppThemeMode.system);
  });

  test('AppSettings copyWith updates only provided values', () {
    const base = AppSettings(
      unit: Unit.kilometers,
      language: AppLanguage.english,
      theme: AppThemeMode.light,
    );

    final updated = base.copyWith(theme: AppThemeMode.dark);

    expect(updated.unit, Unit.kilometers);
    expect(updated.language, AppLanguage.english);
    expect(updated.theme, AppThemeMode.dark);
  });

  test('UnitStorage codes and fallbacks', () {
    expect(Unit.kilometers.code, 'km');
    expect(Unit.miles.code, 'mi');
    expect(UnitStorage.fromCode('mi'), Unit.miles);
    expect(UnitStorage.fromCode('unknown'), Unit.kilometers);
  });

  test('AppLanguageStorage codes and fallbacks', () {
    expect(AppLanguage.system.code, 'system');
    expect(AppLanguage.english.code, 'en');
    expect(AppLanguage.russian.code, 'ru');
    expect(AppLanguageStorage.fromCode('system'), AppLanguage.system);
    expect(AppLanguageStorage.fromCode('ru'), AppLanguage.russian);
    expect(AppLanguageStorage.fromCode('unknown'), AppLanguage.english);
  });

  test('AppThemeModeStorage codes and fallbacks', () {
    expect(AppThemeMode.system.code, 'system');
    expect(AppThemeMode.light.code, 'light');
    expect(AppThemeMode.dark.code, 'dark');
    expect(AppThemeModeStorage.fromCode('light'), AppThemeMode.light);
    expect(AppThemeModeStorage.fromCode('dark'), AppThemeMode.dark);
    expect(AppThemeModeStorage.fromCode('unknown'), AppThemeMode.system);
  });
}
