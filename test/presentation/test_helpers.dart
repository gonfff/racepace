import 'package:flutter/cupertino.dart';
import 'package:racepace/application/calculator/calculator_repository.dart';
import 'package:racepace/application/calculator/calculator_service.dart';
import 'package:racepace/application/splits/splits_presets_repository.dart';
import 'package:racepace/application/splits/splits_presets_service.dart';
import 'package:racepace/application/settings/settings_repository.dart';
import 'package:racepace/application/settings/settings_service.dart';
import 'package:racepace/domain/calculator/calculation.dart';
import 'package:racepace/domain/settings/app_settings.dart';
import 'package:racepace/domain/splits/splits_preset.dart';
import 'package:racepace/presentation/app/calculator_scope.dart';
import 'package:racepace/presentation/app/settings_scope.dart';
import 'package:racepace/presentation/app/splits_presets_scope.dart';
import 'package:racepace/presentation/features/settings/settings_notifier.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';

SettingsNotifier createTestSettingsNotifier({AppSettings? settings}) {
  final repository = FakeSettingsRepository(settings: settings);
  final service = SettingsService(repository);
  final notifier = SettingsNotifier(service);
  return notifier;
}

CalculatorService createTestCalculatorService({List<Calculation>? seed}) {
  return CalculatorService(FakeCalculatorRepository(seed: seed));
}

SplitsPresetsService createTestSplitsPresetsService({
  List<SplitsPreset>? seed,
}) {
  return SplitsPresetsService(FakeSplitsPresetsRepository(seed: seed));
}

Widget buildTestApp({
  required Widget child,
  SettingsNotifier? settingsNotifier,
  CalculatorService? calculatorService,
  SplitsPresetsService? splitsPresetsService,
}) {
  Widget app = CupertinoApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );

  app = SplitsPresetsScope(
    service: splitsPresetsService ?? createTestSplitsPresetsService(),
    child: app,
  );

  if (settingsNotifier != null) {
    app = SettingsScope(controller: settingsNotifier, child: app);
  }

  if (calculatorService != null) {
    app = CalculatorScope(service: calculatorService, child: app);
  }

  return app;
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({AppSettings? settings})
    : _settings =
          settings ??
          const AppSettings(
            unit: AppSettings.defaultUnit,
            language: AppSettings.defaultLanguage,
            theme: AppSettings.defaultTheme,
          );

  AppSettings _settings;

  @override
  Future<AppSettings> loadSettings() async => _settings;

  @override
  Future<void> setLanguage(AppLanguage language) async {
    _settings = _settings.copyWith(language: language);
  }

  @override
  Future<void> setTheme(AppThemeMode theme) async {
    _settings = _settings.copyWith(theme: theme);
  }

  @override
  Future<void> setUnit(Unit unit) async {
    _settings = _settings.copyWith(unit: unit);
  }
}

class FakeCalculatorRepository implements CalculatorRepository {
  FakeCalculatorRepository({List<Calculation>? seed})
    : _entries = List.of(seed ?? const []);

  final List<Calculation> _entries;
  int _nextId = 1;

  @override
  Future<List<Calculation>> loadCalculations() async => List.of(_entries);

  @override
  Future<Calculation> addCalculation(CalculationDraft draft) async {
    final entry = Calculation(
      id: _nextId,
      distance: draft.distance,
      pace: draft.pace,
      time: draft.time,
      unit: draft.unit,
      createdAt: draft.createdAt,
    );
    _nextId += 1;
    _entries.insert(0, entry);
    return entry;
  }

  @override
  Future<void> deleteCalculation(int id) async {
    _entries.removeWhere((entry) => entry.id == id);
  }
}

class FakeSplitsPresetsRepository implements SplitsPresetsRepository {
  FakeSplitsPresetsRepository({List<SplitsPreset>? seed})
    : _presets = List.of(seed ?? const []);

  final List<SplitsPreset> _presets;

  @override
  Future<void> deletePreset(int id) async {
    _presets.removeWhere((preset) => preset.id == id);
  }

  @override
  Future<List<SplitsPreset>> loadPresets() async => List.of(_presets);

  @override
  Future<void> savePreset(SplitsPreset preset) async {
    _presets.removeWhere((item) => item.id == preset.id);
    _presets.insert(0, preset);
  }
}
