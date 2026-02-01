import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:racepace/domain/settings/app_settings.dart';
import 'package:racepace/presentation/core/design/app_theme.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';

part 'splits_screen_dialogs.dart';
part 'splits_screen_widgets.dart';
part 'splits_screen_models.dart';
part 'splits_screen_utils.dart';
part 'splits_screen_input_formatters.dart';

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
  static const double _settingsBlockHeight = 92;
  static const double _valueBlockHeight = 92;
  static const double _maxDistance = 999;
  static const Duration _maxPace = Duration(minutes: 30);
  static const Duration _maxTime = Duration(hours: 99);
  final TextEditingController _startTimeController = TextEditingController(
    text: _defaultStartTime,
  );
  late _SplitInterval _selectedInterval;
  var _strategyPercent = 0;
  double _distance = 0;
  Duration _pace = Duration.zero;
  Duration _time = Duration.zero;

  @override
  void initState() {
    super.initState();
    _selectedInterval = widget.unit == Unit.miles
        ? _SplitInterval.mi1
        : _SplitInterval.km1;
    _distance = widget.distance;
    _pace = widget.pace;
    _time = widget.time;
  }

  @override
  void didUpdateWidget(covariant SplitsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.distance != oldWidget.distance) {
      _distance = widget.distance;
    }
    if (widget.pace != oldWidget.pace) {
      _pace = widget.pace;
    }
    if (widget.time != oldWidget.time) {
      _time = widget.time;
    }
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    super.dispose();
  }

  void _updateSplitsState(VoidCallback update) {
    setState(update);
  }

  String _formattedStartTime() {
    final parsed = _parseClock(_startTimeController.text);
    if (parsed == null) return _defaultStartTime;
    final hours = parsed.inHours.remainder(24);
    final minutes = parsed.inMinutes.remainder(60);
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}';
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
      distance: _distance,
      pace: _pace,
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
                      key: const ValueKey('splits_value_distance'),
                      value: _formatNumber(_distance),
                      label: unitShortLabel,
                      onTap: () => _openValueInputDialog(
                        context,
                        _SplitValueField.distance,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ValueCard(
                      key: const ValueKey('splits_value_pace'),
                      value: _formatDuration(_pace),
                      label: paceUnitLabel,
                      onTap: () =>
                          _openValueInputDialog(context, _SplitValueField.pace),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ValueCard(
                      key: const ValueKey('splits_value_time'),
                      value: _formatDuration(_time),
                      label: localizations.calculatorTimeFormat,
                      onTap: () =>
                          _openValueInputDialog(context, _SplitValueField.time),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Text(
                    localizations.splitsSettingsTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _SettingsBlock(
                          key: const ValueKey('splits_setting_interval'),
                          label: localizations.splitsIntervalTitle,
                          value: _selectedInterval.label(localizations),
                          onTap: () => _openIntervalPicker(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SettingsBlock(
                          key: const ValueKey('splits_setting_strategy'),
                          label: localizations.splitsPaceStrategyTitle,
                          value: _strategyTileLabel(
                            localizations,
                            _strategyPercent,
                          ),
                          onTap: () => _openStrategyPicker(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SettingsBlock(
                          key: const ValueKey('splits_setting_start_time'),
                          label: localizations.splitsStartTimeTitle,
                          value: _formattedStartTime(),
                          onTap: () => _openStartTimePicker(context),
                        ),
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
