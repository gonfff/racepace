import 'package:flutter/widgets.dart';
import 'package:racepace/presentation/features/settings/settings_notifier.dart';

class SettingsScope extends InheritedNotifier<SettingsNotifier> {
  const SettingsScope({
    required SettingsNotifier controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static SettingsNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    final controller = scope?.notifier;
    assert(controller != null, 'SettingsScope not found in widget tree.');
    return controller!;
  }
}
