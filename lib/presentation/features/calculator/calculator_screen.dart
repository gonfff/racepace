import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:racepace/domain/calculator/calculation.dart';
import 'package:racepace/domain/settings/app_settings.dart';
import 'package:racepace/presentation/app/calculator_scope.dart';
import 'package:racepace/presentation/app/settings_scope.dart';
import 'package:racepace/presentation/core/design/app_theme.dart';
import 'package:racepace/presentation/features/calculator/splits_screen.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';

part 'calculator_screen_formatters.dart';
part 'calculator_screen_helpers.dart';
part 'calculator_screen_input_dialog.dart';
part 'calculator_screen_value_widgets.dart';
part 'calculator_screen_distance_chip.dart';
part 'calculator_screen_saved_table.dart';

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
    final hasDistance = _parseDistance(_distanceController.text) != null;
    final hasPace = _parseDuration(_paceController.text) != null;
    final hasTime = _parseDuration(_timeController.text) != null;
    final canViewSplits = hasDistance && hasPace && hasTime;
    final unitShortLabel = _unitShortLabel(localizations, unit);
    final paceUnitLabel = '${localizations.unitMinutesShort}/$unitShortLabel';

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        middle: Text(localizations.screenCalculator),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
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
                      key: const ValueKey('calculator_value_distance'),
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
                      key: const ValueKey('calculator_value_pace'),
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
                      key: const ValueKey('calculator_value_time'),
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
              const SizedBox(height: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                key: const ValueKey('calculator_view_splits'),
                onPressed: canViewSplits
                    ? () {
                        final distance = _parseDistance(
                          _distanceController.text,
                        );
                        final pace = _parseDuration(_paceController.text);
                        final time = _parseDuration(_timeController.text);
                        if (distance == null || pace == null || time == null) {
                          return;
                        }
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => SplitsScreen(
                              distance: distance,
                              pace: pace,
                              time: time,
                              unit: unit,
                              onValuesChanged: (newDistance, newPace, newTime) {
                                _isUpdating = true;
                                _distanceController.text = _formatNumber(
                                  newDistance,
                                );
                                _paceController.text = _formatDuration(newPace);
                                _timeController.text = _formatDuration(newTime);
                                _isUpdating = false;
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackgroundColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CupertinoColors.systemGrey4.resolveFrom(context),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.table),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          localizations.calculatorViewSplits,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: canViewSplits
                                ? CupertinoColors.label.resolveFrom(context)
                                : CupertinoColors.systemGrey.resolveFrom(
                                    context,
                                  ),
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: canViewSplits
                            ? CupertinoColors.systemGrey.resolveFrom(context)
                            : CupertinoColors.systemGrey3.resolveFrom(context),
                      ),
                    ],
                  ),
                ),
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
                    minimumSize: const Size(28, 28),
                    key: const ValueKey('calculator_save'),
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
