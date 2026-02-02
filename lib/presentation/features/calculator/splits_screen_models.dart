part of 'splits_screen.dart';

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

enum _SplitValueField { distance, pace, time }

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
