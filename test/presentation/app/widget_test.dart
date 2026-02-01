// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:racepace/application/calculator/calculator_repository.dart';
import 'package:racepace/application/calculator/calculator_service.dart';
import 'package:racepace/application/settings/settings_repository.dart';
import 'package:racepace/application/settings/settings_service.dart';
import 'package:racepace/domain/calculator/calculation.dart';
import 'package:racepace/domain/settings/app_settings.dart';
import 'package:racepace/presentation/app/racepace_app.dart';
import 'package:racepace/presentation/features/settings/settings_notifier.dart';

void main() {
  testWidgets('Racepace app builds', (WidgetTester tester) async {
    final repository = _FakeSettingsRepository();
    final service = SettingsService(repository);
    final notifier = SettingsNotifier(service);
    await notifier.load();
    final calculatorService = CalculatorService(_FakeCalculatorRepository());

    await tester.pumpWidget(
      RacepaceApp(
        settingsNotifier: notifier,
        calculatorService: calculatorService,
      ),
    );

    expect(find.byType(CupertinoApp), findsOneWidget);
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<AppSettings> loadSettings() async {
    return const AppSettings(
      unit: AppSettings.defaultUnit,
      language: AppSettings.defaultLanguage,
      theme: AppSettings.defaultTheme,
    );
  }

  @override
  Future<void> setLanguage(AppLanguage language) async {}

  @override
  Future<void> setTheme(AppThemeMode theme) async {}

  @override
  Future<void> setUnit(Unit unit) async {}
}

class _FakeCalculatorRepository implements CalculatorRepository {
  @override
  Future<List<Calculation>> loadCalculations() async => [];

  @override
  Future<Calculation> addCalculation(CalculationDraft draft) async {
    return Calculation(
      id: 1,
      distance: draft.distance,
      pace: draft.pace,
      time: draft.time,
      unit: draft.unit,
      createdAt: draft.createdAt,
    );
  }

  @override
  Future<void> deleteCalculation(int id) async {}
}
