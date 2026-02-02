import 'package:flutter/cupertino.dart';
import 'package:racepace/application/calculator/calculator_repository.dart';
import 'package:racepace/application/calculator/calculator_service.dart';
import 'package:racepace/application/settings/settings_repository.dart';
import 'package:racepace/application/settings/settings_service.dart';
import 'package:racepace/domain/calculator/calculation.dart';
import 'package:racepace/domain/settings/app_settings.dart';
import 'package:racepace/presentation/app/calculator_scope.dart';
import 'package:racepace/presentation/app/settings_scope.dart';
import 'package:racepace/presentation/features/settings/settings_notifier.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';

SettingsNotifier createTestSettingsNotifier({AppSettings? settings}) {
  final repository = FakeSettingsRepository(settings: settings);
  final service = SettingsService(repository);
  final notifier = SettingsNotifier(service);
  return notifier;
}

CalculatorService createTestCalculatorService({
  List<Calculation>? seed,
}) {
  return CalculatorService(FakeCalculatorRepository(seed: seed));
}

Widget buildTestApp({
  required Widget child,
  SettingsNotifier? settingsNotifier,
  CalculatorService? calculatorService,
}) {
  Widget wrapped = child;
  if (calculatorService != null) {
    wrapped = CalculatorScope(service: calculatorService, child: wrapped);
  }
  if (settingsNotifier != null) {
    wrapped = SettingsScope(controller: settingsNotifier, child: wrapped);
  }

  return CupertinoApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: wrapped,
  );
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({AppSettings? settings})
      : _settings = settings ??
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
