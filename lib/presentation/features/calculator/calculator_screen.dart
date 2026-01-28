import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pacenote/domain/calculator/calculation.dart';
import 'package:pacenote/domain/settings/app_settings.dart';
import 'package:pacenote/presentation/app/calculator_scope.dart';
import 'package:pacenote/presentation/app/settings_scope.dart';
import 'package:pacenote/presentation/core/design/app_theme.dart';
import 'package:pacenote/presentation/l10n/app_localizations.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const double _maxDistance = 999;
  static const Duration _maxPace = Duration(minutes: 30);
  static const Duration _maxTime = Duration(hours: 99);
  static const double _valueBlockHeight = 92;
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _paceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  final List<Calculation> _entries = [];
  _CalculatorMode _mode = _CalculatorMode.sprint;
  bool _isUpdating = false;
  final List<_CalcField> _lastChanged = [];
  bool _hasLoaded = false;

  static const List<int> _sprintDistancesMeters = [
    100,
    200,
    300,
    400,
    500,
    600,
    800,
    1000,
    1600,
  ];
  static const List<double> _longDistancesKm = [1, 2, 3, 5, 10, 21.1, 42.2];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) return;
    _hasLoaded = true;
    _loadSaved();
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _paceController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final settings = SettingsScope.of(context).settings;
    final unit = settings.unit;
    final sprintDistances = _sprintDistancesMeters;
    final longDistances = _longDistancesKm;
    final canSave = _calculateValues() != null;
    final unitShortLabel = _unitShortLabel(localizations, unit);
    final paceUnitLabel = '${localizations.unitMinutesShort}/$unitShortLabel';

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        middle: Text(localizations.screenCalculator),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: widget.onOpenSettings,
          child: const Icon(CupertinoIcons.gear_alt_fill),
        ),
      ),
      child: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      localizations.calculatorDistances,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CupertinoSlidingSegmentedControl<_CalculatorMode>(
                    groupValue: _mode,
                    onValueChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _mode = value;
                      });
                    },
                    padding: const EdgeInsets.all(1),
                    backgroundColor: AppTheme.cardBackgroundColor(context),
                    thumbColor: CupertinoColors.activeBlue,
                    children: {
                      _CalculatorMode.sprint: _ToggleLabel(
                        text: localizations.calculatorModeSprint,
                      ),
                      _CalculatorMode.longDistance: _ToggleLabel(
                        text: localizations.calculatorModeLong,
                      ),
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _mode == _CalculatorMode.sprint
                    ? sprintDistances
                          .map(
                            (meters) => _DistanceChip(
                              label: _formatSprintDistanceChip(
                                meters,
                                localizations,
                              ),
                              isSelected: _isSprintDistanceSelected(
                                meters,
                                unit,
                              ),
                              onPressed: () =>
                                  _applySprintDistance(meters, unit),
                            ),
                          )
                          .toList()
                    : longDistances
                          .map(
                            (distanceKm) => _DistanceChip(
                              label: _formatLongDistanceChip(
                                distanceKm,
                                unit,
                                unitShortLabel,
                              ),
                              isSelected: _isLongDistanceSelected(
                                distanceKm,
                                unit,
                              ),
                              onPressed: () =>
                                  _applyLongDistance(distanceKm, unit),
                            ),
                          )
                          .toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _TitleText(text: localizations.calculatorDistance),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TitleText(text: localizations.calculatorPace),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TitleText(text: localizations.calculatorTime),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ValueColumn(
                      value: _displayDistance(),
                      unitLabel: unitShortLabel,
                      secondaryInlineText: null,
                      isEmpty: _parseDistance(_distanceController.text) == null,
                      onTap: () =>
                          _openInputDialog(context, _CalcField.distance, unit),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ValueColumn(
                      value: _displayPace(),
                      unitLabel: paceUnitLabel,
                      secondaryInlineText: null,
                      isEmpty: _parseDuration(_paceController.text) == null,
                      onTap: () =>
                          _openInputDialog(context, _CalcField.pace, unit),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ValueColumn(
                      value: _displayTime(),
                      unitLabel: localizations.calculatorTimeFormat,
                      secondaryInlineText: null,
                      isEmpty: _parseDuration(_timeController.text) == null,
                      onTap: () =>
                          _openInputDialog(context, _CalcField.time, unit),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      localizations.calculatorSavedCalculations,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    minSize: 28,
                    onPressed: canSave ? () => _saveCalculation(unit) : null,
                    child: Text(localizations.calculatorSave),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _SavedCalculationsTable(
                      entries: _entries,
                      localizations: localizations,
                      onSelect: _applySavedEntry,
                      onDelete: _removeSavedEntry,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleChange(_CalcField field) {
    if (_isUpdating) return;
    _trackField(field);
    _recalculateFromLastTwo();
    setState(() {});
  }

  void _trackField(_CalcField field) {
    _lastChanged.remove(field);
    _lastChanged.add(field);
    if (_lastChanged.length > 2) {
      _lastChanged.removeAt(0);
    }
  }

  void _applySprintDistance(int meters, Unit unit) {
    final distance = _distanceFromMetersInUnit(meters, unit);
    _isUpdating = true;
    _distanceController.text = _formatNumber(distance);
    _isUpdating = false;
    _handleChange(_CalcField.distance);
  }

  void _applyLongDistance(double distanceKm, Unit unit) {
    final distance = _distanceFromKmInUnit(distanceKm, unit);
    _isUpdating = true;
    _distanceController.text = _formatNumber(distance);
    _isUpdating = false;
    _handleChange(_CalcField.distance);
  }

  bool _isSprintDistanceSelected(int meters, Unit unit) {
    final currentDistance = _parseDistance(_distanceController.text);
    if (currentDistance == null) return false;
    final distance = _distanceFromMetersInUnit(meters, unit);
    return (currentDistance - distance).abs() < 0.01;
  }

  bool _isLongDistanceSelected(double distanceKm, Unit unit) {
    final currentDistance = _parseDistance(_distanceController.text);
    if (currentDistance == null) return false;
    final distance = _distanceFromKmInUnit(distanceKm, unit);
    return (currentDistance - distance).abs() < 0.01;
  }

  void _saveCalculation(Unit unit) {
    final values = _calculateValues();
    if (values == null) return;
    _isUpdating = true;
    _distanceController.text = _formatNumber(values.distance);
    _paceController.text = _formatDuration(values.pace);
    _timeController.text = _formatDuration(values.time);
    _isUpdating = false;
    _persistCalculation(values, unit);
  }

  void _applySavedEntry(Calculation entry) {
    final settingsUnit = SettingsScope.of(context).settings.unit;
    var distance = entry.distance;
    var pace = entry.pace;
    final time = entry.time;
    if (entry.unit != settingsUnit) {
      distance = _convertDistance(entry.distance, entry.unit, settingsUnit);
      pace = _paceFromDistanceTime(distance, time) ?? entry.pace;
    }
    _isUpdating = true;
    _distanceController.text = _formatNumber(distance);
    _paceController.text = _formatDuration(pace);
    _timeController.text = _formatDuration(time);
    _isUpdating = false;
    _lastChanged
      ..clear()
      ..addAll([_CalcField.distance, _CalcField.pace]);
    setState(() {});
  }

  Future<void> _removeSavedEntry(Calculation entry) async {
    final service = CalculatorScope.of(context);
    await service.deleteCalculation(entry.id);
    if (!mounted) return;
    setState(() {
      _entries.remove(entry);
    });
  }

  Future<void> _persistCalculation(_CalculationValues values, Unit unit) async {
    final service = CalculatorScope.of(context);
    final saved = await service.addCalculation(
      CalculationDraft(
        distance: values.distance,
        pace: values.pace,
        time: values.time,
        unit: unit,
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    setState(() {
      _entries.insert(0, saved);
    });
  }

  Future<void> _loadSaved() async {
    final service = CalculatorScope.of(context);
    final entries = await service.loadCalculations();
    if (!mounted) return;
    setState(() {
      _entries
        ..clear()
        ..addAll(entries);
    });
  }

  String _displayDistance() {
    final distance = _parseDistance(_distanceController.text);
    if (distance == null) return '—';
    return _formatNumber(distance);
  }

  String _displayPace() {
    final pace = _parseDuration(_paceController.text);
    if (pace == null) return '—';
    return _formatDuration(pace);
  }

  String _displayTime() {
    final time = _parseDuration(_timeController.text);
    if (time == null) return '—';
    return _formatDuration(time);
  }

  String _displaySpeed(String unitShortLabel, AppLocalizations localizations) {
    final pace = _parseDuration(_paceController.text);
    if (pace == null || pace.inSeconds == 0) return '—';
    final speed = 3600 / pace.inSeconds;
    final formatted = _formatSpeed(speed);
    return '$formatted $unitShortLabel/${localizations.unitHoursShort}';
  }

  Future<void> _openInputDialog(
    BuildContext context,
    _CalcField field,
    Unit unit,
  ) async {
    final initialText = switch (field) {
      _CalcField.distance => _distanceController.text,
      _CalcField.pace => _paceController.text,
      _CalcField.time => _timeController.text,
    };
    final controller = TextEditingController(
      text: field == _CalcField.distance
          ? initialText
          : _TimeTextInputFormatter.format(
              _digitsOnly(initialText),
              allowHours: field == _CalcField.time,
            ),
    );
    final isTimeField = field == _CalcField.time;
    final isPaceField = field == _CalcField.pace;
    final inputFormatters = <TextInputFormatter>[
      if (isTimeField || isPaceField)
        _TimeTextInputFormatter(allowHours: isTimeField)
      else
        FilteringTextInputFormatter.digitsOnly,
    ];
    final placeholder = switch (field) {
      _CalcField.distance => '0',
      _CalcField.pace => '__:__',
      _CalcField.time => '__:__:__',
    };

    final result = await showCupertinoDialog<String?>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(switch (field) {
            _CalcField.distance => AppLocalizations.of(
              context,
            ).calculatorDistance,
            _CalcField.pace => AppLocalizations.of(context).calculatorPace,
            _CalcField.time => AppLocalizations.of(context).calculatorTime,
          }),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: inputFormatters,
              placeholder: placeholder,
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(AppLocalizations.of(context).calculatorCancel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(AppLocalizations.of(context).calculatorOk),
            ),
          ],
        );
      },
    );

    if (result == null) return;
    final trimmed = result.trim();
    if (trimmed.isEmpty) return;

    switch (field) {
      case _CalcField.distance:
        final value = double.tryParse(trimmed);
        if (value == null || value <= 0) return;
        final clamped = _clampDistance(value);
        _distanceController.text = _formatNumber(clamped);
        break;
      case _CalcField.pace:
        final paceDigits = _digitsOnly(trimmed);
        if (paceDigits.isEmpty) return;
        final pace = _durationFromDigits(paceDigits, allowHours: false);
        if (pace == null) return;
        _paceController.text = _formatDuration(_clampPace(pace));
        break;
      case _CalcField.time:
        final timeDigits = _digitsOnly(trimmed);
        if (timeDigits.isEmpty) return;
        final time = _durationFromDigits(timeDigits, allowHours: true);
        if (time == null) return;
        _timeController.text = _formatDuration(_clampTime(time));
        break;
    }

    _handleChange(field);
  }

  void _recalculateFromLastTwo() {
    if (_lastChanged.length < 2) return;
    final distance = _parseDistance(_distanceController.text);
    final pace = _parseDuration(_paceController.text);
    final time = _parseDuration(_timeController.text);
    final target = _resolveTarget(_lastChanged[0], _lastChanged[1]);

    _isUpdating = true;
    switch (target) {
      case _CalcField.distance:
        final derived = _distanceFromPaceTime(pace, time);
        if (derived != null) {
          _distanceController.text = _formatNumber(_clampDistance(derived));
        }
        break;
      case _CalcField.pace:
        final derived = _paceFromDistanceTime(distance, time);
        if (derived != null) {
          _paceController.text = _formatDuration(_clampPace(derived));
        }
        break;
      case _CalcField.time:
        final derived = _timeFromDistancePace(distance, pace);
        if (derived != null) {
          _timeController.text = _formatDuration(_clampTime(derived));
        }
        break;
    }
    _isUpdating = false;
  }

  _CalcField _resolveTarget(_CalcField first, _CalcField second) {
    if ((first == _CalcField.distance && second == _CalcField.pace) ||
        (first == _CalcField.pace && second == _CalcField.distance)) {
      return _CalcField.time;
    }
    if ((first == _CalcField.distance && second == _CalcField.time) ||
        (first == _CalcField.time && second == _CalcField.distance)) {
      return _CalcField.pace;
    }
    return _CalcField.distance;
  }

  _CalculationValues? _calculateValues() {
    final distance = _parseDistance(_distanceController.text);
    final pace = _parseDuration(_paceController.text);
    final time = _parseDuration(_timeController.text);
    final providedCount = [
      distance,
      pace,
      time,
    ].where((value) => value != null);
    if (providedCount.length < 2) return null;

    final calculatedDistance = distance ?? _distanceFromPaceTime(pace, time);
    final calculatedPace = pace ?? _paceFromDistanceTime(distance, time);
    final calculatedTime = time ?? _timeFromDistancePace(distance, pace);

    if (calculatedDistance == null ||
        calculatedPace == null ||
        calculatedTime == null) {
      return null;
    }

    return _CalculationValues(
      distance: _clampDistance(calculatedDistance),
      pace: _clampPace(calculatedPace),
      time: _clampTime(calculatedTime),
    );
  }

  double? _distanceFromPaceTime(Duration? pace, Duration? time) {
    if (pace == null || time == null) return null;
    if (pace.inSeconds == 0) return null;
    return time.inSeconds / pace.inSeconds;
  }

  Duration? _paceFromDistanceTime(double? distance, Duration? time) {
    if (distance == null || time == null) return null;
    if (distance == 0) return null;
    final paceSeconds = (time.inSeconds / distance).round();
    return Duration(seconds: paceSeconds);
  }

  Duration? _timeFromDistancePace(double? distance, Duration? pace) {
    if (distance == null || pace == null) return null;
    final timeSeconds = (distance * pace.inSeconds).round();
    return Duration(seconds: timeSeconds);
  }

  double _clampDistance(double value) {
    final clamped = value.clamp(0, _maxDistance);
    return clamped is double ? clamped : clamped.toDouble();
  }

  Duration _clampPace(Duration pace) {
    if (pace > _maxPace) return _maxPace;
    return pace;
  }

  Duration _clampTime(Duration time) {
    if (time > _maxTime) return _maxTime;
    return time;
  }

  String _digitsOnly(String text) {
    return text.replaceAll(RegExp(r'\D'), '');
  }

  Duration? _durationFromDigits(String digits, {required bool allowHours}) {
    final cleaned = digits.replaceAll(RegExp(r'\D'), '');
    if (cleaned.isEmpty) return null;

    if (!allowHours) {
      if (cleaned.length <= 2) {
        return Duration(minutes: int.parse(cleaned));
      }
      final minutes = int.parse(cleaned.substring(0, cleaned.length - 2));
      final seconds = int.parse(cleaned.substring(cleaned.length - 2));
      return Duration(minutes: minutes, seconds: seconds);
    }

    if (cleaned.length <= 2) {
      return Duration(minutes: int.parse(cleaned));
    }
    if (cleaned.length <= 4) {
      final minutes = int.parse(cleaned.substring(0, cleaned.length - 2));
      final seconds = int.parse(cleaned.substring(cleaned.length - 2));
      return Duration(minutes: minutes, seconds: seconds);
    }

    final hours = int.parse(cleaned.substring(0, cleaned.length - 4));
    final minutes = int.parse(
      cleaned.substring(cleaned.length - 4, cleaned.length - 2),
    );
    final seconds = int.parse(cleaned.substring(cleaned.length - 2));
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
}

enum _CalculatorMode { sprint, longDistance }

enum _CalcField { distance, pace, time }

class _CalculationValues {
  const _CalculationValues({
    required this.distance,
    required this.pace,
    required this.time,
  });

  final double distance;
  final Duration pace;
  final Duration time;
}

class _ValueColumn extends StatelessWidget {
  const _ValueColumn({
    required this.value,
    required this.unitLabel,
    this.secondaryInlineText,
    required this.isEmpty,
    required this.onTap,
  });

  static const double _valueTextHeight = 36;
  static const double _unitTextHeight = 18;

  final String value;
  final String unitLabel;
  final String? secondaryInlineText;
  final bool isEmpty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isEmpty
        ? CupertinoColors.systemGrey.resolveFrom(context)
        : CupertinoColors.label.resolveFrom(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _CalculatorScreenState._valueBlockHeight,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CupertinoColors.systemGrey4.resolveFrom(context),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: _valueTextHeight,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: _unitTextHeight,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    secondaryInlineText == null
                        ? unitLabel
                        : '$unitLabel · $secondaryInlineText',
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  const _TitleText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ToggleLabel extends StatelessWidget {
  const _ToggleLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TimeTextInputFormatter extends TextInputFormatter {
  _TimeTextInputFormatter({required this.allowHours});

  final bool allowHours;

  static String format(String digits, {required bool allowHours}) {
    final maxLength = allowHours ? 6 : 4;
    final trimmed = digits.length > maxLength
        ? digits.substring(0, maxLength)
        : digits;
    final slots = allowHours ? 6 : 4;
    final padded = List<String>.generate(
      slots,
      (index) => index < trimmed.length ? trimmed[index] : '_',
    );
    if (allowHours) {
      return '${padded[0]}${padded[1]}:${padded[2]}${padded[3]}:${padded[4]}${padded[5]}';
    }
    return '${padded[0]}${padded[1]}:${padded[2]}${padded[3]}';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formatted = format(digits, allowHours: allowHours);
    final digitsBeforeCursor = _countDigitsBefore(
      newValue.text,
      newValue.selection.baseOffset,
    );
    final caret = _caretOffsetForDigitIndex(
      digitsBeforeCursor,
      allowHours: allowHours,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: caret),
    );
  }

  static int _countDigitsBefore(String text, int offset) {
    if (offset <= 0) return 0;
    final limit = offset.clamp(0, text.length);
    return RegExp(r'\d').allMatches(text.substring(0, limit)).length;
  }

  static int _caretOffsetForDigitIndex(
    int digitIndex, {
    required bool allowHours,
  }) {
    final maxDigits = allowHours ? 6 : 4;
    final clamped = digitIndex.clamp(0, maxDigits);
    final base = clamped is int ? clamped : clamped.toInt();
    if (allowHours) {
      if (base <= 2) return base;
      if (base <= 4) return base + 1;
      return base + 2;
    }
    if (base <= 2) return base;
    return base + 1;
  }
}

class _DistanceChip extends StatelessWidget {
  const _DistanceChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? CupertinoColors.activeBlue.withOpacity(0.15)
        : AppTheme.cardBackgroundColor(context);
    final borderColor = isSelected
        ? CupertinoColors.activeBlue
        : CupertinoColors.systemGrey4.resolveFrom(context);
    final textColor = isSelected
        ? CupertinoColors.activeBlue
        : CupertinoColors.label.resolveFrom(context);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _SavedCalculationsTable extends StatelessWidget {
  const _SavedCalculationsTable({
    required this.entries,
    required this.localizations,
    required this.onSelect,
    required this.onDelete,
  });

  final List<Calculation> entries;
  final AppLocalizations localizations;
  final ValueChanged<Calculation> onSelect;
  final ValueChanged<Calculation> onDelete;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: entries
          .asMap()
          .entries
          .map(
            (entry) => _SavedCard(
              entry: entry.value,
              unitLabel: _unitShortLabel(localizations, entry.value.unit),
              onSelect: onSelect,
              onDelete: onDelete,
            ),
          )
          .toList(),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({
    required this.entry,
    required this.unitLabel,
    required this.onSelect,
    required this.onDelete,
  });

  final Calculation entry;
  final String unitLabel;
  final ValueChanged<Calculation> onSelect;
  final ValueChanged<Calculation> onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: const SizedBox.shrink(),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(CupertinoIcons.trash, color: CupertinoColors.white),
      ),
      onDismissed: (_) => onDelete(entry),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(entry),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: CupertinoColors.systemGrey4.resolveFrom(context),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatNumber(entry.distance)} $unitLabel',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${_formatDuration(entry.pace)} / ${_formatDuration(entry.time)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _distanceFromKmInUnit(double distanceKm, Unit unit) {
  return unit == Unit.kilometers ? distanceKm : distanceKm * 0.621371;
}

double _convertDistance(double value, Unit from, Unit to) {
  if (from == to) return value;
  if (from == Unit.kilometers) {
    return value * 0.621371;
  }
  return value / 0.621371;
}

double _distanceFromMetersInUnit(int meters, Unit unit) {
  return _distanceFromKmInUnit(meters / 1000, unit);
}

String _formatSprintDistanceChip(int meters, AppLocalizations localizations) {
  if (meters == 1600) {
    return localizations.calculatorSprintMile;
  }
  return '$meters ${localizations.unitMetersShort}';
}

String _formatLongDistanceChip(double distanceKm, Unit unit, String unitLabel) {
  final distance = _distanceFromKmInUnit(distanceKm, unit);
  return '${_formatNumber(distance)} $unitLabel';
}

double? _parseDistance(String text) {
  final normalized = text.replaceAll(',', '.').trim();
  if (normalized.isEmpty) return null;
  final value = double.tryParse(normalized);
  if (value == null || value <= 0) return null;
  return value;
}

Duration? _parseDuration(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  final parts = trimmed.split(':');
  if (parts.length > 3) return null;
  final values = parts
      .map((part) => int.tryParse(part.trim()))
      .toList(growable: false);
  if (values.any((value) => value == null)) return null;

  if (values.length == 1) {
    return Duration(minutes: values[0]!);
  }
  if (values.length == 2) {
    return Duration(minutes: values[0]!, seconds: values[1]!);
  }
  return Duration(hours: values[0]!, minutes: values[1]!, seconds: values[2]!);
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }
  final totalMinutes = duration.inMinutes;
  return '${_twoDigits(totalMinutes)}:${_twoDigits(seconds)}';
}

String _formatNumber(double value) {
  final fixed = value.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _formatSpeed(double value) {
  return value.toStringAsFixed(1).replaceFirst(RegExp(r'\.?0+$'), '');
}

String _unitShortLabel(AppLocalizations localizations, Unit unit) {
  return unit == Unit.miles
      ? localizations.unitMilesShort
      : localizations.unitKilometersShort;
}
