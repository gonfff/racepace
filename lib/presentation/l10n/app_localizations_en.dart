// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Racepace';

  @override
  String get tabCalculator => 'Calculator';

  @override
  String get tabNotes => 'Notes';

  @override
  String get screenCalculator => 'Calculator';

  @override
  String get screenNotes => 'Notes';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Preferences will live here.';

  @override
  String get settingsClose => 'Close';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsBaseUnit => 'Base unit';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsAboutSupport => 'Support';

  @override
  String get settingsAboutVersion => 'Version';

  @override
  String get settingsVersionUnknown => 'Unknown';

  @override
  String get settingsAboutAuthor => 'Author';

  @override
  String get settingsAboutSourceCode => 'Source code';

  @override
  String get settingsAboutTelegram => 'Telegram';

  @override
  String get settingsCopyAction => 'Copy';

  @override
  String get unitKilometers => 'Kilometers';

  @override
  String get unitMiles => 'Miles';

  @override
  String get unitKilometersShort => 'km';

  @override
  String get unitMilesShort => 'mi';

  @override
  String get unitMetersShort => 'm';

  @override
  String get unitHoursShort => 'h';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageSystem => 'System';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get unitMinutesShort => 'min';

  @override
  String get calculatorModeSprint => 'Sprint';

  @override
  String get calculatorModeLong => 'Stayer';

  @override
  String get calculatorDistances => 'Distances';

  @override
  String get calculatorDistance => 'Distance';

  @override
  String get calculatorPace => 'Pace';

  @override
  String get calculatorSpeed => 'Speed';

  @override
  String get calculatorTime => 'Time';

  @override
  String get calculatorTimeFormat => 'h:mm:ss';

  @override
  String get calculatorInputWheel => 'Wheel';

  @override
  String get calculatorInputKeyboard => 'Keyboard';

  @override
  String get calculatorViewSplits => 'View splits';

  @override
  String get splitsSettingsTitle => 'Split settings';

  @override
  String get splitsIntervalTitle => 'Split interval';

  @override
  String get splitsPaceStrategyTitle => 'Pace strategy';

  @override
  String get splitsStartTimeTitle => 'Start time';

  @override
  String get splitsStrategyNegative10 => 'Negative 10%';

  @override
  String get splitsStrategyNegative5 => 'Negative 5%';

  @override
  String get splitsStrategySteady => 'Steady';

  @override
  String get splitsStrategyPositive5 => 'Positive 5%';

  @override
  String get splitsStrategyPositive10 => 'Positive 10%';

  @override
  String get splitsStrategyNegative10Description =>
      'Start 5% slower, finish 5% faster.';

  @override
  String get splitsStrategyNegative5Description =>
      'Start 2.5% slower, finish 2.5% faster.';

  @override
  String get splitsStrategySteadyDescription => 'Even pace throughout.';

  @override
  String get splitsStrategyPositive5Description =>
      'Start 2.5% faster, finish 2.5% slower.';

  @override
  String get splitsStrategyPositive10Description =>
      'Start 5% faster, finish 5% slower.';

  @override
  String splitsStrategyNegativeLabel(Object percent) {
    return 'Negative $percent%';
  }

  @override
  String splitsStrategyPositiveLabel(Object percent) {
    return 'Positive $percent%';
  }

  @override
  String splitsStrategyNegativeDescription(Object percent) {
    return 'Negative split. Start $percent% slower, finish $percent% faster.';
  }

  @override
  String splitsStrategyPositiveDescription(Object percent) {
    return 'Positive split. Start $percent% faster, finish $percent% slower.';
  }

  @override
  String get splitsColumnIndex => '#';

  @override
  String get splitsColumnDistance => 'Distance';

  @override
  String get splitsColumnPace => 'Pace';

  @override
  String get splitsColumnFromZero => 'Gun time';

  @override
  String get splitsColumnFromStart => 'Chip time';

  @override
  String get calculatorCancel => 'Cancel';

  @override
  String get calculatorOk => 'OK';

  @override
  String get calculatorSave => 'Save';

  @override
  String get calculatorSavedCalculations => 'Saved calculations';

  @override
  String get calculatorNoSaved => 'No saved calculations yet';

  @override
  String get calculatorSprintMile => '1 mile';

  @override
  String get calculatorPlaceholder => 'Calculator tools will live here.';

  @override
  String get notesPlaceholder => 'Functionality is coming soon.';
}
