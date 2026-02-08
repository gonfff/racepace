import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';
import 'package:racepace/presentation/l10n/app_localizations_en.dart';
import 'package:racepace/presentation/l10n/app_localizations_ru.dart';

void main() {
  testWidgets('AppLocalizations delegate loads English', (tester) async {
    late AppLocalizations l10n;

    await tester.pumpWidget(
      CupertinoApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(l10n.appTitle, 'Racepace');
  });

  test('AppLocalizationsEn getters and methods return strings', () {
    final l10n = AppLocalizationsEn();
    _expectNonEmptyStrings(_allStrings(l10n));
  });

  test('AppLocalizationsRu getters and methods return strings', () {
    final l10n = AppLocalizationsRu();
    _expectNonEmptyStrings(_allStrings(l10n));
  });
}

List<String> _allStrings(AppLocalizations l10n) {
  return [
    l10n.appTitle,
    l10n.tabCalculator,
    l10n.tabNotes,
    l10n.screenCalculator,
    l10n.screenNotes,
    l10n.settingsTitle,
    l10n.settingsSubtitle,
    l10n.settingsClose,
    l10n.settingsSectionGeneral,
    l10n.settingsSectionAbout,
    l10n.settingsBaseUnit,
    l10n.settingsLanguage,
    l10n.settingsTheme,
    l10n.settingsAbout,
    l10n.settingsSupport,
    l10n.settingsAboutSection,
    l10n.settingsAboutSupport,
    l10n.settingsAboutVersion,
    l10n.settingsVersionUnknown,
    l10n.settingsAboutAuthor,
    l10n.settingsAboutSourceCode,
    l10n.settingsAboutTelegram,
    l10n.settingsCopyAction,
    l10n.unitKilometers,
    l10n.unitMiles,
    l10n.unitKilometersShort,
    l10n.unitMilesShort,
    l10n.unitMetersShort,
    l10n.unitHoursShort,
    l10n.languageEnglish,
    l10n.languageRussian,
    l10n.languageSystem,
    l10n.themeSystem,
    l10n.themeLight,
    l10n.themeDark,
    l10n.unitMinutesShort,
    l10n.calculatorModeSprint,
    l10n.calculatorModeLong,
    l10n.calculatorDistances,
    l10n.calculatorDistance,
    l10n.calculatorPace,
    l10n.calculatorSpeed,
    l10n.calculatorTime,
    l10n.calculatorTimeFormat,
    l10n.calculatorInputWheel,
    l10n.calculatorInputKeyboard,
    l10n.calculatorViewSplits,
    l10n.splitsSettingsTitle,
    l10n.splitsPresets,
    l10n.splitsPresetsButton,
    l10n.splitsPresetsEmpty,
    l10n.splitsIntervalTitle,
    l10n.splitsPaceStrategyTitle,
    l10n.splitsStartTimeTitle,
    l10n.splitsStrategyNegative10,
    l10n.splitsStrategyNegative5,
    l10n.splitsStrategySteady,
    l10n.splitsStrategyPositive5,
    l10n.splitsStrategyPositive10,
    l10n.splitsStrategyNegative10Description,
    l10n.splitsStrategyNegative5Description,
    l10n.splitsStrategySteadyDescription,
    l10n.splitsStrategyPositive5Description,
    l10n.splitsStrategyPositive10Description,
    l10n.splitsColumnIndex,
    l10n.splitsColumnDistance,
    l10n.splitsColumnPace,
    l10n.splitsColumnFromZero,
    l10n.splitsColumnFromStart,
    l10n.calculatorCancel,
    l10n.calculatorOk,
    l10n.calculatorSave,
    l10n.calculatorSavedCalculations,
    l10n.calculatorNoSaved,
    l10n.calculatorSprintMile,
    l10n.calculatorPlaceholder,
    l10n.notesPlaceholder,
    l10n.splitsStrategyNegativeLabel(5),
    l10n.splitsStrategyPositiveLabel(5),
    l10n.splitsStrategyNegativeDescription(5),
    l10n.splitsStrategyPositiveDescription(5),
  ];
}

void _expectNonEmptyStrings(List<String> values) {
  for (final value in values) {
    expect(value, isNotEmpty);
  }
}
