import 'package:flutter/widgets.dart';
import 'package:racepace/application/splits/splits_presets_service.dart';

class SplitsPresetsScope extends InheritedWidget {
  const SplitsPresetsScope({
    required this.service,
    required super.child,
    super.key,
  });

  final SplitsPresetsService service;

  static SplitsPresetsService? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SplitsPresetsScope>();
    return scope?.service;
  }

  static SplitsPresetsService of(BuildContext context) {
    final service = maybeOf(context);
    assert(service != null, 'SplitsPresetsScope not found in widget tree.');
    return service!;
  }

  @override
  bool updateShouldNotify(SplitsPresetsScope oldWidget) =>
      service != oldWidget.service;
}
