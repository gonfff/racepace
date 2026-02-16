part of 'splits_screen.dart';

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
  const epsilon = 1e-9;
  if (distance <= 0) return [];
  final intervalDistance = _intervalDistanceInUnit(interval, unit);
  if (intervalDistance <= 0) return [];
  final basePaceSeconds = pace.inSeconds.toDouble();
  var remaining = distance;
  var covered = 0.0;
  var elapsedSeconds = 0.0;
  final splits = <_SplitRow>[];
  var index = 1;

  while (remaining > epsilon) {
    final splitDistance = remaining >= intervalDistance
        ? intervalDistance
        : remaining;
    final ratio = (covered + splitDistance / 2) / distance;
    final paceFactor = _paceFactor(strategyPercent, ratio);
    final splitPaceSeconds = basePaceSeconds * paceFactor;
    final splitSeconds = splitPaceSeconds * splitDistance;
    elapsedSeconds += splitSeconds;
    covered = (covered + splitDistance).clamp(0.0, distance).toDouble();
    remaining = (remaining - splitDistance).clamp(0.0, distance).toDouble();

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

String _buildShareText(
  AppLocalizations localizations,
  String unitShortLabel,
  String paceUnitLabel,
  List<_SplitRow> splits,
) {
  final buffer = StringBuffer();
  buffer.writeln(
    '${localizations.splitsColumnDistance} ($unitShortLabel)\t'
    '${localizations.splitsColumnPace} ($paceUnitLabel)\t'
    '${localizations.splitsColumnFromStart}',
  );
  for (final row in splits) {
    buffer.writeln(
      '${_formatNumber(row.distance)}\t'
      '${_formatDuration(row.pace)}\t'
      '${_formatDuration(row.elapsed)}',
    );
  }
  return buffer.toString().trimRight();
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _unitShortLabel(AppLocalizations localizations, Unit unit) {
  return unit == Unit.miles
      ? localizations.unitMilesShort
      : localizations.unitKilometersShort;
}

String _digitsOnly(String text) {
  return text.replaceAll(RegExp(r'\D'), '');
}

double? _parseDistance(String text) {
  final normalized = text.replaceAll(',', '.').trim();
  if (normalized.isEmpty) return null;
  final value = double.tryParse(normalized);
  if (value == null || value <= 0) return null;
  return value;
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

double _clampDistance(double value) {
  final clamped = value.clamp(0, _SplitsScreenState._maxDistance);
  return clamped is double ? clamped : clamped.toDouble();
}

Duration _clampPace(Duration pace) {
  if (pace > _SplitsScreenState._maxPace) return _SplitsScreenState._maxPace;
  return pace;
}

Duration _clampTime(Duration time) {
  if (time > _SplitsScreenState._maxTime) return _SplitsScreenState._maxTime;
  return time;
}
