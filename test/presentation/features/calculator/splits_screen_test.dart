import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:racepace/domain/settings/app_settings.dart';
import 'package:racepace/presentation/features/calculator/splits_screen.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('Splits screen allows editing and settings', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: const SplitsScreen(
          distance: 10,
          pace: Duration(minutes: 5),
          time: Duration(minutes: 50),
          unit: Unit.kilometers,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(SplitsScreen));
    final l10n = AppLocalizations.of(context);

    await tester.tap(find.byKey(const ValueKey('splits_value_distance')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), '5.0');
    await tester.tap(find.text(l10n.calculatorOk));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('splits_value_pace')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), '0530');
    await tester.tap(find.text(l10n.calculatorOk));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('splits_value_time')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), '010000');
    await tester.tap(find.text(l10n.calculatorOk));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('splits_setting_interval')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CupertinoPicker), const Offset(0, -32));
    await tester.tap(find.text(l10n.calculatorOk));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('splits_setting_strategy')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CupertinoPicker), const Offset(0, -32));
    await tester.tap(find.text(l10n.calculatorOk));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('splits_setting_start_time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.calculatorOk));
    await tester.pumpAndSettle();
  });
}
