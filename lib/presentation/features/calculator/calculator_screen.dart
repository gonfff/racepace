import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:racepace/domain/calculator/calculation.dart';
import 'package:racepace/domain/settings/app_settings.dart';
import 'package:racepace/presentation/app/calculator_scope.dart';
import 'package:racepace/presentation/app/settings_scope.dart';
import 'package:racepace/presentation/core/design/app_theme.dart';
import 'package:racepace/presentation/features/calculator/splits_screen.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';

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
              const SizedBox(height: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
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
    final localizations = AppLocalizations.of(context);
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
    final isDistanceField = field == _CalcField.distance;
    final inputFormatters = <TextInputFormatter>[
      if (isTimeField || isPaceField)
        _TimeTextInputFormatter(allowHours: isTimeField)
      else
        _DistanceTextInputFormatter(),
    ];
    final placeholder = switch (field) {
      _CalcField.distance => '0.0',
      _CalcField.pace => '__:__',
      _CalcField.time => '__:__:__',
    };
    final unitShortLabel = _unitShortLabel(localizations, unit);
    final paceUnitLabel = '${localizations.unitMinutesShort}/$unitShortLabel';
    final title = switch (field) {
      _CalcField.distance => localizations.calculatorDistance,
      _CalcField.pace => localizations.calculatorPace,
      _CalcField.time => localizations.calculatorTime,
    };
    const inputFieldHeight = 44.0;
    var distanceValue = _parseDistance(_distanceController.text) ?? 0;
    var distanceWhole = distanceValue.floor();
    var distanceTenths = ((distanceValue - distanceWhole) * 10).round();
    final maxDistanceWhole = _maxDistance.floor();
    if (distanceWhole > maxDistanceWhole) {
      distanceWhole = maxDistanceWhole;
      distanceTenths = 0;
    }
    if (distanceTenths < 0) distanceTenths = 0;
    if (distanceTenths > 9) distanceTenths = 9;
    final paceValue = _clampPace(
      _parseDuration(_paceController.text) ?? Duration.zero,
    );
    var paceMinutes = paceValue.inMinutes;
    var paceSeconds = paceValue.inSeconds.remainder(60);
    final timeValue = _clampTime(
      _parseDuration(_timeController.text) ?? Duration.zero,
    );
    var timeHours = timeValue.inHours;
    var timeMinutes = timeValue.inMinutes.remainder(60);
    var timeSeconds = timeValue.inSeconds.remainder(60);
    final distanceWholeController = FixedExtentScrollController(
      initialItem: distanceWhole,
    );
    final distanceTenthsController = FixedExtentScrollController(
      initialItem: distanceTenths,
    );
    final paceMinutesController = FixedExtentScrollController(
      initialItem: paceMinutes,
    );
    final paceSecondsController = FixedExtentScrollController(
      initialItem: paceSeconds,
    );
    final timeHoursController = FixedExtentScrollController(
      initialItem: timeHours,
    );
    final timeMinutesController = FixedExtentScrollController(
      initialItem: timeMinutes,
    );
    final timeSecondsController = FixedExtentScrollController(
      initialItem: timeSeconds,
    );

    Duration? durationFromMaskedInput(String text, {required bool allowHours}) {
      final digits = _digitsOnly(text);
      if (digits.isEmpty) return null;
      return _durationFromDigits(digits, allowHours: allowHours);
    }

    void syncWheelFromText(StateSetter setState) {
      if (isDistanceField) {
        final parsed = _parseDistance(controller.text) ?? 0;
        var whole = parsed.floor();
        var tenths = ((parsed - whole) * 10).round();
        if (whole > maxDistanceWhole) {
          whole = maxDistanceWhole;
          tenths = 0;
        }
        if (tenths < 0) tenths = 0;
        if (tenths > 9) tenths = 9;
        setState(() {
          distanceWhole = whole;
          distanceTenths = tenths;
        });
        distanceWholeController.jumpToItem(whole);
        distanceTenthsController.jumpToItem(tenths);
      } else if (isPaceField) {
        final parsed = _clampPace(
          durationFromMaskedInput(controller.text, allowHours: false) ??
              Duration.zero,
        );
        final minutes = parsed.inMinutes;
        final seconds = parsed.inSeconds.remainder(60);
        setState(() {
          paceMinutes = minutes;
          paceSeconds = seconds;
        });
        paceMinutesController.jumpToItem(minutes);
        paceSecondsController.jumpToItem(seconds);
      } else {
        final parsed = _clampTime(
          durationFromMaskedInput(controller.text, allowHours: true) ??
              Duration.zero,
        );
        final hours = parsed.inHours;
        final minutes = parsed.inMinutes.remainder(60);
        final seconds = parsed.inSeconds.remainder(60);
        setState(() {
          timeHours = hours;
          timeMinutes = minutes;
          timeSeconds = seconds;
        });
        timeHoursController.jumpToItem(hours);
        timeMinutesController.jumpToItem(minutes);
        timeSecondsController.jumpToItem(seconds);
      }
    }

    String wheelValue() {
      if (isDistanceField) {
        final value = distanceWhole + (distanceTenths / 10);
        return _clampDistance(value).toStringAsFixed(1);
      }
      if (isPaceField) {
        final duration = Duration(minutes: paceMinutes, seconds: paceSeconds);
        return _formatDuration(_clampPace(duration));
      }
      final duration = Duration(
        hours: timeHours,
        minutes: timeMinutes,
        seconds: timeSeconds,
      );
      return _formatDuration(_clampTime(duration));
    }

    Widget buildPickerColumn({
      required FixedExtentScrollController scrollController,
      required int itemCount,
      required ValueChanged<int> onSelected,
    }) {
      return Expanded(
        child: CupertinoPicker(
          scrollController: scrollController,
          itemExtent: 32,
          onSelectedItemChanged: onSelected,
          useMagnifier: true,
          magnification: 1.1,
          children: List.generate(
            itemCount,
            (index) => Center(child: Text('$index')),
          ),
        ),
      );
    }

    Widget buildDistancePicker(StateSetter setState, VoidCallback syncText) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPickerColumn(
                  scrollController: distanceWholeController,
                  itemCount: maxDistanceWhole + 1,
                  onSelected: (value) => setState(() {
                    distanceWhole = value;
                    if (distanceWhole >= maxDistanceWhole) {
                      distanceTenths = 0;
                      distanceTenthsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('.', style: TextStyle(fontSize: 18)),
                ),
                buildPickerColumn(
                  scrollController: distanceTenthsController,
                  itemCount: 10,
                  onSelected: (value) => setState(() {
                    distanceTenths = value;
                    if (distanceWhole >= maxDistanceWhole && value > 0) {
                      distanceTenths = 0;
                      distanceTenthsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            unitShortLabel,
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      );
    }

    Widget buildPacePicker(StateSetter setState, VoidCallback syncText) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPickerColumn(
                  scrollController: paceMinutesController,
                  itemCount: _maxPace.inMinutes + 1,
                  onSelected: (value) => setState(() {
                    paceMinutes = value;
                    if (paceMinutes >= _maxPace.inMinutes && paceSeconds > 0) {
                      paceSeconds = 0;
                      paceSecondsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(':', style: TextStyle(fontSize: 18)),
                ),
                buildPickerColumn(
                  scrollController: paceSecondsController,
                  itemCount: 60,
                  onSelected: (value) => setState(() {
                    paceSeconds = value;
                    if (paceMinutes >= _maxPace.inMinutes && value > 0) {
                      paceSeconds = 0;
                      paceSecondsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            paceUnitLabel,
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      );
    }

    Widget buildTimePicker(StateSetter setState, VoidCallback syncText) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPickerColumn(
                  scrollController: timeHoursController,
                  itemCount: _maxTime.inHours + 1,
                  onSelected: (value) => setState(() {
                    timeHours = value;
                    if (timeHours >= _maxTime.inHours &&
                        (timeMinutes > 0 || timeSeconds > 0)) {
                      timeMinutes = 0;
                      timeSeconds = 0;
                      timeMinutesController.jumpToItem(0);
                      timeSecondsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(':', style: TextStyle(fontSize: 18)),
                ),
                buildPickerColumn(
                  scrollController: timeMinutesController,
                  itemCount: 60,
                  onSelected: (value) => setState(() {
                    timeMinutes = value;
                    if (timeHours >= _maxTime.inHours &&
                        (value > 0 || timeSeconds > 0)) {
                      timeMinutes = 0;
                      timeSeconds = 0;
                      timeMinutesController.jumpToItem(0);
                      timeSecondsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(':', style: TextStyle(fontSize: 18)),
                ),
                buildPickerColumn(
                  scrollController: timeSecondsController,
                  itemCount: 60,
                  onSelected: (value) => setState(() {
                    timeSeconds = value;
                    if (timeHours >= _maxTime.inHours &&
                        (timeMinutes > 0 || value > 0)) {
                      timeMinutes = 0;
                      timeSeconds = 0;
                      timeMinutesController.jumpToItem(0);
                      timeSecondsController.jumpToItem(0);
                    }
                    syncText();
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            localizations.calculatorTimeFormat,
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      );
    }

    String? result;
    var isSyncing = false;
    try {
      result = await showCupertinoDialog<String?>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              void syncTextFromWheel() {
                if (isSyncing) return;
                isSyncing = true;
                final text = wheelValue();
                controller.value = controller.value.copyWith(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
                isSyncing = false;
              }

              void syncWheelFromField() {
                if (isSyncing) return;
                isSyncing = true;
                syncWheelFromText(setState);
                isSyncing = false;
              }

              final inputField = CupertinoTextField(
                controller: controller,
                keyboardType: isDistanceField
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number,
                inputFormatters: inputFormatters,
                placeholder: placeholder,
                textAlign: TextAlign.center,
                onChanged: (_) => syncWheelFromField(),
              );
              final picker = switch (field) {
                _CalcField.distance => buildDistancePicker(
                  setState,
                  syncTextFromWheel,
                ),
                _CalcField.pace => buildPacePicker(setState, syncTextFromWheel),
                _CalcField.time => buildTimePicker(setState, syncTextFromWheel),
              };

              return CupertinoAlertDialog(
                title: Text(title),
                content: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: inputFieldHeight, child: inputField),
                      const SizedBox(height: 12),
                      picker,
                    ],
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(localizations.calculatorCancel),
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () => Navigator.of(context).pop(controller.text),
                    child: Text(localizations.calculatorOk),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      distanceWholeController.dispose();
      distanceTenthsController.dispose();
      paceMinutesController.dispose();
      paceSecondsController.dispose();
      timeHoursController.dispose();
      timeMinutesController.dispose();
      timeSecondsController.dispose();
    }

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

class _DistanceTextInputFormatter extends TextInputFormatter {
  static const int _maxIntegerDigits = 3;
  static const int _maxFractionDigits = 1;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(',', '.');
    text = text.replaceAll(RegExp(r'[^0-9.]'), '');
    final firstDot = text.indexOf('.');
    if (firstDot != -1) {
      final beforeDot = text.substring(0, firstDot);
      final afterDot = text.substring(firstDot + 1).replaceAll('.', '');
      text = '$beforeDot.$afterDot';
    }

    final dotIndex = text.indexOf('.');
    if (dotIndex != -1) {
      var intPart = text.substring(0, dotIndex);
      var fracPart = text.substring(dotIndex + 1);
      if (intPart.isEmpty) intPart = '0';
      if (intPart.length > _maxIntegerDigits) {
        intPart = intPart.substring(0, _maxIntegerDigits);
      }
      if (fracPart.length > _maxFractionDigits) {
        fracPart = fracPart.substring(0, _maxFractionDigits);
      }
      text = fracPart.isEmpty ? '$intPart.' : '$intPart.$fracPart';
    } else if (text.length > _maxIntegerDigits) {
      text = text.substring(0, _maxIntegerDigits);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
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
