import 'package:pacenote/domain/settings/app_settings.dart';

class Calculation {
  const Calculation({
    required this.id,
    required this.distance,
    required this.pace,
    required this.time,
    required this.unit,
    required this.createdAt,
  });

  final int id;
  final double distance;
  final Duration pace;
  final Duration time;
  final Unit unit;
  final DateTime createdAt;
}

class CalculationDraft {
  const CalculationDraft({
    required this.distance,
    required this.pace,
    required this.time,
    required this.unit,
    required this.createdAt,
  });

  final double distance;
  final Duration pace;
  final Duration time;
  final Unit unit;
  final DateTime createdAt;
}
