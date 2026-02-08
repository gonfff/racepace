import 'package:flutter/cupertino.dart';
import 'package:racepace/presentation/features/calculator/calculator_screen.dart';
import 'package:racepace/presentation/features/settings/settings_sheet.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return CalculatorScreen(onOpenSettings: () => _showSettingsSheet(context));
  }

  void _showSettingsSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SettingsSheet(),
    );
  }
}
