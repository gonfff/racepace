import 'package:flutter/widgets.dart';
import 'package:racepace/application/calculator/calculator_service.dart';

class CalculatorScope extends InheritedWidget {
  const CalculatorScope({
    required this.service,
    required super.child,
    super.key,
  });

  final CalculatorService service;

  static CalculatorService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CalculatorScope>();
    final service = scope?.service;
    assert(service != null, 'CalculatorScope not found in widget tree.');
    return service!;
  }

  @override
  bool updateShouldNotify(CalculatorScope oldWidget) =>
      service != oldWidget.service;
}
