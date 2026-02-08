import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Racepace'**
  String get appTitle;

  /// No description provided for @tabCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get tabCalculator;

  /// No description provided for @tabNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tabNotes;

  /// No description provided for @screenCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get screenCalculator;

  /// No description provided for @screenNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get screenNotes;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences will live here.'**
  String get settingsSubtitle;

  /// No description provided for @settingsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsClose;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsBaseUnit.
  ///
  /// In en, this message translates to:
  /// **'Base unit'**
  String get settingsBaseUnit;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @settingsAboutSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsAboutSupport;

  /// No description provided for @settingsAboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsAboutVersion;

  /// No description provided for @settingsVersionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get settingsVersionUnknown;

  /// No description provided for @settingsAboutAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get settingsAboutAuthor;

  /// No description provided for @settingsAboutSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get settingsAboutSourceCode;

  /// No description provided for @settingsAboutTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get settingsAboutTelegram;

  /// No description provided for @settingsCopyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get settingsCopyAction;

  /// No description provided for @unitKilometers.
  ///
  /// In en, this message translates to:
  /// **'Kilometers'**
  String get unitKilometers;

  /// No description provided for @unitMiles.
  ///
  /// In en, this message translates to:
  /// **'Miles'**
  String get unitMiles;

  /// No description provided for @unitKilometersShort.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get unitKilometersShort;

  /// No description provided for @unitMilesShort.
  ///
  /// In en, this message translates to:
  /// **'mi'**
  String get unitMilesShort;

  /// No description provided for @unitMetersShort.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitMetersShort;

  /// No description provided for @unitHoursShort.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get unitHoursShort;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @unitMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMinutesShort;

  /// No description provided for @calculatorModeSprint.
  ///
  /// In en, this message translates to:
  /// **'Sprint'**
  String get calculatorModeSprint;

  /// No description provided for @calculatorModeLong.
  ///
  /// In en, this message translates to:
  /// **'Stayer'**
  String get calculatorModeLong;

  /// No description provided for @calculatorDistances.
  ///
  /// In en, this message translates to:
  /// **'Distances'**
  String get calculatorDistances;

  /// No description provided for @calculatorDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get calculatorDistance;

  /// No description provided for @calculatorPace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get calculatorPace;

  /// No description provided for @calculatorSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get calculatorSpeed;

  /// No description provided for @calculatorTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get calculatorTime;

  /// No description provided for @calculatorTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'h:mm:ss'**
  String get calculatorTimeFormat;

  /// No description provided for @calculatorInputWheel.
  ///
  /// In en, this message translates to:
  /// **'Wheel'**
  String get calculatorInputWheel;

  /// No description provided for @calculatorInputKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get calculatorInputKeyboard;

  /// No description provided for @calculatorViewSplits.
  ///
  /// In en, this message translates to:
  /// **'View splits'**
  String get calculatorViewSplits;

  /// No description provided for @splitsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Split settings'**
  String get splitsSettingsTitle;

  /// No description provided for @splitsPresets.
  ///
  /// In en, this message translates to:
  /// **'Split presets'**
  String get splitsPresets;

  /// No description provided for @splitsPresetsButton.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get splitsPresetsButton;

  /// No description provided for @splitsPresetsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No presets yet'**
  String get splitsPresetsEmpty;

  /// No description provided for @splitsIntervalTitle.
  ///
  /// In en, this message translates to:
  /// **'Split interval'**
  String get splitsIntervalTitle;

  /// No description provided for @splitsPaceStrategyTitle.
  ///
  /// In en, this message translates to:
  /// **'Pace strategy'**
  String get splitsPaceStrategyTitle;

  /// No description provided for @splitsStartTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get splitsStartTimeTitle;

  /// No description provided for @splitsStrategyNegative10.
  ///
  /// In en, this message translates to:
  /// **'Negative 10%'**
  String get splitsStrategyNegative10;

  /// No description provided for @splitsStrategyNegative5.
  ///
  /// In en, this message translates to:
  /// **'Negative 5%'**
  String get splitsStrategyNegative5;

  /// No description provided for @splitsStrategySteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get splitsStrategySteady;

  /// No description provided for @splitsStrategyPositive5.
  ///
  /// In en, this message translates to:
  /// **'Positive 5%'**
  String get splitsStrategyPositive5;

  /// No description provided for @splitsStrategyPositive10.
  ///
  /// In en, this message translates to:
  /// **'Positive 10%'**
  String get splitsStrategyPositive10;

  /// No description provided for @splitsStrategyNegative10Description.
  ///
  /// In en, this message translates to:
  /// **'Start 5% slower, finish 5% faster.'**
  String get splitsStrategyNegative10Description;

  /// No description provided for @splitsStrategyNegative5Description.
  ///
  /// In en, this message translates to:
  /// **'Start 2.5% slower, finish 2.5% faster.'**
  String get splitsStrategyNegative5Description;

  /// No description provided for @splitsStrategySteadyDescription.
  ///
  /// In en, this message translates to:
  /// **'Even pace throughout.'**
  String get splitsStrategySteadyDescription;

  /// No description provided for @splitsStrategyPositive5Description.
  ///
  /// In en, this message translates to:
  /// **'Start 2.5% faster, finish 2.5% slower.'**
  String get splitsStrategyPositive5Description;

  /// No description provided for @splitsStrategyPositive10Description.
  ///
  /// In en, this message translates to:
  /// **'Start 5% faster, finish 5% slower.'**
  String get splitsStrategyPositive10Description;

  /// No description provided for @splitsStrategyNegativeLabel.
  ///
  /// In en, this message translates to:
  /// **'Negative {percent}%'**
  String splitsStrategyNegativeLabel(Object percent);

  /// No description provided for @splitsStrategyPositiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Positive {percent}%'**
  String splitsStrategyPositiveLabel(Object percent);

  /// No description provided for @splitsStrategyNegativeDescription.
  ///
  /// In en, this message translates to:
  /// **'Negative split. Start {percent}% slower, finish {percent}% faster.'**
  String splitsStrategyNegativeDescription(Object percent);

  /// No description provided for @splitsStrategyPositiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Positive split. Start {percent}% faster, finish {percent}% slower.'**
  String splitsStrategyPositiveDescription(Object percent);

  /// No description provided for @splitsColumnIndex.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get splitsColumnIndex;

  /// No description provided for @splitsColumnDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get splitsColumnDistance;

  /// No description provided for @splitsColumnPace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get splitsColumnPace;

  /// No description provided for @splitsColumnFromZero.
  ///
  /// In en, this message translates to:
  /// **'Gun time'**
  String get splitsColumnFromZero;

  /// No description provided for @splitsColumnFromStart.
  ///
  /// In en, this message translates to:
  /// **'Chip time'**
  String get splitsColumnFromStart;

  /// No description provided for @calculatorCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get calculatorCancel;

  /// No description provided for @calculatorOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get calculatorOk;

  /// No description provided for @calculatorSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get calculatorSave;

  /// No description provided for @calculatorSavedCalculations.
  ///
  /// In en, this message translates to:
  /// **'Saved calculations'**
  String get calculatorSavedCalculations;

  /// No description provided for @calculatorNoSaved.
  ///
  /// In en, this message translates to:
  /// **'No saved calculations yet'**
  String get calculatorNoSaved;

  /// No description provided for @calculatorSprintMile.
  ///
  /// In en, this message translates to:
  /// **'1 mile'**
  String get calculatorSprintMile;

  /// No description provided for @calculatorPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Calculator tools will live here.'**
  String get calculatorPlaceholder;

  /// No description provided for @notesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Functionality is coming soon.'**
  String get notesPlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
