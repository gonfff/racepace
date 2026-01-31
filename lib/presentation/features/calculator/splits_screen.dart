import 'package:flutter/cupertino.dart';
import 'package:racepace/domain/settings/app_settings.dart';
import 'package:racepace/presentation/core/design/app_theme.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';

class SplitsScreen extends StatefulWidget {
  const SplitsScreen({
    super.key,
    required this.distance,
    required this.pace,
    required this.time,
    required this.unit,
  });

  final double distance;
  final Duration pace;
  final Duration time;
  final Unit unit;

  @override
  State<SplitsScreen> createState() => _SplitsScreenState();
}

class _SplitsScreenState extends State<SplitsScreen> {
  static const _defaultStartTime = '09:00';
  final TextEditingController _startTimeController = TextEditingController(
    text: _defaultStartTime,
  );
  late _SplitInterval _selectedInterval;
  var _strategyPercent = 0;

  @override
  void initState() {
    super.initState();
    _selectedInterval = widget.unit == Unit.miles
        ? _SplitInterval.mi1
        : _SplitInterval.km1;
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    super.dispose();
  }

  String _formattedStartTime() {
    final parsed = _parseClock(_startTimeController.text);
    if (parsed == null) return _defaultStartTime;
    final hours = parsed.inHours.remainder(24);
    final minutes = parsed.inMinutes.remainder(60);
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}';
  }

  Future<void> _openIntervalPicker(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    var selected = _selectedInterval;
    final intervals = _SplitInterval.values;
    final initialIndex = intervals
        .indexOf(_selectedInterval)
        .clamp(0, intervals.length - 1);
    final result = await showCupertinoDialog<_SplitInterval>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(localizations.splitsIntervalTitle),
          content: SizedBox(
            height: 160,
            child: CupertinoPicker(
              itemExtent: 32,
              scrollController: FixedExtentScrollController(
                initialItem: initialIndex,
              ),
              onSelectedItemChanged: (index) {
                selected = intervals[index];
              },
              children: intervals
                  .map(
                    (interval) =>
                        Center(child: Text(interval.label(localizations))),
                  )
                  .toList(),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(localizations.calculatorCancel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(selected),
              child: Text(localizations.calculatorOk),
            ),
          ],
        );
      },
    );
    if (result == null) return;
    setState(() {
      _selectedInterval = result;
    });
  }

  Future<void> _openStrategyPicker(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    var selected = _strategyPercent;
    const minPercent = -10;
    const maxPercent = 10;
    final itemCount = maxPercent - minPercent + 1;
    final result = await showCupertinoDialog<int>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(localizations.splitsPaceStrategyTitle),
          content: SizedBox(
            height: 160,
            child: CupertinoPicker(
              itemExtent: 32,
              scrollController: FixedExtentScrollController(
                initialItem: selected - minPercent,
              ),
              onSelectedItemChanged: (index) {
                selected = minPercent + index;
              },
              children: List.generate(itemCount, (index) {
                final value = minPercent + index;
                return Center(child: Text(_strategyPickerLabel(value)));
              }),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(localizations.calculatorCancel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(selected),
              child: Text(localizations.calculatorOk),
            ),
          ],
        );
      },
    );
    if (result == null) return;
    setState(() {
      _strategyPercent = result;
    });
  }

  Future<void> _openStartTimePicker(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final current =
        _parseClock(_startTimeController.text) ??
        _parseClock(_defaultStartTime)!;
    var selectedHours = current.inHours.remainder(24);
    var selectedMinutes = current.inMinutes.remainder(60);
    final now = DateTime.now();
    final result = await showCupertinoDialog<Duration?>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(localizations.splitsStartTimeTitle),
          content: SizedBox(
            height: 160,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              initialDateTime: DateTime(
                now.year,
                now.month,
                now.day,
                selectedHours,
                selectedMinutes,
              ),
              onDateTimeChanged: (value) {
                selectedHours = value.hour;
                selectedMinutes = value.minute;
              },
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(localizations.calculatorCancel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(
                context,
              ).pop(Duration(hours: selectedHours, minutes: selectedMinutes)),
              child: Text(localizations.calculatorOk),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (result == null) return;
    setState(() {
      _startTimeController.text = _formatClock(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final unitShortLabel = _unitShortLabel(localizations, widget.unit);
    final paceUnitLabel = '${localizations.unitMinutesShort}/$unitShortLabel';
    final startTime =
        _parseClock(_startTimeController.text) ??
        _parseClock(_defaultStartTime)!;
    final splits = _buildSplits(
      distance: widget.distance,
      pace: widget.pace,
      unit: widget.unit,
      interval: _selectedInterval,
      strategyPercent: _strategyPercent,
      startTime: startTime,
    );

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        middle: Text(localizations.calculatorViewSplits),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _ValueCard(
                      value: _formatNumber(widget.distance),
                      label: unitShortLabel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ValueCard(
                      value: _formatDuration(widget.pace),
                      label: paceUnitLabel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ValueCard(
                      value: _formatDuration(widget.time),
                      label: localizations.calculatorTimeFormat,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  CupertinoFormSection.insetGrouped(
                    header: Text(localizations.splitsSettingsTitle),
                    margin: EdgeInsets.zero,
                    children: [
                      _SplitsSettingsTile(
                        label: localizations.splitsIntervalTitle,
                        value: _selectedInterval.label(localizations),
                        onTap: () => _openIntervalPicker(context),
                      ),
                      _SplitsSettingsTile(
                        label: localizations.splitsPaceStrategyTitle,
                        value: _strategyTileLabel(
                          localizations,
                          _strategyPercent,
                        ),
                        onTap: () => _openStrategyPicker(context),
                      ),
                      _SplitsSettingsTile(
                        label: localizations.splitsStartTimeTitle,
                        value: _formattedStartTime(),
                        onTap: () => _openStartTimePicker(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _strategyDescription(localizations, _strategyPercent),
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SplitsTable(
                    splits: splits,
                    unitShortLabel: unitShortLabel,
                    paceUnitLabel: paceUnitLabel,
                    localizations: localizations,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitsSettingsTile extends StatelessWidget {
  const _SplitsSettingsTile({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final valueStyle = textStyle.copyWith(
      color: CupertinoColors.systemGrey.resolveFrom(context),
    );
    final row = Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: textStyle)),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: valueStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(CupertinoIcons.forward, size: 16),
        ),
      ],
    );
    return CupertinoFormRow(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: row,
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitsTable extends StatelessWidget {
  const _SplitsTable({
    required this.splits,
    required this.unitShortLabel,
    required this.paceUnitLabel,
    required this.localizations,
  });

  final List<_SplitRow> splits;
  final String unitShortLabel;
  final String paceUnitLabel;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    if (splits.isEmpty) {
      return const SizedBox.shrink();
    }
    final dividerColor = CupertinoColors.systemGrey4.resolveFrom(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                _HeaderCell(text: localizations.splitsColumnIndex, flex: 1),
                _HeaderCell(text: localizations.splitsColumnDistance, flex: 2),
                _HeaderCell(text: localizations.splitsColumnPace, flex: 2),
                _HeaderCell(text: localizations.splitsColumnFromStart, flex: 2),
                _HeaderCell(text: localizations.splitsColumnFromZero, flex: 2),
              ],
            ),
          ),
          Container(height: 1, color: dividerColor),
          ...splits.map((row) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      _BodyCell(text: row.index.toString(), flex: 1),
                      _BodyCell(
                        text: '${_formatNumber(row.distance)} $unitShortLabel',
                        flex: 2,
                      ),
                      _BodyCell(text: _formatDuration(row.pace), flex: 2),
                      _BodyCell(text: _formatDuration(row.elapsed), flex: 2),
                      _BodyCell(text: _formatClock(row.clock), flex: 2),
                    ],
                  ),
                ),
                if (row != splits.last)
                  Container(height: 1, color: dividerColor),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text, required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell({required this.text, required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SplitRow {
  const _SplitRow({
    required this.index,
    required this.distance,
    required this.pace,
    required this.elapsed,
    required this.clock,
  });

  final int index;
  final double distance;
  final Duration pace;
  final Duration elapsed;
  final Duration clock;
}

enum _SplitInterval {
  m200(200),
  m400(400),
  km1(1000),
  mi1(1609.344),
  km5(5000),
  km10(10000);

  const _SplitInterval(this.meters);

  final double meters;

  String label(AppLocalizations localizations) {
    switch (this) {
      case _SplitInterval.m200:
        return '200 ${localizations.unitMetersShort}';
      case _SplitInterval.m400:
        return '400 ${localizations.unitMetersShort}';
      case _SplitInterval.km1:
        return '1 ${localizations.unitKilometersShort}';
      case _SplitInterval.mi1:
        return '1 ${localizations.unitMilesShort}';
      case _SplitInterval.km5:
        return '5 ${localizations.unitKilometersShort}';
      case _SplitInterval.km10:
        return '10 ${localizations.unitKilometersShort}';
    }
  }
}

String _strategyTileLabel(AppLocalizations localizations, int percent) {
  if (percent == 0) return localizations.splitsStrategySteady;
  final absValue = percent.abs().toDouble();
  final value = _formatPercent(absValue);
  if (percent < 0) {
    return localizations.splitsStrategyNegativeLabel(value);
  }
  return localizations.splitsStrategyPositiveLabel(value);
}

String _strategyPickerLabel(int percent) {
  if (percent == 0) return '0%';
  final sign = percent > 0 ? '+' : '-';
  return '$sign${percent.abs()}%';
}

String _strategyDescription(AppLocalizations localizations, int percent) {
  if (percent == 0) return localizations.splitsStrategySteadyDescription;
  final absValue = percent.abs() / 2;
  final value = _formatPercent(absValue);
  if (percent < 0) {
    return localizations.splitsStrategyNegativeDescription(value);
  }
  return localizations.splitsStrategyPositiveDescription(value);
}

List<_SplitRow> _buildSplits({
  required double distance,
  required Duration pace,
  required Unit unit,
  required _SplitInterval interval,
  required int strategyPercent,
  required Duration startTime,
}) {
  if (distance <= 0) return [];
  final intervalDistance = _intervalDistanceInUnit(interval, unit);
  if (intervalDistance <= 0) return [];
  final basePaceSeconds = pace.inSeconds.toDouble();
  var remaining = distance;
  var covered = 0.0;
  var elapsedSeconds = 0.0;
  final splits = <_SplitRow>[];
  var index = 1;

  while (remaining > 0) {
    final splitDistance = remaining >= intervalDistance
        ? intervalDistance
        : remaining;
    final ratio = (covered + splitDistance / 2) / distance;
    final paceFactor = _paceFactor(strategyPercent, ratio);
    final splitPaceSeconds = basePaceSeconds * paceFactor;
    final splitSeconds = splitPaceSeconds * splitDistance;
    elapsedSeconds += splitSeconds;
    covered += splitDistance;
    remaining -= splitDistance;

    final paceDuration = Duration(seconds: splitPaceSeconds.round());
    final elapsedDuration = Duration(seconds: elapsedSeconds.round());
    final clockDuration = startTime + elapsedDuration;

    splits.add(
      _SplitRow(
        index: index,
        distance: covered,
        pace: paceDuration,
        elapsed: elapsedDuration,
        clock: clockDuration,
      ),
    );
    index += 1;
  }

  return splits;
}

double _paceFactor(int percent, double ratio) {
  if (percent == 0) return 1.0;
  final delta = percent.abs() / 100;
  final clamped = ratio.clamp(0.0, 1.0);
  final isNegative = percent < 0;
  final startFactor = isNegative ? 1 + delta / 2 : 1 - delta / 2;
  final endFactor = isNegative ? 1 - delta / 2 : 1 + delta / 2;
  return startFactor + (endFactor - startFactor) * clamped;
}

double _intervalDistanceInUnit(_SplitInterval interval, Unit unit) {
  if (unit == Unit.kilometers) {
    return interval.meters / 1000;
  }
  return interval.meters / 1609.344;
}

Duration? _parseClock(String text) {
  final digits = text.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  int hours;
  int minutes;
  if (digits.length <= 2) {
    hours = int.tryParse(digits) ?? 0;
    minutes = 0;
  } else {
    final hoursPart = digits.substring(0, digits.length - 2);
    final minutesPart = digits.substring(digits.length - 2);
    hours = int.tryParse(hoursPart) ?? 0;
    minutes = int.tryParse(minutesPart) ?? 0;
  }
  final clampedHours = hours.clamp(0, 23);
  final clampedMinutes = minutes.clamp(0, 59);
  return Duration(hours: clampedHours, minutes: clampedMinutes);
}

String _formatClock(Duration duration) {
  final hours = duration.inHours.remainder(24);
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
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

String _formatPercent(double value) {
  if (value % 1 == 0) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1).replaceFirst(RegExp(r'0$'), '');
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _unitShortLabel(AppLocalizations localizations, Unit unit) {
  return unit == Unit.miles
      ? localizations.unitMilesShort
      : localizations.unitKilometersShort;
}
