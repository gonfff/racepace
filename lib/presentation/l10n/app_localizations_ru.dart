// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Racepace';

  @override
  String get tabCalculator => 'Калькулятор';

  @override
  String get tabNotes => 'Заметки';

  @override
  String get screenCalculator => 'Калькулятор';

  @override
  String get screenNotes => 'Заметки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSubtitle => 'Здесь появятся параметры.';

  @override
  String get settingsClose => 'Закрыть';

  @override
  String get settingsSectionGeneral => 'Общее';

  @override
  String get settingsSectionAbout => 'О приложении';

  @override
  String get settingsBaseUnit => 'Базовая мера';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsSupport => 'Поддержка';

  @override
  String get settingsAboutSection => 'О приложении';

  @override
  String get settingsAboutSupport => 'Поддержка';

  @override
  String get settingsAboutVersion => 'Версия';

  @override
  String get settingsVersionUnknown => 'Неизвестно';

  @override
  String get settingsAboutAuthor => 'Автор';

  @override
  String get settingsAboutSourceCode => 'Исходный код';

  @override
  String get settingsAboutTelegram => 'Телеграм';

  @override
  String get settingsCopyAction => 'Копировать';

  @override
  String get unitKilometers => 'Километры';

  @override
  String get unitMiles => 'Мили';

  @override
  String get unitKilometersShort => 'км';

  @override
  String get unitMilesShort => 'ми';

  @override
  String get unitMetersShort => 'м';

  @override
  String get unitHoursShort => 'ч';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageSystem => 'Системный';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Темная';

  @override
  String get unitMinutesShort => 'мин';

  @override
  String get calculatorModeSprint => 'Спринт';

  @override
  String get calculatorModeLong => 'Стайерские';

  @override
  String get calculatorDistances => 'Дистанции';

  @override
  String get calculatorDistance => 'Дистанция';

  @override
  String get calculatorPace => 'Темп';

  @override
  String get calculatorSpeed => 'Скорость';

  @override
  String get calculatorTime => 'Время';

  @override
  String get calculatorTimeFormat => 'ч:мин:сек';

  @override
  String get calculatorInputWheel => 'Колесо';

  @override
  String get calculatorInputKeyboard => 'Клавиатура';

  @override
  String get calculatorViewSplits => 'Показать сплиты';

  @override
  String get splitsSettingsTitle => 'Настройки сплитов';

  @override
  String get splitsIntervalTitle => 'Интервал';

  @override
  String get splitsPaceStrategyTitle => 'Стратегия темпа';

  @override
  String get splitsStartTimeTitle => 'Время старта';

  @override
  String get splitsStrategyNegative10 => 'Негатив 10%';

  @override
  String get splitsStrategyNegative5 => 'Негатив 5%';

  @override
  String get splitsStrategySteady => 'Ровно';

  @override
  String get splitsStrategyPositive5 => 'Позитив 5%';

  @override
  String get splitsStrategyPositive10 => 'Позитив 10%';

  @override
  String get splitsStrategyNegative10Description =>
      'Старт на 5% медленнее, финиш на 5% быстрее.';

  @override
  String get splitsStrategyNegative5Description =>
      'Старт на 2.5% медленнее, финиш на 2.5% быстрее.';

  @override
  String get splitsStrategySteadyDescription =>
      'Равномерный темп на всей дистанции.';

  @override
  String get splitsStrategyPositive5Description =>
      'Старт на 2.5% быстрее, финиш на 2.5% медленнее.';

  @override
  String get splitsStrategyPositive10Description =>
      'Старт на 5% быстрее, финиш на 5% медленнее.';

  @override
  String splitsStrategyNegativeLabel(Object percent) {
    return 'Негатив $percent%';
  }

  @override
  String splitsStrategyPositiveLabel(Object percent) {
    return 'Позитив $percent%';
  }

  @override
  String splitsStrategyNegativeDescription(Object percent) {
    return 'Отрицательный сплит. Старт на $percent% медленнее, финиш на $percent% быстрее.';
  }

  @override
  String splitsStrategyPositiveDescription(Object percent) {
    return 'Положительный сплит. Старт на $percent% быстрее, финиш на $percent% медленнее.';
  }

  @override
  String get splitsColumnIndex => '№';

  @override
  String get splitsColumnDistance => 'Дистанция';

  @override
  String get splitsColumnPace => 'Темп';

  @override
  String get splitsColumnFromZero => 'От выстрела';

  @override
  String get splitsColumnFromStart => 'От старта';

  @override
  String get calculatorCancel => 'Отмена';

  @override
  String get calculatorOk => 'Ок';

  @override
  String get calculatorSave => 'Сохранить';

  @override
  String get calculatorSavedCalculations => 'Сохраненные расчеты';

  @override
  String get calculatorNoSaved => 'Пока нет сохраненных расчетов';

  @override
  String get calculatorSprintMile => '1 миля';

  @override
  String get calculatorPlaceholder =>
      'Здесь появятся инструменты калькулятора.';

  @override
  String get notesPlaceholder => 'Скоро здесь появится функциональность.';
}
