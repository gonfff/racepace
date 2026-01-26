// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pacenote/application/settings/settings_repository.dart';
import 'package:pacenote/application/settings/settings_service.dart';
import 'package:pacenote/domain/settings/app_settings.dart';
import 'package:pacenote/presentation/app/pacenote_app.dart';
import 'package:pacenote/presentation/features/settings/settings_notifier.dart';

void main() {
  testWidgets('Pacenote app builds', (WidgetTester tester) async {
    final repository = _FakeSettingsRepository();
    final service = SettingsService(repository);
    final notifier = SettingsNotifier(service);
    await notifier.load();

    await tester.pumpWidget(PacenoteApp(settingsNotifier: notifier));

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
