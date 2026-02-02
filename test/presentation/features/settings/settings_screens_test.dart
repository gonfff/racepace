import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:racepace/presentation/features/settings/about_screen.dart';
import 'package:racepace/presentation/features/settings/settings_sheet.dart';
import 'package:racepace/presentation/features/settings/support_screen.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('Settings sheet allows changing options', (tester) async {
    final notifier = createTestSettingsNotifier();
    await notifier.load();

    await tester.pumpWidget(
      buildTestApp(child: const SettingsSheet(), settingsNotifier: notifier),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(SettingsSheet));
    final l10n = AppLocalizations.of(context);

    await tester.tap(find.text(l10n.settingsBaseUnit).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.unitMiles).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.settingsLanguage).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.languageEnglish).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.settingsTheme).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.themeDark).last);
    await tester.pumpAndSettle();

    final aboutSection = find.widgetWithText(
      CupertinoFormSection,
      l10n.settingsSectionAbout,
    );
    final aboutFinder = find
        .descendant(
          of: aboutSection,
          matching: find.widgetWithText(CupertinoFormRow, l10n.settingsAbout),
        )
        .first;
    await tester.ensureVisible(aboutFinder);
    await tester.tap(aboutFinder);
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);
    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();

    final supportFinder = find
        .descendant(
          of: aboutSection,
          matching: find.widgetWithText(CupertinoFormRow, l10n.settingsSupport),
        )
        .first;
    await tester.ensureVisible(supportFinder);
    await tester.tap(supportFinder);
    await tester.pumpAndSettle();
    expect(find.byType(SupportScreen), findsOneWidget);
    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();
  });
}
