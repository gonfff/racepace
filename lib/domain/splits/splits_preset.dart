class SplitsPreset {
  const SplitsPreset({
    required this.id,
    required this.intervalCode,
    required this.strategyPercent,
  });

  final int id;
  final String intervalCode;
  final int strategyPercent;

  Map<String, Object> toJson() {
    return {
      'id': id,
      'interval': intervalCode,
      'strategyPercent': strategyPercent,
    };
  }

  static SplitsPreset? fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final interval = json['interval'];
    final strategyPercent = json['strategyPercent'];
    if (id is! int || interval is! String || strategyPercent is! int) {
      return null;
    }
    return SplitsPreset(
      id: id,
      intervalCode: interval,
      strategyPercent: strategyPercent,
    );
  }
}
