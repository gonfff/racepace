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

enum SplitValueField { distance, pace, time }

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

String _splitIntervalCode(_SplitInterval interval) {
  switch (interval) {
    case _SplitInterval.m200:
      return 'm200';
    case _SplitInterval.m400:
      return 'm400';
    case _SplitInterval.km1:
      return 'km1';
    case _SplitInterval.mi1:
      return 'mi1';
    case _SplitInterval.km5:
      return 'km5';
    case _SplitInterval.km10:
      return 'km10';
  }
}

_SplitInterval? _splitIntervalFromCode(String code) {
  switch (code) {
    case 'm200':
      return _SplitInterval.m200;
    case 'm400':
      return _SplitInterval.m400;
    case 'km1':
      return _SplitInterval.km1;
    case 'mi1':
      return _SplitInterval.mi1;
    case 'km5':
      return _SplitInterval.km5;
    case 'km10':
      return _SplitInterval.km10;
  }
  return null;
}
