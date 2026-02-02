import 'package:flutter/cupertino.dart';
import 'package:racepace/presentation/features/calculator/calculator_screen.dart';
import 'package:racepace/presentation/features/notes/notes_screen.dart';
import 'package:racepace/presentation/features/settings/settings_sheet.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.divide_square),
            label: localizations.tabCalculator,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.doc_text),
            label: localizations.tabNotes,
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return CalculatorScreen(
                  onOpenSettings: () => _showSettingsSheet(context),
                );
              case 1:
                return NotesScreen(
                  onOpenSettings: () => _showSettingsSheet(context),
                );
              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SettingsSheet(),
    );
  }
}
