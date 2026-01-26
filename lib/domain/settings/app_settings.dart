enum Unit { kilometers, miles }

enum AppLanguage { system, english, russian }

enum AppThemeMode { system, light, dark }

class AppSettings {
  const AppSettings({
    required this.unit,
    required this.language,
    required this.theme,
  });

  static const Unit defaultUnit = Unit.kilometers;
  static const AppLanguage defaultLanguage = AppLanguage.english;
  static const AppThemeMode defaultTheme = AppThemeMode.system;

  final Unit unit;
  final AppLanguage language;
  final AppThemeMode theme;

  AppSettings copyWith({
    Unit? unit,
    AppLanguage? language,
    AppThemeMode? theme,
  }) {
    return AppSettings(
      unit: unit ?? this.unit,
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }
}

extension UnitStorage on Unit {
  String get code => switch (this) {
    Unit.kilometers => 'km',
    Unit.miles => 'mi',
  };

  static Unit fromCode(String code) {
    return switch (code) {
      'mi' => Unit.miles,
      _ => Unit.kilometers,
    };
  }
}

extension AppLanguageStorage on AppLanguage {
  String get code => switch (this) {
    AppLanguage.system => 'system',
    AppLanguage.english => 'en',
    AppLanguage.russian => 'ru',
  };

  static AppLanguage fromCode(String code) {
    return switch (code) {
      'system' => AppLanguage.system,
      'ru' => AppLanguage.russian,
      _ => AppLanguage.english,
    };
  }
}

extension AppThemeModeStorage on AppThemeMode {
  String get code => switch (this) {
    AppThemeMode.system => 'system',
    AppThemeMode.light => 'light',
    AppThemeMode.dark => 'dark',
  };

  static AppThemeMode fromCode(String code) {
    return switch (code) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };
  }
}
