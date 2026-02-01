import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:racepace/domain/settings/app_settings.dart';
import 'package:racepace/presentation/features/calculator/calculator_screen.dart';
import 'package:racepace/presentation/features/calculator/splits_screen.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('Calculator screen handles input and navigation', (tester) async {
    final notifier = createTestSettingsNotifier(
      settings: const AppSettings(
        unit: Unit.kilometers,
        language: AppSettings.defaultLanguage,
        theme: AppSettings.defaultTheme,
      ),
    );
    await notifier.load();
    final calculatorService = createTestCalculatorService();

    await tester.pumpWidget(
      buildTestApp(
        child: CalculatorScreen(onOpenSettings: () {}),
        settingsNotifier: notifier,
        calculatorService: calculatorService,
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(CalculatorScreen));
    final l10n = AppLocalizations.of(context);

    await tester.tap(find.text(l10n.calculatorModeLong));
    await tester.pumpAndSettle();

    await tester.tap(find.text('5 ${l10n.unitKilometersShort}'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calculator_value_distance')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), '5.0');
    await tester.tap(find.text(l10n.calculatorOk));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calculator_value_pace')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), '0500');
    await tester.tap(find.text(l10n.calculatorOk));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calculator_value_time')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), '002500');
    await tester.tap(find.text(l10n.calculatorOk));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calculator_save')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calculator_view_splits')));
    await tester.pumpAndSettle();

    expect(find.byType(SplitsScreen), findsOneWidget);
  });
}
