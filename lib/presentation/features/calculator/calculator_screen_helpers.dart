part of 'calculator_screen.dart';

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

String _unitShortLabel(AppLocalizations localizations, Unit unit) {
  return unit == Unit.miles
      ? localizations.unitMilesShort
      : localizations.unitKilometersShort;
}
